#' Sub-national coverage by denominator card
#'
#' A card of the Denominator selection page ([denominator_selection_ui()]) with one tab per
#' indicator (the app's `sub_derived_indicators` setting). Each tab has a chart of the indicator's
#' coverage in each admin level 1 area, for each denominator the app offers. The card has no
#' filters. It calls the dataset's `calculate_derived_coverage()` for admin level 1 and reads its
#' `survey_year`, which the chart's title names.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `subnational_denominator_ui()` returns the card's UI as Shiny tags.
#'   `subnational_denominator_server()` is called for its side effects.
#'
#' @concept Countdown app pages
#' @export
subnational_denominator_ui <- function(id, i18n) {
  ns <- NS(id)
  cd_tabbed_charts_ui(
    ns("panel"), 
    i18n, 
    'title_subnational_derived', 
    uiInput = cd_coverage_plot_ui, 
    indicators = cd_cfg("sub_derived_indicators"),
        showCustom = FALSE
  )
}

#' @rdname subnational_denominator_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The card
#'   does no work before that.
#' @export
subnational_denominator_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {

      cd_tabbed_charts_server(
        "panel",
        serverInput = function(id, current_indicator) {
          # active(): see coverage_server() in modules/3_national_coverage/coverage.R for why.
          derived_data <- reactive({
            req(cache(), active())
            cache()$calculate_derived_coverage(current_indicator, 'adminlevel_1')
          })

          current_plot_year <- reactive({
            req(cache())
            cache()$survey_year
          })

          cd_coverage_plot_server(
            id = id, # or just ind if inside the same module id
            about = .cd_about("derived_coverage", indicator = current_indicator, admin_level = "adminlevel_1"),
            filename = reactive(paste0(current_indicator, "_adminlevel_1_derived_coverage")),
            data_fn = derived_data,
            sheet_name = reactive(i18n$t(paste0("opt_", current_indicator))),
            plot_fun = function(d) {
              plot(
                d,
                title = str_glue(i18n$t("plt_title_cross_section_subnat"), indicator = i18n$t(paste0('opt_', current_indicator)), year = current_plot_year()),
                x_title = str_glue(i18n$t("opt_coverage")),
                y_title = i18n$t("lbl_axis_y_region"),
                legend_labels = cd_only_denominators(as.list(cd_denominator_labels(i18n)))
              )
            },
            i18n = i18n
          )
        },
        indicators = cd_cfg("sub_derived_indicators"),
        showCustom = FALSE
      )

    }
  )
}
