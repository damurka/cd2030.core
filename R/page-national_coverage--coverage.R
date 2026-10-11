#' Coverage charts for one geography
#'
#' The body of the national and sub-national coverage pages: one card of charts with a tab for each
#' indicator the app lists (`cd_cfg("nat_cov_indicators")`) and a Custom tab for any other analysis
#' indicator. A tab plots the indicator's coverage by year from the health facility data, with the
#' denominator selected for that indicator, beside the survey and WUENIC estimates. It reads the
#' dataset's `get_filtered_coverage()`, which takes the indicator's rows from `calculate_coverage()`
#' for the admin level and region. The tab `"fpet"`, when an app lists it, shows the family planning
#' estimates instead (`cache()$fpet_data`, from 2010 onwards). The piece has no filters of its own:
#' the page gives it the admin level and region.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param key_label The translation key of the card's title.
#'
#' @return `coverage_ui()` returns the card's UI as Shiny tags. `coverage_server()` returns a
#'   reactive that holds the key of the tab shown: an indicator's name, or `"custom"`.
#'
#' @examples
#' \dontrun{
#' # the charts in a page module, at national level
#' my_page_ui <- function(id, i18n) {
#'   ns <- NS(id)
#'   cd_page_ui(id, i18n, coverage_ui(ns("body"), i18n, "title_coverage_national"))
#' }
#' my_page_server <- function(id, cache, i18n, active = reactive(TRUE)) {
#'   moduleServer(id, function(input, output, session) {
#'     coverage_server("body", cache, i18n, reactive("national"), active = active)
#'   })
#' }
#'
#' # for one region: the admin level and the region are reactives
#' coverage_server("body", cache, i18n, reactive("adminlevel_1"), reactive("Nairobi"), active = active)
#' }
#'
#' @concept Countdown app pages
#' @export
coverage_ui <- function(id, i18n, key_label) {
  ns <- NS(id)
  cd_tabbed_charts_ui(ns("panel"), i18n, key_label, cd_coverage_plot_ui, indicators = cd_cfg("nat_cov_indicators"))
}

#' @rdname coverage_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param admin_level A reactive that returns the level the coverage is worked out at: `"national"`,
#'   `"adminlevel_1"` (admin level 1) or `"district"`.
#' @param region A reactive that returns the name of the region (or district) to show, or `NULL` for
#'   none.
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The
#'   charts do no work before that.
#' @export
coverage_server <- function(id, cache, i18n, admin_level, region = reactive(NULL), active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {

      cd_tabbed_charts_server(
        "panel",
        serverInput = function(id, current_indicator) {
          ind <- cd_tab_indicator(current_indicator)
          # active(): every page's module server is created at startup (see app.R), so without this Shiny
          # would compute every indicator's coverage data once on the session's first flush, for a page no
          # one has opened -- the same fix bayesian_server() needed for its (far more expensive) model fits.
          denom_rx <- reactive({
            req(cache(), active())
            cache()$get_denominator(ind())
          })
          data_rx <- reactive({
            req(cache(), active(), cache()$check_coverage_params)
            cache()$get_filtered_coverage(indicator = ind(), admin_level = admin_level(), region = region())
          })
          fpet_data <- reactive({
            req(cache(), active())
            cache()$fpet_data %>%
              filter(year >= 2010)
          })
          
          cd_coverage_plot_server(
            id = id, # or just ind if inside the same module id
            about = if (identical(current_indicator, "fpet")) .cd_about("natcov_fpet") else .cd_about("coverage", indicator = current_indicator, admin_level = admin_level, region = region, denominator = denom_rx),
            filename = reactive(paste0(ind(), "_", region(), "_survey_", denom_rx())),
            data_fn = if (identical(current_indicator, 'fpet')) fpet_data else data_rx,
            sheet_name = reactive(i18n$t(paste0("opt_", ind()))),
            plot_fun = function(d) {

              if (ind() != 'fpet') {
                indicator <- i18n$t(paste0("opt_", ind()))
                denominator <- i18n$t(paste0("opt_", denom_rx()))
                region <- region()
                title <- if (admin_level() == "national") "plt_title_coverage_nat_est" else "plt_title_coverage_subnat_est"
                plot(d,
                    title = str_glue(i18n$t(title)),
                    x_title = i18n$t("title_global_year"),
                    y_title = str_glue(i18n$t("lbl_axis_y_coverage")),
                    caption = str_glue(i18n$t("plt_caption_coverage_denom")),
                    legend_labels = list(
                      dhis2  = i18n$t("lbl_coverage_dhis2_est"),
                      wuenic = i18n$t("lbl_coverage_wuenic_est"),
                      survey = i18n$t("lbl_coverage_survey_est"),
                      ci     = i18n$t("lbl_coverage_95ci")
                    ))
                } else {
                  # Extract country to append to the translated base title
                  country_name <- attr(d, "country") %||% ""
                  base_title <- i18n$t("title_graph_fpet")
                  
                  plot(
                    d, 
                    title = paste0(base_title, ", ", country_name),
                    x_title = i18n$t("title_global_year"),
                    y_title = i18n$t("ylab_fpet"),
                    caption = i18n$t("caption_fpet"),
                    
                    # Translate the legend (adjust the keys based on what they are named in your CSV/tibble)
                    indicator_labels = list(
                      prevalence = i18n$t("lbl_fpet_mcpr"),
                      demand = i18n$t("lbl_fpet_demand")
                    )
                  )
                }
              },
            i18n = i18n
          )
        },
        indicators = cd_cfg("nat_cov_indicators")
      )
    }
  )
}
