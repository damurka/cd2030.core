#' Coverage trends by denominator card
#'
#' A card of the Denominator selection page ([denominator_selection_ui()]) with one tab per
#' indicator (the app's `cov_trend_indicators` setting). Each tab has a chart of the indicator's
#' coverage over the years, with one line per denominator the app offers, for the country or for
#' the chosen region. The card has no filters of its own: the page passes it the admin level and
#' the region. It calls the dataset's `calculate_derived_coverage()`, and draws nothing until the
#' dataset's `check_inequality_params` is `TRUE`.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `coverage_trends_ui()` returns the card's UI as Shiny tags. `coverage_trends_server()`
#'   is called for its side effects.
#'
#' @examples
#' \dontrun{
#' # the card in a page that has an admin level filter, as the Denominator selection page does
#' my_page_ui <- function(id, i18n) {
#'   ns <- NS(id)
#'   cd_page_ui(id, i18n,
#'     filters = cd_filter_bar(cd_admin_level_ui(ns("admin_level"), i18n, include_national = TRUE)),
#'     coverage_trends_ui(ns("coverage"), i18n)
#'   )
#' }
#' my_page_server <- function(id, cache, i18n, active = reactive(TRUE)) {
#'   moduleServer(id, function(input, output, session) {
#'     admin <- cd_admin_parts(cd_admin_level_server("admin_level", cache, i18n))
#'     coverage_trends_server("coverage", cache, admin$admin_level, admin$region, i18n, active = active)
#'   })
#' }
#' }
#'
#' @concept Countdown app pages
#' @export
coverage_trends_ui <- function(id, i18n) {
  ns <- NS(id)
  cd_tabbed_charts_ui(
    ns("panel"), 
    i18n, 
    "title_denom_pop_trend",
    uiInput = cd_coverage_plot_ui,
    indicators = cd_cfg("cov_trend_indicators"),
        showCustom = FALSE
  )
}

#' @rdname coverage_trends_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param admin_level A reactive that returns the admin level of the chart: `"national"`,
#'   `"adminlevel_1"` or `"district"`.
#' @param region A reactive that returns the name of the chosen region, or `NULL` when none is
#'   chosen. For an admin level other than national, the chart is drawn only once a region is
#'   chosen.
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The card
#'   does no work before that.
#' @export
coverage_trends_server <- function(id, cache, admin_level, region, i18n, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(admin_level))
  stopifnot(is.reactive(region))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns

      cd_tabbed_charts_server(
        "panel",
        serverInput = function(id, current_indicator) {
          # active(): see coverage_server() in modules/3_national_coverage/coverage.R for why.
          coverage <- reactive({
            req(cache(), active(), cache()$check_inequality_params, admin_level())
            cache()$calculate_derived_coverage(current_indicator, admin_level(), region())
          })

          cd_coverage_plot_server(
            id = id, # or just ind if inside the same module id
            about = .cd_about("derived_coverage_trend", indicator = current_indicator, admin_level = admin_level, region = region),
            filename = reactive(paste0("sheet_", current_indicator, "_derived_coverage")),
            data_fn = coverage,
            sheet_name = reactive(i18n$t(paste0(current_indicator, "_derived_coverage"))),
            plot_fun = function(d) {
              req(admin_level())
              if (admin_level() != "national") req(region())
              region_name <- region()
              title <- if (is.null(region())) "plt_title_denom_nat_trend" else "plt_title_denom_subnat_trend"
              indicator <- i18n$t(paste0("opt_", current_indicator))
              plot(d, 
                   type = 'trend',
                   region = region(),
                   title = str_glue(i18n$t(title)),
                   x_title = i18n$t("title_global_year"),
                   y_title = str_glue(i18n$t("lbl_axis_y_coverage")),
                   legend_labels = cd_only_denominators(cd_denominator_labels(i18n)))
            },
            i18n = i18n
          )
        },
        indicators = cd_cfg("cov_trend_indicators"),
        showCustom = FALSE
      )

    }
  )
}
