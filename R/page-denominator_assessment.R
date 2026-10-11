#' Tabs of the denominator assessment chart
#'
#' The keys of the tabs on the denominator assessment page ([denominator_assessment_ui()]): total
#' population, births and children under one.
#'
#' @format A character vector.
#'
#' @examples
#' den_indicators
#'
#' @concept Countdown app pages
#' @export
den_indicators <-c("population", "births", "under1")

#' Denominator assessment page
#'
#' The page that compares the population figures in the health data (DHIS2) with the United
#' Nations estimates over the years. One card has three tabs, each with a chart: total population,
#' births (the DHIS2 live births and total births) and children under one. The one filter is the
#' population chip ([cd_population_ui()]), which shows the dataset's `derivation_population` and
#' saves a change to it there. The charts read `denominator_metrics` from the dataset.
#'
#' @param id The module's id. A page's id is also its entry in the app's page registry.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `denominator_assessment_ui()` returns the page's UI as Shiny tags.
#'   `denominator_assessment_server()` is called for its side effects.
#'
#' @examples
#' \dontrun{
#' # the page's entry in an app's page registry
#' cd_page_def(
#'   id = "denominator_assessment",
#'   ui = denominator_assessment_ui,
#'   server = denominator_assessment_server,
#'   title = "title_denom_assessment",
#'   section = "lbl_nav_section_denominators",
#'   subtitle = "sub_denom_assessment"
#' )
#' }
#'
#' @concept Countdown app pages
#' @export
denominator_assessment_ui <- function(id, i18n) {
  ns <- NS(id)

  cd_page_ui(id, i18n,
    filters = cd_filter_bar(
      cd_population_ui(ns("derivation_population"))
    ),
    cd_tabbed_charts_ui(ns("panel"), i18n, "title_denom_pop_comparison", cd_coverage_plot_ui,
      indicators = den_indicators, showCustom = FALSE
    )
  )
}

#' @rdname denominator_assessment_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The page
#'   does no work before that.
#' @export
denominator_assessment_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      cd_population_server("derivation_population", cache)

      cd_tabbed_charts_server(
        "panel",
        serverInput = function(id, current_indicator) {
          # active(): see coverage_server() in modules/3_national_coverage/coverage.R for why.
          denominators <- reactive({
            req(cache(), active())
            cache()$denominator_metrics
          })
          
          cd_coverage_plot_server(
            id = id, # or just ind if inside the same module id
            about = .cd_about("denominator_trend", variant = current_indicator),
            filename = reactive(paste0(current_indicator, "_plot")),
            data_fn = denominators,
            sheet_name = reactive(i18n$t(paste0("opt_", current_indicator))),
            plot_fun = function(d) {
              if (current_indicator == "population") {
                my_title <- i18n$t("plt_title_denom_pop")
                my_labels <- c(i18n$t("lbl_leg_denom_un_pop"), i18n$t("lbl_leg_denom_dhis2_pop"))
              } else if (current_indicator == "births") {
                my_title <- i18n$t("plt_title_denom_births")
                my_labels <- c(i18n$t("lbl_leg_denom_un_births"), i18n$t("lbl_leg_denom_dhis2_live_births"), i18n$t("lbl_leg_denom_dhis2_tot_births"))
              } else if (current_indicator == "under1") {
                my_title <- i18n$t("plt_title_denom_under1")
                my_labels <- c(i18n$t("lbl_leg_denom_un_under1"), i18n$t("lbl_leg_denom_dhis2_under1"))
              }

              plot(d,
                metric = current_indicator,
                title = my_title,
                x_title = i18n$t("title_global_year"),
                y_title = i18n$t("opt_population"),
                legend_labels = my_labels
              )
            },
            i18n = i18n
          )
        },
        indicators = den_indicators,
        showCustom = FALSE
      )

    }
  )
}
