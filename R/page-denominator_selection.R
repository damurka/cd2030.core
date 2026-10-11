#' Denominator selection page
#'
#' The page where the person compares the candidate denominators and chooses the ones the analysis
#' uses. It has three cards: coverage from each denominator beside the survey estimate
#' ([survey_comparison_ui()]), coverage by admin level 1 area ([subnational_denominator_ui()]) and
#' coverage over the years ([coverage_trends_ui()]). The filters are the denominator for the
#' vaccination indicators, the denominator for the maternal indicators (only in an app that has
#' them, see [cd_has_maternal()]) and the admin level, which includes national, with its region.
#' The denominator filters are also where the choice is made ([cd_denominator_ui()]): they show
#' the dataset's `denominator` and `maternal_denominator`, and a change is saved there.
#'
#' @param id The module's id. A page's id is also its entry in the app's page registry.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `denominator_selection_ui()` returns the page's UI as Shiny tags.
#'   `denominator_selection_server()` is called for its side effects.
#'
#' @examples
#' \dontrun{
#' # the page's entry in an app's page registry
#' cd_page_def(
#'   id = "denominator_selection",
#'   ui = denominator_selection_ui,
#'   server = denominator_selection_server,
#'   title = "title_denom_selection",
#'   section = "lbl_nav_section_denominators",
#'   subtitle = "sub_denom_selection"
#' )
#' }
#'
#' @concept Countdown app pages
#' @export
denominator_selection_ui <- function(id, i18n) {
  ns <- NS(id)

  cd_page_ui(id, i18n,
    filters = cd_filter_bar(
      if (cd_has_maternal()) cd_denominator_ui(ns("maternal_denominator"), i18n, allow_input = TRUE, is_maternal = TRUE),
      cd_denominator_ui(ns("vaxx_denominator"), i18n, allow_input = TRUE),
      cd_admin_level_ui(ns("admin_level"), i18n, include_national = TRUE)
    ),
    survey_comparison_ui(ns("survey"), i18n),
    subnational_denominator_ui(ns('subnational'), i18n),
    coverage_trends_ui(ns("coverage"), i18n)
  )
}

#' @rdname denominator_selection_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The
#'   page's three cards do no work before that.
#' @export
denominator_selection_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      if (cd_has_maternal()) cd_denominator_server("maternal_denominator", cache, i18n, allowInput = TRUE, is_maternal = TRUE)
      cd_denominator_server("vaxx_denominator", cache, i18n, allowInput = TRUE)
      admin <- cd_admin_level_server("admin_level", cache, i18n)

      admin_parts <- cd_admin_parts(admin)
      admin_level <- admin_parts$admin_level
      region <- admin_parts$region

      coverage_trends_server("coverage", cache, admin_level, region, i18n, active = active)
      survey_comparison_server("survey", cache, admin_level, region, i18n, active = active)
      subnational_denominator_server('subnational', cache, i18n, active = active)

    }
  )
}
