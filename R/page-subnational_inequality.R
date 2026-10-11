#' Sub-national inequality page
#'
#' Shows how coverage differs between districts. A filter chooses the admin level. With admin level
#' 1, a second filter chooses a region, and the charts show the coverage of that region's districts;
#' they wait until a region is chosen. With district, there is no second filter and the charts show
#' every district of the country. The page is the inequality charts ([inequality_ui()]), which read
#' `cache()$inequality_district` through the dataset's `get_filtered_inequality()`; that table
#' measures each district against the national value.
#'
#' @param id The module's id. A page's id is also its entry in the app's page registry.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `subnational_inequality_ui()` returns the page's UI as Shiny tags.
#'   `subnational_inequality_server()` returns what [inequality_server()] returns: a reactive that
#'   holds the key of the tab shown.
#'
#' @examples
#' \dontrun{
#' # the page's entry in an app's page registry
#' cd_page_def(
#'   id = "subnational_inequality",
#'   ui = subnational_inequality_ui,
#'   server = subnational_inequality_server,
#'   title = "title_inequ_subnational",
#'   section = "title_nav_subnational_analysis",
#'   subtitle = "sub_inequ_subnational"
#' )
#' }
#'
#' @concept Countdown app pages
#' @export
subnational_inequality_ui <- function(id, i18n) {
  cd_scoped_page_ui(id, i18n, cd_scope("level_region"), inequality_ui, title_key = "title_inequ_subnational")
}

#' @rdname subnational_inequality_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The page
#'   does no work before that.
#' @export
subnational_inequality_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  cd_scoped_page_server(id, cache, i18n, cd_scope("level_region"), inequality_server, active)
}
