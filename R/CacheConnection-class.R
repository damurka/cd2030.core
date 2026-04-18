#' Create a CacheConnection Object
#'
#' `init_CacheConnection` initializes a `CacheConnection` either from a provided `.rds` file path
#' or directly from a `cd_data` object. Only one of the arguments should be non-NULL.
#'
#' @param rds_path Optional character. Path to an RDS file to load the cache from.
#' @param countdown_data Optional `cd_data` object to initialize in-memory cache.
#' @param data_path Optional. Used with the countdown to support in creating the cache file.
#'
#' @return An instance of the `CacheConnection` class.
#'
#' @export
init_CacheConnection <- function(rds_path = NULL, countdown_data = NULL, data_path = NULL, indicator_group = c("auto", "rmncah", "vaccine", "custom")) {
  indicator_group <- arg_match(indicator_group)
  cache <- CacheConnection$new(
    rds_path = rds_path,
    countdown_data = countdown_data,
    data_path = data_path
  )

  profile <- attr_or_null(cache$countdown_data, "profile")
  if (!is.null(profile)) {
    ps <- .parse_profile(profile)
    if (isTRUE(ps$needs_registration)) {
      register_indicator_group(ps$name, ps$value, on_conflict = on_conflict)
    }
  }

  resolved_group <- attr_or_null(cache$countdown_data, "indicator_group")
  if (is.null(resolved_group)) {
    cols <- colnames(cache$countdown_data)
    resolved_group <- resolve_indicator_group(cols, indicator_group, profile)
  }

  check_required_columns_exist(cache$countdown_data, resolved_group)
  set_selected_group(resolved_group)

  return(cache)
}

