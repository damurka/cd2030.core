#' Compute Service Utilization Metrics
#'
#' Calculates annualized service utilization statistics including outpatient (OPD), inpatient (IPD),
#' case fatality rates, and under-5 service use, aggregated either at national or admin level 1.
#'
#' @param .data A data frame containing service and population indicators.
#' @param admin_level Either `"national"` or `"adminlevel_1"` to define the aggregation level.
#'
#' @return A `cd_service_utilization` object (tibble subclass) with summarized and derived indicators:
#' - OPD/IPD totals and rates
#' - Under-5 service utilization
#' - Case fatality rates
#' - Proportion of under-5 deaths
#'
#' @examples
#' \dontrun{
#'   compute_service_utilization(dat, admin_level = "national")
#' }
#'
#' @export
compute_service_utilization <- function(.data, admin_level = c('national', 'adminlevel_1', 'district')) {
  check_cd_data(.data)
  iso3 <- attr_or_abort(.data, 'iso3')
  admin_level <- arg_match(admin_level)
  admin_level_cols <- get_admin_columns(admin_level)
  admin_level_cols <- c(admin_level_cols, 'year')

  pop_vars <- c('total_pop', 'under5_pop', 'under1_pop', 'live_births', 'total_births')
  vars <- c('opd_total', 'opd_under5', 'ipd_total', 'ipd_under5', 'under5_deaths', 'total_deaths')
  mch_vars <- c('anc1', 'anc4', 'pnc48h', 'bcg', 'penta1', "penta3", 'measles1', 'measles2', 'ideliv')

  result <- .data %>%
    mutate(
      year_opd_rr = round(mean(opd_rr, na.rm = TRUE), 1),
      year_ipd_rr = round(mean(ipd_rr, na.rm = TRUE), 1),
      .by = all_of(admin_level_cols)
    ) %>%
    summarise(
      across(all_of(c(vars, mch_vars)), ~ sum(.x, na.rm = TRUE)),
      across(all_of(pop_vars), ~ robust_max(.x)),
      across(starts_with('year_'), ~ robust_max(.x), .names = "{sub('^year_', '', .col)}"),
      .by = c(adminlevel_1, district, year),
    ) %>%
    summarise(
      across(all_of(c(vars, pop_vars, mch_vars)), ~ sum(.x, na.rm = TRUE)),
      across(ends_with('_rr'), ~ robust_max(.x)),
      .by = all_of(admin_level_cols)
    ) %>%
    rename(
      # total_nursemidwife = total_nurses,
      total_opd = opd_total,
      total_ipd = ipd_total,
      total_pop_u5 = under5_pop,
      total_opd_u5 = opd_under5,
      total_ipd_u5 = ipd_under5
    ) %>%
    mutate(
      ratio_opd_pop = total_opd / total_pop,
      ratio_ipd_pop = 100 * (total_ipd / total_pop),
      ratio_opd_u5_pop = total_opd_u5 / total_pop_u5,
      ratio_ipd_u5_pop = 100 * (total_ipd_u5 / total_pop_u5),

      ratio_opd_ipd = total_opd/total_ipd,
      ratio_opd_u5_ipd_u5 = total_opd_u5/total_ipd_u5,

      perc_opd_under5 = 100 * total_opd_u5 / total_opd,
      perc_ipd_under5 = 100 * total_ipd_u5 / total_ipd,
      cfr_under5 = 100 * under5_deaths / total_ipd_u5,
      cfr_total = 100 * total_deaths / total_ipd,
      prop_death = 100 * under5_deaths / total_deaths,

      # MCH preventive index & Curative service index
      mch_prev_services_index = (anc1 + anc4*3 + pnc48h + bcg + (penta1 + penta3)/2 + penta3 + measles1 + measles2 + ideliv*10) / total_pop_u5,
      curative_services_index = (total_opd_u5 + total_ipd_u5 * 10)/total_pop_u5
    ) %>%
    select(-live_births, -under1_pop, -total_births, -any_of(mch_vars))

  new_tibble(
    result,
    class = 'cd_service_utilization',
    admin_level = admin_level,
    iso3 = iso3
  )
}

