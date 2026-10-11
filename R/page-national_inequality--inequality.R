#' Sub-national inequality charts
#'
#' The body of the inequality pages: one card of charts with a tab for each of the app's default
#' indicators (`cd_default_indicator_set()`) and a Custom tab for any other analysis indicator. A
#' tab plots, by year, the coverage of every sub-national unit beside the reference coverage held in
#' the inequality table, with the denominator selected for the indicator. It reads the dataset's
#' `get_filtered_inequality()`: `cache()$inequality_admin1` for admin level 1 with no region, and
#' `cache()$inequality_district` otherwise, limited to the region's districts when a region is
#' given. Both tables measure units against the national value; when a region is given the legend
#' names the reference after the region. The piece has no filters of its own: the page gives it the
#' admin level and region.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param title_key The translation key of the card's title. By default the national page's.
#'
#' @return `inequality_ui()` returns the card's UI as Shiny tags. `inequality_server()` returns a
#'   reactive that holds the key of the tab shown: an indicator's name, or `"custom"`. The national
#'   inequality page uses it to show the same tab on its maps.
#'
#' @examples
#' \dontrun{
#' # the charts in a page module, for the admin level 1 areas of the country
#' my_page_ui <- function(id, i18n) {
#'   ns <- NS(id)
#'   cd_page_ui(id, i18n, inequality_ui(ns("inequality"), i18n, title_key = "title_inequ_national"))
#' }
#' my_page_server <- function(id, cache, i18n, active = reactive(TRUE)) {
#'   moduleServer(id, function(input, output, session) {
#'     shown <- inequality_server("inequality", cache, i18n, reactive("adminlevel_1"), active = active)
#'     observe(message("Tab shown: ", shown()))
#'   })
#' }
#' }
#'
#' @concept Countdown app pages
#' @export
inequality_ui <- function(id, i18n, title_key = "title_inequ_national") {
  ns <- NS(id)

  cd_tabbed_charts_ui(ns("inequality"), i18n, title_key, cd_coverage_plot_ui)
}

#' @rdname inequality_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param admin_level A reactive that returns the level of the units compared: `"adminlevel_1"`
#'   (admin level 1) or `"district"`.
#' @param region A reactive that returns the name of an admin level 1 region, to compare its
#'   districts, or `NULL` to compare every unit of the country. A region is accepted only with
#'   `"adminlevel_1"`.
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The
#'   charts do no work before that.
#' @export
inequality_server <- function(id, cache, i18n, admin_level, region = reactive(NULL), active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(admin_level))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns

      indicator <- cd_indicator_server("indicator")

      selected_tab <- cd_tabbed_charts_server(
        "inequality",
        serverInput = function(id, current_indicator) {
          ind <- cd_tab_indicator(current_indicator)
          # active(): see coverage_server() in modules/3_national_coverage/coverage.R for why.
          denom_rx <- reactive({
            req(cache(), active())
            cache()$get_denominator(ind())
          })
          data_rx <- reactive({
            req(cache(), active())
            cache()$get_filtered_inequality(indicator = ind(), admin_level = admin_level(), region = region())
          })

          cd_coverage_plot_server(
            id = id, # or just ind if inside the same module id
            about = .cd_about("inequality", indicator = current_indicator, admin_level = admin_level, region = region, denominator = denom_rx),
            filename = reactive(paste0(ind(), "_", admin_level(), "_inequality_", denom_rx())),
            data_fn = data_rx,
            sheet_name = reactive(i18n$t(paste0("opt_", ind()))),
            plot_fun = function(d) {
              indicator <- i18n$t(paste0("opt_", ind()))
              subtitle <- if (admin_level() == 'adminlevel_1' && is.null(region())) {
                'lbl_inequ_subnat_admin1'
              } else if (admin_level() == 'adminlevel_1' && !is.null(region())) {
                'lbl_inequ_subnat_region'
              } else if (admin_level() == 'district' && is.null(region())) {
                'lbl_inequ_subnat_district'
              } 
              region <- region()
              denominator <- i18n$t(paste0("opt_", denom_rx()))
              plot(d,
                   title = indicator,
                   subtitle = str_glue(i18n$t(subtitle)),
                   x_title = i18n$t("title_global_year"),
                   y_title = str_glue(i18n$t("lbl_axis_y_coverage")),
                   caption = i18n$t(paste0("plt_caption_equity_", denom_rx())),
                   legend_labels = list(
                     subnational = i18n$t("lbl_inequ_coverage_subnat"),
                     national = i18n$t("title_coverage_national"),
                     region = if (is.null(region)) NULL else str_glue(i18n$t("lbl_inequ_coverage_region"))
                   )
              )
            },
            i18n = i18n
          )
        }
      )

      return(selected_tab)
    }
  )
}
