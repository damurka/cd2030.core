#' Internal consistency page
#'
#' The data quality page on how well related indicators agree with each other. It has two cards
#' and no filters: the ratio chart ([calculate_ratios_ui()]) and the consistency checks, which
#' compare pairs of indicators ([consistency_check_ui()]). Those two pieces read `ratios_summary`
#' and `countdown_data` from the dataset.
#'
#' @param id The module's id. A page's id is also its entry in the app's page registry.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `internal_consistency_ui()` returns the page's UI as Shiny tags.
#'   `internal_consistency_server()` is called for its side effects.
#'
#' @examples
#' \dontrun{
#' # the page's entry in an app's page registry
#' cd_page_def(
#'   id = "internal_consistency",
#'   ui = internal_consistency_ui,
#'   server = internal_consistency_server,
#'   title = "title_consist_main",
#'   section = "lbl_nav_section_quality",
#'   subtitle = "sub_consist_main"
#' )
#' }
#'
#' @concept Countdown app pages
#' @export
internal_consistency_ui <- function(id, i18n) {
  ns <- NS(id)

  cd_page_ui(id, i18n,
    calculate_ratios_ui(ns("ratios"), i18n = i18n),
    consistency_check_ui(ns("consistency"), i18n = i18n)
  )
}

#' @rdname internal_consistency_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The page
#'   does no work before that.
#' @export
internal_consistency_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      calculate_ratios_server("ratios", cache, i18n, active = active)
      consistency_check_server("consistency", cache, i18n, active = active)

    }
  )
}
