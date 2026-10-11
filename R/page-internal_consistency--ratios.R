#' Indicator ratios card
#'
#' A card with one chart of the ratios between related indicators (ANC1 to Penta1, OPV1 to OPV3 and
#' Penta1 to Penta3 have translated labels). It is the first card of the Internal consistency page
#' ([internal_consistency_ui()]) and has no filters. It reads `ratios_summary` from the dataset.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `calculate_ratios_ui()` returns the card's UI as Shiny tags. `calculate_ratios_server()`
#'   is called for its side effects.
#'
#' @examples
#' \dontrun{
#' # the card in a page module, as the Internal consistency page uses it
#' my_page_ui <- function(id, i18n) {
#'   ns <- NS(id)
#'   cd_page_ui(id, i18n, calculate_ratios_ui(ns("ratios"), i18n))
#' }
#' my_page_server <- function(id, cache, i18n, active = reactive(TRUE)) {
#'   moduleServer(id, function(input, output, session) {
#'     calculate_ratios_server("ratios", cache, i18n, active = active)
#'   })
#' }
#' }
#'
#' @concept Countdown app pages
#' @export
calculate_ratios_ui <- function(id, i18n) {
  ns <- NS(id)

  cd_chart_card(
    title = i18n$t("title_consist_ratio_plots"),
    chart_toolbar = cd_plot_toolbar_ui(ns("ratios")),
    i18n = i18n,
    status = "success",
    width = 12,
    cd_plot_ui(ns("ratios"), toolbar_inline = TRUE)
  )
}

#' @rdname calculate_ratios_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The card
#'   does no work before that.
#' @export
calculate_ratios_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ratio_summary <- reactive({
        req(cache(), active())
        cache()$ratios_summary
      })

      cd_plot_server(
        id = "ratios",
        about = .cd_about("dq_ratios"),
        i18n = i18n,
        plot_data = ratio_summary,
        plot_filename = reactive("ratio_plot"),
        plot_fun = function(d) {
          plot(
            d,
            title = i18n$t("plt_title_consist_ratios"),
            # x_title = NULL,
            # y_title = NULL,
            x_labels = c(
              "anc1_penta1"   = i18n$t("lbl_consist_ratio_anc1_penta1"),
              "opv1_opv3"     = i18n$t("lbl_consist_ratio_opv1_opv3"),
              "penta1_penta3" = i18n$t("lbl_consist_ratio_penta1_penta3")
            )
          )
        },
        excel_sheet = "ratio_plot"
      )
    }
  )
}
