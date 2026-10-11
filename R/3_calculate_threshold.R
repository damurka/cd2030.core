#' Calculate coverage/dropout threshold attainment
#'
#' Evaluates administrative regions to determine the percentage that meet specific
#' coverage targets or fall below specific dropout thresholds for a given year.
#'
#' @param .data A tibble of class `cd_indicator_coverage`.
#' @param denominator Character. The denominator used (e.g., `'dhis2'`, `'anc1'`).
#' @param indicator Character. The health indicator group to evaluate (`'anc4'`, `'instlivebirths'`, `'vaccine'`, `'dropout'`).
#'
#' @return A `cd_threshold` object summarizing the percentage of regions meeting the criteria by year.
#'
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' cache <- load_cache_data(path)
#' cache$set_national_estimates(list(sbr = 0.02))
#' cache$adjust_data()
#' coverage <- cache$indicator_coverage_admin1
#'
#' # the percentage of regions that reach the target for institutional live births, by year
#' calculate_threshold(coverage, denominator = "dhis2", indicator = "instlivebirths")
#'
#' # for the three tracer vaccines, with the penta1 denominator
#' calculate_threshold(coverage, denominator = "penta1", indicator = "vaccine")
#'
#' @export
calculate_threshold <- function(.data,
                                denominator = c('dhis2', 'anc1', 'penta1', 'penta1derived', 'anc1derived'),
                                indicator = c('anc4', 'instlivebirths', 'vaccine', 'dropout')) {
  check_cd_indicator_coverage(.data)
  indicator <- arg_match(indicator)
  denominator <- arg_match(denominator)

  admin_level <- attr_or_abort(.data, 'admin_level')
  region <- attr_or_null(.data, 'region')

  admin_level_cols <- get_admin_columns(admin_level, region)

  indicators <- switch(
    indicator,
    vaccine = 'bcg|penta3|measles1',
    dropout = 'dropout_penta13|dropout_penta3mcv1',
    indicator
  )

  targets <- .cd_method$coverage
  coverage <- switch(
    indicator,
    vaccine = if (admin_level == "national") targets$target_vaccine_national else targets$target_vaccine_subnational,
    anc4 = targets$target_anc4,
    instlivebirths = targets$target_instlivebirths,
    dropout = targets$target_dropout
  )

  threshold <- .data %>%
    select(year, any_of(admin_level_cols), matches(paste0('cov_(', indicators, ')_', denominator, '$'))) %>%
    summarise(
      across(starts_with('cov_'), ~ {
        threshold_func <- if (grepl('dropout', cur_column())) {
          function(x) x < targets$target_dropout
        } else {
          function(x) x >= coverage # Using the dynamic coverage variable instead of hardcoded 90
        }
        mean(threshold_func(.x), na.rm = TRUE) * 100
      }),
      .by = year
    )

  new_tibble(
    threshold,
    class = "cd_threshold",
    admin_level = admin_level,
    indicator = indicator,
    region = region,
    threshold = coverage
  )
}

#' Filter high-performing areas by coverage
#'
#' Filters a dataset to retain administrative areas with coverage values
#' above a specified threshold for a given indicator and denominator.
#'
#' @param .data An object of class `cd_indicator_coverage`.
#' @param indicator A string specifying the indicator.
#' @param denominator A string. The denominator used in coverage calculation.
#' @param threshold Numeric. Minimum coverage (in percent, compared after
#'   rounding) an area must reach to be kept. Default is `90`.
#'
#' @return A filtered data frame retaining regions meeting the threshold.
#'
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' cache <- load_cache_data(path)
#' cache$set_national_estimates(list(sbr = 0.02))
#' cache$adjust_data()
#' coverage <- cache$indicator_coverage_admin1
#'
#' filter_high_performers(coverage, indicator = "instlivebirths", denominator = "dhis2")
#' filter_high_performers(coverage, indicator = "instlivebirths", denominator = "dhis2", threshold = 100)
#'
#' @export
filter_high_performers <- function(.data,
                                   indicator,
                                   denominator = c('dhis2', 'anc1', 'penta1', 'penta1derived', 'anc1derived'),
                                   threshold = 90) {
  check_cd_indicator_coverage(.data)
  indicator <- arg_match(indicator, get_analysis_indicators())
  denominator <- arg_match(denominator)

  column <- paste0('cov_', indicator, '_', denominator)
  # a dropout rate meets its target BELOW the threshold, as calculate_threshold() counts it
  meets <- if (grepl('dropout', indicator, fixed = TRUE)) function(x) x < threshold else function(x) x >= threshold

  .data %>%
    mutate(!!sym(column) := round(!!sym(column))) %>%
    filter(meets(!!sym(column))) %>%
    select(any_of(c('adminlevel_1', 'district', 'year', column)))
}
