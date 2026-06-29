#' Combine Immunization Coverage Data
#'
#' `calculate_coverage` integrates immunization coverage data from three sources:
#' DHIS2 (District Health Information Software), survey-based estimates, and
#' WUENIC (WHO-UNICEF estimates). The combined dataset is prepared for analysis
#' at various administrative levels.
#'
#' @param .data A `cd_data` data frame with DHIS2 coverage metrics.
#' @param admin_level Character. Specifies the administrative level for calculations.
#'   Options include:`"national", "adminlevel_1"`, and `"district"`.
#' @param survey_data A data frame containing survey-based immunization estimates.
#' @param wuenic_data A data frame containing WHO-UNICEF (WUENIC) coverage estimates.
#' @param un_estimates Optional. A tibble containing UN population estimates. Required
#'   for national-level calculations.
#' @param sbr Numeric. The stillbirth rate. Default is `0.02`.
#' @param nmr Numeric. Neonatal mortality rate. Default is `0.025`.
#' @param pnmr Numeric. Post-neonatal mortality rate. Default is `0.024`.
#' @param anc1survey Numeric. Survey-derived coverage rate for ANC-1 (antenatal care, first visit). Default is `0.98`.
#' @param dpt1survey Numeric. Survey-derived coverage rate for Penta-1 (DPT1 vaccination). Default is `0.97`.
#' @param survey_year Integer. The year of Penta-1 survey provided
#' @param preg_loss Numeric. Pregnancy loss rate
#' @param twin Numeric. Twin birth rate. Default is `0.015`.
#' @param subnational_map (Optional) A data frame mapping subnational regions to
#'   parent regions, required for subnational-level analyses. Default is `NULL`.
#'
#' @return A `cd_coverage` data frame containing harmonized coverage estimates
#'   for each year from DHIS2, WUENIC, and survey data. Includes metadata for
#'   administrative levels, regions, and denominators.
#'
#' @examples
#' \dontrun{
#' calculate_coverage(precomputed_data, survey_df, wuenic_df)
#' }
#' @export
calculate_coverage <- function(.data,
                               survey_data,
                               wuenic_data,
                               subnational_map = NULL) {
  year = NULL

  # Validate inputs
  check_cd_indicator_coverage(.data)
  check_wuenic_data(wuenic_data)

  admin_level <- attr_or_abort(.data, "admin_level")
  check_survey_data(survey_data, admin_level)

  region <- attr_or_null(.data, "region")
  admin_level_cols <- get_admin_columns(admin_level, region)
  admin_level_cols <- c(admin_level_cols, "year")

  # Prepare DHIS2 data
  dhis2_data <- .data %>%
    select(any_of(admin_level_cols), matches("^cov_"))

  # Prepare survey data
  survey_data <- survey_data %>%
    select(any_of(admin_level_cols), matches("^ll_|^ul|^r_|^se_|^source$")) %>%
    join_subnational_map(admin_level, subnational_map) %>%
    check_district_column(admin_level, dhis2_data)

  # Prepare WUENIC data
  wuenic_data <- wuenic_data %>%
    select(year, matches("^cov_"))

  admin_level_c <- switch(admin_level,
    national = "year",
    adminlevel_1 = c("adminlevel_1", "year"),
    district = c("adminlevel_1", "district", "year")
  )

  # Join and Transform data
  combined_data <- dhis2_data %>%
    full_join(survey_data, by = admin_level_c, relationship = "many-to-many")

  if (admin_level == "national") {
    combined_data <- combined_data %>%
      left_join(wuenic_data, by = "year")
  }

  combined_data <- combined_data %>%
    filter(if (is.null(region)) TRUE else adminlevel_1 == region) %>%
    select(-any_of(c("admin_level_1")))

  # Return result
  new_tibble(
    combined_data,
    class = "cd_coverage",
    admin_level = admin_level,
    region = region
  )
}


