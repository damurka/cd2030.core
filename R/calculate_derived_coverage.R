#' Generate Coverage Data with Derived Denominators
#'
#' Calculates trend-adjusted and subnationally-redistributed coverage estimates
#' using the DTP1-derived denominator logic described in CD2030. It estimates
#' coverage over time based on changes in DHIS2 population counts, while preserving
#' subnational proportions from the base year.
#'
#' This allows estimating:
#' - Trends over time in coverage
#' - Subnational inequities
#'
#' @param .data A `cd_population_metrics` object containing indicator values and DHIS2 population.
#' @param indicator A character string specifying the indicator to calculate coverage for.
#' @param survey_year Integer. The year from which denominator proportions are derived.
#'
#' @return A `cd_derived_coverage` tibble with columns for old and new coverage estimates.
#'
#' @examples
#' calculate_derived_coverage(dhis_data, "penta1", 2019)
#'
#' @export
calculate_derived_coverage <- function(.data, indicator, derivation = c('anc1', 'penta1')) {
  check_cd_population(.data)
  indicator <- arg_match(indicator, get_all_indicators())
  derivation <- arg_match(derivation)

  population <- attr_or_abort(.data, 'population')
  admin_level <- attr_or_abort(.data, 'admin_level')
  region <- attr_or_null(.data, 'region')

  group_vars <- get_admin_columns(admin_level, region)
  penta1_denom <- get_population_column(indicator, derivation)
  penta1_derived_denom_diff <- paste0(penta1_denom, 'derived_diff')
  penta1_derived_denom_exp <- paste0(penta1_denom, 'derived_exp')
  cov_penta1 <- paste0('cov_', indicator, '_', derivation)
  cov_anc1 <- paste0('cov_', indicator, '_', derivation)
  cov_dhis2 <- paste0('cov_', indicator, '_dhis2')
  cov_un <- paste0('cov_', indicator, '_un')
  cov_penta1_derived_diff <- paste0(cov_penta1, 'derived_diff')
  cov_penta1_derived_exp <- paste0(cov_penta1, 'derived_exp')

  data <- .data %>%
    select(any_of(c(group_vars, 'year', population, 'population_growth_change_exp', 'population_growth_change_diff', 
                   'population_proportion', indicator, penta1_denom, penta1_derived_denom_diff, penta1_derived_denom_exp,
                    cov_penta1, cov_anc1, cov_dhis2, cov_un, cov_penta1_derived_diff, cov_penta1_derived_exp)))

  # Return final tibble tagged with admin level
  new_tibble(
    data,
    class = "cd_derived_coverage",
    admin_level = admin_level,
    indicator = indicator
  )
}
