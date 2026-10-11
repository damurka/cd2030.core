#' Overall score page
#'
#' The data quality page that brings the checks together in one table: the completeness of monthly
#' reporting, extreme outliers and the consistency of annual reporting, with a score for each year
#' of the data. The one filter is the region: with none chosen the table is for the country,
#' otherwise it is for that admin level 1 area. The table can be downloaded.
#'
#' The page calls the dataset's `calculate_overall_score()`, and reads its `performance_threshold`
#' (shown in a row label) and `data_years`.
#'
#' @param id The module's id. A page's id is also its entry in the app's page registry.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `overall_score_ui()` returns the page's UI as Shiny tags. `overall_score_server()` is
#'   called for its side effects.
#'
#' @examples
#' \dontrun{
#' # the page's entry in an app's page registry
#' cd_page_def(
#'   id = "overall_score",
#'   ui = overall_score_ui,
#'   server = overall_score_server,
#'   title = "title_score_main",
#'   section = "lbl_nav_section_quality",
#'   subtitle = "sub_score_main"
#' )
#' }
#'
#' @concept Countdown app pages
#' @export
overall_score_ui <- function(id, i18n) {
  ns <- NS(id)

  cd_page_ui(id, i18n,
    filters = cd_filter_bar(
      cd_admin_level_ui(ns("region"), i18n, show_admin_level = FALSE)
    ),
    cd_table_card_ui(ns("overall_score"), i18n, i18n$t("title_score_main"), status = "success")
  )
}

#' @rdname overall_score_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The page
#'   does no work before that.
#' @export
overall_score_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      admin <- cd_admin_level_server("region", cache, i18n, allow_select_all = TRUE, show_district = FALSE, show_admin_level = FALSE)
      region <- reactive({
        req(admin())
        admin()$region
      })

      # active(): see coverage_server() in modules/3_national_coverage/coverage.R for why.
      overall_score <- reactive({
        req(cache(), active())

        translated_labels <- list(
          header = list(
            h1 = i18n$t("title_score_monthly_complete"),
            h2 = i18n$t("title_score_extreme_outliers"),
            h3 = i18n$t("title_score_consist_annual")
          ),
          section = list(
            r1a   = i18n$t("lbl_score_1a"),
            # Combine text + threshold number
            r1b   = paste0(i18n$t("lbl_score_1b_prefix"), cache()$performance_threshold),
            r1c   = if (get_selected_group() == "vaccine") i18n$t("lbl_score_1c_vaccine") else i18n$t("lbl_score_1c_rmncah"),
            r2a   = i18n$t("lbl_score_2a"),
            r2b   = i18n$t("lbl_score_2b"),
            score = i18n$t("lbl_score_annual_score")
          ),
          metric = list(
            r_anc1_penta1    = i18n$t("lbl_consist_ratio_anc1_penta1"),
            r_opv1_opv3      = i18n$t("lbl_consist_ratio_opv1_opv3"),
            r_penta1_penta3  = i18n$t("lbl_consist_ratio_penta1_penta3"),
            ok_anc1_penta1   = i18n$t("lbl_score_range_anc1_penta1"),
            ok_penta1_penta3 = i18n$t("lbl_score_range_penta1_penta3"),
            ok_opv1_opv3     = i18n$t("lbl_score_range_opv1_opv3")
          )
        )
        if (is.null(region())) {
          cache()$calculate_overall_score("national", labels = translated_labels)
        } else {
          cache()$calculate_overall_score("adminlevel_1", region(), labels = translated_labels)
        }
      })

      cd_table_card_server(
        "overall_score",
        i18n,
        data = overall_score,
        table_fun = function(d) plot(d, years = cache()$data_years, title = i18n$t("lbl_score_metric_header")),
        filename = reactive("overall_score"),
        about = .cd_about("overall_score", region = region)
      )
    }
  )
}
