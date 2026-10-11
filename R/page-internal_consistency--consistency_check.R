#' Tab keys of the consistency check pairs
#'
#' Gives the key of each indicator pair the Consistency checks card ([consistency_check_ui()])
#' compares. The pairs come from the app's `consistency_pairs` setting (see [cd_cfg()]). Without
#' that setting they are ANC1 with Penta1 and Penta1 with Penta3. The card has one tab per key,
#' followed by its `"custom"` tab, which is not in this list.
#'
#' @return A character vector with one key per pair, the two indicator codes joined by an
#'   underscore (`"anc1_penta1"`).
#'
#' @examples
#' consistency_pair_keys()
#'
#' # the pairs an app sets
#' old <- options(cd2030.config = list(consistency_pairs = list(c("anc1", "penta1"), c("opv1", "opv3"))))
#' consistency_pair_keys()
#' options(old)
#'
#' @concept Countdown app pages
#' @export
consistency_pair_keys <- function() {
  pairs <- cd_cfg("consistency_pairs", list(c("anc1", "penta1"), c("penta1", "penta3")))
  vapply(pairs, function(p) paste(p, collapse = "_"), character(1))
}

#' Tab label of a consistency check pair
#'
#' Gives the label of one indicator pair's tab on the Consistency checks card
#' ([consistency_check_ui()]). The label is the pair's translation (the key `opt_consist_<x>_<y>`)
#' when the translator has one. Otherwise it is the two indicator codes in capitals joined by "and"
#' (`"ANC1 and PENTA1"`).
#'
#' @param i18n The app's translator (a `shiny.i18n` translator).
#' @param pair A character vector of two indicator codes, the first for the x axis and the second
#'   for the y axis (`c("anc1", "penta1")`).
#'
#' @return The label: what `i18n$t()` gives for the pair's key when it is translated, otherwise a
#'   character string.
#'
#' @examples
#' \dontrun{
#' # i18n is the app's translator, as a page receives it
#' consistency_pair_label(i18n, c("anc1", "penta1"))
#'
#' # the labels of every pair the app compares, named by tab key
#' pairs <- cd_cfg("consistency_pairs", list(c("anc1", "penta1"), c("penta1", "penta3")))
#' labels <- vapply(pairs, function(pair) consistency_pair_label(i18n, pair), character(1))
#' setNames(labels, consistency_pair_keys())
#' }
#'
#' @concept Countdown app pages
#' @export
consistency_pair_label <- function(i18n, pair) {
  key <- paste0("opt_consist_", paste(pair, collapse = "_"))
  if (key %in% rownames(i18n$get_translations())) i18n$t(key) else paste(toupper(pair), collapse = " and ")
}

#' Consistency checks card
#'
#' A card of charts that each compare two indicators, drawn by [plot_comparison()]. It has one tab
#' for each indicator pair the app sets (the `consistency_pairs` setting, see
#' [consistency_pair_keys()]), for example ANC1 against Penta1, and a Custom tab where the person
#' picks any two indicators to compare. It is the second card of the Internal consistency page
#' ([internal_consistency_ui()]). It reads `countdown_data` from the dataset.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `consistency_check_ui()` returns the card's UI as Shiny tags.
#'   `consistency_check_server()` is called for its side effects.
#'
#' @examples
#' \dontrun{
#' # the card in a page module, as the Internal consistency page uses it
#' my_page_ui <- function(id, i18n) {
#'   ns <- NS(id)
#'   cd_page_ui(id, i18n, consistency_check_ui(ns("consistency"), i18n))
#' }
#' my_page_server <- function(id, cache, i18n, active = reactive(TRUE)) {
#'   moduleServer(id, function(input, output, session) {
#'     consistency_check_server("consistency", cache, i18n, active = active)
#'   })
#' }
#' }
#'
#' @concept Countdown app pages
#' @export
consistency_check_ui <- function(id, i18n) {
  ns <- NS(id)
  pairs <- cd_cfg("consistency_pairs", list(c("anc1", "penta1"), c("penta1", "penta3")))
  keys <- consistency_pair_keys()

  panes <- c(
    stats::setNames(lapply(keys, function(k) cd_plot_ui(ns(k), toolbar_inline = TRUE)), keys),
    list(custom = div(
      class = "cd-stack",
      div(
        class = "cd-row",
        cd_indicator_ui(ns("x_title"), i18n, label = "lbl_axis_x_consist"),
        cd_indicator_ui(ns("y_title"), i18n, label = "lbl_axis_y_consist")
      ),
      cd_plot_ui(ns("custom_graph"), toolbar_inline = TRUE)
    ))
  )

  cd_chart_card(
    title = i18n$t("title_consist_checks"),
    chart_toolbar = uiOutput(ns("consist_toolbar")),
    i18n = i18n,
    width = 12,
    tabs = uiOutput(ns("consist_tabs")),
    cd_tab_panes(ns("indicator_tabs"), panes, active = keys[[1]])
  )
}

