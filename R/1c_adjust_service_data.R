#' Adjust Service Data for Coverage Analysis
#'
#' The `adjust_service_data` function processes DHIS-2 health service data, correcting
#' for incomplete reporting, applying k-factor adjustments for accurate scaling, and managing
#' outliers for consistency in data analysis. This standardization supports reliable
#' comparisons in immunization coverage and health service utilization studies.
#'
#' @param .data A `cd_data` dataframe, typically containing health facility data
#'   from DHIS-2 with monthly service counts by district.
#' @param adjustment A character string specifying the type of adjustment to apply:
#'   - **"default"**: Applies a default k-factor of 0.25 across all indicator groups.
#'   - **"custom"**: Uses user-defined `k_factors` for different indicator groups, with
#'       values between 0 and 1.
#'   - **"none"**: Returns the data without any adjustments.
#' @param k_factors A named numeric vector of custom k-factor values between 0 and 1
#'   for each indicator group (e.g., `c(anc = 0.3, idelv = 0.2, ...)`). Used only if
#'   `adjustment = "custom"`.
#' @param settings The adjustment settings ([adjustment_settings_default()]; the Data Adjustment page's): the years
#'   and areas removed, and each indicator's k, outlier and missing-value switches, everywhere or for an area. When
#'   given, `adjustment` and `k_factors` are not used.
#' @param steps `TRUE`: a list of the data after each step (`completeness`, `outliers`, `missing`), for showing what
#'   each changed (see [generate_adjustment_values()]).
#'
#' @details
#' This function prepares service data through a series of steps to ensure data quality and consistency:
#'
#'   1. **Validation**: Checks the structure of `.data` and ensures that the `adjustment`
#'      argument is valid. For `custom` adjustments, `k_factors` must be specified and contain valid values.
#'
#'   2. **k-Factor Defaults**: Default k-factor values are set to 0.25 for each indicator group,
#'      unless overridden by user-provided values in `k_factors`.
#'
#'   3. **Reporting Completeness**: Flags any district-year reporting rates below 75% and imputes
#'      missing data using district-level medians to account for reporting inconsistencies.
#'
#'   4. **k-Factor Scaling**: Adjusts service counts based on the k-factor and reporting rate using
#'      the following scaling formula:
#'      \deqn{AdjustedValue = Value \times \left(1 + \left(\frac{1}{ReportingRate/100} - 1\right) \times k\right)}
#'      where \code{ReportingRate} is the reporting rate in percent, and \code{k} is the k-factor for the indicator group.
#'
#'   5. **Outlier Detection**: Identifies and flags extreme outliers using Hampel's X84 method, marking
#'      values that exceed 5 Median Absolute Deviations (MAD) from the median.
#'
#'   6. **Data Imputation**: Replaces remaining missing values with district-level medians to ensure
#'      data completeness.
#'
#' @return A `cd_adjusted_data` object containing adjusted service data, where outliers are flagged
#'   and managed, and missing values are imputed.
#'
#' @seealso [new_countdown()] for creating `cd_data` objects and [generate_adjustment_values()]
#' for generating adjustment summaries.
#'
#' @examples
#' \dontrun{
#' # Default adjustment
#' adjusted_data <- adjust_service_data(data, adjustment = "default")
#'
#' # Custom adjustment with specific k-factors
#' custom_k <- c(
#'   anc = 0.3, idelv = 0.2, pnc = 0.35, vacc = 0.4,
#'   opd = 0.3, ipd = 0.25
#' )
#' adjusted_data_custom <- adjust_service_data(data,
#'   adjustment = "custom",
#'   k_factors = custom_k
#' )
#'
#' # No adjustment
#' unadjusted_data <- adjust_service_data(data, adjustment = "none")
#' }
#'
#' @export
adjust_service_data <- function(.data,
                                adjustment = c("default", "custom", "none"),
                                k_factors = NULL,
                                settings = NULL,
                                steps = FALSE) {
  district = year = month = NULL

  check_cd_data(.data)

  adjustment <- arg_match(adjustment)

  if (is.null(settings)) {
    if (adjustment == "none") {
      cd_info(c("i" = "No adjustment applied. Data returned as-is."))
      return(new_countdown(.data, "cd_adjusted_data"))
    }
    if (adjustment == "custom") {
      if (is.null(k_factors) || any(k_factors < 0 | k_factors > 1)) {
        cd_abort(c("x" = "k_factors must be a numeric vector with values between 0 and 1 for each indicator group."))
      }
      settings <- adjustment_settings_from_k(k_factors)
    } else {
      settings <- adjustment_settings_default(groups = .cd_method$adjustment$k_groups)
    }
  }
  settings <- adjustment_settings_check(settings)

  # the data kept: the years and areas removed go (their population with them: it is on the same rows)
  .data <- .adjust_remove(.data, settings)

  indicator_groups <- get_indicator_groups()
  all_indicators <- get_adjustment_indicators()
  outlier_indicators <- c(all_indicators, "ipd_total", "ipd_under5")
  rr_window <- .cd_method$adjustment$reporting_rate_window
  rr_cutoff <- .cd_method$adjustment$reporting_rate_cutoff

  # each district's k and switches for each indicator (its own settings, its region's, everywhere's)
  plan <- .adjust_plan(distinct(.data, adminlevel_1, district), settings, all_indicators, intersect(outlier_indicators, names(.data)))
  plan_cols <- setdiff(names(plan), "district")
  clean <- function(d) d %>% select(-any_of(c(paste0(all_indicators, "_rr"), plan_cols)))

  # 1. completeness: each value scaled by its reporting rate and its k (a rate below the cutoff, or missing, replaced by
  # the district's median of the rates within the window first)
  completeness <- .data %>%
    left_join(plan, by = "district") %>%
    mutate(
      across(
        all_of(all_indicators),
        ~ get(paste0(names(keep(indicator_groups, ~ cur_column() %in% .x)), "_rr")),
        .names = "{.col}_rr"
      ),
    ) %>%
    mutate(
      across(
        all_of(paste0(all_indicators, "_rr")),
        ~ if_else(. < rr_cutoff | is.na(.), median(.[. >= rr_window[1] & . <= rr_window[2]], na.rm = TRUE), .)
      ),
      .by = district
    ) %>%
    arrange(district, year, month) %>%
    mutate(
      across(
        all_of(all_indicators),
        ~ {
          rate <- get(paste0(cur_column(), "_rr"))
          k_value <- get(paste0("k__", cur_column()))
          if_else(
            !is.na(rate) & rate != 0,
            round(. * (1 + (1 / (rate / 100) - 1) * k_value), 1),
            .
          )
        }
      )
    )

  # 2. outliers: a month more than 5 x MAD from the district's median replaced by the district's median for the year
  # (the months that are not outliers), where the indicator's outliers are corrected
  outliers <- completeness %>%
    add_outlier5std_column(intersect(outlier_indicators, names(completeness))) %>%
    mutate(
      across(
        all_of(intersect(outlier_indicators, names(completeness))),
        ~ {
          outlier <- get(paste0(cur_column(), "_outlier5std"))
          correct <- get(paste0("out__", cur_column()))
          med <- round(median(if_else(outlier != 1, ., NA_real_), na.rm = TRUE), 0)

          if_else(outlier == 1 & correct, robust_max(med), .)
        }
      ),
      .by = c(district, year)
    )

  # 3. missing values: an empty month filled with the district's median for the year, where the indicator's missing
  # values are filled
  missing <- outliers %>%
    mutate(
      across(
        all_of(all_indicators),
        ~ {
          fill <- get(paste0("miss__", cur_column()))
          med <- round(median(if_else(!is.na(.), ., NA_real_), na.rm = TRUE), 0)
          max_med <- robust_max(med)
          if_else(
            is.na(.) & !is.na(max_med) & fill,
            max_med,
            .
          )
        }
      ),
      .by = c(district, year)
    )

  # (a district-year removed on purpose leaves that district out of that year: the check for it is not run then)
  out <- new_countdown(clean(missing), "cd_adjusted_data", indicator_group = get_selected_group(), validate = !length(settings$removals))
  attr(out, "adjustment_settings") <- settings
  if (isTRUE(steps)) {
    return(list(completeness = clean(completeness), outliers = clean(outliers), missing = out))
  }
  out
}
