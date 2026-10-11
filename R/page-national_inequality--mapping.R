#' Sub-national coverage maps
#'
#' The maps of the national inequality page: one card with a tab for each of the app's default
#' indicators (`cd_default_indicator_set()`) and a Custom tab for any other analysis indicator. A
#' tab draws maps of the indicator's coverage in each admin level 1 area, with the denominator
#' selected for the indicator, for the years chosen for mapping (`cache()$mapping_years`). It reads
#' the dataset's `get_filtered_mapping_data()`, which joins the admin level 1 coverage to the map
#' through the dataset's map mapping. The piece has no filters of its own: the page gives it the
#' colour palette and the tab to show.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `subnational_mapping_ui()` returns the card's UI as Shiny tags.
#'   `subnational_mapping_server()` returns a reactive that holds the key of the tab shown: an
#'   indicator's name, or `"custom"`.
#'
#' @examples
#' \dontrun{
#' # the maps below the inequality charts, showing the tab the charts show
#' my_page_ui <- function(id, i18n) {
#'   ns <- NS(id)
#'   cd_page_ui(id, i18n,
#'     inequality_ui(ns("inequality"), i18n),
#'     cd_map_options(cd_palette_chip(ns("palette"), i18n)),
#'     subnational_mapping_ui(ns("map"), i18n)
#'   )
#' }
#' my_page_server <- function(id, cache, i18n, active = reactive(TRUE)) {
#'   moduleServer(id, function(input, output, session) {
#'     selected_tab <- inequality_server("inequality", cache, i18n, reactive("adminlevel_1"), active = active)
#'     subnational_mapping_server("map", cache, i18n, reactive(input$palette), selected_tab, active = active)
#'   })
#' }
#' }
#'
#' @concept Countdown app pages
#' @export
subnational_mapping_ui <- function(id, i18n) {
  ns <- NS(id)
  cd_tabbed_charts_ui(ns("maps"), i18n, "title_mapping_subnational", cd_coverage_plot_ui)
}

#' @rdname subnational_mapping_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param palette A reactive that returns the name of the maps' colour palette (for example
#'   `"Greens"`).
#' @param selected_tab A reactive that returns the key of the tab to show, or `NULL` to leave the
#'   tabs as they are. When its value changes, the maps switch to that tab.
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The maps
#'   do no work before that.
#' @export
subnational_mapping_server <- function(id, cache, i18n, palette, selected_tab, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(palette))
  stopifnot(is.reactive(selected_tab))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {

      cd_tabbed_charts_server(
        "maps",
        serverInput = function(id, current_indicator) {
          ind <- cd_tab_indicator(current_indicator)
          # active(): see coverage_server() in modules/3_national_coverage/coverage.R for why.
          denom_rx <- reactive({
            req(cache(), active())
            cache()$get_denominator(ind())
          })
          data_rx <- reactive({
            req(cache(), active())
            cache()$get_filtered_mapping_data(ind(), "adminlevel_1", palette())
          })

          cd_coverage_plot_server(
            id = id, # or just ind if inside the same module id
            about = .cd_about("map", indicator = current_indicator, denominator = denom_rx),
            filename = reactive(paste0(ind(), "_adminlevel_1_map_", denom_rx())),
            data_fn = data_rx,
            sheet_name = reactive(i18n$t(paste0("opt_", ind()))),
            plot_fun = function(d) {
              indicator <- i18n$t(paste0("opt_", ind()))
              plot(d,
                   title = str_glue(i18n$t("plt_title_map_dist")),
                   caption = i18n$t("plt_caption_map_dhis2"),
                   legend_title = str_glue(i18n$t("lbl_axis_y_coverage"))
              )
            },
            i18n = i18n
          )
        },
        selected_tab = selected_tab
      )
    }
  )
}
