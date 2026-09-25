#' Calculate Coverage/Dropout Threshold Attainment
#'
#' Evaluates administrative regions to determine the percentage that meet specific
#' coverage targets or fall below specific dropout thresholds for a given year.
#'
#' @param .data A tibble of class `cd_indicator_coverage`.
#' @param denominator Character. The denominator used (e.g., `'dhis2'`, `'anc1'`).
#' @param indicator Character. The health indicator group to evaluate (`'anc4'`, `'ideliv'`, `'vaccine'`, `'dropout'`).
#'
#' @return A `cd_threshold` object summarizing the percentage of regions meeting the criteria by year.
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

  coverage <- switch(
    indicator,
    vaccine = if (admin_level == "national") 90 else 80,
    anc4 = 70,
    instlivebirths = 80,
    dropout = 10
  )

  threshold <- .data %>%
    select(year, any_of(admin_level_cols), matches(paste0('cov_(', indicators, ')_', denominator, '$'))) %>%
    summarise(
      across(starts_with('cov_'), ~ {
        threshold_func <- if (grepl('dropout', cur_column())) {
          function(x) x < 10
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

#' Filter High-Performing Areas by Coverage
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
#' @export
filter_high_performers <- function(.data,
                                   indicator,
                                   denominator = c('dhis2', 'anc1', 'penta1', 'penta1derived', 'anc1derived'),
                                   threshold = 90) {
  check_cd_indicator_coverage(.data)
  indicator <- arg_match(indicator, get_analysis_indicators())
  denominator <- arg_match(denominator)

  column <- paste0('cov_', indicator, '_', denominator)

  .data %>%
    mutate(!!sym(column) := round(!!sym(column))) %>%
    filter(!!sym(column) >= threshold) %>%
    select(any_of(c('adminlevel_1', 'district', 'year', column)))
}
