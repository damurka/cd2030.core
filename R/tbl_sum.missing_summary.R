#' Summary for `cd_completeness_summary`
#'
#' Provides the header shown when a `cd_completeness_summary` object is printed. It labels the
#' table as the percentage of monthly values with complete (non-missing) data, by year, ahead of
#' the usual tibble header.
#'
#' @param x A `cd_completeness_summary` object containing yearly data completeness metrics.
#' @param ... Additional arguments for compatibility with S3 methods.
#'
#' @return A character vector that summarizes the data content and purpose,
#' specifically indicating the proportion of values that are complete across years.
#'
#' @examples
#' \dontrun{
#' # Generate a summary of data completeness by year
#' tbl_sum(cd_completeness_summary_object)
#' }
#'
#' @export
tbl_sum.cd_completeness_summary <- function(x, ...) {
  c(
    "Table 4a" = "Percentage of monthly values with complete data, by year",
    NextMethod()
  )
}

#' Summary for `cd_missing_district`
#'
#' Provides a custom summary for the `cd_missing_district` object,
#' showing the percentage of districts with complete (non-missing) data aggregated
#' by year. This summary helps users understand the distribution of data completeness
#' at the district level across time.
#'
#' @param x A `cd_missing_district` object containing yearly district-level
#'   data completeness metrics.
#' @param ... Additional arguments for compatibility with S3 methods.
#'
#' @return A character vector that summarizes the data content and purpose,
#' indicating the percentage of districts with complete data across years.
#'
#' @examples
#' \dontrun{
#' # Generate a summary of district-level data completeness by year
#' tbl_sum(calculate_district_completeness_summary(data))
#' }
#'
#' @export
tbl_sum.cd_missing_district <- function(x, ...) {
  c(
    "Table 4b" = "Percentage of districts with complete data, by year",
    NextMethod()
  )
}
