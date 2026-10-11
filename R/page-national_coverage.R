#' National coverage page
#'
#' Shows national coverage by year for each indicator: the estimate from the health facility data,
#' with the denominator selected for the indicator, beside the survey and WUENIC estimates. The page
#' is the coverage charts ([coverage_ui()]) at the national level: one card with a tab for each
#' indicator in `cd_cfg("nat_cov_indicators")` and a Custom tab. It has no filters. The data come
#' from the dataset's `get_filtered_coverage()`, which reads
#' `cache()$calculate_coverage("national")`.
#'
#' @param id The module's id. A page's id is also its entry in the app's page registry.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `national_coverage_ui()` returns the page's UI as Shiny tags.
#'   `national_coverage_server()` returns what [coverage_server()] returns: a reactive that holds
#'   the key of the tab shown.
#'
#' @examples
#' \dontrun{
#' # the page's entry in an app's page registry
#' cd_page_def(
#'   id = "national_coverage",
#'   ui = national_coverage_ui,
#'   server = national_coverage_server,
#'   title = "title_coverage_national",
#'   section = "title_nav_national_analysis",
#'   subtitle = "sub_cov_national"
#' )
#' }
#'
#' @concept Countdown app pages
#' @export
national_coverage_ui <- function(id, i18n) {
  cd_scoped_page_ui(id, i18n, cd_scope("national"), coverage_ui, "title_coverage_national")
}

#' @rdname national_coverage_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The page
#'   does no work before that.
#' @export
national_coverage_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  cd_scoped_page_server(id, cache, i18n, cd_scope("national"), coverage_server, active)
}