#' Filter and Reshape Coverage Data
#'
#' `filter_coverage` extracts specific coverage indicators and denominators from a
#' combined coverage dataset, applies regional filtering, and reshapes the data
#' for analysis and visualisation.
#'
#' @param .data A `cd_coverage` data frame with combined immunization coverage data.
#' @param indicator Coverage indicators to include (e.g., `"penta3"`, `"measles1"`).
#' @param denominator Denominator sources for coverage calculations (e.g., `"dhis2"`).
#'
#' @return A reshaped data frame with filtered indicators and denominators.
#'
#' @examples
#' \dontrun{
#' filter_coverage(combined_data, c("penta3", "measles1"), "dhis2", "Central Province")
#' }
#' @export
filter_coverage <- function(.data,
                            indicator,
                            denominator = c("dhis2", "anc1", "penta1", "penta1derived", "anc1derived"),
                            region = NULL) {
  . <- value <- estimates <- NULL

  check_cd_coverage(.data)

  admin_level <- attr_or_abort(.data, "admin_level")
  region_from_calc <- attr_or_null(.data, "region")

  indicator <- arg_match(indicator, get_analysis_indicators())
  denominator <- arg_match(denominator)

  if ((admin_level == "national" || (admin_level == "adminlevel_1" && !is.null(region_from_calc))) && !is.null(region)) {
    cd_abort(c("x" = "{.arg region} must be null."))
  }

  if ((admin_level %in% c("adminlevel_1", "district") && is.null(region_from_calc)) && is.null(region)) {
    cd_abort(c("x" = "{.arg region} must be provided required for subnational analyses."))
  }

  admin_col <- get_admin_columns(admin_level)
  admin_col <- c(admin_col, "year")
  dhis2_col <- paste0("cov_", indicator, "_", denominator)
  survey_estimate_col <- paste0("r_", indicator)
  lower_ci_col <- paste0("ll_", indicator)
  upper_ci_col <- paste0("ul_", indicator)
  wuenic_col <- paste0("cov_", indicator, "_wuenic")

  data <- .data %>%
    select(any_of(c(admin_col, dhis2_col, survey_estimate_col, lower_ci_col, upper_ci_col, wuenic_col)))

  data <- if (is.null(region_from_calc) && admin_level != "national") {
    data %>% filter(!!sym(admin_level) == region)
  } else if (!is.null(region_from_calc) && admin_level != "national") {
    data %>%
      summarise(
        across(any_of(c(dhis2_col, survey_estimate_col, lower_ci_col, upper_ci_col, wuenic_col)), ~ mean(.x, na.rm = TRUE)),
        .by = any_of(c(admin_col, "year"))
      )
  } else {
    data
  }

  data <- data %>%
    # select(any_of(c(admin_col, dhis2_col, survey_estimate_col, lower_ci_col, upper_ci_col, wuenic_col))) %>%
    # filter(if (admin_level == "national") TRUE else !!sym(admin_level) == region) %>% # Filter for region if applicable
    # Transform data
    mutate(
      !!dhis2_col := validate_column_existence(., dhis2_col),
      !!survey_estimate_col := validate_column_existence(., survey_estimate_col),
      !!wuenic_col := validate_column_existence(., wuenic_col),
      !!lower_ci_col := validate_column_existence(., lower_ci_col),
      !!upper_ci_col := validate_column_existence(., upper_ci_col)
    ) %>%
    pivot_longer(cols = contains(indicator), names_to = "estimates") %>%
    arrange(year) %>%
    pivot_wider(names_from = year, values_from = value) %>%
    mutate(
      estimates = case_match(
        estimates,
        dhis2_col ~ "DHIS2 estimate",
        survey_estimate_col ~ "Survey estimates",
        wuenic_col ~ "WUENIC estimates",
        lower_ci_col ~ "95% CI LL",
        upper_ci_col ~ "95% CI UL",
      )
    ) %>%
    select(-any_of(c("adminlevel_1", "district")))

  new_tibble(
    data,
    class = "cd_coverage_filtered",
    admin_level = admin_level,
    indicator = indicator,
    denominator = denominator,
    region = region
  )
}


validate_column_existence <- function(.data, column) {
  if (!column %in% colnames(.data)) {
    cd_warn(c("!" = "Column {.field {column}} not found in the data."))
    return(rep(NA, nrow(.data)))
  }
  .data[[column]]
}