#' Filter and Prepare Service Utilization Data for Mapping
#'
#' Filters a `cd_service_utilization` object by country, indicator, and year.
#' Joins spatial data for subnational mapping and renames geometry for use with `ggplot2::geom_sf()`.
#'
#' @param .data A `cd_service_utilization` object returned by [compute_service_utilization()].
#' @param indicator Character. Service indicator to map, either `"ipd"` or `"opd"`. Defaults to `"ipd"`.
#' @param plot_years Optional. Integer or vector of years to include.
#' @param subnational_map Optional. A mapping data frame to link `NAME_1` from the shapefile to internal admin labels.
#'
#' @return A tibble of class `cd_service_utilization_prepared`, ready for faceted spatial plotting.
#'
#' @details
#' This function:
#' - Selects the under-five service indicator (`ratio_ipd_u5_pop` or `ratio_opd_u5_pop`)
#' - Joins the appropriate admin level 1 shapefile using the specified country ISO
#' - Filters to specified `plot_years` if provided
#' - Renames the geometry column for compatibility with `geom_sf()`
#'
#' Only `adminlevel_1` data is currently supported for mapping.
#'
#' @examples
#' \dontrun{
#' prepare_service_utlization_mapping(service_data, "UGA", indicator = "opd", plot_years = 2019:2022)
#' }
#'
#' @export
prepare_mapping_service_utlization <- function(.data, indicator = c('ipd', 'opd'), plot_years = NULL, subnational_map = NULL,
                                               palette = c('Purples', 'Blues', 'Greens', 'Reds', 'YlGnBu')) {

  check_cd_class(.data, expected_class = 'cd_service_utilization')
  indicator <- arg_match(indicator)
  indicator <- paste0('ratio_', indicator, '_u5_pop')
  palette <- arg_match(palette)
  admin_level <- attr_or_abort(.data, 'admin_level')
  country_iso <- attr_or_abort(.data, 'iso3')

  if (admin_level != 'adminlevel_1') {
    cd_abort(c('x' = 'only {.arg adminlevel_1} is supported for mapping.'))
  }

  shapefile <- get_country_shapefile(country_iso, 'admin_level_1')

  shapefile <- if (is.null(subnational_map)) {
    shapefile %>% mutate(adminlevel_1 = NAME_1)
  } else {
    shapefile %>%
      left_join(subnational_map, by = "NAME_1") %>%
      rename(adminlevel_1 = admin_level_1)
  }

  merged_data <- .data %>%
    left_join(shapefile, by = join_by(adminlevel_1)) %>%
    filter(if (is.null(plot_years)) TRUE else year %in% plot_years) %>%
    select(any_of(c('adminlevel_1', 'district', 'year', indicator)), starts_with('geom')) %>%
    rename_with(~ 'geometry', starts_with('geom'))

  new_tibble(
    merged_data,
    class = 'cd_service_utilization_prepared',
    indicator = indicator,
    palette = palette
  )
}

#' Filter Service Utilization Data for a Specific Region and Indicator
#'
#' Prepares a `cd_service_utilization` object for non-spatial plotting (e.g., time series)
#' by filtering by administrative region and indicator type.
#'
#' @param .data A `cd_service_utilization` object created by [compute_service_utilization()].
#' @param indicator Character. The indicator to visualize. Options include `"opd"`, `"ipd"`,
#' `"under5"` (proportion under 5), `"cfr"` (case fatality rate), or `"deaths"` (proportion of under-5 deaths).
#' @param region Optional. A single region name to filter when data is subnational (`adminlevel_1` or `district`).
#'
#' @return A tibble of class `cd_service_utilization_filtered`, with an attached `indicator` attribute for plotting.
#'
#' @details
#' This function:
#' - Validates the `.data` class and `indicator` input
#' - If data is subnational, filters it by the specified `region`
#' - If data is national, ensures `region` is not provided
#' - Returns a filtered tibble tagged with `cd_service_utilization_filtered` class for downstream plotting
#'
#' @examples
#' \dontrun{
#' # Filter IPD indicator for Central region
#' filtered <- filter_service_utilization(service_data, indicator = "ipd", region = "Central")
#' }
#'
#' @export
filter_service_utilization <- function(.data, indicator = c('opd', 'ipd', 'under5', 'cfr', 'deaths'), region = NULL) {
  check_cd_class(.data, expected_class = 'cd_service_utilization')
  indicator <- arg_match(indicator)

  admin_level <- attr_or_abort(.data, 'admin_level')

  if (admin_level == 'national' && !is.null(region)) {
    cd_abort('x' = '{.arg region} cannot be specified in {.field national} data.')
  }

  if (admin_level != 'national' && is.null(region) && !is_scalar_character(region)) {
    cd_abort('x' = '{.arg region} must be a scalar string.')
  }

  data <- if (admin_level != 'national') {
    .data %>%
      filter(!!sym(admin_level) == region)
  } else {
    .data
  }

  new_tibble(
    data,
    class = 'cd_service_utilization_filtered',
    indicator = indicator
  )
}

#' Format Service Utilization Data for Excel Export
#'
#' Transforms a `cd_service_utilization` object into a wide-format table
#' with labeled indicators, suitable for export to Excel.
#'
#' @param .data A `cd_service_utilization` object produced by [compute_service_utilization()].
#'
#' @return A tibble in wide format with:
#' - One row per indicator per admin unit
#' - One column per year
#' - A human-readable label for each indicator (`indiclabel`)
#'
#' @details
#' The output table includes population, OPD/IPD service utilization,
#' under-5 service metrics, reporting completeness, and case fatality rates,
#' reshaped to facilitate Excel review or reporting.
#'
#' @examples
#' \dontrun{
#'   x <- compute_service_utilization(dat, admin_level = "adminlevel_1")
#'   get_excel_version(x)
#' }
#'
#' @export

