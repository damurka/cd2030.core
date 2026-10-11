#' Sub-national coverage page
#'
#' Shows coverage by year for one region or one district: the estimate from the health facility
#' data, with the denominator selected for the indicator, beside the survey and WUENIC estimates.
#' Two filters choose the admin level (admin level 1 or district) and then the area at that level;
#' the charts wait until an area is chosen. The page is the coverage charts ([coverage_ui()]) for
#' that area: one card with a tab for each indicator in `cd_cfg("nat_cov_indicators")` and a Custom
#' tab. The data come from the dataset's `get_filtered_coverage()`, which reads
#' `cache()$calculate_coverage()` for the chosen level.
#'
#' @param id The module's id. A page's id is also its entry in the app's page registry.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `subnational_coverage_ui()` returns the page's UI as Shiny tags.
#'   `subnational_coverage_server()` returns what [coverage_server()] returns: a reactive that holds
#'   the key of the tab shown.
#'
#' @examples
#' \dontrun{
#' # the page's entry in an app's page registry
#' cd_page_def(
#'   id = "subnational_coverage",
#'   ui = subnational_coverage_ui,
#'   server = subnational_coverage_server,
#'   title = "title_nav_subnational_coverage",
#'   section = "title_nav_subnational_analysis",
#'   subtitle = "sub_cov_subnational"
#' )
#' }
#'
#' @concept Countdown app pages
#' @export
subnational_coverage_ui <- function(id, i18n) {
  cd_scoped_page_ui(id, i18n, cd_scope("level_region", show_district = TRUE), coverage_ui, "title_nav_subnational_coverage")
}

#' @rdname subnational_coverage_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The page
#'   does no work before that.
#' @export
subnational_coverage_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  cd_scoped_page_server(id, cache, i18n, cd_scope("level_region", show_district = TRUE), coverage_server, active)
}