#' CacheConnection Class
#'
#' @description
#' An R6 class that handles persistent or in-memory caching of data used in the Countdown 2030
#' analysis and reporting workflows. It supports tracking of various internal data objects,
#' reactive updates (for Shiny apps), note-taking for report annotations, and saving/loading
#' from `.rds` files.
#'
#' @docType class
#' @name CacheConnection
#' @format An [R6::R6Class] generator object.
#' @keywords internal
CacheConnection <- R6::R6Class(
  "CacheConnection",
  public = list(
    #' @description Initialize a CacheConnection instance.
    #' @param rds_path Path to the RDS file (can be NULL).
    #' @param countdown_data Countdown data of class `cd_data`.
    #' @param data_path Directory to store the cache
    initialize = function(rds_path = NULL, countdown_data = NULL, data_path = NULL) {
      if (is.null(rds_path) && is.null(countdown_data)) {
        cd_abort(c("x" = "Both {.arg rds_path} and {.arg countdown_data} cannot be null."))
      }

      if (!is.null(rds_path) && !is.null(countdown_data)) {
        cd_abort(c("x" = "Only one can have a value: {.arg rds_path} and {.arg countdown_data}."))
      }

      if (!is.null(countdown_data)) {
        check_cd_data(countdown_data)
      }

      # Initialize in-memory data using the template
      private$.in_memory_data <- private$.data_template
      private$.in_memory_data$countdown_data <- countdown_data
      private$.in_memory_data$rds_path <- rds_path
      private$.in_memory_data$survey_source <- NA

      if (!is.null(rds_path)) {
        self$load_from_disk()
      }

      if (is.null(rds_path)) {
        private$initialize_survey_estimates()
      }

      if (!is.null(countdown_data) && !is.null(data_path)) {
        tryCatch(
          {
            self$set_cache_path(file.path(data_path, paste0(self$country, "_", format(Sys.time(), "%Y%m%d%H%M"), ".rds")))
          },
          error = function(e) {
            error_message <- clean_error_message(e)
            cd_warn(c("!" = error_message))
          }
        )
      }

      # private$update_field("indicator_coverage_national", NULL)
      # private$update_field("indicator_coverage_admin1", NULL)
      # private$update_field("indicator_coverage_district", NULL)
      # private$update_field("reporting_rate_national", NULL)
      # private$update_field("reporting_rate_national", NULL)
    },

    #' Load data from disk.
    #' @return None. Updates internal state.
    load_from_disk = function() {
      check_file_path(private$.in_memory_data$rds_path)

      rds_path <- private$.in_memory_data$rds_path
      loaded_data <- readRDS(rds_path)
      loaded_data$rds_path <- rds_path
      # required_fields <- names(private$.data_template)
      # missing_fields <- setdiff(required_fields, names(loaded_data))
      # if (length(missing_fields) > 0) {
      #   cd_abort(c('x' = paste(
      #     'The following required fields are missing in the RDS file:',
      #     paste(missing_fields, collapse = ', ')
      #   )))
      # }
      private$.in_memory_data <- loaded_data
      private$.in_memory_data$countdown_data <- private$.in_memory_data$countdown_data %>%
        rename(instdeliveries = any_of("ideliv"))
    },

    #' Save data to disk (only if changed and RDS path is not NULL)
    #' @return None. Updates file.
    save_to_disk = function() {
      if (private$.has_changed && !is.null(private$.in_memory_data$rds_path)) { # Key change here
        private$.in_memory_data$survey_source <- NA
        saveRDS(private$.in_memory_data, private$.in_memory_data$rds_path)
        private$.has_changed <<- FALSE
      }
    },

    #' @description Adjusts data.
    adjust_data = function() {
      self$set_adjusted_flag(FALSE)
      data <- self$data_with_excluded_years %>%
        adjust_service_data(adjustment = "custom", k_factors = self$k_factors)
      self$set_adjusted_data(data)
    },

    #' @description Run coverage calculation using stored model parameters.
    #' @param admin_level Administrative level ("adminlevel_1" or "district").
    #' @param region Optional region filter.
    calculate_indicator_coverage = function(admin_level, region = NULL) {
      admin_level <- arg_match(admin_level, c("national", "adminlevel_1", "district"))

      if (!self$check_inequality_params) {
        cd_abort(c("x" = "One or more parameters is missing for {.fun calculate_indicator_coverage}"))
      }

      rates <- self$national_estimates
      calculate_indicator_coverage(
        .data = self$adjusted_data,
        admin_level = admin_level,
        derivation_population = self$derivation_population,
        un_estimates = self$un_estimates,
        survey_estimates = self$regional_survey,
        region = region,
        sbr = rates$sbr,
        nmr = rates$nmr,
        pnmr = rates$pnmr,
        anc1survey = rates$anc1,
        dpt1survey = rates$penta1,
        survey_year = self$survey_year,
        twin = rates$twin_rate,
        preg_loss = rates$preg_loss
      )
    },

    #' @description Run inequality calculation using stored model parameters.
    #' @param admin_level Administrative level ("adminlevel_1" or "district").
    #' @param region Optional region filter.
    calculate_inequality = function(admin_level, region = NULL) {
      admin_level <- arg_match(admin_level, c('adminlevel_1', 'district'))

      if (!self$check_inequality_params) {
        cd_abort(c("x" = "One or more parameters is missing for {.fun calculate_inequality}"))
      }

      reference_data <- if ((admin_level == 'adminlevel_1'  || admin_level == 'district') && is.null(region)) {
        self$indicator_coverage_national
      } else if (admin_level == 'adminlevel_1' && !is.null(region)) {
        self$indicator_coverage_admin1
      }

      subnational_coverage <- self$get_base_indicator_coverage(admin_level, region)

      calculate_inequality(subnational_coverage, reference_data)
    },

    #' @description Run coverage calculation using stored model parameters.
    #' @param admin_level Administrative level ("adminlevel_1" or "district").
    calculate_coverage = function(admin_level) {
      check_required(admin_level)

      if (!self$check_coverage_params) {
        cd_abort(c("x" = "One or more parameters is missing for {.fun calculate_coverage}"))
      }

      survey_data <- if (admin_level == "national") self$national_survey else self$regional_survey

      self$get_base_indicator_coverage(admin_level) %>%
        calculate_coverage(
          survey_data = survey_data,
          wuenic_data = self$wuenic_estimates,
          subnational_map = self$survey_mapping
        )
    },

    #' @description Run coverage calculation using stored model parameters.
    #' @param admin_level Administrative level ("adminlevel_1" or "district").
    get_mapping_data = function(admin_level) {
      check_required(admin_level)

      if (!self$check_inequality_params) {
        cd_abort(c("x" = "One or more parameters is missing for {.fun calculate_inequality}"))
      }

      self$indicator_coverage_admin1 %>%
        get_mapping_data(
          subnational_map = self$map_mapping
        )
    },

    #' @description generates the mean institutional livebirths
    lbr_mean = function() {
      indicator <- paste0("cov_instlivebirths_", self$maternal_denominator)
      self$indicator_coverage_national %>%
        select(year, all_of(indicator)) %>%
        summarise(lbr_mean = mean(!!sym(indicator))) %>%
        pull(lbr_mean)
    },

    #' @description creates mortality ratios completeness summary
    #' @param indicator The indicator to generate the summary
    summarise_completeness_ratio = function(indicator) {
      self$mortality_ratios %>%
        summarise_completeness_ratio(indicator, self$lbr_mean())
    },

    #' @description Return the appropriate summary based on the indicator type to plot.
    #' @param indicator Character. Indicator name.
    #' @param map_years the years to include in a map
    #' @return Character. Either the maternal or vaccination denominator.
    filter_mortality_summary = function(indicator, map_years = NULL) {
      years <- if (is.null(map_years)) self$mortality_mapping_years else map_years
      self$mortality_summary %>%
        filter_mortality_summary(self$country_iso, indicator, years, self$map_mapping)
    },

    #' @description Computed service utilization for various indicators.
    #' @param admin_level The level to aggregate data at.
    compute_service_utilization = function(admin_level) {
      if (is.null(self$adjusted_data)) {
        cd_abort(c("x" = "Adjusted data is required"))
      }
      check_required(admin_level)

      self$adjusted_data %>%
        compute_service_utilization(admin_level)
    },

    #' @description Return the appropriate summary based on the indicator type to plot.
    #' @param admin_level The admin level
    #' @param indicator Character. Indicator name.
    #' @param region the years to include in a map
    filter_service_utilization = function(admin_level, indicator, region = NULL) {

      if (is.null(self$adjusted_data)) {
        return(NULL)
      }

      service_data <- if (admin_level == 'national') {
        self$service_utilization_national
      } else if (admin_level == 'adminlevel_1') {
        self$service_utilization_admin1
      } else {
        compute_service_utilization(admin_level)
      }
      service_data %>%
        filter_service_utilization(indicator, region)
    },

    #' @description Return the appropriate summary based on the indicator type to plot.
    #' @param indicator Character. Indicator name.
    #' @param map_years the years to include in a map
    prepare_mapping_service_utlization = function(indicator, map_years = NULL) {

      indicator <- arg_match(indicator, c('ipd', 'opd'))
      years <- if (is.null(map_years)) self$utilization_mapping_years else map_years

      self$service_utilization_admin1 %>%
        prepare_mapping_service_utlization(indicator, years, self$map_mapping)
    },

    #' @description Return the appropriate denominator based on the indicator type.
    #' @param indicator Character. Indicator name.
    #' @return Character. Either the maternal or vaccination denominator.
    get_denominator = function(indicator) {
      if (is_maternal_indicator(indicator)) {
        self$maternal_denominator
      } else {
        self$denominator
      }
    },

    #' @description Return a reactive wrapper (for Shiny).
    reactive = function() {
      # Ensure the reactive stuff is initialized.
      if (is.null(private$.reactiveDep)) {
        private$.reactiveDep <- reactiveValues() # Initialize as an empty reactiveValues
        for (field_name in names(private$.data_template)) {
          private$.reactiveDep[[field_name]] <- 0 # Create a reactive tracker for each field
        }
      }
      reactive({
        private$depend_all()
        self
      })
    },

    #' @description Set the language.
    #' @param value A scalar string representing 2 digit string.
    set_language = function(value) private$setter("language", value, ~ is_scalar_character(.x) && nchar(.x) == 2),

    #' @description Set cache RDS file path.
    #' @param value New file path.
    set_cache_path = function(value) {
      path_set <- private$setter("rds_path", value, ~ !is.null(.x) && length(.x) > 0)
      if (path_set) {
        private$.has_changed <- TRUE
        self$save_to_disk()
        cd_info(c("i" = str_glue("Successfully saved to {.val value}.")))
      }
    },

    #' @description Set the countdown data.
    #' @param value A `cd_data` object.
    set_countdown_data = function(value) {
      private$setter("countdown_data", value, check_cd_data)

      private$update_field("reporting_rate_national", NULL)
      private$update_field("reporting_rate_admin1", NULL)
      private$update_field("reporting_rate_district", NULL)
      private$update_field("district_reporting_rate", NULL)

      private$update_field("completeness_national", NULL)
      private$update_field("completeness_admin1", NULL)
      private$update_field("completeness_district", NULL)
      private$update_field("district_completeness", NULL)

      private$update_field("outliers_national", NULL)
      private$update_field("outliers_admin1", NULL)
      private$update_field("outliers_district", NULL)
      private$update_field("district_outliers_summary", NULL)

      private$update_field("adequacy_ratios", NULL)
    },

    #' @description Set adjusted data.
    #' @param value A `cd_data` object.
    set_adjusted_data = function(value) {
      private$setter("adjusted_data", value, check_cd_data)
      private$.has_changed <<- TRUE
      self$set_adjusted_flag(TRUE)
      private$.invalidate_coverage <<- TRUE
    },

    #' @description Set performance threshold.
    #' @param value A numeric scalar.
    set_performance_threshold = function(value) {
      private$setter("performance_threshold", value, is_scalar_integerish)
    },

    #' @description Set years to exclude.
    #' @param value Numeric vector.
    set_excluded_years = function(value) private$setter("excluded_years", value, is.numeric),

    #' @description Set K-factors.
    #' @param value Named numeric vector.
    set_k_factors = function(value) {
      vacc_factors <- c("anc", "idelv", "vacc")
      factors <- if (get_selected_group() == "vaccine") {
        vacc_factors
      } else {
        c(vacc_factors, "opd", "ipd")
      }
      private$setter("k_factors", value, ~ is.numeric(.x) && all(factors %in% names(.x)))
    },

    #' @description Set adjusted flag.
    #' @param value Logical scalar.
    set_adjusted_flag = function(value) private$setter("adjusted_flag", value, ~ is.logical(.x) && length(.x) == 1),

    #' @description Set survey estimates.
    #' @param value Named numeric vector.
    set_survey_estimates = function(value) {
      common_factors <- c("anc1", "instlivebirths", "bcg", "penta1", "penta3", "measles1")
      factors <- if (get_selected_group() == "vaccine") {
        c(common_factors, "opv1", "opv3")
      } else {
        c(common_factors, "anc4", "low_bweight", "csection")
      }
      if (!is.numeric(value)) {
        cd_abort(c("x" = "Survey must be a numeric vector."))
      }
      if (!all(factors %in% names(value))) {
        missing <- setdiff(factors, names(value))
        cd_warn(c("!" = "Survey values are missing the following {.val {missing}}"))
      }
      private$update_field("survey_estimates", value)
    },

    #' @description Set national estimates.
    #' @param value Named list.
    set_derivation_population = function(value) {
      private$setter("derivation_population", value, is_scalar_character)
      private$.invalidate_coverage <<- TRUE
    },

    #' @description Set national estimates.
    #' @param value Named list.
    set_national_estimates = function(value) {
      private$setter("national_estimates", value, is.list)
      private$.invalidate_coverage <<- TRUE
    },

    #' @description Set year of survey estimates.
    #' @param value Character scalar.
    set_survey_source = function(value) private$setter("survey_source", value, is_scalar_character),

    #' @description Set year of survey estimates.
    #' @param value Integer year.
    set_survey_year = function(value) private$setter("survey_year", value, is_scalar_integerish),

    #' @description Set start year of surveys.
    #' @param value Integer year.
    set_start_survey_year = function(value) private$setter("start_survey_year", value, is_scalar_integerish),

    #' @description Set denominator type.
    #' @param value Character scalar.
    set_denominator = function(value) private$setter("denominator", value, is_scalar_character),

    #' @description Set denominator type.
    #' @param value Character scalar.
    set_maternal_denominator = function(value) private$setter("maternal_denominator", value, is_scalar_character),

    #' @description Set selected region.
    #' @param value Character scalar.
    set_selected_admin_level_1 = function(value) private$setter("selected_admin_level_1", value, is_scalar_character),

    #' @description Set selected district.
    #' @param value Character scalar.
    set_selected_district = function(value) private$setter("selected_district", value, is_scalar_character),

    #' @description Set mapping years.
    #' @param value Integer vector.
    set_mapping_years = function(value) private$setter("selected_mapping_years", value, is.numeric),

    #' @description Set mapping years.
    #' @param value Integer vector.
    set_mortality_mapping_years = function(value) private$setter("selected_mortality_mapping_years", value, is.numeric),

    #' @description Set mapping years.
    #' @param value Integer vector.
    set_utilization_mapping_years = function(value) private$setter("selected_utilization_mapping_years", value, is.numeric),

    #' @description Set FPET data.
    #' @param value Data frame.
    set_fpet_data = function(value) private$setter("fpet_data", value, check_fpet_data),

    #' @description Set UN estimates.
    #' @param value Data frame.
    set_un_estimates = function(value) {
      private$setter("un_estimates", value, check_un_estimates_data)
      private$.invalidate_coverage <<- TRUE
    },

    #' @description Set UN mortality estimates
    #' @param value Data frame.
    set_un_mortality_estimates = function(value) private$setter("un_mortality_estimates", value, check_un_mortality_data),

    #' @description Set WUENIC estimates.
    #' @param value Data frame.
    set_wuenic_estimates = function(value) private$setter("wuenic_estimates", value, check_wuenic_data),

    #' @description Set national survey.
    #' @param value Data frame.
    set_national_survey = function(value) private$setter("national_survey", value, check_survey_data),

    #' @description Set regional survey.
    #' @param value Data frame.
    set_regional_survey = function(value) private$setter("regional_survey", value, ~ check_survey_data(.x, "adminlevel_1")),

    #' @description Set WIQ survey.
    #' @param value Data frame.
    set_wiq_survey = function(value) private$setter("wiq_survey", value, check_equity_data),

    #' @description Set area-level survey.
    #' @param value Data frame.
    set_area_survey = function(value) private$setter("area_survey", value, check_equity_data),

    #' @description Set education-level survey.
    #' @param value Data frame.
    set_education_survey = function(value) private$setter("education_survey", value, check_equity_data),

    #' @description Set survey mapping table.
    #' @param value Data frame.
    set_survey_mapping = function(value) private$setter("survey_mapping", value, is.data.frame),

    #' @description Set map overlay mapping.
    #' @param value Data frame.
    set_map_mapping = function(value) private$setter("map_mapping", value, is.data.frame),

    #' @description Set map overlay mapping.
    #' @param value Data frame.
    set_sector_national_estimates = function(value) private$setter("sector_national_estimates", value, is.data.frame),

    #' @description Set map overlay mapping.
    #' @param value Data frame.
    set_sector_area_estimates = function(value) private$setter("sector_area_estimates", value, is.data.frame),

    #' @description Set map overlay mapping.
    #' @param value Data frame.
    set_csection_national_estimates = function(value) private$setter("csection_national_estimates", value, is.data.frame),

    #' @description Set map overlay mapping.
    #' @param value Data frame.
    set_csection_area_estimates = function(value) private$setter("csection_area_estimates", value, is.data.frame),

    #' @description Calculate reporting rates (Wrapper).
    #' @param admin_level Administrative level.
    #' @param region Optional region filter.
    calculate_reporting_rate = function(admin_level, region = NULL) {
      # We use self$countdown_data as the source
      calculate_average_reporting_rate(
        .data = self$countdown_data,
        admin_level = admin_level,
        region = region
      )
    },
    #' @description Calculate reporting rates (Wrapper).
    #' @param region Optional region filter.
    calculate_district_reporting_rate = function(region = NULL) {
      calculate_district_reporting_rate(
        .data = self$countdown_data,
        threshold = self$performance_threshold,
        region = region
      )
    },
    #' @description Calculate reporting rates (Wrapper).
    #' @param admin_level Administrative level.
    #' @param region Optional region filter.
    calculate_completeness_summary = function(admin_level, region = NULL) {
      calculate_completeness_summary(
        .data = self$countdown_data,
        admin_level = admin_level,
        threshold = self$performance_threshold,
        region = region
      )
    },
    #' @description Calculate reporting rates (Wrapper).
    #' @param region Optional region filter.
    calculate_district_completeness_summary = function(region = NULL) {
      calculate_district_completeness_summary(
        .data = self$countdown_data,
        region = region
      )
    },
    #' @description Calculate reporting rates (Wrapper).
    #' @param indicator Administrative level.
    #' @param region Optional region filter.
    list_missing_units = function(indicator, region = NULL) {
      list_missing_units(
        .data = self$countdown_data,
        indicator = indicator,
        region = region
      )
    },
    #' @description Calculate reporting rates (Wrapper).
    #' @param admin_level Administrative level.
    #' @param region Optional region filter.
    calculate_outliers_summary = function(admin_level, region = NULL) {
      calculate_outliers_summary(
        .data = self$countdown_data,
        admin_level = admin_level,
        region = region
      )
    },
    #' @description Calculate reporting rates (Wrapper).
    #' @param region Optional region filter.
    calculate_district_outlier_summary = function(region = NULL) {
      calculate_district_outlier_summary(
        .data = self$countdown_data,
        region = region
      )
    },
    #' @description Calculate reporting rates (Wrapper).
    #' @param region Optional region filter.
    calculate_ratios_and_adequacy = function(region = NULL) {
      calculate_ratios_and_adequacy(
        .data = self$countdown_data,
        region = region
      )
    },
    #' @description Calculate overall score (Wrapper).
    #' @param admin_level Administrative level ("national" or "adminlevel_1").
    #' @param region Optional region name (required if admin_level is "adminlevel_1").
    #' @param labels Optional region name (required if admin_level is "adminlevel_1").
    calculate_overall_score = function(admin_level = c("national", "adminlevel_1"), region = NULL, labels = NULL) {
      admin_level <- arg_match(admin_level)
      if (admin_level == "adminlevel_1" && is.null(region)) {
        cd_abort(c("x" = "{.arg region} must be provided for adminlevel_1"))
      }
      if (admin_level == "national" && !is.null(region)) {
        cd_abort(c("x" = "{.arg region} must be null for national admin_level"))
      }

      if (admin_level == "national") {
        calculate_overall_score1(
          average_reporting_rate    = self$reporting_rate_national,
          district_reporting_rate   = self$district_reporting_rate,
          district_completeness     = self$district_completeness,
          outliers_summary          = self$outliers_national,
          district_outliers_summary = self$district_outliers_summary,
          ratios_summary            = self$adequacy_ratios,
          labels                    = labels
        )
      } else {
        # 1. Reporting Rate: Filter the cached Admin1 dataset
        avg_rr <- self$reporting_rate_admin1 %>%
          filter(adminlevel_1 == region)

        # 2. Outliers: Filter the cached Admin1 dataset
        out_sum <- self$outliers_admin1 %>%
          filter(adminlevel_1 == region)

        # 3. District Metrics & Ratios:
        # These are aggregations. We cannot filter the national aggregate.
        # We must re-calculate them specifically for the region.
        dst_rr <- self$calculate_district_reporting_rate(region)
        dst_comp <- self$calculate_district_completeness_summary(region)
        dst_out <- self$calculate_district_outlier_summary(region)
        ratios <- self$calculate_ratios_and_adequacy(region)

        calculate_overall_score1(
          average_reporting_rate    = avg_rr,
          district_reporting_rate   = dst_rr,
          district_completeness     = dst_comp,
          outliers_summary          = out_sum,
          district_outliers_summary = dst_out,
          ratios_summary            = ratios,
          labels                    = labels
        )
      }
    },
    #' @description Get filtered indicator coverage responsive to admin level and survey year.
    #' @param indicator Character. The target health indicator.
    #' @param admin_level Character. Level of aggregation ("national", "adminlevel_1", "district").
    #' @param region Character. Optional region or district name to filter by.
    get_filtered_indicator_coverage = function(indicator, admin_level, region = NULL) {
      indicator <- arg_match(indicator, get_all_indicators())
      admin_level <- arg_match(admin_level, c("national", "adminlevel_1", "district"))

      if (!self$check_inequality_params) {
        cd_abort(c("x" = "One or more parameters is missing for {.fun get_filtered_indicator_coverage}"))
      }

      # 1. Retrieve the appropriate coverage data based on admin level
      cov_data <- self$get_base_indicator_coverage(admin_level, region)

      # 2. Extract the survey estimate for the specific indicator
      survey_rate <- unname(self$survey_estimates[indicator])
      if (is.null(survey_rate)) {
        survey_rate <- NA_real_
      }

      # 3. Apply the filtering and formatting function
      cov_data %>%
        filter_indicator_coverage(
          indicator = indicator,
          survey_coverage = survey_rate,
          survey_year = self$survey_year
        )
    },
    #' @description Get filtered coverage data responsive to admin level and indicator.
    #' @param indicator Character. The target health indicator.
    #' @param admin_level Character. Level of aggregation ("national", "adminlevel_1", "district").
    #' @param region Character. Optional region or district name to filter by.
    get_filtered_coverage = function(indicator, admin_level, region = NULL) {
      indicator <- arg_match(indicator, get_analysis_indicators())
      admin_level <- arg_match(admin_level, c("national", "adminlevel_1", "district"))

      # 1. Validate required parameters
      if (!self$check_coverage_params) {
        cd_abort(c("x" = "One or more parameters is missing for {.fun get_filtered_coverage}"))
      }

      # 2. Dynamically fetch the correct denominator
      denom <- self$get_denominator(indicator)

      # 3. Calculate the coverage for the requested administrative level
      # 4. Filter and reshape the data for plotting
      self$calculate_coverage(admin_level) %>%
        filter_coverage(
          indicator = indicator,
          denominator = denom,
          region = region
        )
    },
    #' @description Get filtered inequality data responsive to admin level and indicator.
    #' @param indicator Character. The target health indicator.
    #' @param admin_level Character. Level of aggregation ("adminlevel_1", "district").
    #' @param region Character. Optional region filter.
    get_filtered_inequality = function(indicator, admin_level, region = NULL) {
      indicator <- arg_match(indicator, get_analysis_indicators())
      admin_level <- arg_match(admin_level, c("adminlevel_1", "district"))

      if (!self$check_inequality_params) {
        cd_abort(c("x" = "One or more parameters is missing for {.fun get_filtered_inequality}"))
      }

      if (admin_level != 'adminlevel_1' && !is.null(region)) {
        cd_abort(c("x" = "{.arg region} should only be used in {.val adminlevel_1}"))
      }

      # 1. Fetch and validate the denominator
      denom <- self$get_denominator(indicator)
      if (is.null(denom)) {
        cd_abort(c("x" = "The denominator for indicator '{indicator}' is NULL in the cache state."))
      }

      # 2. Retrieve from the active bindings
      ineq_data <- if (admin_level == "adminlevel_1" && is.null(region)) {
        self$inequality_admin1
      } else {
        self$inequality_district
      }

      # 3. Apply region filter if one is selected
      if (!is.null(region)) {
        ineq_data <- ineq_data %>% filter(adminlevel_1 == region)
      }

      # 4. Filter and reshape for plotting
      ineq_data %>%
        filter_inequality(
          indicator = indicator,
          denominator = denom
        )
    },
    #' @description Get filtered mapping data responsive to indicator, palette, and years.
    #' @param indicator Character. The target health indicator.
    #' @param palette Character. Color palette for mapping.
    #' @param admin_level Character. Level of aggregation (defaults to "adminlevel_1").
    get_filtered_mapping_data = function(indicator, admin_level, palette) {
      indicator <- arg_match(indicator, get_analysis_indicators())
      admin_level <- arg_match(admin_level, c("adminlevel_1", "district"))
      check_required(palette)

      # 1. Validate parameters
      if (!self$check_inequality_params) {
        cd_abort(c("x" = "One or more parameters is missing for {.fun get_filtered_mapping_data}"))
      }

      # 2. Fetch and validate the denominator
      denom <- self$get_denominator(indicator)
      if (is.null(denom)) {
        cd_abort(c("x" = "The denominator for indicator '{indicator}' is NULL in the cache state."))
      }

      # 3. Resolve plotting years (fallback to cached years if not explicitly provided)
      years_to_plot <- self$mapping_years

      # 4. Retrieve the spatial mapping data
      map_data <- self$get_mapping_data(admin_level)

      # 5. Filter and reshape for the map plot
      map_data %>%
        filter_mapping_data(
          indicator = indicator,
          denominator = denom,
          palette = palette,
          plot_year = years_to_plot
        )
    },
    #' @description Get baseline indicator coverage data responsive to admin level and region.
    #' @param admin_level Character. Level of aggregation ("national", "adminlevel_1", "district").
    #' @param region Character. Optional region filter.
    get_base_indicator_coverage = function(admin_level, region = NULL) {
      admin_level <- arg_match(admin_level, c("national", "adminlevel_1", "district"))

      if (!self$check_inequality_params) {
        cd_abort(c("x" = "One or more parameters is missing for {.fun get_base_indicator_coverage}"))
      }

      data <- if (admin_level == "national" && is.null(region)) {
        self$indicator_coverage_national
      } else if (admin_level == "adminlevel_1" && is.null(region)) {
        self$indicator_coverage_admin1
      } else if (admin_level == "district"  && is.null(region)) {
        self$indicator_coverage_district
      } else {
        self$calculate_indicator_coverage(admin_level, region)
      }

      data
    },
    #' @description Get calculated threshold data responsive to admin level and indicator.
    #' @param indicator Character. The target health indicator group (e.g., "vaccine", "dropout").
    #' @param admin_level Character. Level of aggregation ("national", "adminlevel_1", "district").
    #' @param region Character. Optional region filter.
    get_filtered_threshold = function(indicator, admin_level, region = NULL) {
      indicator <- arg_match(indicator, c('anc4', 'instdeliveries', 'vaccine', 'dropout'))
      admin_level <- arg_match(admin_level, c("national", "adminlevel_1", "district"))

      if (!self$check_inequality_params) {
        cd_abort(c("x" = "One or more parameters is missing for {.fun get_filtered_threshold}"))
      }

      # 1. Fetch base coverage data
      cov_data <- self$get_base_indicator_coverage(admin_level, region)

      # 2. Fetch and validate denominator
      denom <- self$get_denominator(indicator)
      if (is.null(denom)) {
        cd_abort(c("x" = "The denominator for indicator '{indicator}' is NULL in the cache state."))
      }

      # 3. Calculate and return threshold
      cov_data %>%
        calculate_threshold(
          indicator = indicator,
          denominator = denom
        )
    },

    #' @description Get high-performing regions based on indicator and threshold.
    #' @param indicator Character. The specific health indicator (e.g., "penta3").
    #' @param admin_level Character. Level of aggregation ("national", "adminlevel_1", "district").
    #' @param region Character. Optional region filter.
    get_high_performers = function(indicator, admin_level, region = NULL) {
      indicator <- arg_match(indicator, get_analysis_indicators())
      admin_level <- arg_match(admin_level, c("national", "adminlevel_1", "district"))

      if (!self$check_inequality_params) {
        cd_abort(c("x" = "One or more parameters is missing for {.fun get_high_performers}"))
      }

      # 1. Fetch base coverage data
      cov_data <- self$get_base_indicator_coverage(admin_level, region)

      # 2. Fetch and validate denominator
      denom <- self$get_denominator(indicator)
      if (is.null(denom)) {
        cd_abort(c("x" = "The denominator for indicator '{indicator}' is NULL in the cache state."))
      }

      threshold <- case_when(
        # Split the vaccine logic into two clear, vectorized conditions
        indicator %in% list_vaccine_indicators() & admin_level == "national" ~ 90,
        indicator %in% list_vaccine_indicators() & admin_level != "national" ~ 80,

        # Other explicit targets
        indicator == "anc4" ~ 70,
        indicator == "instdeliveries" ~ 80,
        str_detect(indicator, "dropout") ~ 10,

        # The fallback for anything else (e.g., anc1, sba)
        .default = 80
      )

      # 3. Filter and return high performers
      cov_data %>%
        filter_high_performers(
          indicator = indicator,
          denominator = denom,
          threshold = threshold
        )
    },

    #' @description Get the regional estimate.
    #' @param admin_level description
    #' @param region Character. .
    get_regional_estimates = function(admin_level, region) {
      iso <- self$country_iso
      rates <- self$national_estimates

      if (is.null(region)) return(rates)

      target_admin1 <- region

      # 1. Look up parent region if district
      if (admin_level == "district") {
        target_admin1 <- self$adjusted_data %>%
          filter(district == region) %>%
          pull(adminlevel_1) %>%
          na.omit() %>%
          unique() %>%
          first()

        if (is.null(target_admin1) || is.na(target_admin1)) {
          return(rates)
        }
      }

      message(paste0(iso, ': ', target_admin1))

      # 2. Extract regional data safely
      reg_data <- survey_data$gregion %>%
        filter(iso3 == iso, adminlevel_1 == target_admin1) %>%
        select(year, starts_with("r_"), -ends_with("24_35")) %>%
        rename_with(~ str_remove(.x, "r_"), starts_with("r_"))

      # 3. Check if rows survived the filter
      if (nrow(reg_data) == 0) {
        return(rates)
      }

      # 4. Determine columns based on group
      group <- get_selected_group()
      cols_to_keep <- if (group == "vaccine") {
        c("anc1", "instlivebirths", "bcg", "penta1", "penta3", "opv1", "opv3", "measles1", "nmr", "pnmr", "sbr")
      } else {
        c("anc1", "anc4", "instlivebirths", "bcg", "penta1", "penta3", "measles1", "low_bweight", "csection", "nmr", "pnmr", "sbr")
      }

      # Safely intersect to ensure we only pivot columns that actually exist
      cols_to_keep <- intersect(cols_to_keep, names(reg_data))

      if (length(cols_to_keep) == 0) {
        return(rates)
      }

      # 5. Process and scale the rates
      reg_est <- reg_data %>%
        select(year, any_of(cols_to_keep)) %>%
        pivot_longer(cols = -year) %>%
        filter(!is.na(value)) %>%
        slice_max(order_by = year, by = name, with_ties = FALSE) %>%
        mutate(
          value = case_when(
            name %in% c("nmr", "pnmr", "sbr") ~ value / 1000,
            # Safely convert percentage values (like 96.7) to proportions (0.967)
            !name %in% c("nmr", "pnmr", "sbr") & value > 1 ~ value / 100,
            TRUE ~ value # Uses TRUE instead of .default to guarantee older dplyr compatibility
          )
        )

      reg_named <- set_names(reg_est$value, reg_est$name)

      # 6. Override the national rates with the successful regional rates
      for (ind in names(reg_named)) {
        rates[[ind]] <- reg_named[[ind]]
      }

      return(rates)
    }
  ),
  active = list(
    #' @field language Get the UI language.
    language = function(value) private$getter("language", value),

    #' @field cache_path Get cache path.
    cache_path = function(value) private$getter("rds_path", value),

    #' @field countdown_data Get countdown data.
    countdown_data = function(value) private$getter("countdown_data", value),

    #' @field data_years Get countdown data.
    data_years = function(value) {
      years <- private$getter("data_years", value)
      if (is.null(years)) {
        years <- self$countdown_data %>%
          distinct(year) %>%
          arrange(year) %>%
          pull(year)
        private$update_field("data_years", years)
      }
      return(years)
    },
    #' @field subnational_regions Get countdown data.
    subnational_regions = function(value) {
      regions <- private$getter("subnational_regions", value)
      if (is.null(regions)) {
        regions <- self$countdown_data %>%
          distinct(adminlevel_1, district) %>%
          arrange(adminlevel_1, district)
        private$update_field("subnational_regions", regions)
      }
      return(regions)
    },

    #' @field country Get country name.
    country = function(value) {
      if (missing(value)) {
        if (is.null(self$countdown_data)) {
          return(NULL)
        }

        return(attr_or_abort(self$countdown_data, "country"))
      }

      cd_abort(c("x" = "{.field country} is readonly."))
    },

    #' @field country_iso Get country ISO3 code.
    country_iso = function(value) {
      if (missing(value)) {
        if (is.null(self$countdown_data)) {
          return(NULL)
        }

        return(attr_or_abort(self$countdown_data, "iso3"))
      }

      cd_abort(c("x" = "{.field iso3} is readonly."))
    },

    #' @field adjusted_data Gets adjusted data.
    adjusted_data = function(value) {
      if (missing(value)) {
        private$depend("adjusted_data")
        if (self$adjusted_flag && !is.null(private$.in_memory_data$adjusted_data)) {
          return(private$.in_memory_data$adjusted_data)
        } else if (self$adjusted_flag && is.null(private$.in_memory_data$adjusted_data)) {
          self$adjust_data()
          return(private$.in_memory_data$adjusted_data)
        }
        return(NULL)
      }

      cd_abort(c("x" = "{.field adjusted_data} is readonly."))
    },

    #' @field data_with_excluded_years Get data with excluded years removed.
    data_with_excluded_years = function(value) {
      if (missing(value)) {
        private$depend("excluded_years")
        excluded_years <- self$excluded_years
        data <- self$countdown_data %>%
          filter(if (length(excluded_years) > 0) !year %in% excluded_years else TRUE)
        return(data)
      }

      cd_abort(c("x" = "{.field data_with_excluded_years} is readonly."))
    },

    #' @field performance_threshold Gets performance threshold.
    performance_threshold = function(value) private$getter("performance_threshold", value),

    #' @field excluded_years Gets excluded years.
    excluded_years = function(value) private$getter("excluded_years", value),

    #' @field k_factors Gets k-factors.
    k_factors = function(value) private$getter("k_factors", value),

    #' @field adjusted_flag Gets adjusted flag.
    adjusted_flag = function(value) private$getter("adjusted_flag", value),

    #' @field derivation_population Gets adjusted flag.
    derivation_population = function(value) {
      pop <- private$getter("derivation_population", value)
      if (is.null(pop)) {
        pop <- "totlivebirths_dhis2"
        self$set_derivation_population(pop)
      }
      return(pop)
    },

    #' @field indicator_coverage_national Gets adjusted data.
    indicator_coverage_national = function(value) {
      if (missing(value)) {
        private$depend("derivation_population")
        private$depend("adjusted_data")
        private$depend("national_estimates")
        private$depend("un_estimates")
        cov <- private$getter("indicator_coverage_national", value)
        if (is.null(cov) || private$.invalidate_coverage) {
          cov <- self$calculate_indicator_coverage("national")
          private$update_field("indicator_coverage_national", cov)
          private$.invalidate_coverage <- FALSE
        }
        return(cov)
      }

      cd_abort(c("x" = "{.field indicator_coverage_national} is readonly."))
    },

    #' @field indicator_coverage_admin1 Gets adjusted data.
    indicator_coverage_admin1 = function(value) {
      if (missing(value)) {
        private$depend("derivation_population")
        private$depend("adjusted_data")
        private$depend("national_estimates")
        cov <- private$getter("indicator_coverage_admin1", value)
        if (is.null(cov) || private$.invalidate_coverage) {
          cov <- self$calculate_indicator_coverage("adminlevel_1")
          private$update_field("indicator_coverage_admin1", cov)
          private$.invalidate_coverage <- FALSE
        }
        return(cov)
      }

      cd_abort(c("x" = "{.field indicator_coverage_admin1} is readonly."))
    },

    #' @field indicator_coverage_district Gets adjusted data.
    indicator_coverage_district = function(value) {
      if (missing(value)) {
        private$depend("derivation_population")
        private$depend("adjusted_data")
        private$depend("national_estimates")
        cov <- private$getter("indicator_coverage_district", value)
        if (is.null(cov) || private$.invalidate_coverage) {
          cov <- self$calculate_indicator_coverage("district")
          private$update_field("indicator_coverage_district", cov)
          private$.invalidate_coverage <- FALSE
        }
        return(cov)
      }

      cd_abort(c("x" = "{.field indicator_coverage_admin1} is readonly."))
    },

    #' @field survey_estimates Gets survey estimates.
    survey_estimates = function(value) {
      estimates <- private$getter("survey_estimates", value)
      group <- get_selected_group()
      if (group == "vaccine") {
        estimates[c("anc1", "instlivebirths", "bcg", "penta1", "penta3", "measles1", "opv1", "opv3", "measles1")]
      } else {
        estimates[which(!estimates %in% c("opv1", "opv3"))]
      }
    },

    #' @field national_estimates Gets national estimates.
    national_estimates = function(value) {
      if (missing(value)) {
        private$depend("national_estimates")
        survey <- self$survey_estimates
        return(c(
          private$.in_memory_data$national_estimates,
          list(
            anc1 = unname(survey["anc1"]) / 100,
            penta1 = unname(survey["penta1"]) / 100
          )
        ))
      }

      if (!is.list(value)) {
        cd_abort(c("x" = "Analysis values must be a list."))
      }
      private$update_field("national_estimates", value)
    },

    #' @field admin1_estimates Gets national estimates.
    admin1_estimates = function(value) {
      if (missing(value)) {
        private$depend("regional_survey")
        private$depend("national_estimates")
        survey <- self$regional_survey
        rate <- self$national_estimates
        return(get_national_rates(self$regional_survey,
                                  'adminlevel_1',
                                  rate$anc1,
                                  rate$penta1,
                                  rate$sbr,
                                  rate$nmr,
                                  rate$pnmr,
                                  rate$twin_rate,
                                  rate$preg_loss))
      }

      cd_abort(c("x" = "{.field admin1_estimates} is readonly."))
    },

    #' @field survey_years Get survey years.
    survey_years = function(value) {
      self$national_survey %>%
        distinct(year) %>%
        arrange(year) %>%
        pull(year)
    },

    #' @field survey_source Gets survey source of information.
    survey_source = function(value) private$getter("survey_source", value),

    #' @field survey_year Gets survey year of survey estimates.
    survey_year = function(value) private$getter("survey_year", value),

    #' @field start_survey_year Gets start survey year.
    start_survey_year = function(value) private$getter("start_survey_year", value),

    #' @field denominator Gets denominator.
    denominator = function(value) private$getter("denominator", value),

    #' @field maternal_denominator Gets denominator.
    maternal_denominator = function(value) private$getter("maternal_denominator", value),

    #' @field selected_admin_level_1 Gets selected region.
    selected_admin_level_1 = function(value) private$getter("selected_admin_level_1", value),

    #' @field selected_district Gets selected district.
    selected_district = function(value) private$getter("selected_district", value),

    #' @field mortality_mapping_years Gets mapping years.
    mortality_mapping_years = function(value) private$getter("selected_mortality_mapping_years", value),

    #' @field utilization_mapping_years Gets mapping years.
    utilization_mapping_years = function(value) private$getter("selected_utilization_mapping_years", value),

    #' @field mapping_years Gets mapping years.
    mapping_years = function(value) private$getter("selected_mapping_years", value),

    #' @field fpet_data Gets UN estimates.
    fpet_data = function(value) private$getter("fpet_data", value),

    #' @field un_estimates Gets UN estimates.
    un_estimates = function(value) {
      iso <- self$country_iso
      private$getter("un_estimates", value) %||% (un_estimates %>% filter(iso3 == iso))
    },

    #' @field un_mortality_estimates Gets UN mortality estimates.
    un_mortality_estimates = function(value) {
      iso <- self$country_iso
      private$getter("un_mortality_estimates", value) %||% (un_mortality %>% filter(iso3 == iso))
    },

    #' @field wuenic_estimates Gets WUENIC estimates.
    wuenic_estimates = function(value) {
      iso <- self$country_iso
      est <- private$getter("wuenic_estimates", value) %||% wuenic
      if (!"iso3" %in% names(est)) {
        est <- est %>%
          rename(iso3 = iso)
      }

      est %>% filter(iso3 == !!iso)
    },

    #' @field national_survey Gets national survey.
    national_survey = function(value) {
      survey <- private$getter("national_survey", value) %||% survey_data$all
      private$filter_survey(survey)
    },

    #' @field regional_survey Gets regional survey.
    regional_survey = function(value) {
      survey <- private$getter("regional_survey", value) %||% survey_data$gregion
      private$filter_survey(survey)
    },

    #' @field wiq_survey Gets WIQ survey.
    wiq_survey = function(value) {
      survey <- private$getter("wiq_survey", value)
      if (is.null(survey)) {
        survey <- survey_data$wiq %>%
          pivot_longer(
            cols = matches('q[1-5]$'),
            names_pattern = '(.*)(q[1-5])$',
            names_to = c('.value', 'level')
          ) %>%
          mutate(level = str_to_upper(level)) %>%
          new_tibble(class = 'cd_equity_data')
      }
      private$filter_survey(survey)
    },

    #' @field area_survey Gets area survey.
    area_survey = function(value) {
      survey <- private$getter("area_survey", value)
      if (is.null(survey)) {
        survey <- survey_data$area %>%
          select(-matches('_[12]$')) %>%
          pivot_longer(
            cols = matches('_area[12]$'),
            names_pattern = '(.*)_(area[12])$',
            names_to = c('.value', 'level')
          ) %>%
          mutate(
            level = case_match(
              level,
              'area1' ~ 'urban',
              'area2' ~ 'rural'
            )
          ) %>%
          new_tibble(class = 'cd_equity_data')
      }
      private$filter_survey(survey)
    },

    #' @field education_survey Gets  education survey.
    education_survey = function(value) {
      survey <- private$getter("education_survey", value)
      if (is.null(survey)) {
        survey <- survey_data$meduc %>%
          pivot_longer(
            cols = matches('_me[1-3]$'),
            names_pattern = '(.*)_(me[1-3])$',
            names_to = c('.value', 'level')
          ) %>%
          mutate(
            level = case_match(
              level,
              'me1' ~ 'none',
              'me2' ~ 'primary',
              'me3' ~ 'secondary+',
              .ptype = factor(levels = c('none', 'primary', 'secondary+'))
            )
          ) %>%
          new_tibble(class = 'cd_equity_data')
      }
      private$filter_survey(survey)
    },

    #' @field survey_mapping Gets survey mapping.
    survey_mapping = function(value) private$getter("survey_mapping", value),

    #' @field map_mapping Gets map mapping.
    map_mapping = function(value) private$getter("map_mapping", value),

    #' @field sector_national_estimates Gets map mapping.
    sector_national_estimates = function(value) private$getter("sector_national_estimates", value),

    #' @field sector_area_estimates Gets map mapping.
    sector_area_estimates = function(value) private$getter("sector_area_estimates", value),

    #' @field csection_national_estimates Gets map mapping.
    csection_national_estimates = function(value) private$getter("csection_national_estimates", value),

    #' @field csection_area_estimates Gets map mapping.
    csection_area_estimates = function(value) private$getter("csection_area_estimates", value),

    #' @field check_inequality_params checks if inputs for inequality calculations are available
    check_inequality_params = function() {
      !is.null(self$adjusted_data) &&
        !is.null(self$survey_year) &&
        !is.null(self$un_estimates) &&
        all(!is.na(self$national_estimates))
    },

    #' @field check_coverage_params checks if inputs for coverage calculations are available
    check_coverage_params = function() {
      self$check_inequality_params &&
        !is.null(self$wuenic_estimates) &&
        !is.null(self$national_survey) &&
        !is.null(self$regional_survey)
    },

    #' @field check_mortality_params checks if inputs for mortality calculations are available
    check_mortality_params = function() {
      !is.null(self$adjusted_data) &&
        !is.null(self$un_mortality_estimates)
    },

    #' @field check_sector_params checks if inputs for mortality calculations are available
    check_sector_params = function() {
      !is.null(self$sector_national_estimates) && !is.null(self$sector_area_estimates) &&
        !is.null(self$csection_national_estimates) && !is.null(self$csection_area_estimates)
    },

    #' @field reporting_rate_national Get cached national reporting rates.
    reporting_rate_national = function(value) {
      if (missing(value)) {
        # 1. Register dependency for reactivity (if using Shiny)
        private$depend("countdown_data")

        # 2. Check cache
        data <- private$getter("reporting_rate_national", value)

        # 3. If cache is empty, calculate and save
        if (is.null(data)) {
          data <- self$calculate_reporting_rate("national")
          private$update_field("reporting_rate_national", data)
        }
        return(data)
      }
      cd_abort(c("x" = "Read-only field."))
    },

    #' @field reporting_rate_admin1 Get cached admin1 reporting rates.
    reporting_rate_admin1 = function(value) {
      if (missing(value)) {
        private$depend("countdown_data")
        data <- private$getter("reporting_rate_admin1", value)

        if (is.null(data)) {
          # Note: We calculate for ALL regions to maximize cache reusability
          data <- self$calculate_reporting_rate("adminlevel_1")
          private$update_field("reporting_rate_admin1", data)
        }
        return(data)
      }
      cd_abort(c("x" = "Read-only field."))
    },

    #' @field reporting_rate_district Get cached district reporting rates.
    reporting_rate_district = function(value) {
      if (missing(value)) {
        private$depend("countdown_data")
        data <- private$getter("reporting_rate_district", value)

        if (is.null(data)) {
          data <- self$calculate_reporting_rate("district")
          private$update_field("reporting_rate_district", data)
        }
        return(data)
      }
      cd_abort(c("x" = "Read-only field."))
    },

    #' @field district_reporting_rate Get cached district reporting rates.
    district_reporting_rate = function(value) {
      if (!missing(value)) {
        cd_abort(c("x" = "Read-only field."))
      }

      private$depend("countdown_data")
      private$depend("performance_threshold")

      data <- private$getter("district_reporting_rate", value)

      # Recompute if empty OR threshold changed
      if (is.null(data)) {
        data <- self$calculate_district_reporting_rate()
        private$update_field("district_reporting_rate", data)
      }

      data
    },

    #' @field completeness_national Get cached district reporting rates.
    completeness_national = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")
      private$depend("performance_threshold")

      data <- private$getter("completeness_national", value)
      if (is.null(data)) {
        data <- self$calculate_completeness_summary("national")
        private$update_field("completeness_national", data)
      }
      data
    },

    #' @field completeness_admin1 Get cached district reporting rates.
    completeness_admin1 = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")
      private$depend("performance_threshold")

      data <- private$getter("completeness_admin1", value)
      if (is.null(data)) {
        # Cache for ALL regions for reuse (filter later if needed)
        data <- self$calculate_completeness_summary("adminlevel_1")
        private$update_field("completeness_admin1", data)
      }
      data
    },

    #' @field completeness_district Get cached district reporting rates.
    completeness_district = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")
      private$depend("performance_threshold")

      data <- private$getter("completeness_district", value)
      if (is.null(data)) {
        data <- self$calculate_completeness_summary("district")
        private$update_field("completeness_district", data)
      }
      data
    },

    #' @field district_completeness Get cached district reporting rates.
    district_completeness = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")

      data <- private$getter("district_completeness", value)
      if (is.null(data)) {
        # Cache national/all-regions version
        data <- self$calculate_district_completeness_summary()
        private$update_field("district_completeness", data)
      }
      data
    },

    #' @field outliers_national Get cached district reporting rates.
    outliers_national = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")

      data <- private$getter("outliers_national", value)
      if (is.null(data)) {
        data <- self$calculate_outliers_summary("national")
        private$update_field("outliers_national", data)
      }
      data
    },

    #' @field outliers_admin1 Get cached district reporting rates.
    outliers_admin1 = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")

      data <- private$getter("outliers_admin1", value)
      if (is.null(data)) {
        # cache ALL regions for reuse
        data <- self$calculate_outliers_summary("adminlevel_1")
        private$update_field("outliers_admin1", data)
      }
      data
    },

    #' @field outliers_district Get cached district reporting rates.
    outliers_district = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")

      data <- private$getter("outliers_district", value)
      if (is.null(data)) {
        data <- self$calculate_outliers_summary("district")
        private$update_field("outliers_district", data)
      }
      data
    },

    #' @field district_outliers_summary Get cached district reporting rates.
    district_outliers_summary = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")

      data <- private$getter("district_outliers_summary", value)
      if (is.null(data)) {
        data <- self$calculate_district_outlier_summary()
        private$update_field("district_outliers_summary", data)
      }
      data
    },

    #' @field list_outlier_units Get cached district reporting rates.
    list_outlier_units = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")

      data <- private$getter("list_outlier_units", value)
      if (is.null(data)) {
        data <- list_outlier_units(.data = self$countdown_data)
        private$update_field("list_outlier_units", data)
      }
      data
    },
    #' @field ratios_summary Get cached district reporting rates.
    ratios_summary = function(value) {
      if (!missing(value)) {
        cd_abort(c("x" = "Read-only field."))
      }

      private$depend("countdown_data")
      private$depend("ratios_summary")

      data <- private$getter("ratios_summary", value)

      # Recompute if empty OR threshold changed
      if (is.null(data)) {
        data <- self$adequacy_ratios %>%
          calculate_ratios_summary(self$survey_estimates)
        private$update_field("ratios_summary", data)
      }

      data
    },

    #' @field adequacy_ratios Get cached district reporting rates.
    adequacy_ratios = function(value) {
      if (!missing(value)) {
        cd_abort(c("x" = "Read-only field."))
      }

      private$depend("countdown_data")

      data <- private$getter("adequacy_ratios", value)

      # Recompute if empty OR threshold changed
      if (is.null(data)) {
        data <- self$calculate_ratios_and_adequacy()
        private$update_field("adequacy_ratios", data)
      }

      data
    },
    #' @field overall_score Get cached national overall score.
    overall_score = function(value) {
      if (!missing(value)) {
        cd_abort(c("x" = "Read-only field."))
      }

      private$depend("countdown_data")
      private$depend("performance_threshold") # Score depends on threshold

      # 1. Check cache
      data <- private$getter("overall_score", value)

      # 2. If cache is empty, calculate (Defaults to National) and save
      if (is.null(data)) {
        data <- self$calculate_overall_score(admin_level = "national")
        private$update_field("overall_score", data)
      }

      data
    },
    #' @field denominator_metrics Get cached national overall score.
    denominator_metrics = function(value) {
      if (!missing(value)) {
        cd_abort(c("x" = "Read-only field."))
      }

      private$depend("un_estimates")
      private$depend("adjusted_data") # Score depends on threshold

      # 1. Check cache
      data <- private$getter("denominator_metrics", value)

      # 2. If cache is empty, calculate (Defaults to National) and save
      if (is.null(data) && !is.null(self$adjusted_data)) {
        data <- self$calculate_overall_score(admin_level = "national")
        data <- self$adjusted_data %>%
          prepare_population_metrics(un_estimates = self$un_estimates)
        private$update_field("denominator_metrics", data)
      }

      data
    },
    #' @field inequality_admin1 Gets cached inequality data for admin level 1.
    inequality_admin1 = function(value) {
      if (missing(value)) {
        private$depend("adjusted_data")
        private$depend("un_estimates")
        private$depend("national_estimates")

        data <- private$getter("inequality_admin1", value)

        if (is.null(data) || private$.invalidate_coverage) {
          data <- self$calculate_inequality(admin_level = "adminlevel_1")
          private$update_field("inequality_admin1", data)
        }
        return(data)
      }
      cd_abort(c("x" = "{.field inequality_admin1} is readonly."))
    },

    #' @field inequality_district Gets cached inequality data for district level.
    inequality_district = function(value) {
      if (missing(value)) {
        private$depend("adjusted_data")
        private$depend("un_estimates")
        private$depend("national_estimates")

        data <- private$getter("inequality_district", value)

        if (is.null(data) || private$.invalidate_coverage) {
          # Calculates for all districts nationally and caches it
          data <- self$calculate_inequality(admin_level = "district")
          private$update_field("inequality_district", data)
        }
        return(data)
      }
      cd_abort(c("x" = "{.field inequality_district} is readonly."))
    },

    #' @field mortality_summary Creates the mortality summary.
    mortality_summary = function(value) {
      if (missing(value)) {
        private$depend("adjusted_data")
        summary <- private$getter("mortality_summary", value)
        if (is.null(summary) && !is.null(self$adjusted_data)) {
          summary <- create_mortality_summary(self$adjusted_data)
          private$update_field("mortality_summary", summary)
        }
        return(summary)
      }

      cd_abort(c("x" = "{.field mortality_summary} is readonly."))
    },

    #' @field mortality_ratios Creates the mortality summary.
    mortality_ratios = function(value) {
      if (missing(value)) {
        private$depend("mortality_summary")
        ratios <- private$getter("mortality_ratios", value)
        if (is.null(ratios)) {
          ratios <- self$mortality_summary %>% create_mortality_ratios(self$un_mortality_estimates)
          private$update_field("mortality_ratios", ratios)
        }
        return(ratios)
      }

      cd_abort(c("x" = "{.field mortality_ratios} is readonly."))
    },

    #' @field service_utilization_national Gets adjusted data.
    service_utilization_national = function(value) {
      if (missing(value)) {
        private$depend("adjusted_data")
        cov <- private$getter("service_utilization_national", value)
        if (is.null(cov)) {
          cov <- self$compute_service_utilization("national")
          private$update_field("service_utilization_national", cov)
        }
        return(cov)
      }

      cd_abort(c("x" = "{.field service_utilization_national} is readonly."))
    },

    #' @field service_utilization_admin1 Gets adjusted data.
    service_utilization_admin1 = function(value) {
      if (missing(value)) {
        private$depend("adjusted_data")
        cov <- private$getter("service_utilization_admin1", value)
        if (is.null(cov)) {
          cov <- self$compute_service_utilization("adminlevel_1")
          private$update_field("service_utilization_admin1", cov)
        }
        return(cov)
      }

      cd_abort(c("x" = "{.field service_utilization_admin1} is readonly."))
    },

    #' @field health_system_comparison coverage calculation using stored model parameters.
    health_system_comparison = function(value) {
      if (missing(value)) {
        private$depend("adjusted_data")
        private$depend("indicator_coverage_admin1")
        private$depend("indicator_coverage_district")
        cov <- private$getter("health_system_comparison", value)
        if (is.null(cov) && !is.null(self$adjusted_data)) {
          cov <- self$adjusted_data %>%
            calculate_health_system_comparison(self$indicator_coverage_admin1, self$indicator_coverage_district)
          private$update_field("health_system_comparison", cov)
        }
        return(cov)
      }

      cd_abort(c("x" = "{.field health_system_comparison} is readonly."))
    },

    #' @field health_system_metrics_national coverage calculation using stored model parameters.
    health_system_metrics_national = function(value) {
      if (missing(value)) {
        private$depend("adjusted_data")
        cov <- private$getter("health_system_metrics_national", value)
        if (is.null(cov) && !is.null(self$adjusted_data)) {
          cov <- self$adjusted_data %>%
            calculate_health_system_metrics('national')
          private$update_field("health_system_metrics_national", cov)
        }
        return(cov)
      }

      cd_abort(c("x" = "{.field health_system_metrics_national} is readonly."))
    },

    #' @field health_system_metrics_admin1 coverage calculation using stored model parameters.
    health_system_metrics_admin1 = function(value) {
      if (missing(value)) {
        private$depend("adjusted_data")
        cov <- private$getter("health_system_metrics_admin1", value)
        if (is.null(cov) && !is.null(self$adjusted_data)) {
          cov <- self$adjusted_data %>%
            calculate_health_system_metrics('adminlevel_1')
          private$update_field("health_system_metrics_admin1", cov)
        }
        return(cov)
      }

      cd_abort(c("x" = "{.field health_system_metrics_admin1} is readonly."))
    }
  ),
  private = list(
    .data_template = list(
      language = "en",
      rds_path = NULL,
      countdown_data = NULL,
      data_years = NULL,
      subnational_regions = NULL,
      performance_threshold = 90,
      excluded_years = numeric(),
      k_factors = c(anc = 0, idelv = 0, vacc = 0, opd = 0, ipd = 0),
      denominator = "penta1",
      maternal_denominator = "anc1",
      derivation_population = "totlivebirths_dhis2",
      adjusted_flag = FALSE,
      adjusted_data = NULL,
      survey_estimates = c(anc1 = NA, penta1 = NA, penta3 = NA, opv1 = NA, opv3 = NA, measles1 = NA, bcg = NA, anc4 = NA, instlivebirths = NA, low_bweight = NA, csection = NA),
      national_estimates = list(nmr = NA, pnmr = NA, twin_rate = 0.015, preg_loss = 0.03, sbr = NA),
      survey_year = NULL,
      indicator_coverage_national = NULL,
      indicator_coverage_admin1 = NULL,
      indicator_coverage_district = NULL,
      start_survey_year = NULL,
      survey_source = NA,
      selected_admin_level_1 = NULL,
      selected_district = NULL,
      selected_mortality_mapping_years = NULL,
      selected_utilization_mapping_years = NULL,
      selected_mapping_years = NULL,
      # palette = c(coverage = 'Greens', dropout = 'Reds'),
      un_estimates = NULL,
      un_mortality_estimates = NULL,
      wuenic_estimates = NULL,
      national_survey = NULL,
      regional_survey = NULL,
      wiq_survey = NULL,
      area_survey = NULL,
      education_survey = NULL,
      survey_mapping = NULL,
      map_mapping = NULL,
      fpet_data = NULL,
      sector_national_estimates = NULL,
      sector_area_estimates = NULL,
      csection_national_estimates = NULL,
      csection_area_estimates = NULL,
      reporting_rate_national = NULL,
      reporting_rate_admin1 = NULL,
      reporting_rate_district = NULL,
      district_reporting_rate = NULL,
      completeness_national = NULL,
      completeness_admin1 = NULL,
      completeness_district = NULL,
      district_completeness = NULL,
      outliers_national = NULL,
      outliers_admin1 = NULL,
      outliers_district = NULL,
      district_outliers_summary = NULL,
      list_outlier_units = NULL,
      ratios_summary = NULL,
      adequacy_ratios = NULL,
      overall_score = NULL,
      denominator_metrics = NULL,
      inequality_admin1 = NULL,
      inequality_district = NULL,
      mortality_summary = NULL,
      mortality_ratios = NULL,
      service_utilization_national = NULL,
      service_utilization_admin1 = NULL,
      health_system_comparison = NULL,
      health_system_metrics_national = NULL,
      health_system_metrics_admin1 = NULL
    ),
    .in_memory_data = NULL,
    .invalidate_coverage = FALSE,
    .has_changed = FALSE,
    .reactiveDep = NULL,
    #' Update a field (with change tracking)
    update_field = function(field_name, value) {
      if (!identical(private$.in_memory_data[[field_name]], value)) {
        private$.in_memory_data[[field_name]] <<- value
        private$.has_changed <<- TRUE
        private$trigger(field_name)
        self$save_to_disk()
      }
    },
    getter = function(field_name, value) {
      if (is_missing(value)) {
        private$depend(field_name)
        return(private$.in_memory_data[[field_name]])
      }

      cd_abort(c("x" = "{.field field_name} is readonly"))
    },
    setter = function(field_name, value, validation_exp = NULL) {
      check_required(field_name)
      check_required(value)

      validate_fn <- if (!is.null(validation_exp)) {
        if (rlang::is_formula(validation_exp)) {
          rlang::as_function(validation_exp)
        } else if (rlang::is_function(validation_exp)) {
          validation_exp
        } else {
          cd_abort(c("x" = "{.arg {validation}} must be a function or a formula."))
        }
      } else {
        function(x) TRUE
      }
      if (!validate_fn(value)) {
        cd_abort(c("x" = "Invalid value for field {.field {field_name}}."))
      }
      private$update_field(field_name, value)
    },
    filter_survey = function(survey) {
      check_required(survey)
      start_year <- self$start_survey_year
      load_data_or_file(.data = survey, country_iso = self$country_iso) %>%
        filter(if (is.null(start_year)) TRUE else year >= start_year)
    },
    initialize_survey_estimates = function() {
      iso <- self$country_iso
      estimates <- survey_data$all %>%
        filter(iso3 == iso) %>%
        select(year, starts_with("r_"), -ends_with("24_35")) %>%
        rename_with(~ str_remove(.x, "r_"), starts_with("r_"))

      group <- get_selected_group()
      nat_est <- if (group == "vaccine") {
        estimates %>%
          select(year, anc1, instlivebirths, bcg, penta1, penta3, opv1, opv3, measles1, nmr, pnmr) %>%
          pivot_longer(cols = -year) %>%
          filter(!is.na(value)) %>%
          slice_max(order_by = year, by = name)
      } else {
        estimates %>%
          select(year, anc1, anc4, instlivebirths, bcg, penta1, penta3, measles1, low_bweight, csection, nmr, pnmr) %>%
          pivot_longer(cols = -year) %>%
          filter(!is.na(value)) %>%
          slice_max(order_by = year, by = name)
      }

      year <- max(nat_est$year)
      survey_est <- nat_est %>%
        filter(!name %in% c("nmr", "pnmr")) %>%
        mutate(value = round(value, 1))
      survey_est <- set_names(survey_est$value, survey_est$name)
      nat_est <- nat_est %>%
        filter(name %in% c("nmr", "pnmr")) %>%
        mutate(
          value = case_when(
            name == "nmr" ~ value / 1000,
            name == "pnmr" ~ value / 1000,
            .default = value
          )
        )
      nat_est <- set_names(nat_est$value, nat_est$name)

      self$set_national_estimates(c(list(pnmr = NA, nmr = NA, sbr = NA, twin_rate = 0.015, preg_loss = 0.03), nat_est))
      self$set_survey_estimates(survey_est)
      self$set_survey_year(year)
    },
    depend = function(field_name) {
      if (!is.null(private$.reactiveDep[[field_name]])) {
        private$.reactiveDep[[field_name]]
      }
      invisible()
    },
    trigger = function(field_name) {
      if (!is.null(private$.reactiveDep[[field_name]])) {
        private$.reactiveDep[[field_name]] <- isolate(private$.reactiveDep[[field_name]] + 1)
      }
    },
    depend_all = function() {
      for (field_name in names(private$.data_template)) {
        private$depend(field_name) # Establish dependency for each field
      }
      invisible()
    }
  )
)