get_excel_version <- function(.data) {
  check_service_utilization(.data)

  admin_level <- attr_or_abort(.data, 'admin_level')
  admin_level_col <- get_admin_columns(admin_level)

  indicator_labels <- c(
    "total_pop"           = "Estimated population, all ages",
    "under5_pop"          = "Estimated population under-5",
    "ratio_opd_pop"      = "Mean OPD visits per person per year, all ages",
    "ratio_ipd_pop"       = "Mean IPD admissions per 100 persons per year, all ages",
    "opd_rr"              = "Completeness reporting OPD",
    "opd_total"           = "N of OPD visits per year, 5+",
    "opd_under5"          = "N of OPD visits per year, under-5",
    "ratio_opd_u5_pop"     = "Mean OPD visits per child per year, under-5",
    "perc_opd_under5"     = "Percent of OPD visits that are under-5",
    "ipd_rr"              = "Completeness reporting IPD",
    "ipd_total"           = "N of IPD admissions per year, all ages",
    "ipd_under5"          = "N of IPD admissions per year, under-5",
    "ratio_ipd_u5_pop"     = "Mean IPD admissions per 100 children per year, under-5",
    "perc_ipd_under5"     = "Percent of IPD admissions that are under-5",
    "total_deaths"         = "N of deaths per year, all ages",
    "under5_deaths"        = "N of deaths in children under-5",
    "cfr_total"           = "CFR: deaths per 100 admissions per year, all ages",
    "cfr_under5"          = "CFR: deaths per 100 admissions per year, under-5",
    "prop_death"          = "Proportion of under-5 deaths (%): under-5 to total deaths"
  )

  .data %>%
    pivot_longer(
      cols = -any_of(c(admin_level_col, 'year')),
      names_to = "indic",
      values_to = "value"
    ) %>%
    pivot_wider( names_from = year, values_from = value) %>%
    mutate(indiclabel = factor(indicator_labels[indic], levels = unname(indicator_labels))) %>%
    arrange(!!!syms(admin_level_col)) %>%
    relocate(!!!syms(admin_level_col), indiclabel)
}

