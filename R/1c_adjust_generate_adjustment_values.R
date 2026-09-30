#' Generate Adjusted and Unadjusted Service Counts by Year
#'
#' `generate_adjustment_values` calculates yearly unadjusted and adjusted service counts
#' for each indicator within a `cd_data` dataset, applying the specified adjustment type.
#' It provides a comparison of raw and adjusted values for analysis purposes.
#'
#' @param .data A `cd_data` dataframe containing service data for adjustments.
#' @param adjustment A character string specifying the adjustment type:
#'   - `"default"`: Applies preset k-factors (e.g., 0.25) for each indicator group.
#'   - `"custom"`: Uses user-specified `k_factors` values for each indicator group.
#'   - `"none"`: Skips adjustments, returning only the raw data.
#' @param k_factors A named numeric vector of custom k-factor values between 0 and 1 for
#'   each indicator group (e.g., `c(anc = 0.3, idelv = 0.2, ...)`). Required if
#'   `adjustment = "custom"`.
#' @param settings The adjustment settings ([adjust_service_data()]): when given, the counts after each step are
#'   given too (`_completeness`, `_outliers`), and the reported counts are those of the data kept (the removed years
#'   and areas left out).
#' @param area,level One area only: a region (`level = "adminlevel_1"`) or a district (`"district"`); `NULL`, all.
#'
#' @details This function performs the following steps:
#'   1. **Data Validation**: Ensures `.data` is of the `cd_data` class and `adjustment`
#'      is correctly specified.
#'   2. **Unadjusted Summation**: Calculates the yearly sums of unadjusted service counts.
#'   3. **Adjusted Summation**: Applies [adjust_service_data()] to compute adjusted values,
#'      then calculates the yearly sums.
#'   4. **Combining Results**: Merges unadjusted and adjusted yearly counts for comparison.
#'
#' @return A `cd_adjustment_values` tibble containing:
#'   - Columns for unadjusted values, suffixed with `_raw`.
#'   - Columns for adjusted values, suffixed with `_adj`.
#'   - A `year` column indicating the year of each count.
#'
#' @seealso [adjust_service_data()] for the detailed adjustment function.
#'
#' @examples
#' \dontrun{
#' # Generate adjustment values with default k-factors
#' adjustment_values_default <- generate_adjustment_values(data, adjustment = "default")
#'
#' # Generate adjustment values with custom k-factors
#' custom_k <- c(anc = 0.3, idelv = 0.2, pnc = 0.35, vacc = 0.4, opd = 0.3, ipd = 0.25)
#' adjustment_values_custom <-
#'   generate_adjustment_values(data, adjustment = "custom", k_factors = custom_k)
#'
#' # Generate unadjusted values only
#' unadjusted_values <- generate_adjustment_values(data, adjustment = "none")
#' }
#'
#' @export
generate_adjustment_values <- function(.data,
                                       adjustment = c("default", "custom", "none"),
                                       k_factors = NULL,
                                       settings = NULL,
                                       area = NULL,
                                       level = c("adminlevel_1", "district")) {
  year <- NULL

  check_cd_data(.data)
  adjustment <- arg_match(adjustment)
  level <- arg_match(level)

  all_indicators <- get_all_indicators()
  if (!is.null(area)) {
    keep <- if (level == "district") .data$district %in% area else .data$adminlevel_1 %in% area
    .data <- .data[keep, , drop = FALSE]
  }
  yearly <- function(d, suffix) {
    d %>%
      summarise(across(any_of(all_indicators), ~ sum(.x, na.rm = TRUE)), .by = year) %>%
      rename_with(~ paste0(.x, suffix), any_of(all_indicators))
  }

  if (is.null(settings)) {
    unadjusted_data <- yearly(.data, "_raw")
    adjusted_data <- yearly(adjust_service_data(.data, adjustment, k_factors), "_adj")
    combined_data <- unadjusted_data %>% left_join(adjusted_data, by = "year")
    return(new_tibble(combined_data, class = "cd_adjustment_values"))
  }

  # the reported counts of the data kept, then the counts after each step
  settings <- adjustment_settings_check(settings)
  steps <- adjust_service_data(.data, settings = settings, steps = TRUE)
  combined_data <- yearly(.adjust_remove(.data, settings), "_raw") %>%
    left_join(yearly(steps$completeness, "_completeness"), by = "year") %>%
    left_join(yearly(steps$outliers, "_outliers"), by = "year") %>%
    left_join(yearly(steps$missing, "_adj"), by = "year") %>%
    arrange(year)

  new_tibble(
    combined_data,
    class = "cd_adjustment_values",
    steps = TRUE,
    area = area,
    level = if (!is.null(area)) level
  )
}

#' Filter one indicator’s adjustment values
#'
#' Keeps `year` and the two columns for a single indicator’s raw and adjusted
#' values, e.g. `anc1_raw` and `anc1_adj`.
#'
#' @param .data A tibble of class `cd_adjustment_values`.
#' @param indicator A single indicator name. Must be one of `get_all_indicators()`.
#'
#' @return A tibble with class `cd_adjustment_values_filtered` containing:
#'   - `year`
#'   - `<indicator>_raw`
#'   - `<indicator>_adj`
#'
#' The result carries an attribute `indicator` with the selected indicator.
#'
#' @examples
#' \dontrun{
#' x <- filter_adjustment_value(adj_values, "anc1")
#' attr(x, "indicator")   # "anc1"
#' }
#' @export
filter_adjustment_value <- function(.data, indicator) {
  check_cd_class(.data, 'cd_adjustment_values')
  indicator <- arg_match(indicator, get_all_indicators())

  data <- .data %>%
    select(year, any_of(paste0(indicator, c("_raw", "_completeness", "_outliers", "_adj")))) %>%
    mutate(
      # Calculate the difference and percentage difference
      diff = get(paste0(indicator, "_adj")) - get(paste0(indicator, "_raw")),
      perc_diff = (diff / get(paste0(indicator, "_raw"))) * 100
    ) %>%
    select(-diff, -perc_diff)

  new_tibble(
    data,
    class = 'cd_adjustment_values_filtered',
    indicator = indicator,
    steps = isTRUE(attr(.data, "steps"))
  )
}