#' @rdname consistency_check_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The card
#'   does no work before that.
#' @export
consistency_check_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns

      pairs <- cd_cfg("consistency_pairs", list(c("anc1", "penta1"), c("penta1", "penta3")))
      keys <- consistency_pair_keys()

      # Page-owned tab strip + cd_tab_panes() -- same pattern as outlier_detection_server() and reporting_rate_server();
      # hand-rolled here (not cd_tabbed_charts_*()) because the "custom" tab has TWO cd_indicator_ui()s.
      consist_current_tab <- reactiveVal(keys[[1]])

      output$consist_tabs <- renderUI({
        labels <- c(
          vapply(pairs, function(p) consistency_pair_label(i18n, p), character(1)),
          i18n$t("opt_consist_custom")
        )
        cd_tab_strip(ns, tabs = stats::setNames(labels, c(keys, "custom")), active = consist_current_tab())
      })

      output$consist_toolbar <- renderUI({
        tab <- consist_current_tab()
        cd_plot_toolbar_ui(ns(if (identical(tab, "custom")) "custom_graph" else tab))
      })

      lapply(c(keys, "custom"), function(key) {
        observeEvent(input[[paste0("tab_", key)]], {
          consist_current_tab(key)
          cd_update_tab_panes(session, "indicator_tabs", selected = key)
        }, ignoreInit = TRUE)
      })

      x_title <- cd_indicator_server("x_title")
      y_title <- cd_indicator_server("y_title")
      legend_labels <- reactive({
        c(
          district = i18n$t("lbl_leg_consist_district"),
          linear_fit = i18n$t("lbl_leg_consist_linear_fit"),
          diagonale = i18n$t("lbl_leg_consist_diagonal")
        )
      })

      # active(): see coverage_server() in modules/3_national_coverage/coverage.R for why.
      data <- reactive({
        req(cache(), active())
        cache()$countdown_data
      })

      lapply(seq_along(pairs), function(i) {
        local({
          x <- pairs[[i]][[1]]
          y <- pairs[[i]][[2]]
          cd_plot_server(
            id = keys[[i]],
            about = .cd_about("consistency", variant = keys[[i]]),
            i18n = i18n,
            plot_data = data,
            plot_filename = reactive(paste0(keys[[i]], "_plot")),
            plot_fun = function(d) {
              # the title template names {vacc1} and {vacc2}
              vacc1 <- i18n$t(paste0("opt_", x))
              vacc2 <- i18n$t(paste0("opt_", y))
              plot_comparison(
                d, x, y,
                title = str_glue(i18n$t("plt_title_consist_checks")),
                x_title = vacc1,
                y_title = vacc2,
                legend_labels = legend_labels()
              )
            },
            excel_sheet = "ratio_plot"
          )
        })
      })

      cd_plot_server(
        id = "custom_graph",
        about = .cd_about(NULL),
        i18n = i18n,
        plot_data = data,
        plot_filename = reactive(paste0(x_title(), "_", y_title(), "_plot")),
        plot_fun = function(d) {
          req(x_title(), y_title())
          vacc1 <- i18n$t(paste0("opt_", x_title()))
          vacc2 <- i18n$t(paste0("opt_", y_title()))
          plot_comparison(
            d,
            x_title(),
            y_title(),
            title = str_glue(i18n$t("plt_title_consist_checks")),
            x_title = vacc1,
            y_title = vacc2,
            legend_labels = legend_labels()
          )
        },
        excel_sheet = "ratio_plot"
      )
    }
  )
}
