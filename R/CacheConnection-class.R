#' Create a CacheConnection Object
#'
#' `init_CacheConnection` initializes a `CacheConnection` either from a provided `.rds` file path
#' or directly from a `cd_data` object. Only one of the arguments should be non-NULL.
#'
#' @param rds_path Optional character. Path to an RDS file to load the cache from.
#' @param countdown_data Optional `cd_data` object to initialize in-memory cache.
#' @param data_path Optional character. Path to the original source file
#'   (e.g. the `.xlsx` `countdown_data` was parsed from). Used to derive
#'   where the cache lives -- see `CacheConnection$initialize`.
#' @param wizard_parts Optional `load_excel_parts()` result -- a third, mutually-exclusive mode
#'   alongside `rds_path`/`countdown_data` for the Load Data wizard's own in-progress state (see
#'   `CacheConnection$initialize`'s own `wizard_parts` doc).
#' @param indicator_group Character. Specifies the indicator group to use (auto, rmncah, vaccine, custom).
#'
#' @return An instance of the `CacheConnection` class.
#'
#' @export
init_CacheConnection <- function(rds_path = NULL, countdown_data = NULL, data_path = NULL, wizard_parts = NULL, indicator_group = c("auto", "rmncah", "vaccine", "custom")) {
  indicator_group <- arg_match(indicator_group)
  cache <- CacheConnection$new(
    rds_path = rds_path,
    countdown_data = countdown_data,
    data_path = data_path,
    wizard_parts = wizard_parts
  )

  if (!is.null(wizard_parts)) {
    # Wizard-in-progress mode: no countdown_data yet, so there's no indicator group to resolve or
    # validate against required columns for -- that happens for real at Finish, inside
    # merge_and_standardize()'s own new_countdown() call.
    return(cache)
  }

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
#' analysis and reporting workflows.
#'
#' **Dependency Architecture:**
#' * **Layer 0 (Core Data):** Raw `countdown_data`, thresholds, external surveys (`un_estimates`).
#' * **Layer 1 (DQA & Adjustments):** Depends on Layer 0. Includes `adjusted_data`, reporting rates, completeness, overall scores.
#' * **Layer 2 (Coverage & Denominators):** Depends on Layer 1. Includes derived coverages at national, admin1, and district levels.
#' * **Layer 3 (Inequality & Health Systems):** Depends on Layer 2 (Coverage). Includes inequalities, mortality ratios, and service utilization summaries.
#'
#' @docType class
#' @name CacheConnection
#' @format An [R6::R6Class] generator object.
#' @keywords internal
CacheConnection <- R6::R6Class(
  "CacheConnection",
  public = list(
    #' @field data_version Defines the current internal data version to handle backward compatibility.
    data_version = '1.0.3',

    #' @description Initialize a CacheConnection instance.
    #' @param rds_path Path to the RDS file to load state from (can be NULL).
    #' @param countdown_data Countdown data of class `cd_data`.
    #' @param data_path Path to the original source file `countdown_data` was
    #'   built from (e.g. the picked `.xlsx`). The cache always lives at
    #'   `<dirname(data_path)>/<stem(data_path)>.rds` -- if that file already
    #'   exists, it's loaded instead of `countdown_data` (the fresh parse is
    #'   discarded); otherwise it's created there. This is the only place
    #'   that decides the cache's location and load-vs-create behavior, so
    #'   every caller gets the same behavior regardless of how they got here.
    #' @param wizard_parts A `load_excel_parts()` result (`list(parts, sheet_names, sheet_ids, ...)`)
    #'   -- a third, mutually-exclusive mode alongside `rds_path`/`countdown_data`, for the Load Data
    #'   wizard's own in-progress state (Phase 3 of the wizard redesign, apps/rmncah): the sheets
    #'   have been read and cleaned but not yet merged/standardized into a real `cd_data` object, so
    #'   there's no `countdown_data` yet -- see `wizard_parts`/`country`/`country_iso`'s own active
    #'   bindings below for how the rest of the class degrades gracefully until `set_countdown_data()`
    #'   is finally called (at Finish, once `merge_and_standardize()` has run).
    initialize = function(rds_path = NULL, countdown_data = NULL, data_path = NULL, wizard_parts = NULL) {
      supplied <- c(rds = !is.null(rds_path), countdown = !is.null(countdown_data), wizard = !is.null(wizard_parts))
      if (sum(supplied) == 0) {
        cd_abort(c("x" = "One of {.arg rds_path}, {.arg countdown_data}, or {.arg wizard_parts} must be provided."))
      }
      if (sum(supplied) > 1) {
        cd_abort(c("x" = "Only one of {.arg rds_path}, {.arg countdown_data}, or {.arg wizard_parts} can have a value."))
      }

      if (!is.null(wizard_parts)) {
        # Wizard-in-progress mode: no cd_data yet, and nothing gets persisted until the wizard's own
        # Finish action explicitly calls set_cache_path() -- see apps/rmncah's upload_box.R for why
        # nothing calls it any earlier than that. Deliberately NOT calling
        # private$initialize_survey_estimates() here (unlike the countdown_data branch below) --
        # country_iso isn't known yet at this point (set_wizard_country() hasn't run), and
        # extract_national_estimates_from_survey() needs it to filter the bundled survey data to the
        # right country; it degrades to a dplyr error on a NULL iso, not a graceful no-op. Called
        # instead from set_wizard_country() itself, once country_iso is actually known.
        private$.in_memory_data <- private$.data_template
        private$.in_memory_data$wizard_parts <- wizard_parts
        private$.in_memory_data$version <- self$data_version
      } else {
        cache_path <- NULL
        if (!is.null(countdown_data) && !is.null(data_path)) {
          cache_path <- file.path(dirname(data_path), paste0(tools::file_path_sans_ext(basename(data_path)), ".rds"))
          if (file.exists(cache_path)) {
            # A cache for this source file already exists -- load it instead
            # of treating the freshly-parsed countdown_data as authoritative.
            rds_path <- cache_path
            countdown_data <- NULL
          }
        }

        if (!is.null(countdown_data)) {
          check_cd_data(countdown_data)
        }

        # Initialize in-memory data using the template
        private$.in_memory_data <- private$.data_template
        private$.in_memory_data$countdown_data <- countdown_data
        private$.in_memory_data$rds_path <- rds_path

        private$.in_memory_data$version <- self$data_version

        if (!is.null(rds_path)) {
          self$load_from_disk()

          loaded_version <- private$.in_memory_data$version
          if (is.null(loaded_version) || loaded_version != self$data_version) {
            # Version is old or missing. Wipe the computed tables!
            private$invalidate_cached_data()

            # Upgrade the version stamp to the current version so it doesn't trigger again
            private$update_field("version", self$data_version)
          }
        } else {
          private$initialize_survey_estimates()
        }

        if (!is.null(countdown_data) && !is.null(cache_path)) {
          tryCatch(
            {
              self$set_cache_path(cache_path)
            },
            error = function(e) {
              error_message <- clean_error_message(e)
              cd_warn(c("!" = error_message))
            }
          )
        }

        if ('instdeliveries' %in% colnames(private$.in_memory_data$countdown_data)) {
          private$invalidate_cached_data()
          private$.in_memory_data$countdown_data <- private$.in_memory_data$countdown_data %>%
            rename(ideliv = any_of('instdeliveries'))

          if (!is.null(private$.in_memory_data$adjusted_data)) {
            private$.in_memory_data$adjusted_data <- private$.in_memory_data$adjusted_data %>%
              rename(ideliv = any_of('instdeliveries'))
          }
        }
      }
    },

    #' @description Load cached data from the designated RDS file on disk.
    load_from_disk = function() {
      check_file_path(private$.in_memory_data$rds_path)
      rds_path <- private$.in_memory_data$rds_path
      loaded_data <- readRDS(rds_path)
      loaded_data$rds_path <- rds_path
      private$.in_memory_data <- loaded_data
      private$.in_memory_data$countdown_data <- private$.in_memory_data$countdown_data %>%
        rename(ideliv = any_of("ideliv"))
    },

    #' @description Save current in-memory state to the assigned RDS file, provided state has changed.
    save_to_disk = function() {
      if (private$.has_changed && !is.null(private$.in_memory_data$rds_path)) {
        
        # 1. Take a shallow copy of the data we want to save (INCLUDING the models)
        data_to_save <- private$.in_memory_data
        
        # 2. THE GHOST ENVIRONMENT TRICK:
        # We temporarily empty the heavy data and Shiny reactives out of the R6 class.
        # When saveRDS explores the Bayesian Models' environments, it will only find 
        # a tiny, empty shell of an R6 class, preventing the gigabytes of recursion!
        cached_memory <- private$.in_memory_data
        cached_reactives <- private$.reactiveDep
        
        private$.in_memory_data <- list()
        private$.reactiveDep <- NULL
        
        tryCatch({
          # 3. Save to disk. This will now be lightning fast and tiny.
          saveRDS(data_to_save, data_to_save$rds_path)
          private$.has_changed <<- FALSE
        }, finally = {
          # 4. Instantly restore the data back to the live R6 class memory!
          # The Shiny app never even notices the data was missing.
          private$.in_memory_data <- cached_memory
          private$.reactiveDep <- cached_reactives
        })
      }
    },

    #' @description Processes raw data into adjusted data using excluded years and k-factors.
    adjust_data = function() {
      self$set_adjusted_flag(FALSE)
      data <- self$data_with_excluded_years %>%
        adjust_service_data(adjustment = "custom", k_factors = self$k_factors)
      self$set_adjusted_data(data)
    },

    # =========================================================================
    # CORE CALCULATION METHODS (Called by Active Bindings)
    # =========================================================================

    #' @description Run indicator coverage calculation using stored models and parameters.
    #' @param admin_level Administrative level ("national", "adminlevel_1", or "district").
    #' @param region Optional region filter.
    #' @param show_district Logical. Whether to show the district column.
    calculate_indicator_coverage = function(admin_level, region = NULL, show_district = TRUE) {
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
        subnational_map = self$survey_mapping,
        region = region,
        show_district = show_district,
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

    #' @description Run inequality calculation using subnational coverage compared to reference data.
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

    #' @description Integrates immunization coverage data from DHIS2, Surveys, and WUENIC.
    #' @param admin_level Administrative level ("national", "adminlevel_1", or "district").
    #' @param region Optional region filter.
    calculate_coverage = function(admin_level, region = NULL) {
      check_required(admin_level)
      if (!self$check_coverage_params) {
        cd_abort(c("x" = "One or more parameters is missing for {.fun calculate_coverage}"))
      }
      survey_data <- if (admin_level == "national") self$national_survey else self$regional_survey

      self$get_base_indicator_coverage(admin_level, region, FALSE) %>%
        calculate_coverage(
          survey_data = survey_data,
          wuenic_data = self$wuenic_estimates,
          subnational_map = self$survey_mapping
        ) %>% 
        mutate(country = self$country, iso = self$country_iso) %>% 
        relocate(country, iso)
    },

    #' @description Generate Continuum of Care Coverage Data summary format.
    #' @param admin_level Character. The geographic level to calculate and shape. 
    #' @param type Character. The type of data to summarise ('maternal' or 'child').
    #' @param region Character. Optional region filter.
    generate_coverage_data = function(admin_level, type, region = NULL) {
      type <- arg_match(type, c('maternal', 'child'))
      denom <- if (type == 'maternal') self$maternal_denominator else self$denominator
      admin_level <- arg_match(admin_level, c('national', 'adminlevel_1'))
      self$calculate_coverage(admin_level, region) %>%
        generate_coverage_data(type = type, denominator = denom)
    },

    #' @description Formats base coverage data with spatial map coordinates for plotting.
    #' @param admin_level Administrative level.
    get_mapping_data = function(admin_level) {
      check_required(admin_level)
      if (!self$check_inequality_params) {
        cd_abort(c("x" = "One or more parameters is missing for {.fun calculate_inequality}"))
      }
      self$indicator_coverage_admin1 %>%
        get_mapping_data(subnational_map = self$map_mapping)
    },

    #' @description Retrieves the mean of institutional livebirths from the national coverage cache.
    lbr_mean = function() {
      indicator <- paste0("cov_instlivebirths_", self$maternal_denominator)
      self$indicator_coverage_national %>%
        select(year, all_of(indicator)) %>%
        summarise(lbr_mean = mean(!!sym(indicator))) %>%
        pull(lbr_mean)
    },

    #' @description Creates mortality completeness ratio summaries.
    #' @param indicator Character. The indicator to generate the summary for.
    summarise_completeness_ratio = function(indicator) {
      self$mortality_ratios %>%
        summarise_completeness_ratio(indicator, self$lbr_mean())
    },

    #' @description Returns the appropriate mortality summary based on the indicator type to plot.
    #' @param indicator Character. Indicator name.
    #' @param map_years Numeric vector. The years to include in a map.
    #' @param palette Character. RColorBrewer sequential palette for the map.
    filter_mortality_summary = function(indicator, map_years = NULL, palette = 'Reds') {
      years <- if (is.null(map_years)) self$mortality_mapping_years else map_years
      self$mortality_summary %>%
        filter_mortality_summary(self$country_iso, indicator, years, self$map_mapping, palette = palette)
    },

    #' @description Computes service utilization for various indicators (OPD/IPD).
    #' @param admin_level The level to aggregate data at ("national", "adminlevel_1").
    compute_service_utilization = function(admin_level) {
      if (is.null(self$adjusted_data)) cd_abort(c("x" = "Adjusted data is required"))
      check_required(admin_level)
      self$adjusted_data %>% compute_service_utilization(admin_level)
    },

    #' @description Filters service utilization data for a specific indicator and region.
    #' @param admin_level Administrative level.
    #' @param indicator Character. Indicator name.
    #' @param region Character. Optional region filter.
    filter_service_utilization = function(admin_level, indicator, region = NULL) {
      if (is.null(self$adjusted_data)) return(NULL)
      service_data <- if (admin_level == 'national') {
        self$service_utilization_national
      } else if (admin_level == 'adminlevel_1') {
        self$service_utilization_admin1
      } else {
        compute_service_utilization(admin_level)
      }
      service_data %>% filter_service_utilization(indicator, region)
    },

    #' @description Prepares service utilization data mapping tables.
    #' @param indicator Character. Indicator name ('ipd', 'opd').
    #' @param map_years Numeric vector. Years to include.
    #' @param palette Character. RColorBrewer sequential palette for the map.
    prepare_mapping_service_utlization = function(indicator, map_years = NULL, palette = 'Purples') {
      indicator <- arg_match(indicator, c('ipd', 'opd'))
      years <- if (is.null(map_years)) self$utilization_mapping_years else map_years
      self$service_utilization_admin1 %>%
        prepare_mapping_service_utlization(indicator, years, self$map_mapping, palette = palette)
    },

    #' @description Resolves the appropriate denominator column string based on the indicator category.
    #' @param indicator Character. The indicator name.
    get_denominator = function(indicator) {
      if (is_maternal_indicator(indicator)) {
        self$maternal_denominator
      } else {
        self$denominator
      }
    },

    #' @description Returns a reactive wrapper for use within Shiny applications.
    reactive = function() {
      if (is.null(private$.reactiveDep)) {
        private$.reactiveDep <- reactiveValues() 
        for (field_name in names(private$.data_template)) {
          private$.reactiveDep[[field_name]] <- 0 
        }
      }
      reactive({
        private$depend_all()
        self
      })
    },

    # =========================================================================
    # SETTERS (Triggering Reactive Cascades)
    # =========================================================================

    #' @description Sets the UI Language.
    #' @param value A two-character language string.
    set_language = function(value) private$setter("language", value, ~ is_scalar_character(.x) && nchar(.x) == 2),

    #' @description Sets the caching RDS path and attempts a save to disk immediately.
    #' @param value Character string representing the file path.
    set_cache_path = function(value) {
      path_set <- private$setter("rds_path", value, ~ !is.null(.x) && length(.x) > 0)
      if (path_set) {
        private$.has_changed <- TRUE
        self$save_to_disk()
        cd_info(c("i" = "Successfully saved to {.val {value}}."))
      }
    },

    #' @description Sets the core unadjusted countdown data. Wipes all derived caches.
    #' @param value A `cd_data` tibble.
    set_countdown_data = function(value) {
      private$setter("countdown_data", value, check_cd_data)
      private$invalidate_cached_data()
    },

    #' @description Sets the Load Data wizard's own in-progress, not-yet-merged sheets
    #'   (`load_excel_parts()`'s result). Called once, right after a fresh Excel/Stata upload, by
    #'   `apps/rmncah`'s own `upload_box.R` -- see `wizard_parts`'s own active-binding comment for
    #'   what this unblocks in the meantime, and `merge_and_standardize()`/Finish for where it's
    #'   cleared.
    #' @param value The list `load_excel_parts()` returns.
    set_wizard_parts = function(value) private$setter("wizard_parts", value, is.list),

    #' @description Clears the wizard's in-progress parts/country state once Finish has actually
    #'   merged them into real `countdown_data` -- called right after `set_countdown_data()` at
    #'   Finish (`wizard_panels.R`). Not just tidiness: `run_all_quality_checks()` branches on
    #'   whether `wizard_parts` is still set, so leaving it behind would keep routing a
    #'   now-fully-merged cache through the pre-merge check path if the wizard's own Data Quality
    #'   step (or edit mode) is ever revisited afterward.
    clear_wizard_parts = function() {
      private$update_field("wizard_parts", NULL)
      private$update_field("wizard_country", NULL)
      private$update_field("wizard_country_iso", NULL)
    },

    #' @description Sets the wizard's best-effort, non-aborting country resolution -- see
    #'   `country`/`country_iso`'s own active-binding comments for why this is separate from the
    #'   real `check_single_country()` validation. Uses `update_field()` directly (not `setter()`,
    #'   which rejects `NULL`) since `value$country`/`value$country_iso` being `NULL` -- an
    #'   ambiguous or unmatched admin sheet -- is itself a legitimate, expected result to store: the
    #'   `country`/`country_iso` bindings need a real `NULL` back, not a stray `NA`, to keep matching
    #'   the `is.null()` convention every other consumer already uses. Also runs
    #'   `initialize_survey_estimates()` once a real `country_iso` is actually known -- the
    #'   `initialize()`-time call the non-wizard branch gets was deliberately skipped for wizard mode
    #'   (see that branch's own comment) precisely because it needed this to have already happened.
    #' @param value A `list(country, country_iso)`, as `resolve_country_best_effort()` returns.
    set_wizard_country = function(value) {
      private$update_field("wizard_country", value$country)
      private$update_field("wizard_country_iso", value$country_iso)
      if (!is.null(value$country_iso)) {
        private$initialize_survey_estimates()
      }
    },

    #' @description Marks this cache's data as having finished the Load Data wizard with its
    #'   quality checks passed -- set once, at Finish, right before `set_cache_path()` writes it to
    #'   disk. See `quality_confirmed`'s own active-binding comment for what reads this.
    #' @param value Logical.
    set_quality_confirmed = function(value) private$setter("quality_confirmed", value, is.logical),

    #' @description A permanent snapshot of `run_all_quality_checks()`'s own result, taken once at
    #'   Finish -- right before `clear_wizard_parts()` (`wizard_panels.R`, apps/rmncah), while
    #'   `wizard_parts` is still set, so this captures the exact pre-merge, per-sheet checks the user
    #'   actually saw during the walkthrough. Exists because `clear_wizard_parts()`'s own removal of
    #'   `wizard_parts` (deliberate -- see its own comment) means `run_all_quality_checks()` would
    #'   otherwise silently fall through to the POST-merge check path (`.run_post_merge_quality_checks()`)
    #'   the moment Data Quality is revisited after Finish (a landing-page Edit link, or edit mode
    #'   generally) -- a genuinely different set of checks, computed against the merged/standardized
    #'   `countdown_data` instead of the original unmerged sheets, that can report different numbers
    #'   than what was shown at upload time. Confirmed live: this is exactly the bug reported as
    #'   "data quality is not giving the actual values given during the uploading". `wizard_parts`
    #'   itself can't just be kept around instead -- it would grow stale the moment anything
    #'   downstream (Remove Years, Data Adjustment) changes `countdown_data`, which this snapshot,
    #'   frozen at the one moment it was genuinely accurate, doesn't have that problem.
    #' @param value The list `run_all_quality_checks()` returns.
    set_wizard_quality_results = function(value) private$setter("wizard_quality_results", value, is.list),

    #' @description Sets custom adjusted data. Wipes downstream coverage/health system metrics.
    #' @param value A `cd_data` tibble.
    set_adjusted_data = function(value) {
      # 1. Save the new data
      private$setter("adjusted_data", value, check_cd_data)
      
      # 2. Update the flag
      self$set_adjusted_flag(TRUE)
      
      # 3. Trigger the master cascade (safely clears coverage, mortality, utilization, etc.)
      private$invalidate_downstream_adjusted()
    },

    #' @description Sets the performance threshold used for DQA score calculations.
    #' @param value Integer scalar (e.g., 90).
    set_performance_threshold = function(value) {
      if (private$setter("performance_threshold", value, is_scalar_integerish)) {
        private$invalidate_dqa_cache()
      }
    },

    #' @description Sets a list of years to manually exclude from modeling.
    #' @param value Numeric vector of years.
    set_excluded_years = function(value) {
      if (private$setter("excluded_years", value, is.numeric)) {
        private$update_field("adjusted_data", NULL)
        private$invalidate_downstream_adjusted()
      }
    },

    #' @description Sets the correction factors for under-reporting.
    #' @param value Named numeric vector of k-factors.
    set_k_factors = function(value) {
      vacc_factors <- c("anc", "idelv", "vacc")
      factors <- if (get_selected_group() == "vaccine") vacc_factors else c(vacc_factors, "opd")

      if (private$setter("k_factors", value, ~ is.numeric(.x) && all(factors %in% names(.x)))) {
        private$update_field("adjusted_data", NULL)
        private$invalidate_downstream_adjusted()
      }
    },

    #' @description Toggles the adjusted flag status.
    #' @param value Logical scalar.
    set_adjusted_flag = function(value) {
      if (private$setter("adjusted_flag", value, ~ is.logical(.x) && length(.x) == 1)) {
        private$invalidate_downstream_adjusted()
      }
    },

    #' @description Manually overrides survey estimates. Clears coverage cache.
    #' @param value Named numeric vector.
    set_survey_estimates = function(value) {
      if (!is.numeric(value)) cd_abort(c("x" = "Survey must be a numeric vector."))
      
      common_factors <- c("anc1", "instlivebirths", "bcg", "penta1", "penta3", "measles1")
      factors <- if (get_selected_group() == "vaccine") {
        c(common_factors, "opv1", "opv3")
      } else {
        c(common_factors, "anc4", "low_bweight", "csection")
      }
      
      if (!all(factors %in% names(value))) {
        missing <- setdiff(factors, names(value))
        cd_warn(c("!" = "Survey values are missing the following {.val {missing}}"))
      }

      new_est <- set_names(rep(NA_real_, length(factors)), factors)
      current_est <- private$.in_memory_data$survey_estimates
      if (!is.null(current_est)) {
        existing_keys <- intersect(names(current_est), factors)
        new_est[existing_keys] <- current_est[existing_keys]
      }
      
      incoming_keys <- intersect(names(value), factors)
      new_est[incoming_keys] <- value[incoming_keys]

      if (private$setter("survey_estimates", new_est, is.numeric)) {
        private$invalidate_coverage_cache()
      }      
    },

    #' @description Sets the base derivation population indicator (e.g. totlivebirths_dhis2).
    #' @param value Character scalar.
    set_derivation_population = function(value) {
      if (private$setter("derivation_population", value, is_scalar_character)) {
        private$invalidate_coverage_cache()
      }
    },

    #' @description Sets list of explicit national estimates (nmr, pnmr, etc.).
    #' @param value Named list.
    set_national_estimates = function(value) {
      if (!is.list(value)) cd_abort(c("x" = "National estimates must be a list."))
      
      current_est <- private$.in_memory_data$national_estimates
      if (is.null(current_est)) {
        current_est <- list(nmr = NA_real_, pnmr = NA_real_, twin_rate = 0.015, preg_loss = 0.03, sbr = NA_real_)
      }

      valid_keys <- intersect(names(value), names(current_est))
      current_est[valid_keys] <- value[valid_keys]

      if (private$setter("national_estimates", current_est, is.list)) {
        private$invalidate_coverage_cache()
      }
    },

    #' @description Set integer year representing the source survey year.
    #' @param value Integer year.
    set_survey_year = function(value) {
      if (private$setter("survey_year", value, is_scalar_integerish)) {
        private$invalidate_denominator_cache()
      }
    },

    #' @description Clears the survey year back to unset. See clear_un_estimates() for why this bypasses the
    #'   public setter -- set_survey_year()'s own validation (is_scalar_integerish) rejects NULL outright, so
    #'   there was no supported way to un-set an already-entered survey year (e.g. the user clearing the
    #'   field by hand) until this.
    clear_survey_year = function() {
      private$update_field("survey_year", NULL)
      private$invalidate_denominator_cache()
    },

    #' @description Set year the survey timeline begins filtering from.
    #' @param value Integer year.
    set_start_survey_year = function(value) private$setter("start_survey_year", value, is_scalar_integerish),

    #' @description Set baseline denominator (e.g. penta1).
    #' @param value Character scalar.
    set_denominator = function(value) {
      if (private$setter("denominator", value, is_scalar_character)) {
        private$invalidate_coverage_cache()
      }
    },

    #' @description Set maternal specific baseline denominator (e.g. anc1).
    #' @param value Character scalar.
    set_maternal_denominator = function(value) {
      if (private$setter("maternal_denominator", value, is_scalar_character)) {
        private$invalidate_coverage_cache()
      }
    },

    #' @description Sets the selected Region for targeted dashboard filtering.
    #' @param value Character scalar.
    set_selected_admin_level_1 = function(value) private$setter("selected_admin_level_1", value, is_scalar_character),

    #' @description Sets the selected District for targeted dashboard filtering.
    #' @param value Character scalar.
    set_selected_district = function(value) private$setter("selected_district", value, is_scalar_character),

    #' @description Sets mapping years for generic plots.
    #' @param value Integer vector.
    set_mapping_years = function(value) private$setter("selected_mapping_years", value, is.numeric),

    #' @description Stores what the user changed about how one chart (or, with `id = "default"`, every chart of this dataset)
    #'   looks: text, legend, fonts, sizes. See [cd_chart_options()]. Saved with the dataset, so it survives reloads.
    #' @param id Character. A chart id, by convention `"<page>/<chart>"` (e.g. `"national_coverage/anc4"`), or `"default"`
    #'   for settings that apply to every chart (a font, a text scale).
    #' @param options A [cd_chart_options()] object (or a list of its fields). `NULL` removes what is stored for `id`.
    #' @return Invisibly, TRUE when something changed.
    set_chart_options = function(id, options) {
      if (!is_scalar_character(id) || !nzchar(id)) cd_abort(c("x" = "{.arg id} must be a single non-empty string."))
      stored <- private$.in_memory_data[["chart_options"]] %||% list()
      stored[[id]] <- if (is.null(options)) NULL else as_chart_options(options)
      invisible(private$setter("chart_options", stored, is.list))
    },

    #' @description Saves a report built in the report builder (see [export_report()]), or removes it.
    #' @param id Character. The report's id.
    #' @param project A list: `name`, `design` and `blocks` (see [report_presets()]), or `NULL` to remove the report.
    set_report_project = function(id, project) {
      if (!is_scalar_character(id) || !nzchar(id)) cd_abort(c("x" = "{.arg id} must be a single non-empty string."))
      if (!is.null(project) && !is.list(project)) cd_abort(c("x" = "{.arg project} must be a list or NULL."))
      stored <- private$.in_memory_data[["report_projects"]] %||% list()
      stored[[id]] <- project
      invisible(private$setter("report_projects", stored, is.list))
    },

    #' @description Saves a picture used by the reports (a block's `src` is then `"asset:<id>"`), or removes it. Pictures
    #'   are kept once in the dataset rather than inside each report; the Word file and the PDF embed their own copy.
    #' @param id Character. The picture's id.
    #' @param asset A list: `type` (a MIME type such as `"image/png"`) and `data` (a raw vector), or `NULL` to remove it.
    set_report_asset = function(id, asset) {
      if (!is_scalar_character(id) || !nzchar(id)) cd_abort(c("x" = "{.arg id} must be a single non-empty string."))
      if (!is.null(asset) && !(is.list(asset) && is.raw(asset$data) && is_scalar_character(asset$type))) {
        cd_abort(c("x" = "{.arg asset} must be a list with {.field type} (character) and {.field data} (raw), or NULL."))
      }
      stored <- private$.in_memory_data[["report_assets"]] %||% list()
      stored[[id]] <- asset
      invisible(private$setter("report_assets", stored, is.list))
    },

    #' @description Saves a theme made from an Office file (see [report_theme_from_file()]), or removes it. Its template
    #'   (the file itself) is kept as a report asset, `theme$template` being `"asset:<id>"`.
    #' @param id Character. The theme's id.
    #' @param theme A theme list, or `NULL` to remove it.
    set_report_theme = function(id, theme) {
      if (!is_scalar_character(id) || !nzchar(id)) cd_abort(c("x" = "{.arg id} must be a single non-empty string."))
      if (!is.null(theme) && !is.list(theme)) cd_abort(c("x" = "{.arg theme} must be a list, or NULL."))
      stored <- private$.in_memory_data[["report_themes"]] %||% list()
      stored[[id]] <- theme
      invisible(private$setter("report_themes", stored, is.list))
    },

    #' @description The chart options that apply to one chart: the dataset's `"default"` options with the chart's own on top.
    #' @param id Character. A chart id (see `set_chart_options()`), or `NULL` for the defaults alone.
    #' @return A [cd_chart_options()] object (empty when nothing is stored).
    get_chart_options = function(id = NULL) {
      stored <- self$chart_options
      merge_chart_options(stored[["default"]], if (!is.null(id) && !identical(id, "default")) stored[[id]])
    },

    #' @description Forgets stored chart options.
    #' @param id Character. The chart id to reset, or `NULL` to reset every chart and the defaults.
    #' @return Invisibly, TRUE when something changed.
    reset_chart_options = function(id = NULL) {
      if (is.null(id)) return(invisible(private$setter("chart_options", list(), is.list)))
      self$set_chart_options(id, NULL)
    },

    #' @description Sets mapping years explicitly for mortality dashboards.
    #' @param value Integer vector.
    set_mortality_mapping_years = function(value) private$setter("selected_mortality_mapping_years", value, is.numeric),

    #' @description Sets mapping years explicitly for utilization dashboards.
    #' @param value Integer vector.
    set_utilization_mapping_years = function(value) private$setter("selected_utilization_mapping_years", value, is.numeric),

    #' @description Sets the Family Planning Estimation Tool (FPET) dataset.
    #' @param value Data frame.
    set_fpet_data = function(value) private$setter("fpet_data", value, check_fpet_data),

    #' @description Sets the official UN Demographic Estimates dataset. Clears denominators.
    #' @param value Data frame.
    set_un_estimates = function(value) {
      if (private$setter("un_estimates", value, check_un_estimates_data)) {
        private$invalidate_denominator_cache()
        private$invalidate_coverage_cache()
      }
    },

    #' @description Clears any uploaded UN Demographic Estimates override, reverting the un_estimates active
    #'   binding to the package's own built-in default for the current country (its own %||% fallback). The
    #'   public setter validates its input and rejects NULL outright, so this bypasses it via update_field()
    #'   directly, the same way invalidate_cached_data() already resets other fields to NULL internally -- there
    #'   was no supported way to undo an override before this.
    clear_un_estimates = function() {
      private$update_field("un_estimates", NULL)
      private$invalidate_denominator_cache()
      private$invalidate_coverage_cache()
    },

    #' @description Sets the UN Mortality specific estimates dataset. Clears mortality cache.
    #' @param value Data frame.
    set_un_mortality_estimates = function(value) {
      if (private$setter("un_mortality_estimates", value, check_un_mortality_data)) {
        private$invalidate_mortality_cache()
      }
    },

    #' @description Clears any uploaded UN Mortality Estimates override, reverting to the package's built-in
    #'   default for the current country. See clear_un_estimates() for why this bypasses the public setter.
    clear_un_mortality_estimates = function() {
      private$update_field("un_mortality_estimates", NULL)
      private$invalidate_mortality_cache()
    },

    #' @description Sets WUENIC estimates dataset. Clears coverage cache.
    #' @param value Data frame.
    set_wuenic_estimates = function(value) {
      if (private$setter("wuenic_estimates", value, check_wuenic_data)) {
        private$invalidate_coverage_cache()
      }
    },

    #' @description Clears any uploaded WUENIC Estimates override, reverting to the package's built-in default
    #'   for the current country. See clear_un_estimates() for why this bypasses the public setter.
    clear_wuenic_estimates = function() {
      private$update_field("wuenic_estimates", NULL)
      private$invalidate_coverage_cache()
    },

    #' @description Sets overall national survey dataset and automatically extracts its estimates.
    #' @param value Data frame.
    set_national_survey = function(value) {
      private$setter("national_survey", value, check_survey_data)
      private$extract_national_estimates_from_survey(private$.in_memory_data$national_survey)
    },

    #' @description Clears an uploaded national survey override, reverting to the package's own
    #'   built-in default. See clear_un_estimates() for why this bypasses the public setter -- unlike
    #'   that one, this deliberately does NOT re-run extract_national_estimates_from_survey(): any
    #'   national rate fields it already filled in are their own, separately edited values now, the
    #'   same way clearing un_estimates never un-does anything it once fed into a downstream
    #'   calculation either.
    clear_national_survey = function() private$update_field("national_survey", NULL),

    #' @description Sets the disaggregated regional survey dataset.
    #' @param value Data frame.
    set_regional_survey = function(value) {
      if (private$setter("regional_survey", value, ~ check_survey_data(.x, "adminlevel_1"))) {
        private$invalidate_coverage_cache()
      }
    },

    #' @description Clears an uploaded regional survey override, reverting to the package's own
    #'   built-in default. See clear_un_estimates() for why this bypasses the public setter.
    clear_regional_survey = function() {
      private$update_field("regional_survey", NULL)
      private$invalidate_coverage_cache()
    },

    #' @description Sets a user-uploaded shapefile override, replacing the package-bundled default
    #'   for the current country -- see `shapefile`'s own active-binding comment for the
    #'   override-with-fallback pattern this mirrors (`regional_survey`, above).
    #' @param value An `sf` object (as `read_shapefile_folder()` returns).
    set_shapefile = function(value) private$setter("shapefile", value, ~ inherits(.x, "sf")),

    #' @description Clears an uploaded shapefile override, reverting to the package's built-in
    #'   default for the current country.
    clear_shapefile = function() private$update_field("shapefile", NULL),

    #' @description Sets which column of the uploaded shapefile holds admin-1 names -- a real
    #'   uploaded shapefile won't necessarily use the bundled shapefile's own `NAME_1` convention, so
    #'   `check_shapefile_admin_names()` needs to be told which one to use.
    #' @param value Character. A column name present in `self$shapefile`.
    set_shapefile_name_field = function(value) private$setter("shapefile_name_field", value, is_scalar_character),

    #' @description Sets wealth quantile (WIQ) survey dataset.
    #' @param value Data frame.
    set_wiq_survey = function(value) private$setter("wiq_survey", value, check_equity_data),

    #' @description Clears an uploaded WIQ survey override, reverting to the package's own built-in
    #'   default (or NULL, for a country with no bundled equity default -- see the `wiq_survey` active
    #'   binding). See clear_un_estimates() for why this bypasses the public setter.
    clear_wiq_survey = function() private$update_field("wiq_survey", NULL),

    #' @description Sets area level (urban/rural) survey dataset.
    #' @param value Data frame.
    set_area_survey = function(value) private$setter("area_survey", value, check_equity_data),

    #' @description Clears an uploaded area survey override, reverting to the package's own built-in
    #'   default. See clear_un_estimates() for why this bypasses the public setter.
    clear_area_survey = function() private$update_field("area_survey", NULL),

    #' @description Sets education level survey dataset.
    #' @param value Data frame.
    set_education_survey = function(value) private$setter("education_survey", value, check_equity_data),

    #' @description Clears an uploaded education survey override, reverting to the package's own
    #'   built-in default. See clear_un_estimates() for why this bypasses the public setter.
    clear_education_survey = function() private$update_field("education_survey", NULL),

    #' @description Sets survey to countdown nomenclature mapping matrix.
    #' @param value Data frame.
    set_survey_mapping = function(value) {
      private$setter("survey_mapping", value, is.data.frame)
      private$invalidate_coverage_cache()
    },

    #' @description Clears the survey region mapping back to "unmapped" -- unlike un_estimates/
    #'   un_mortality_estimates/wuenic_estimates, this field has no package-bundled default to fall back to, so
    #'   clearing it just means "ask the user to map again," not "use the built-in data."
    clear_survey_mapping = function() {
      private$update_field("survey_mapping", NULL)
      private$invalidate_coverage_cache()
    },

    #' @description Sets map coordinates to countdown nomenclature mapping matrix.
    #' @param value Data frame.
    set_map_mapping = function(value) private$setter("map_mapping", value, is.data.frame),

    #' @description Clears the map region mapping back to "unmapped" -- see clear_survey_mapping(), same
    #'   reasoning (no package-bundled default for this field either).
    clear_map_mapping = function() {
      private$update_field("map_mapping", NULL)
    },

    #' @description Checks whether a data field is still at its built-in default -- i.e. the user has not
    #'   uploaded an override (un_estimates/un_mortality_estimates/wuenic_estimates, each with a real
    #'   package-bundled fallback) or made a mapping (survey_mapping/map_mapping, which have no default at all,
    #'   so this is equivalent there to asking whether anything has been set). There was previously no way to
    #'   ask this at all: the active bindings for the first three never return NULL once a country is set (they
    #'   fall back to the bundled dataset instead), so app-layer code checking `is.null(cache$un_estimates)` to
    #'   mean "nothing uploaded yet" was always structurally wrong -- this checks the underlying stored value
    #'   directly, before any fallback is applied.
    #' @param field_name Character. The field to check (e.g. "un_estimates", "survey_mapping").
    #' @return Logical. TRUE if nothing has been set for this field (so it's showing the built-in default, or
    #'   is simply empty for a field with no default).
    is_default = function(field_name) {
      is.null(private$getter(field_name))
    },

    #' @description Set sector national estimates mapping.
    #' @param value Data frame.
    set_sector_national_estimates = function(value) private$setter("sector_national_estimates", value, is.data.frame),

    #' @description Set sector area estimates mapping.
    #' @param value Data frame.
    set_sector_area_estimates = function(value) private$setter("sector_area_estimates", value, is.data.frame),

    #' @description Set c-section national estimates mapping.
    #' @param value Data frame.
    set_csection_national_estimates = function(value) private$setter("csection_national_estimates", value, is.data.frame),

    #' @description Set c-section area estimates mapping.
    #' @param value Data frame.
    set_csection_area_estimates = function(value) private$setter("csection_area_estimates", value, is.data.frame),

    # =========================================================================
    # DQA & AGGREGATION WRAPPERS
    # =========================================================================

    #' @description Wrapper to calculate average reporting rates from raw countdown data.
    #' @param admin_level Administrative level ("national", "adminlevel_1", "district").
    #' @param region Optional region filter.
    calculate_reporting_rate = function(admin_level, region = NULL) {
      calculate_average_reporting_rate(.data = self$countdown_data, admin_level = admin_level, region = region)
    },
    
    #' @description Wrapper to calculate proportion of districts meeting reporting thresholds.
    #' @param region Optional region filter.
    calculate_district_reporting_rate = function(region = NULL) {
      calculate_district_reporting_rate(.data = self$countdown_data, threshold = self$performance_threshold, region = region)
    },
    
    #' @description Wrapper to calculate completeness proportions from raw countdown data.
    #' @param admin_level Administrative level.
    #' @param region Optional region filter.
    calculate_completeness_summary = function(admin_level, region = NULL) {
      calculate_completeness_summary(.data = self$countdown_data, admin_level = admin_level, threshold = self$performance_threshold, region = region)
    },

    #' @description Wrapper to calculate district level completeness details.
    #' @param region Optional region filter.
    calculate_district_completeness_summary = function(region = NULL) {
      calculate_district_completeness_summary(.data = self$countdown_data, region = region)
    },

    #' @description Locates missing/non-reporting facility units.
    #' @param indicator Target indicator name.
    #' @param region Optional region filter.
    list_missing_units = function(indicator, region = NULL) {
      list_missing_units(.data = self$countdown_data, indicator = indicator, region = region)
    },

    #' @description Identifies severe outliers across administrative levels using Hampel method.
    #' @param admin_level Administrative level.
    #' @param region Optional region filter.
    calculate_outliers_summary = function(admin_level, region = NULL) {
      calculate_outliers_summary(.data = self$countdown_data, admin_level = admin_level, region = region)
    },

    #' @description Flags percentage of districts with acceptable outlier variances.
    #' @param region Optional region filter.
    calculate_district_outlier_summary = function(region = NULL) {
      calculate_district_outlier_summary(.data = self$countdown_data, region = region)
    },

    #' @description Calculates adequacy ratios across chronological indicator sequences (e.g. Penta1 to Penta3).
    #' @param region Optional region filter.
    calculate_ratios_and_adequacy = function(region = NULL) {
      calculate_ratios_and_adequacy(.data = self$countdown_data, region = region)
    },

    # =========================================================================
    # PHASE 2 DATA QUALITY WRAPPERS (informational -- see R/0_data_quality_checks.R)
    # =========================================================================

    #' @description Flags district-years where a service indicator looks mixed up with population data.
    check_population_service_collision = function() {
      check_population_service_collision(.data = self$countdown_data)
    },

    #' @description Flags indicators that are entirely empty across the whole dataset.
    check_indicator_emptiness = function() {
      check_indicator_emptiness(.data = self$countdown_data)
    },

    #' @description Matches survey `adminlevel_1` names against the dataset's own admin-1 names,
    #'   skipping names already resolved via `survey_mapping`.
    check_survey_admin_names = function() {
      survey <- self$regional_survey
      if (!is.null(survey) && !isTRUE(self$is_default("survey_mapping"))) {
        mapped <- self$survey_mapping$adminlevel_1
        survey <- survey[!survey$adminlevel_1 %in% mapped, , drop = FALSE]
      }
      # self$subnational_regions, not self$countdown_data directly -- it already has the
      # `adminlevel_1` column either way, and (Phase 3 of the wizard redesign) falls back to the raw
      # Admin sheet pre-Finish, when there's no countdown_data yet at all.
      check_survey_admin_names(regional_survey = survey, countdown_data = self$subnational_regions)
    },

    #' @description Matches the shapefile's own admin-1 name column (`self$shapefile_name_field` --
    #'   `self$shapefile`'s uploaded override if one exists, otherwise the bundled default) against
    #'   the dataset's own admin-1 names, skipping names already resolved via `map_mapping`.
    check_shapefile_admin_names = function() {
      shapefile <- self$shapefile
      name_field <- self$shapefile_name_field
      if (!is.null(shapefile) && !isTRUE(self$is_default("map_mapping"))) {
        mapped <- self$map_mapping[[name_field]]
        shapefile <- shapefile[!shapefile[[name_field]] %in% mapped, , drop = FALSE]
      }
      check_shapefile_admin_names(shapefile = shapefile, countdown_data = self$subnational_regions, name_field = name_field)
    },

    #' @description Calculates the aggregate DQA overall score assessing reporting, completeness, and outliers.
    #' @param admin_level Administrative level ("national" or "adminlevel_1").
    #' @param region Optional region name (required if admin_level is "adminlevel_1").
    #' @param labels Optional custom display labels.
    calculate_overall_score = function(admin_level = c("national", "adminlevel_1"), region = NULL, labels = NULL) {
      admin_level <- arg_match(admin_level)
      if (admin_level == "adminlevel_1" && is.null(region)) cd_abort(c("x" = "{.arg region} must be provided for adminlevel_1"))
      if (admin_level == "national" && !is.null(region)) cd_abort(c("x" = "{.arg region} must be null for national admin_level"))

      if (admin_level == "national") {
        calculate_overall_score1(
          average_reporting_rate    = self$reporting_rate_national,
          district_reporting_rate   = self$district_reporting_rate,
          district_completeness     = self$district_completeness,
          outliers_summary          = self$outliers_national,
          district_outliers_summary = self$district_outliers_summary,
          ratios_summary            = self$adequacy_ratios,
          labels                    = labels,
          threshold                 = self$performance_threshold
        )
      } else {
        avg_rr <- self$reporting_rate_admin1 %>% filter(adminlevel_1 == region)
        out_sum <- self$outliers_admin1 %>% filter(adminlevel_1 == region)
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
          labels                    = labels,
          threshold                 = self$performance_threshold
        )
      }
    },

    #' @description Calculates Service DQA Summary comparing general reporting vs specific utilization metrics.
    #' @param admin_level Administrative level ("national" or "adminlevel_1").
    #' @param region Optional region name (required if admin_level is "adminlevel_1").
    #' @param labels Optional custom labels.
    calculate_service_dqa_summary = function(admin_level = c("national", "adminlevel_1"), region = NULL, labels = NULL) {
      admin_level <- arg_match(admin_level)
      if (admin_level == "adminlevel_1" && is.null(region)) cd_abort(c("x" = "{.arg region} must be provided for adminlevel_1"))
      if (admin_level == "national" && !is.null(region)) cd_abort(c("x" = "{.arg region} must be null for national admin_level"))

      if (admin_level == "national") {
        generate_service_dqa_summary(
          average_reporting_rate    = self$reporting_rate_national,
          district_reporting_rate   = self$district_reporting_rate,
          completeness_national     = self$completeness_national,
          district_completeness     = self$district_completeness,
          outliers_summary          = self$outliers_national,
          district_outliers_summary = self$district_outliers_summary,
          service_utilization       = self$service_utilization_national,
          threshold                 = self$performance_threshold,
          labels                    = labels
        )
      } else {
        avg_rr <- self$reporting_rate_admin1 %>% filter(adminlevel_1 == region)
        comp_sum <- self$completeness_admin1 %>% filter(adminlevel_1 == region)
        out_sum <- self$outliers_admin1 %>% filter(adminlevel_1 == region)
        dst_rr   <- self$calculate_district_reporting_rate(region)
        dst_comp <- self$calculate_district_completeness_summary(region)
        dst_out  <- self$calculate_district_outlier_summary(region)
        srv_util <- self$service_utilization_admin1 %>% filter(adminlevel_1 == region)

        generate_service_dqa_summary(
          average_reporting_rate    = avg_rr,
          district_reporting_rate   = dst_rr,
          completeness_national     = comp_sum,
          district_completeness     = dst_comp,
          outliers_summary          = out_sum,
          district_outliers_summary = dst_out,
          service_utilization       = srv_util,
          threshold                 = self$performance_threshold,
          labels                    = labels
        )
      }
    },

    #' @description Generates Service Utilization Admin 1 Data mapping format.
    #' @param metric_type Character. Either "opd" or "ipd".
    #' @return A tibble with class `cd_service_util_admin1`.
    generate_admin1_service_utilization = function(metric_type = c("opd", "ipd")) {
      metric_type <- arg_match(metric_type)
      self$service_utilization_admin1 %>% generate_admin1_service_utilization(metric_type)
    },

    #' @description Formats Maternal Child Health vs Curative Index data for plotting.
    generate_admin1_mch_curative_index = function() {
      self$service_utilization_admin1 %>% generate_admin1_mch_curative_index()
    },

    #' @description Gets filtered coverage data isolating a specific indicator for charts.
    #' @param indicator Character. The target health indicator.
    #' @param admin_level Character. Level of aggregation.
    #' @param region Character. Optional region or district name.
    get_filtered_coverage = function(indicator, admin_level, region = NULL) {
      indicator <- arg_match(indicator, get_analysis_indicators())
      admin_level <- arg_match(admin_level, c("national", "adminlevel_1", "district"))
      if (!self$check_coverage_params) cd_abort(c("x" = "One or more parameters is missing for {.fun get_filtered_coverage}"))

      denom <- self$get_denominator(indicator)
      self$calculate_coverage(admin_level) %>%
        filter_coverage(indicator = indicator, denominator = denom, region = region)
    },

    #' @description Gets filtered inequality data targeting a single indicator.
    #' @param indicator Character. The target health indicator.
    #' @param admin_level Character. Level of aggregation.
    #' @param region Character. Optional region filter.
    get_filtered_inequality = function(indicator, admin_level, region = NULL) {
      indicator <- arg_match(indicator, get_analysis_indicators())
      admin_level <- arg_match(admin_level, c("adminlevel_1", "district"))

      if (!self$check_inequality_params) cd_abort(c("x" = "One or more parameters is missing for {.fun get_filtered_inequality}"))
      if (admin_level != 'adminlevel_1' && !is.null(region)) cd_abort(c("x" = "{.arg region} should only be used in {.val adminlevel_1}"))

      denom <- self$get_denominator(indicator)
      if (is.null(denom)) cd_abort(c("x" = "The denominator for indicator '{indicator}' is NULL in the cache state."))

      ineq_data <- if (admin_level == "adminlevel_1" && is.null(region)) self$inequality_admin1 else self$inequality_district
      if (!is.null(region)) ineq_data <- ineq_data %>% filter(adminlevel_1 == region)
      
      ineq_data %>% filter_inequality(indicator = indicator, denominator = denom)
    },

    #' @description Filters mapping spatial data focusing on a specific year and palette.
    #' @param indicator Character. The target health indicator.
    #' @param admin_level Character. Level of aggregation.
    #' @param palette Character. Color palette for mapping.
    #' @param plot_year Integer. Year to plot.
    get_filtered_mapping_data = function(indicator, admin_level, palette, plot_year = NULL) {
      indicator <- arg_match(indicator, get_analysis_indicators())
      admin_level <- arg_match(admin_level, c("adminlevel_1", "district"))
      check_required(palette)

      if (!self$check_inequality_params) cd_abort(c("x" = "One or more parameters is missing for {.fun get_filtered_mapping_data}"))
      denom <- self$get_denominator(indicator)
      if (is.null(denom)) cd_abort(c("x" = "The denominator for indicator '{indicator}' is NULL in the cache state."))

      years_to_plot <- plot_year %||% self$mapping_years
      map_data <- self$get_mapping_data(admin_level)
      map_data %>% filter_mapping_data(indicator = indicator, denominator = denom, palette = palette, plot_year = years_to_plot)
    },

    #' @description Returns the base denominator and numerator metrics before survey interpolation.
    #' @param admin_level Character. Level of aggregation.
    #' @param region Character. Optional region filter.
    #' @param show_district Optional. Whether to show the district column.
    get_base_indicator_coverage = function(admin_level, region = NULL, show_district = TRUE) {
      admin_level <- arg_match(admin_level, c("national", "adminlevel_1", "district"))
      if (!self$check_inequality_params) cd_abort(c("x" = "One or more parameters is missing for {.fun get_base_indicator_coverage}"))

      data <- if (admin_level == "national" && is.null(region)) {
        self$indicator_coverage_national
      } else if (admin_level == "adminlevel_1" && is.null(region)) {
        self$indicator_coverage_admin1
      } else if (admin_level == "district"  && is.null(region)) {
        self$indicator_coverage_district
      } else {
        self$calculate_indicator_coverage(admin_level, region, show_district)
      }
      data
    },

    #' @description Evaluates indicator data against set threshold benchmarks (e.g. 80% coverage).
    #' @param indicator Character. The target health indicator group.
    #' @param target_unit Character. Evaluated level ("district" or "adminlevel_1").
    #' @param region Character. Optional region filter.
    get_filtered_threshold = function(indicator, target_unit, region = NULL) {
      indicator <- arg_match(indicator, c('anc4', 'instlivebirths', 'vaccine', 'dropout'))
      target_unit <- arg_match(target_unit, c("district", "adminlevel_1"))

      if (!is.null(region) && target_unit != "district") {
        cd_abort(c("x" = "Invalid threshold evaluation request.", "i" = "At the regional level (when region is provided), you can only check the proportion of 'district'."))
      }
      if (!self$check_inequality_params) cd_abort(c("x" = "One or more parameters is missing for {.fun get_filtered_threshold}"))

      query_admin_level <- if (!is.null(region)) "adminlevel_1" else target_unit
      show_districts_flag <- (target_unit == "district")

      cov_data <- self$get_base_indicator_coverage(admin_level = query_admin_level, region = region, show_district = show_districts_flag)
      denom <- self$get_denominator(indicator)
      if (is.null(denom)) cd_abort(c("x" = "The denominator for indicator '{indicator}' is NULL in the cache state."))

      cov_data %>% calculate_threshold(indicator = indicator, denominator = denom)
    },

    #' @description Derives specific complex coverage indicators based on basic survey data.
    #' @param indicator Character. The target health indicator.
    #' @param admin_level Character. Administrative level.
    #' @param region Character. Optional region name.
    calculate_derived_coverage = function(indicator, admin_level, region = NULL) {
      indicator <- arg_match(indicator, get_analysis_indicators())
      admin_level <- arg_match(admin_level, c("national", "adminlevel_1", "district"))
      self$calculate_coverage(admin_level) %>% calculate_derived_coverage(indicator)
    },

    #' @description Identifies regions/districts that exceed benchmark coverage thresholds.
    #' @param indicator Character. The target health indicator.
    #' @param admin_level Character. Level of aggregation.
    #' @param region Character. Optional region filter.
    get_high_performers = function(indicator, admin_level, region = NULL) {
      indicator <- arg_match(indicator, get_analysis_indicators())
      admin_level <- arg_match(admin_level, c("national", "adminlevel_1", "district"))

      if (!self$check_inequality_params) cd_abort(c("x" = "One or more parameters is missing for {.fun get_high_performers}"))
      cov_data <- self$get_base_indicator_coverage(admin_level, region)
      denom <- self$get_denominator(indicator)
      if (is.null(denom)) cd_abort(c("x" = "The denominator for indicator '{indicator}' is NULL in the cache state."))

      threshold <- case_when(
        indicator %in% list_vaccine_indicators() & admin_level == "national" ~ 90,
        indicator %in% list_vaccine_indicators() & admin_level != "national" ~ 80,
        indicator == "anc4" ~ 70,
        indicator == "instlivebirths" ~ 80,
        str_detect(indicator, "dropout") ~ 10,
        .default = 80
      )

      cov_data %>% filter_high_performers(indicator = indicator, denominator = denom, threshold = threshold)
    },

    #' @description Substitutes national rates with regional estimates for a specific requested sub-region.
    #' @param admin_level Character. Level of aggregation.
    #' @param region Character. Region name.
    get_regional_estimates = function(admin_level, region) {
      iso <- self$country_iso
      rates <- self$national_estimates

      if (is.null(region)) return(rates)

      target_admin1 <- region
      if (admin_level == "district") {
        target_admin1 <- self$subnational_regions %>%
          filter(district == region) %>%
          distinct(adminlevel_1) %>%
          pull(adminlevel_1)
        if (is.null(target_admin1) || is.na(target_admin1)) return(rates)
      }

      parsed <- parse_estimates_from_df(reg_data, self$country_iso, target_admin1)
      if (is.null(parsed)) return(rates)
      
      vals <- parsed$values
      
      needs_conversion <- !names(vals) %in% c('nmr', 'pnmr', 'sbr') & vals > 1
      vals[needs_conversion] <- vals[needs_conversion] / 100
      rates[names(vals)] <- vals
      
      return(rates)
    },

    #' @description Generates a formatted table of core health system metrics.
    #' @param labels Character. Optional custom labels to use on the table headers.
    generate_health_system_table = function(labels = NULL) {
      self$health_system_metrics_national %>% generate_health_system_table(labels)
    },

    #' @description Prepares scatter plot data comparing Primary Health Care performance.
    #' @param indicator Character. The independent variable to plot ("ratio_fac_pop" or "ratio_hstaff_pop").
    generate_phc_scatter_data = function(indicator) {
      indicator <- arg_match(indicator, c("ratio_fac_pop", "ratio_hstaff_pop"))
      self$health_system_metrics_admin1 %>% generate_phc_scatter_data(x_indicator = indicator)
    },

    #' @description Extracts private versus public sector ownership distributions.
    #' @param legend_labels Named list. Optional list to override default labels for Private, NGO, and Public.
    generate_private_sector_data = function(legend_labels = NULL) {
      self$health_system_metrics_admin1 %>% generate_private_sector_data(legend_labels = legend_labels)
    },

    #' @description Generates or retrieves a pre-calculated Bayesian mathematical model for an indicator.
    #' @param admin_level Administrative level ("national", "adminlevel_1").
    #' @param indicator Character. Indicator name (e.g., 'penta3').
    get_bayes_model = function(admin_level, indicator) {
      admin_level <- arg_match(admin_level, c('national', 'adminlevel_1'))
      indicator <- arg_match(indicator, c('anc4', 'anc_1trimester', 'ideliv', 'measles1', 'penta3'))

      denominator <- self$get_denominator(indicator)
      key <- paste(admin_level, indicator, denominator, sep = "_")
      
      models_list <- private$getter("bayesian_models")
      if (is.null(models_list)) models_list <- list()
      
      if (is.null(models_list[[key]])) {
        cov_data <- self$calculate_coverage(admin_level)
        new_model <- generate_bayes_model(
          coverage_data = cov_data,
          overall_score = self$overall_score,
          indicator = indicator,
          denominator = denominator
        )
        models_list[[key]] <- new_model
        private$update_field("bayesian_models", models_list)
      }
      return(models_list[[key]])
    }
  ),

  # =========================================================================
  # ACTIVE BINDINGS (Cached Property Accessors)
  # =========================================================================
  active = list(
    #' @field language Active Binding: Gets the UI language.
    language = function(value) private$getter("language", value),

    #' @field cache_path Active Binding: Gets the physical disk path for the `.rds` cache.
    cache_path = function(value) private$getter("rds_path", value),

    #' @field countdown_data Active Binding: Gets the raw, unadjusted countdown tibble.
    countdown_data = function(value) private$getter("countdown_data", value),

    #' @field data_years Active Binding: Extracts unique years present in the raw data. Before
    #'   Finish (`wizard_parts` still set, no `countdown_data` yet), falls back to the raw Population
    #'   sheet's own `year` column -- confirmed live this matters: several other page modules read
    #'   `cache()$data_years` unconditionally the moment `cache()` itself becomes non-NULL (e.g.
    #'   `modules/1b_remove_years.R`'s own `req(cache()$data_years)`), and those page modules are
    #'   instantiated at app startup the same "always running" way the wizard's own step servers are
    #'   -- reachable well before Finish, not just after.
    data_years = function(value) {
      years <- private$getter("data_years", value)
      if (is.null(years) && !is.null(self$countdown_data)) {
        years <- self$countdown_data %>% distinct(year) %>% arrange(year) %>% pull(year)
        private$update_field("data_years", years)
      } else if (is.null(years) && !is.null(self$wizard_parts)) {
        wp <- self$wizard_parts
        population_data <- wp$parts[[wp$population_sheet_name]]
        if (!is.null(population_data) && "year" %in% colnames(population_data)) {
          years <- population_data %>% distinct(year) %>% arrange(year) %>% pull(year)
        }
      }
      return(years)
    },

    #' @field subnational_regions Active Binding: Extracts unique admin1 and district combinations.
    #'   Before Finish (`wizard_parts` still set, no `countdown_data` yet), falls back to the raw
    #'   Admin sheet's own `first_admin_level`/`district` columns -- this is what lets Map
    #'   Survey/Map Shapefile show the real admin1 list mid-wizard, per the wizard redesign's own
    #'   requirement that mapping happens "against the admin1 from admin sheet."
    subnational_regions = function(value) {
      regions <- private$getter("subnational_regions", value)
      if (is.null(regions) && !is.null(self$countdown_data)) {
        regions <- self$countdown_data %>% distinct(adminlevel_1, district) %>% arrange(adminlevel_1, district)
        private$update_field("subnational_regions", regions)
      } else if (is.null(regions) && !is.null(self$wizard_parts)) {
        wp <- self$wizard_parts
        admin_data <- wp$parts[[wp$admin_sheet_name]]
        if (all(c("first_admin_level", "district") %in% colnames(admin_data))) {
          regions <- admin_data %>%
            distinct(adminlevel_1 = first_admin_level, district) %>%
            arrange(adminlevel_1, district)
        }
      }
      return(regions)
    },

    #' @field country Active Binding: Gets the text string representing the focal country. Readonly.
    #'   Before Finish, falls back to `wizard_country` -- a best-effort, non-aborting resolution
    #'   (`resolve_country_best_effort()`, 0_import_load_data.R) computed right after upload, since
    #'   the real, validated `country` attribute only exists once `merge_and_standardize()`'s
    #'   `match_country()` call has actually run. The genuine validation (is there cleanly one
    #'   country value at all) stays `check_single_country()`'s job, surfaced at the Data Quality
    #'   step -- this fallback's only job is unblocking everything else that needs a country before
    #'   Finish (the header badge, national-rate/survey defaults, the bundled shapefile lookup).
    country = function(value) {
      if (missing(value)) {
        if (!is.null(self$countdown_data)) return(attr_or_abort(self$countdown_data, "country"))
        return(private$getter("wizard_country"))
      }
      cd_abort(c("x" = "{.field country} is readonly."))
    },

    #' @field country_iso Active Binding: Gets the 3-letter ISO code for the country. Readonly.
    #'   Same pre-Finish fallback as `country` above.
    country_iso = function(value) {
      if (missing(value)) {
        if (!is.null(self$countdown_data)) return(attr_or_abort(self$countdown_data, "iso3"))
        return(private$getter("wizard_country_iso"))
      }
      cd_abort(c("x" = "{.field iso3} is readonly."))
    },

    #' @field wizard_parts Active Binding: Gets the Load Data wizard's own in-progress,
    #'   not-yet-merged sheets (`load_excel_parts()`'s result) -- `NULL` once Finish has merged them
    #'   into `countdown_data`, or for any cache that was never in wizard mode to begin with.
    wizard_parts = function(value) private$getter("wizard_parts", value),

    #' @field quality_confirmed Active Binding: `TRUE` once this cache's data finished the Load Data
    #'   wizard with its quality checks passed (set once, at Finish -- see `set_quality_confirmed()`
    #'   below) -- persisted with everything else in the `.rds`, so it survives a resume. `FALSE` for
    #'   a cache still mid-wizard, and for any cache built outside the wizard entirely.
    quality_confirmed = function(value) private$getter("quality_confirmed", value),

    #' @field wizard_quality_results Active Binding: Gets the frozen, pre-merge quality-check
    #'   snapshot taken at Finish (`NULL` before Finish, and for any cache that never went through
    #'   the wizard) -- see `set_wizard_quality_results()`'s own comment for why this exists and what
    #'   reads it (`run_all_quality_checks()`).
    wizard_quality_results = function(value) private$getter("wizard_quality_results", value),

    #' @field adjusted_data Active Binding: Gets countdown data with K-factors applied. Adjusts automatically if flags are met.
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

    #' @field data_with_excluded_years Active Binding: Raw data filtered to remove user-excluded years. Readonly.
    #'   `NULL` before Finish (no `countdown_data` yet, mid-wizard) -- "Remove Years" is a separate,
    #'   post-Finish page, not something the wizard itself needs a pre-merge equivalent for.
    data_with_excluded_years = function(value) {
      if (missing(value)) {
        if (is.null(self$countdown_data)) return(NULL)
        private$depend("excluded_years")
        excluded_years <- self$excluded_years
        data <- self$countdown_data %>% filter(if (length(excluded_years) > 0) !year %in% excluded_years else TRUE)
        return(data)
      }
      cd_abort(c("x" = "{.field data_with_excluded_years} is readonly."))
    },

    #' @field performance_threshold Active Binding: Gets the integer threshold used for DQA success checks.
    performance_threshold = function(value) private$getter("performance_threshold", value),

    #' @field excluded_years Active Binding: Gets the numeric vector of years blocked from modeling.
    excluded_years = function(value) private$getter("excluded_years", value),

    #' @field k_factors Active Binding: Gets the named vector of numeric adjustment ratios.
    k_factors = function(value) private$getter("k_factors", value),

    #' @field adjusted_flag Active Binding: Gets boolean representing if adjustments are active.
    adjusted_flag = function(value) private$getter("adjusted_flag", value),

    #' @field derivation_population Active Binding: Gets the string indicating the origin population indicator.
    derivation_population = function(value) {
      pop <- private$getter("derivation_population", value)
      if (is.null(pop)) {
        pop <- "totlivebirths_dhis2"
        self$set_derivation_population(pop)
      }
      return(pop)
    },

    # -------------------------------------------------------------------------
    # DQA Metrics
    # -------------------------------------------------------------------------

    #' @field reporting_rate_national Active Binding: Gets the cached national reporting rate dataset.
    reporting_rate_national = function(value) {
      if (missing(value)) {
        private$depend("countdown_data")
        data <- private$getter("reporting_rate_national", value)
        if (is.null(data)) {
          data <- self$calculate_reporting_rate("national")
          private$update_field("reporting_rate_national", data)
        }
        return(data)
      }
      cd_abort(c("x" = "Read-only field."))
    },

    #' @field reporting_rate_admin1 Active Binding: Gets the cached region-level reporting rate dataset.
    reporting_rate_admin1 = function(value) {
      if (missing(value)) {
        private$depend("countdown_data")
        data <- private$getter("reporting_rate_admin1", value)
        if (is.null(data)) {
          data <- self$calculate_reporting_rate("adminlevel_1")
          private$update_field("reporting_rate_admin1", data)
        }
        return(data)
      }
      cd_abort(c("x" = "Read-only field."))
    },

    #' @field reporting_rate_district Active Binding: Gets the cached district-level reporting rate dataset.
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

    #' @field district_reporting_rate Active Binding: Gets percentage of districts passing the reporting threshold.
    district_reporting_rate = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")
      private$depend("performance_threshold")

      data <- private$getter("district_reporting_rate", value)
      if (is.null(data)) {
        data <- self$calculate_district_reporting_rate()
        private$update_field("district_reporting_rate", data)
      }
      return(data)
    },

    #' @field completeness_national Active Binding: Gets non-missing values percentage at national level.
    completeness_national = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")
      private$depend("performance_threshold")

      data <- private$getter("completeness_national", value)
      if (is.null(data)) {
        data <- self$calculate_completeness_summary("national")
        private$update_field("completeness_national", data)
      }
      return(data)
    },

    #' @field completeness_admin1 Active Binding: Gets non-missing values percentage at region level.
    completeness_admin1 = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")
      private$depend("performance_threshold")

      data <- private$getter("completeness_admin1", value)
      if (is.null(data)) {
        data <- self$calculate_completeness_summary("adminlevel_1")
        private$update_field("completeness_admin1", data)
      }
      return(data)
    },

    #' @field completeness_district Active Binding: Gets non-missing values percentage at district level.
    completeness_district = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")
      private$depend("performance_threshold")

      data <- private$getter("completeness_district", value)
      if (is.null(data)) {
        data <- self$calculate_completeness_summary("district")
        private$update_field("completeness_district", data)
      }
      return(data)
    },

    #' @field district_completeness Active Binding: Gets % of districts passing completeness thresholds.
    district_completeness = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")

      data <- private$getter("district_completeness", value)
      if (is.null(data)) {
        data <- self$calculate_district_completeness_summary()
        private$update_field("district_completeness", data)
      }
      return(data)
    },

    #' @field outliers_national Active Binding: Gets percentage of non-outlier values at national level.
    outliers_national = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")

      data <- private$getter("outliers_national", value)
      if (is.null(data)) {
        data <- self$calculate_outliers_summary("national")
        private$update_field("outliers_national", data)
      }
      return(data)
    },

    #' @field outliers_admin1 Active Binding: Gets percentage of non-outlier values at region level.
    outliers_admin1 = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")

      data <- private$getter("outliers_admin1", value)
      if (is.null(data)) {
        data <- self$calculate_outliers_summary("adminlevel_1")
        private$update_field("outliers_admin1", data)
      }
      return(data)
    },

    #' @field outliers_district Active Binding: Gets percentage of non-outlier values at district level.
    outliers_district = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")

      data <- private$getter("outliers_district", value)
      if (is.null(data)) {
        data <- self$calculate_outliers_summary("district")
        private$update_field("outliers_district", data)
      }
      return(data)
    },

    #' @field district_outliers_summary Active Binding: Gets % of districts passing outlier safety checks.
    district_outliers_summary = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")

      data <- private$getter("district_outliers_summary", value)
      if (is.null(data)) {
        data <- self$calculate_district_outlier_summary()
        private$update_field("district_outliers_summary", data)
      }
      return(data)
    },

    #' @field list_outlier_units Active Binding: Generates a table of facilities identified as severe outliers.
    list_outlier_units = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")

      data <- private$getter("list_outlier_units", value)
      if (is.null(data)) {
        data <- list_outlier_units(.data = self$countdown_data)
        private$update_field("list_outlier_units", data)
      }
      return(data)
    },

    #' @field ratios_summary Active Binding: Summarizes adequacy ratios (like ANC1/Penta1) over time.
    ratios_summary = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")
      private$depend("ratios_summary")

      data <- private$getter("ratios_summary", value)
      if (is.null(data)) {
        data <- self$adequacy_ratios %>% calculate_ratios_summary(self$survey_estimates)
        private$update_field("ratios_summary", data)
      }
      return(data)
    },

    #' @field adequacy_ratios Active Binding: Calculates district-by-district chronological indicator consistency.
    adequacy_ratios = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")

      data <- private$getter("adequacy_ratios", value)
      if (is.null(data)) {
        data <- self$calculate_ratios_and_adequacy()
        private$update_field("adequacy_ratios", data)
      }
      return(data)
    },

    #' @field overall_score Active Binding: Merges DQA tables to formulate the master health score grade.
    overall_score = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("countdown_data")
      private$depend("performance_threshold")

      data <- private$getter("overall_score", value)
      if (is.null(data)) {
        data <- self$calculate_overall_score(admin_level = "national")
        private$update_field("overall_score", data)
      }
      return(data)
    },

    # -------------------------------------------------------------------------
    # Denominators & Coverage
    # -------------------------------------------------------------------------

    #' @field denominator_metrics Active Binding: Compiles demographic targets from DHIS2 and UN data.
    denominator_metrics = function(value) {
      if (!missing(value)) cd_abort(c("x" = "Read-only field."))
      private$depend("un_estimates")
      private$depend("adjusted_data")

      data <- private$getter("denominator_metrics", value)
      if (is.null(data) && !is.null(self$adjusted_data)) {
        data <- self$adjusted_data %>% prepare_population_metrics(un_estimates = self$un_estimates)
        private$update_field("denominator_metrics", data)
      }
      return(data)
    },

    #' @field indicator_coverage_national Active Binding: Gets national-level indicator coverage calculations.
    indicator_coverage_national = function(value) {
      if (missing(value)) {
        private$depend("derivation_population")
        private$depend("adjusted_data")
        private$depend("national_estimates")
        private$depend("un_estimates")
        
        cov <- private$getter("indicator_coverage_national", value)
        if (is.null(cov)) {
          cov <- self$calculate_indicator_coverage("national")
          private$update_field("indicator_coverage_national", cov)
        }
        return(cov)
      }
      cd_abort(c("x" = "{.field indicator_coverage_national} is readonly."))
    },

    #' @field indicator_coverage_admin1 Active Binding: Gets region-level indicator coverage calculations.
    indicator_coverage_admin1 = function(value) {
      if (missing(value)) {
        private$depend("derivation_population")
        private$depend("adjusted_data")
        private$depend("national_estimates")
        
        cov <- private$getter("indicator_coverage_admin1", value)
        if (is.null(cov)) {
          cov <- self$calculate_indicator_coverage("adminlevel_1")
          private$update_field("indicator_coverage_admin1", cov)
        }
        return(cov)
      }
      cd_abort(c("x" = "{.field indicator_coverage_admin1} is readonly."))
    },

    #' @field indicator_coverage_district Active Binding: Gets district-level indicator coverage calculations.
    indicator_coverage_district = function(value) {
      if (missing(value)) {
        private$depend("derivation_population")
        private$depend("adjusted_data")
        private$depend("national_estimates")
        
        cov <- private$getter("indicator_coverage_district", value)
        if (is.null(cov)) {
          cov <- self$calculate_indicator_coverage("district")
          private$update_field("indicator_coverage_district", cov)
        }
        return(cov)
      }
      cd_abort(c("x" = "{.field indicator_coverage_district} is readonly."))
    },

    # -------------------------------------------------------------------------
    # Extracted Estimates & Raw Data Sources
    # -------------------------------------------------------------------------

    #' @field survey_estimates Active Binding: Extracts and formats targeted rates from the master survey.
    survey_estimates = function(value) {
      estimates <- private$getter("survey_estimates", value)
      group <- get_selected_group()
      if (group == "vaccine") {
        estimates[c("anc1", "instlivebirths", "bcg", "penta1", "penta3", "measles1", "opv1", "opv3", "measles1")]
      } else {
        estimates[which(!estimates %in% c("opv1", "opv3"))]
      }
    },

    #' @field national_estimates Active Binding: Fetches the configured national baseline estimates list.
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
      cd_abort(c("x" = "{.field national_estimates} is readonly. Use {.fun set_national_estimates} instead."))
    },

    #' @field admin1_estimates Active Binding: Fetches merged regional estimates from survey mapping.
    admin1_estimates = function(value) {
      if (missing(value)) {
        private$depend("regional_survey")
        private$depend("national_estimates")
        rate <- self$national_estimates
        return(get_national_rates(self$regional_survey, 'adminlevel_1', rate$anc1, rate$penta1, rate$sbr, rate$nmr, rate$pnmr, rate$twin_rate, rate$preg_loss))
      }
      cd_abort(c("x" = "{.field admin1_estimates} is readonly."))
    },

    #' @field survey_years Active Binding: Fetches a unique list of survey years available.
    survey_years = function(value) {
      self$national_survey %>% distinct(year) %>% arrange(year) %>% pull(year)
    },

    #' @field survey_year Active Binding: Fetches the anchor integer year used for survey calculations.
    survey_year = function(value) private$getter("survey_year", value),

    #' @field start_survey_year Active Binding: Fetches the chronological starting boundary for models.
    start_survey_year = function(value) private$getter("start_survey_year", value),

    #' @field denominator Active Binding: Fetches standard analysis denominator.
    denominator = function(value) private$getter("denominator", value),

    #' @field maternal_denominator Active Binding: Fetches maternal-specific analysis denominator.
    maternal_denominator = function(value) private$getter("maternal_denominator", value),

    #' @field selected_admin_level_1 Active Binding: Dashboard specific Region selection.
    selected_admin_level_1 = function(value) private$getter("selected_admin_level_1", value),

    #' @field selected_district Active Binding: Dashboard specific District selection.
    selected_district = function(value) private$getter("selected_district", value),

    #' @field mortality_mapping_years Active Binding: Fetches years requested for mortality charts.
    mortality_mapping_years = function(value) private$getter("selected_mortality_mapping_years", value),

    #' @field utilization_mapping_years Active Binding: Fetches years requested for utilization charts.
    utilization_mapping_years = function(value) private$getter("selected_utilization_mapping_years", value),

    #' @field mapping_years Active Binding: Fetches years requested for standard map generation.
    mapping_years = function(value) private$getter("selected_mapping_years", value),

    #' @field chart_options Active Binding: every stored chart option, a named list of [cd_chart_options()] (read-only; use
    #'   `set_chart_options()` / `get_chart_options()`).
    chart_options = function(value) private$getter("chart_options", value),

    #' @field report_projects Active Binding: the reports built in the report builder, a named list by id (read-only; use
    #'   `set_report_project()`).
    report_projects = function(value) private$getter("report_projects", value),

    #' @field report_assets Active Binding: the pictures the reports use, a named list by id of `list(type, data)`
    #'   (read-only; use `set_report_asset()`).
    report_assets = function(value) private$getter("report_assets", value),
    #' @field report_themes Active Binding: the themes made from Office files, a named list by id (read-only; use
    #'   `set_report_theme()`).
    report_themes = function(value) private$getter("report_themes", value),

    #' @field fpet_data Active Binding: Fetches FPET metrics (loads from global if missing).
    fpet_data = function(value) {
      iso <- self$country_iso
      dt <- private$getter("fpet_data", value)
      if (is.null(dt)) {
        dt <- fpet %>% filter(iso3 == iso)
        attr(dt, 'country') <- self$country
      }
      return(dt)
    },

    #' @field un_estimates Active Binding: Fetches demographic targets set by the UN.
    un_estimates = function(value) {
      iso <- self$country_iso
      private$getter("un_estimates", value) %||% (un_estimates %>% filter(iso3 == iso))
    },

    #' @field un_mortality_estimates Active Binding: Fetches mortality targets set by the UN.
    un_mortality_estimates = function(value) {
      iso <- self$country_iso
      private$getter("un_mortality_estimates", value) %||% (un_mortality %>% filter(iso3 == iso))
    },

    #' @field wuenic_estimates Active Binding: Fetches immunization estimates tracked by WHO.
    wuenic_estimates = function(value) {
      iso <- self$country_iso
      est <- private$getter("wuenic_estimates", value) %||% wuenic
      if (!"iso3" %in% names(est)) est <- est %>% rename(iso3 = iso)
      est %>% filter(iso3 == !!iso)
    },

    #' @field national_survey Active Binding: Fetches overall national survey raw frame.
    national_survey = function(value) {
      survey <- private$getter("national_survey", value) %||% survey_data$all
      private$filter_survey(survey)
    },

    #' @field regional_survey Active Binding: Fetches regional survey raw frame.
    regional_survey = function(value) {
      survey <- private$getter("regional_survey", value) %||% survey_data$gregion
      private$filter_survey(survey)
    },

    #' @field shapefile Active Binding: Fetches the shapefile to use for this country -- a
    #'   user-uploaded override (`set_shapefile()`) if one exists, otherwise the package-bundled
    #'   default for `country_iso`, same override-with-fallback pattern as `regional_survey` above.
    #'   `NULL` if `country_iso` isn't known yet (mid-wizard, before the admin sheet's country
    #'   resolves) -- there's nothing to fetch a bundled shapefile FOR yet.
    shapefile = function(value) {
      uploaded <- private$getter("shapefile", value)
      if (!is.null(uploaded)) return(uploaded)
      if (is.null(self$country_iso)) return(NULL)
      get_country_shapefile(self$country_iso, level = "admin_level_1")
    },

    #' @field shapefile_name_field Active Binding: Which column of `self$shapefile` holds admin-1
    #'   names -- `"NAME_1"` (the bundled shapefile's own column) unless a user-uploaded one set a
    #'   different field via `set_shapefile_name_field()`.
    shapefile_name_field = function(value) private$getter("shapefile_name_field", value) %||% "NAME_1",

    #' @field wiq_survey Active Binding: Fetches wealth inequality (WIQ) survey raw frame.
    wiq_survey = function(value) {
      survey <- private$getter("wiq_survey", value)
      if (is.null(survey)) {
        survey <- survey_data$wiq %>%
          mutate(level = factor(level, levels = c('Q1', 'Q2', 'Q3', 'Q4', 'Q5'))) %>% 
          new_tibble(class = 'cd_equity_data')
      }
      private$filter_survey(survey)
    },

    #' @field area_survey Active Binding: Fetches area based (urban/rural) survey frame.
    area_survey = function(value) {
      survey <- private$getter("area_survey", value)
      if (is.null(survey)) {
        survey <- survey_data$area %>%
          mutate(level = factor(level, levels = c('urban', 'rural'))) %>%
          new_tibble(class = 'cd_equity_data')
      }
      private$filter_survey(survey)
    },

    #' @field education_survey Active Binding: Fetches maternal education level survey frame.
    education_survey = function(value) {
      survey <- private$getter("education_survey", value)
      if (is.null(survey)) {
        survey <- survey_data$meduc %>%
          mutate(levels = factor(level, levels = c('none', 'primary', 'secondary+'))) %>%
          new_tibble(class = 'cd_equity_data')
      }
      private$filter_survey(survey)
    },

    #' @field survey_mapping Active Binding: Retrieves text mapping linking survey regions to raw regions.
    survey_mapping = function(value) private$getter("survey_mapping", value),

    #' @field map_mapping Active Binding: Retrieves mapping linking map coordinates to raw regions.
    map_mapping = function(value) private$getter("map_mapping", value),

    #' @field sector_national_estimates Active Binding: Returns cache of national sector breakdown.
    sector_national_estimates = function(value) private$getter("sector_national_estimates", value),

    #' @field sector_area_estimates Active Binding: Returns cache of sub-area sector breakdown.
    sector_area_estimates = function(value) private$getter("sector_area_estimates", value),

    #' @field csection_national_estimates Active Binding: Returns cached national csection estimates.
    csection_national_estimates = function(value) private$getter("csection_national_estimates", value),

    #' @field csection_area_estimates Active Binding: Returns cached sub-area csection estimates.
    csection_area_estimates = function(value) private$getter("csection_area_estimates", value),

    # -------------------------------------------------------------------------
    # Parameter Flags (Checkers)
    # -------------------------------------------------------------------------

    #' @field check_inequality_params Active Binding: Returns boolean if data necessary for inequality calculations exists.
    check_inequality_params = function() {
      !is.null(self$adjusted_data) && !is.null(self$survey_year) && !is.null(self$un_estimates) && all(!is.na(self$national_estimates))
    },

    #' @field check_coverage_params Active Binding: Returns boolean if data necessary for coverage calculations exists.
    check_coverage_params = function() {
      self$check_inequality_params && !is.null(self$wuenic_estimates) && !is.null(self$national_survey) && !is.null(self$regional_survey)
    },

    #' @field check_mortality_params Active Binding: Returns boolean if data necessary for mortality calculations exists.
    check_mortality_params = function() {
      !is.null(self$adjusted_data) && !is.null(self$un_mortality_estimates)
    },

    #' @field check_sector_params Active Binding: Returns boolean if data necessary for public/private sector calculations exists.
    check_sector_params = function() {
      !is.null(self$sector_national_estimates) && !is.null(self$sector_area_estimates) && !is.null(self$csection_national_estimates) && !is.null(self$csection_area_estimates)
    },

    # -------------------------------------------------------------------------
    # Derived Layers (Inequality, Health Systems, Mortality)
    # -------------------------------------------------------------------------

    #' @field inequality_admin1 Active Binding: Automatically calculates and caches Admin1 inequality matrices.
    inequality_admin1 = function(value) {
      if (missing(value)) {
        private$depend("adjusted_data")
        private$depend("un_estimates")
        private$depend("national_estimates")

        data <- private$getter("inequality_admin1", value)
        if (is.null(data)) {
          data <- self$calculate_inequality(admin_level = "adminlevel_1")
          private$update_field("inequality_admin1", data)
        }
        return(data)
      }
      cd_abort(c("x" = "{.field inequality_admin1} is readonly."))
    },

    #' @field inequality_district Active Binding: Automatically calculates and caches District inequality matrices.
    inequality_district = function(value) {
      if (missing(value)) {
        private$depend("adjusted_data")
        private$depend("un_estimates")
        private$depend("national_estimates")

        data <- private$getter("inequality_district", value)
        if (is.null(data)) {
          data <- self$calculate_inequality(admin_level = "district")
          private$update_field("inequality_district", data)
        }
        return(data)
      }
      cd_abort(c("x" = "{.field inequality_district} is readonly."))
    },

    #' @field mortality_summary Active Binding: Calculates mortality summaries combining live births and still births.
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

    #' @field mortality_ratios Active Binding: Calculates precise mortality ratios comparing internal data with UN estimates.
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

    #' @field service_utilization_national Active Binding: Caches OPD/IPD utilizations summed to the National scale.
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

    #' @field service_utilization_admin1 Active Binding: Caches OPD/IPD utilizations parsed by Admin 1 level.
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

    #' @field health_system_comparison Active Binding: Summarizes health system efficiency linking resources to coverage.
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

    #' @field health_system_metrics_national Active Binding: Compiles core indicators (staff density, beds) at the National scale.
    health_system_metrics_national = function(value) {
      if (missing(value)) {
        private$depend("adjusted_data")
        cov <- private$getter("health_system_metrics_national", value)
        if (is.null(cov) && !is.null(self$adjusted_data)) {
          cov <- self$adjusted_data %>% calculate_health_system_metrics('national')
          private$update_field("health_system_metrics_national", cov)
        }
        return(cov)
      }
      cd_abort(c("x" = "{.field health_system_metrics_national} is readonly."))
    },

    #' @field health_system_metrics_admin1 Active Binding: Compiles core indicators (staff density, beds) at the Admin 1 scale.
    health_system_metrics_admin1 = function(value) {
      if (missing(value)) {
        private$depend("adjusted_data")
        cov <- private$getter("health_system_metrics_admin1", value)
        if (is.null(cov) && !is.null(self$adjusted_data)) {
          cov <- self$adjusted_data %>% calculate_health_system_metrics('adminlevel_1')
          private$update_field("health_system_metrics_admin1", cov)
        }
        return(cov)
      }
      cd_abort(c("x" = "{.field health_system_metrics_admin1} is readonly."))
    },

    #' @field national_private_share Active Binding: Returns baseline metrics regarding private sector operations (National).
    national_private_share = function(value) {
      if (missing(value)) {
        dt <- private$getter("national_private_share", value) %||% (private_share$national %>% filter(iso == self$country_iso))
        return(dt)
      }
      cd_abort(c("x" = "{.field national_private_share} is readonly."))
    },

    #' @field area_private_share Active Binding: Returns baseline metrics regarding private sector operations (Area/Region).
    area_private_share = function(value) {
      if (missing(value)) {
        dt <- private$getter("area_private_share", value) %||% (private_share$area %>% filter(iso == self$country_iso))
        return(dt)
      }
      cd_abort(c("x" = "{.field area_private_share} is readonly."))
    }
  ),
  
  # =========================================================================
  # PRIVATE ARCHITECTURE (Internal Logic & Cascades)
  # =========================================================================
  private = list(
    .data_template = list(
      version = NULL,
      language = "en",
      rds_path = NULL,
      countdown_data = NULL,
      # wizard_parts/wizard_country/wizard_country_iso/quality_confirmed: the Load Data wizard's own
      # in-progress state (Phase 3 of the wizard redesign, apps/rmncah). NULL for every non-wizard
      # cache (a resumed .rds, a .dta load, any programmatic init_CacheConnection(countdown_data=...)
      # call) -- purely additive. wizard_parts holds load_excel_parts()'s result (separate,
      # unmerged sheets) until Finish calls merge_and_standardize() + set_countdown_data() and clears
      # it back to NULL. wizard_country/wizard_country_iso are a best-effort, non-aborting country
      # resolution (resolve_country_best_effort(), 0_import_load_data.R) computed right after upload
      # so country/country_iso have something to return before Finish -- see those active bindings'
      # own comments below for why this is deliberately separate from check_single_country()'s real
      # validation. quality_confirmed is the durable, persisted record that this cache's data
      # actually finished the wizard with its quality checks passed -- set once, at Finish, and the
      # only thing Phase 9's sidebar-locking condition needs (not wizard_parts, which is gone by
      # then). wizard_quality_results is the OTHER thing set right at Finish, alongside
      # quality_confirmed, and deliberately NOT cleared by clear_wizard_parts() -- a frozen snapshot
      # of what the pre-merge checks found, so run_all_quality_checks() has something accurate to
      # show if Data Quality is ever revisited after wizard_parts itself is gone (see its own setter
      # comment for the bug this fixes).
      wizard_parts = NULL,
      wizard_country = NULL,
      wizard_country_iso = NULL,
      quality_confirmed = FALSE,
      wizard_quality_results = NULL,
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
      start_survey_year = NULL,

      selected_admin_level_1 = NULL,
      selected_district = NULL,
      selected_mortality_mapping_years = NULL,
      selected_utilization_mapping_years = NULL,
      selected_mapping_years = NULL,

      # What the user has changed about how charts look: list(default = <cd_chart_options>, `<chart id>` = <cd_chart_options>)
      chart_options = list(),
      report_projects = list(),
      report_assets = list(),
      report_themes = list(),

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
      shapefile = NULL,
      shapefile_name_field = NULL,

      bayesian_models = NULL,

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

      indicator_coverage_national = NULL,
      indicator_coverage_admin1 = NULL,
      indicator_coverage_district = NULL,
      inequality_admin1 = NULL,
      inequality_district = NULL,
     
      fpet_data = NULL,
      sector_national_estimates = NULL,
      sector_area_estimates = NULL,
      csection_national_estimates = NULL,
      csection_area_estimates = NULL,
      
      mortality_summary = NULL,
      mortality_ratios = NULL,
      service_utilization_national = NULL,
      service_utilization_admin1 = NULL,
      health_system_comparison = NULL,
      health_system_metrics_national = NULL,
      health_system_metrics_admin1 = NULL
    ),
    .in_memory_data = NULL,
    .has_changed = FALSE,
    .reactiveDep = NULL,

    # -------------------------------------------------------------------------
    # Getters and Setters
    # -------------------------------------------------------------------------

    update_field = function(field_name, value) {
      if (!identical(private$.in_memory_data[[field_name]], value)) {
        private$.in_memory_data[[field_name]] <<- value
        private$.has_changed <<- TRUE
        private$trigger(field_name)
        self$save_to_disk()
        return(TRUE)
      }
      return(FALSE)
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

      return(private$update_field(field_name, value))
    },

    # -------------------------------------------------------------------------
    # Invalidation Cascades (The Core Reactive Engine)
    # -------------------------------------------------------------------------

    #' Invalidate entirely (Usually triggered on initial data load)
    invalidate_cached_data = function() {
      private$invalidate_dqa_cache()
      private$invalidate_downstream_adjusted()
      private$update_field("fpet_data", NULL)
      private$update_field("sector_national_estimates", NULL)
      private$update_field("sector_area_estimates", NULL)
      private$update_field("csection_national_estimates", NULL)
      private$update_field("csection_area_estimates", NULL)
    },

    #' Invalidate downstream computations (Coverage, Mortality, etc.) derived from adjustments
    invalidate_downstream_adjusted = function() {
      private$invalidate_denominator_cache()
      private$invalidate_coverage_cache()
      private$invalidate_mortality_cache()
      private$invalidate_utilization_cache()
    },

    #' Invalidate Data Quality Cache
    invalidate_dqa_cache = function() {
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
      private$update_field("list_outlier_units", NULL)
      private$update_field("ratios_summary", NULL)
      private$update_field("adequacy_ratios", NULL)
      private$update_field("overall_score", NULL)
    },

    #' Invalidate Denominator Cache
    invalidate_denominator_cache = function() {
      private$update_field("denominator_metrics", NULL)
    },

    #' Invalidate Coverage Cache (Automatically cascades to Inequality & Health Systems)
    invalidate_coverage_cache = function() {
      private$update_field("indicator_coverage_national", NULL)
      private$update_field("indicator_coverage_admin1", NULL)
      private$update_field("indicator_coverage_district", NULL)

      private$update_field("bayesian_models", NULL)
      
      # Implicit Cascade: If Coverage drops, dependent matrices drop too.
      private$invalidate_inequality_cache()
      private$invalidate_health_systems_cache()
    },

    #' Invalidate Inequality Cache
    invalidate_inequality_cache = function() {
      private$update_field("inequality_admin1", NULL)
      private$update_field("inequality_district", NULL)
    },

    #' Invalidate Mortality Cache
    invalidate_mortality_cache = function() {
      private$update_field("mortality_summary", NULL)
      private$update_field("mortality_ratios", NULL)
    },

    #' Invalidate Utilization Cache
    invalidate_utilization_cache = function() {
      private$update_field("service_utilization_national", NULL)
      private$update_field("service_utilization_admin1", NULL)
    },

    #' Invalidate Health Systems Cache
    invalidate_health_systems_cache = function() {
      private$update_field("health_system_comparison", NULL)
      private$update_field("health_system_metrics_national", NULL)
      private$update_field("health_system_metrics_admin1", NULL)
    },

    # -------------------------------------------------------------------------
    # Utility Extraction Methods
    # -------------------------------------------------------------------------

    extract_national_estimates_from_survey = function(survey_data) {
      if (is.null(survey_data) || nrow(survey_data) == 0) return()

      parsed <- parse_estimates_from_df(survey_data, self$country_iso)
      if (is.null(parsed)) return()

      # Separate normal survey parameters from mortality/sbr
      survey_vals <- parsed$values[!names(parsed$values) %in% c("nmr", "pnmr", "sbr")]
      nat_vals <- parsed$values[names(parsed$values) %in% c("nmr", "pnmr", "sbr")]
      
      # Feed the parsed data directly into our newly bulletproofed public setters!
      private$update_field("survey_year", parsed$year)
      if (length(survey_vals) > 0) self$set_survey_estimates(survey_vals)
      if (length(nat_vals) > 0) self$set_national_estimates(as.list(nat_vals))
    },

    filter_survey = function(survey) {
      check_required(survey)
      start_year <- self$start_survey_year
      load_data_or_file(.data = survey, country_iso = self$country_iso) %>%
        filter(if (is.null(start_year)) TRUE else year >= start_year)
    },

    initialize_survey_estimates = function() {
      if (is.null(survey_data$all)) return()
      # Re-use the exact same logic
      private$extract_national_estimates_from_survey(survey_data$all)
    },

    # -------------------------------------------------------------------------
    # Reactivity Integration Engine
    # -------------------------------------------------------------------------

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
        private$depend(field_name) 
      }
      invisible()
    }
  )
)