#' Generate Service DQA Summary
#'
#' @param average_reporting_rate Dataframe. Reporting rate data.
#' @param district_reporting_rate Dataframe. District reporting rate data.
#' @param completeness_national Dataframe. National completeness data.
#' @param district_completeness Dataframe. District completeness data.
#' @param outliers_summary Dataframe. National outliers data.
#' @param district_outliers_summary Dataframe. District outliers summary data.
#' @param service_utilization Dataframe. Output of compute_service_utilization('national').
#' @param threshold Numeric. The threshold to display in the label (default: 90).
#' @param labels List. Optional custom labels for sections and indicators.
#' @return A wide-format tibble with summarized DQA indicators grouped by section.
#' @export
generate_service_dqa_summary <- function(average_reporting_rate,
                                         district_reporting_rate,
                                         completeness_national,
                                         district_completeness,
                                         outliers_summary,
                                         district_outliers_summary,
                                         service_utilization,
                                         threshold = 90,
                                         labels = NULL) {
  
  # 1. Prepare Component Summaries
  rr_summary <- average_reporting_rate %>% 
    select(year, opd_rr) %>% 
    left_join(
      district_reporting_rate %>% 
        select(year, district_opd_rr = low_opd_rr),
      by = join_by(year)
    )
  
  completeness_summary <- completeness_national %>% 
    select(year, mis_opd_under5, mis_ipd_under5) %>% 
    left_join(
      district_completeness %>% 
        select(year, districts_no_missing_opd = mis_opd_under5, districts_no_missing_ipd = mis_ipd_under5),
      by = join_by(year)
    )
  
  outlier_summary <- outliers_summary %>% 
    select(year, opd_under5_outlier5std) %>% 
    left_join(
      district_outliers_summary %>% 
        select(year, districts_no_outlier_opd = opd_under5_outlier5std),
      by = join_by(year)
    )
  
  service_summary <- service_utilization %>%
    select(
      year,
      ratio_opd_u5_ipd_u5,
      perc_opd_under5,
      perc_ipd_under5
    )
  
  # 2. Group indicators to avoid repetition
  completeness_inds <- c(
    "opd_rr", "district_opd_rr", "mis_opd_under5", 
    "mis_ipd_under5", "districts_no_missing_opd", "districts_no_missing_ipd"
  )
  outlier_inds <- c(
    "opd_under5_outlier5std", "districts_no_outlier_opd"
  )

  id_map <- c(
    opd_rr                   = "1a",
    district_opd_rr          = "1b",
    mis_opd_under5           = "1c",
    mis_ipd_under5           = "1d",
    districts_no_missing_opd = "1e",
    districts_no_missing_ipd = "1f",
    
    opd_under5_outlier5std   = "2a",
    districts_no_outlier_opd = "2b",
    
    ratio_opd_u5_ipd_u5      = "3a",
    perc_opd_under5          = "3b",
    perc_ipd_under5          = "3c"
  )
  
  # 3. Define Default Labels
  default_labels <- list(
    header = list(
      h1 = "1. Completeness of reporting",
      h2 = "2. Extreme outliers",
      h3 = "3. Service DQA indicators"
    ),
    indicator = list(
      opd_rr                   = "% expected monthly facility reports (National)",
      district_opd_rr          = paste0("% districts with reporting rates >=", threshold),
      mis_opd_under5           = "% non-missing OPD monthly values",
      mis_ipd_under5           = "% non-missing IPD monthly values",
      districts_no_missing_opd = "% districts with no missing OPD values",
      districts_no_missing_ipd = "% districts with no missing IPD values",
      
      opd_under5_outlier5std   = "% OPD monthly values not extreme outliers",
      districts_no_outlier_opd = "% districts with no OPD extreme outliers",
      
      ratio_opd_u5_ipd_u5      = "Ratio OPD/IPD under 5",
      perc_opd_under5          = "% OPD under 5",
      perc_ipd_under5          = "% IPD under 5"
    )
  )
  
  # Override defaults if custom labels are provided
  if (!is.null(labels)) {
    if (!is.null(labels$header)) default_labels$header <- modifyList(default_labels$header, as.list(labels$header))
    if (!is.null(labels$indicator)) default_labels$indicator <- modifyList(default_labels$indicator, as.list(labels$indicator))
  }
  
  # Flatten to named character vectors for fast mapping
  header_map <- unlist(default_labels$header)
  label_map <- unlist(default_labels$indicator)
  
  # 4. Combine, Map, and Reshape
  combined_data <- rr_summary %>% 
    left_join(completeness_summary, by = join_by(year)) %>% 
    left_join(outlier_summary, by = join_by(year)) %>% 
    left_join(service_summary, by = join_by(year)) %>% 
    pivot_longer(
      cols = -year,
      names_to = "indicator",
      values_to = "value" 
    ) %>% 
    mutate(
      indicator_label = coalesce(unname(label_map[indicator]), indicator),
      no = coalesce(unname(id_map[indicator]), '99'),
      header = case_when(
        startsWith(no, "1") ~ unname(header_map["h1"]),
        startsWith(no, "2") ~ unname(header_map["h2"]),
        TRUE                ~ unname(header_map["h3"])
      ),
    ) %>% 
    select(header, no, indicator_label, year, value) %>% 
    pivot_wider(
      names_from = year,
      values_from = value
    ) %>% 
    arrange(no)
  
  new_tibble(
    combined_data,
    class = "cd_utilization_dqa",
    threshold = threshold
  )
}

#' Generate Service Utilization Admin 1 Data
#'
#' @param service_utilization Dataframe containing admin1 service utilization.
#' @param metric_type Character. Either "opd" or "ipd".
#' @return A tibble with class `cd_service_util_admin1`.
#' @export
generate_admin1_service_utilization <- function(service_utilization, metric_type = c("opd", "ipd")) {
  check_cd_class(service_utilization, 'cd_service_utilization')
  if (!'adminlevel_1' %in% colnames(service_utilization)) {
    cd_abort('{.arg service_utilization} must be a subnational dataset')
  }
  metric_type <-arg_match(metric_type)
  
  target_col <- paste0('ratio_', metric_type, '_u5_pop')
  
  df <- service_utilization %>% 
    filter(year == max(year, na.rm = TRUE)) %>% 
    select(adminlevel_1, year, !!sym(target_col))

  new_tibble(
    df,
    class = 'cd_service_utilization_admin1',
    metric_type = metric_type
  )
}

#' Generate MCH vs Curative Index Data
#'
#' @param service_utilization Dataframe containing admin1 service utilization.
#' @return A tibble with class `cd_mch_curative_index`.
#' @export
generate_admin1_mch_curative_index <- function(service_utilization) {
  check_cd_class(service_utilization, 'cd_service_utilization')
  if (!'adminlevel_1' %in% colnames(service_utilization)) {
    cd_abort('{.arg service_utilization} must be a subnational dataset')
  }
 
  df <- service_utilization %>%
    filter(year == max(year, na.rm = TRUE)) %>%
    select(adminlevel_1, year, mch_prev_services_index, curative_services_index)

  new_tibble(
    df,
    class = 'cd_mch_curative_index'
  )
}
