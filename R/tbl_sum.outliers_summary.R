#' Summary for `cd_outlier`
#'
#' Provides a custom summary for the `cd_outlier` object, displaying
#' the percentage of monthly indicator values not considered extreme outliers, aggregated by year.
#' This summary is essential for assessing data quality and trends across indicators.
#'
#' @param x A `cd_outlier` object containing aggregated data quality metrics for monthly values.
#' @param ... Additional arguments for compatibility with S3 methods.
#'
#' @return A character vector summarizing the content and purpose of the data,
#' indicating the proportion of values meeting the criteria for non-outliers by year.
#'
#' @examples
#' data <- load_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#'
#' # the summary is the header printed above the table
#' calculate_outliers_summary(data, admin_level = "national")
#'
#' @export
tbl_sum.cd_outlier <- function(x, ...) {
  c(
    "Table 2a" = "Percentage of monthly values that are not extreme outliers, by year",
    NextMethod()
  )
}

#' Summary for `cd_district_outliers_summary`
#'
#' Provides a summary for the `cd_district_outliers_summary` object, indicating the percentage of districts
#' without extreme outliers for each indicator by year. This summary supports monitoring data quality across
#' districts by showing the proportion of non-extreme values across all indicators.
#'
#' @param x A `cd_district_outliers_summary` object containing the percentage of districts without extreme outliers
#'   for each indicator and year.
#' @param ... Additional arguments for compatibility with S3 methods.
#'
#' @return A character vector describing the purpose and content of the data, highlighting the percentage of districts
#'   with no extreme outliers for each indicator annually.
#'
#' @examples
#' data <- load_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#'
#' # the summary is the header printed above the table
#' calculate_district_outlier_summary(data)
#'
#' @export
tbl_sum.cd_district_outliers_summary <- function(x, ...) {
  c(
    "Table 2b" = "Percentage of districts with no extreme outliers, by year",
    NextMethod()
  )
}
