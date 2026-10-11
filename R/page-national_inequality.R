#' National inequality page
#'
#' Shows how coverage differs between the admin level 1 areas of the country, in two cards. The
#' first is the inequality charts ([inequality_ui()]): each area's coverage by year against national
#' coverage, from `cache()$inequality_admin1`. The second is the maps of the same coverage
#' ([subnational_mapping_ui()]), from the dataset's `get_filtered_mapping_data()`; changing the tab
#' of the charts changes the tab of the maps too. Two controls above the maps apply to the maps
#' only: the years to map, which are saved in the dataset (`set_mapping_years()`), and the colour
#' palette.
#'
#' @param id The module's id. A page's id is also its entry in the app's page registry.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `national_inequality_ui()` returns the page's UI as Shiny tags.
#'   `national_inequality_server()` is called for its side effects; its value (the observer that
#'   saves the chosen years) is of no use to a caller.
#'
#' @examples
#' \dontrun{
#' # the page's entry in an app's page registry
#' cd_page_def(
#'   id = "national_inequality",
#'   ui = national_inequality_ui,
#'   server = national_inequality_server,
#'   title = "title_inequ_national",
#'   section = "title_nav_national_analysis",
#'   subtitle = "sub_inequ_national"
#' )
#' }
#'
#' @concept Countdown app pages
#' @export
national_inequality_ui <- function(id, i18n) {
  ns <- NS(id)

  cd_page_ui(id, i18n,
    inequality_ui(ns("inequality"), i18n),
    # Years and palette are for the maps only, so they sit above the map charts rather than in the page-wide bar.
    cd_map_options(
      cd_chip_multi(ns("years"), "title_global_select_years", i18n = i18n),
      cd_palette_chip(ns("palette"), i18n)
    ),
    subnational_mapping_ui(ns("map"), i18n)
  )
}

#' @rdname national_inequality_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The
#'   charts and maps do no work before that.
#' @export
national_inequality_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {

      selected_tab <- inequality_server("inequality", cache, i18n, reactive('adminlevel_1'), active = active)
      subnational_mapping_server("map", cache, i18n, reactive(input$palette), selected_tab, active = active)

      cd_years_sync(input, session, "years",
        years = reactive({ req(cache()); cache()$data_years }),
        selected = reactive({ req(cache()); cache()$mapping_years })
      )

      observeEvent(input$years, {
        req(cache())
        cache()$set_mapping_years(cd_years_input(input$years, cache()$data_years))
      })

    }
  )
}
