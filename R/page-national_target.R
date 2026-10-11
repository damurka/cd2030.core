#' National coverage target page
#'
#' Shows how much of the country meets the coverage targets. One filter chooses the admin level
#' (admin level 1 or district). The page is the target charts and table ([target_ui()]) for the
#' whole country: by year, the percentage of regions or districts that meet each target group's
#' target (the dataset's `get_filtered_threshold()`), and a table of the areas whose coverage of a
#' chosen indicator reaches the target (the dataset's `get_high_performers()`).
#'
#' @param id The module's id. A page's id is also its entry in the app's page registry.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `national_target_ui()` returns the page's UI as Shiny tags. `national_target_server()`
#'   returns what [target_server()] returns: a reactive that holds the key of the tab shown.
#'
#' @examples
#' \dontrun{
#' # the page's entry in an app's page registry
#' cd_page_def(
#'   id = "national_target",
#'   ui = national_target_ui,
#'   server = national_target_server,
#'   title = "title_nav_global_coverage",
#'   section = "title_nav_national_analysis",
#'   subtitle = "sub_target_national"
#' )
#' }
#'
#' @concept Countdown app pages
#' @export
national_target_ui <- function(id, i18n) {
  cd_scoped_page_ui(id, i18n, cd_scope("level"), target_ui)
}

#' @rdname national_target_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The page
#'   does no work before that.
#' @export
national_target_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  cd_scoped_page_server(id, cache, i18n, cd_scope("level"), target_server, active)
}
