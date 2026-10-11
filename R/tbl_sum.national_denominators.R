#' Summary for `cd_population_metrics`
#'
#' The print header of the population table [prepare_population_metrics()] gives: the population, births and
#' under-ones from DHIS2, beside the UN's at national level.
#'
#' @param x A `cd_population_metrics` object.
#' @param ... Additional arguments (not used).
#'
#' @return A character vector: the table's title, the country and the default header.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$set_national_estimates(list(sbr = 0.02))
#' cache$adjust_data()
#'
#' # the summary is the header printed above the table
#' cache$denominator_metrics
#'
#' @export
tbl_sum.cd_population_metrics <- function(x, ...) {
  c(
    "Table 2a" = "Total Population and Live Birth by Source",
    "Country" = attr(x, "country") %||% "",
    NextMethod()
  )
}