join_subnational_map <- function(.data, admin_level, map) {
  # admin_level_argument will be used once the district column is introduce in survey

  adminlevel_1 <- admin_level_1 <- NULL

  if (admin_level != "national") {
    if (!is.null(map)) {
      .data <- .data %>%
        left_join(map, join_by(adminlevel_1)) %>%
        filter(!is.na(admin_level_1)) %>%
        select(-adminlevel_1) %>%
        rename(adminlevel_1 = admin_level_1)
    }
  }

  .data
}

check_district_column <- function(.data, admin_level, dhis2_data) {
  adminlevel_1 = district = NULL

  if (admin_level == "district" && !"district" %in% colnames(.data)) {
    .data <- dhis2_data %>%
      distinct(adminlevel_1, district) %>%
      left_join(.data, by = "adminlevel_1", relationship = "many-to-many")
  }

  .data
}

#' Generate Coverage Data for Continuum of Care
#'
#' @description 
#' Processes and shapes raw coverage data into a clean, long format optimized for 
#' continuum-of-care plotting. It dynamically builds regex patterns based on the 
#' spatial level and data type to extract relevant columns:
#' * **National**: Extracts Facility, Survey, and WUENIC data.
#' * **Subnational**: Extracts Facility data only.
#' 
#' The function automatically filters for the absolute latest available data point 
#' per indicator-source combination and converts the `indicator` column into an 
#' ordered factor representing the lifecycle stages to ensure plots are always ordered correctly.
#'
#' @param .data A data frame/tibble originating from `calculate_coverage()`. 
#'   Must contain an `admin_level` attribute.
#' @param type Character. Specifies whether to extract 'maternal' or 'child' indicators.
#' @param denominator Character. The denominator to use for the specified indicator type. 
#'   Options include "dhis2", "anc1", "penta1", "penta1derived", or "anc1derived".
#'
#' @return A tibble of class `cd_coverage_selected` containing the latest 
#'   coverage values, categorized sources, and ordered indicators. Retains 
#'   `admin_level` and `admin_col` attributes for downstream plotting.
#'
#' @export
generate_coverage_data <- function(.data,
                                   type = c('maternal', 'child'),
                                   denominator = c("dhis2", "anc1", "penta1", "penta1derived", "anc1derived")) {
  
  check_cd_coverage(.data)
  admin_level <- attr_or_abort(.data, "admin_level")
  region <- attr_or_null(.data, "region")
  admin_level_col <- get_admin_columns(admin_level, region)
  admin_level_cols <- c(admin_level_col, 'year')

  type <- arg_match(type)
  denominator <- arg_match(denominator)
  
  # 1. Define terms based on the selected type
  terms <- if (type == 'maternal') {
    c("anc_1trimester", 'anc1', "anc4", "ideliv", "instlivebirths", "pnc48h")
  } else {
    c('bcg', 'penta1', 'penta3', 'measles1', 'measle2')
  }
  terms_regex <- paste(terms, collapse = '|')

  # 2. Build Regex for Extraction
  regex_match <- if (admin_level == 'national') {
    fac_regex <- paste0('^cov_(', terms_regex, ')_(', denominator, '|wuenic)$')
    surv_regex <- paste0('^r_(', terms_regex, ')$')
    paste(fac_regex, surv_regex, sep = '|')
  } else {
    paste0('^cov_(', terms_regex, ')_(', denominator, ')$')
  }

  # 3. Wrangle Data
  plot_data <- .data %>% 
    select(any_of(admin_level_cols), matches(regex_match)) %>% 
    pivot_longer(-any_of(admin_level_cols)) %>% 
    arrange(pick(any_of(admin_level_cols))) %>% 
    filter(!is.na(value)) %>% 
    slice_tail(n = 1, by = any_of(c(admin_level_col, 'name'))) %>% 
    mutate(
      source = case_when(
        grepl(paste0("^cov_.*_", denominator, "$"), name) ~ "facility",
        grepl("^cov_.*_wuenic$", name) ~ "wuenic",
        grepl("^r_", name) ~ "survey",
        .ptype = factor(levels = c('facility', 'survey', 'wuenic'))
      ),
      indicator = name %>% 
        sub("^cov_|^r_", "", .) %>% 
        sub(paste0("_(", denominator, "|wuenic)$"), "", .),
      indicator = factor(indicator, levels = terms)
    )
    
  return(
    new_tibble(
      plot_data, 
      class = "cd_coverage_selected",
      admin_level = admin_level
    )
  )
}