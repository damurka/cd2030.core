#' The standard indicators of a tabbed chart card
#'
#' The indicators a tabbed chart card ([cd_tabbed_charts_ui()]) gives a tab each when the page names
#' none and the app has not set its own. This is the RMNCAH app's set. Read the indicators in use
#' with [cd_default_indicator_set()], which also takes the app's option into account.
#'
#' @format A character vector of five indicator codes: `"anc4"`, `"instlivebirths"`,
#'   `"low_bweight"`, `"penta3"` and `"measles1"`.
#'
#' @examples
#' cd_default_indicators
#'
#' @concept Countdown app layout
#' @export
cd_default_indicators <- c('anc4', "instlivebirths", "low_bweight", 'penta3', "measles1")

#' The indicators this app's tabbed chart cards show
#'
#' The indicators a tabbed chart card ([cd_tabbed_charts_ui()]) gives a tab each when the page names
#' none.
#'
#' @details Reads `options(cd2030.default_indicators = )`. An app sets it to a character vector of
#' indicator codes, or to a function with no arguments that returns one. A function is called each
#' time, so its answer can follow something that is only known later, such as the indicator group.
#' When the option is not set, the result is [cd_default_indicators].
#'
#' @return A character vector of indicator codes.
#'
#' @examples
#' cd_default_indicator_set()
#'
#' old <- options(cd2030.default_indicators = function() c("penta3", "measles1"))
#' cd_default_indicator_set()
#' options(old)
#'
#' @concept Countdown app layout
#' @export
cd_default_indicator_set <- function() {
  d <- getOption("cd2030.default_indicators", cd_default_indicators)
  if (is.function(d)) d() else d
}

#' Chart card with one tab for each indicator
#'
#' A card that shows the same chart for several indicators, one tab each, with a "Custom" tab where
#' the reader chooses any other indicator. The page says how one chart is drawn (`uiInput` and
#' `serverInput`), and this module makes the tabs, switches between them and puts the chart tools of
#' the tab on show in the card's header. Many analysis pages are built from it.
#'
#' @details `uiInput` and `serverInput` are the two halves of one chart, usually
#' [cd_coverage_plot_ui()] and a function that calls [cd_coverage_plot_server()]:
#' * `uiInput(id, toolbar_inline = TRUE)` is called once for each tab and returns that tab's chart.
#'   It must leave the chart's tools out when `toolbar_inline` is `TRUE`, because the card's header
#'   shows them. The header draws the tools with [cd_coverage_plot_toolbar_ui()], so the chart must
#'   be a [cd_coverage_plot_ui()] or use the same ids.
#' * `serverInput(id, indicator)` starts the chart of one tab. It is called once for each indicator,
#'   with the indicator's code as both arguments. For the Custom tab it is called once, with the
#'   id `"custom"` and a reactive that returns the indicator the reader chose; read either with
#'   [cd_tab_indicator()]. It runs inside this module, so `id` is used as it is, without `ns()`.
#'
#' A tab's label is the translation of `opt_` followed by the indicator's code. The tabs that are
#' not on show are hidden, and Shiny does not draw a hidden chart.
#'
#' Give `indicators` and `showCustom` the same values in the ui and the server call.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label. In
#'   `cd_tabbed_charts_server()` it is the last argument and defaults to the translator the app
#'   registered with `cd_use_i18n()`.
#' @param title_key The translation key of the card's title.
#' @param uiInput A function `function(id, toolbar_inline)` that returns the UI of one tab's chart
#'   (see Details).
#' @param indicators A character vector of indicator codes, one tab each, in this order. `NULL` (the
#'   default) uses [cd_default_indicator_set()].
#' @param customIndicators The indicators the Custom tab's chip offers, as [cd_indicator_ui()] takes
#'   them. Default `get_analysis_indicators()`. Only the ui uses it. The server accepts it and
#'   ignores it.
#' @param showCustom Logical. `TRUE` (the default) adds the Custom tab after the indicators' tabs.
#' @param width The card's width, passed to the kit's `cd_chart_card()`. Default `12`. The kit's
#'   card takes a width and ignores it: a card is as wide as the place it is put in.
#'
#' @return `cd_tabbed_charts_ui()` returns the UI as Shiny tags (the card).
#'
#'   `cd_tabbed_charts_server()` returns a reactive holding the key of the tab on show: an
#'   indicator's code, or `"custom"`.
#'
#' @examples
#' \dontrun{
#' # in a page's ui
#' cd_tabbed_charts_ui(ns("panel"), i18n, "title_coverage_national", cd_coverage_plot_ui,
#'   indicators = c("penta3", "measles1")
#' )
#'
#' # in the page's server
#' cd_tabbed_charts_server("panel",
#'   serverInput = function(id, indicator) {
#'     cd_coverage_plot_server(
#'       id = id,
#'       filename = reactive(paste0(indicator, "_coverage")),
#'       data_fn = reactive(my_coverage_data(cache(), indicator)),
#'       sheet_name = reactive(i18n$t(paste0("opt_", indicator))),
#'       i18n = i18n
#'     )
#'   },
#'   indicators = c("penta3", "measles1")
#' )
#' }
#'
#' @concept Countdown app layout
#' @export
cd_tabbed_charts_ui <- function(id, i18n, title_key, uiInput,
                        indicators = NULL,
                        customIndicators = get_analysis_indicators(),
                        showCustom = TRUE, width = 12) {
  ns <- NS(id)

  indicators <- indicators %||% cd_default_indicator_set()

  # toolbar_inline = TRUE: this card's header (cd_chart_card(), below) carries the tool row instead -- the
  # opt-in mechanism cd_plot_toolbar_ui()'s own comment (_shared/R/charts/plot-downloads.R) documents; every
  # OTHER caller of cd_coverage_plot_ui() outside a cd_tabbed_charts_ui() keeps the old overlay-on-chart default.
  panels <- set_names(map(indicators, ~ uiInput(ns(.x), toolbar_inline = TRUE)), indicators)

  if (isTRUE(showCustom)) {
    panels[["custom"]] <- div(
      class = "cd-stack",
      cd_indicator_ui(ns("indicator"), i18n, indicators = customIndicators),
      uiInput(ns("custom"), toolbar_inline = TRUE)
    )
  }

  cd_chart_card(
    title = i18n$t(title_key),
    chart_toolbar = uiOutput(ns("panel_toolbar")),
    i18n = i18n,
    width = width,
    tabs = uiOutput(ns("panel_tabs")),
    cd_tab_panes(ns("indicator_tabs"), panels)
  )
}

#' @rdname cd_tabbed_charts_ui
#' @param serverInput A function `function(id, indicator)` that starts the server of one tab's chart
#'   (see Details).
#' @param selected_tab A reactive that returns the key of a tab to show (an indicator's code or
#'   `"custom"`), or `NULL`. When its value changes to a key, the card switches to that tab. It lets
#'   another card's tabs drive this card's. Default `reactive(NULL)`, which never switches.
#' @export
cd_tabbed_charts_server <- function(id,
                            serverInput,
                            indicators = NULL,
                            customIndicators = get_analysis_indicators(),
                            showCustom = TRUE,
                            selected_tab = reactive(NULL),
                            i18n = cd_i18n()) {
  stopifnot(is.function(serverInput))
  stopifnot(is.reactive(selected_tab))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns
      indicators <- indicators %||% cd_default_indicator_set()
      tab_keys <- c(indicators, if (isTRUE(showCustom)) "custom" else NULL)

      walk(indicators, ~ {
        local({
          id <- .x
          serverInput(id, .x)
        })
      })

      selected <- cd_indicator_server("indicator")

      # Started once: the Custom tab's chart follows the choice, a reactive. Starting it again for each choice left
      # the earlier ones' observers running on the same ids (a change to one chart's options was also written for
      # the indicators chosen before).
      if (isTRUE(showCustom)) {
        serverInput("custom", reactive({
          req(selected())
          selected()
        }))
      }

      # Page-owned tab strip (cd_tab_strip(), content_dashboard.R) + cd_tab_panes() (cd_tabbed_charts_ui(), above,
      # _shared/R/core (and components/)) that actually switches the content -- current_tab is purely this strip's own
      # "which one is underlined" state; cd_update_tab_panes() is what shows/hides each pane (and, via Shiny's
      # normal suspend-when-hidden behaviour, what actually stops every OTHER tab's chart from rendering while
      # it's hidden). Mirrors 1a_checks_reporting_rate.R's own reporting_rate_server() exactly, generalized from 2
      # hardcoded tabs to however many tab_keys this particular caller has.
      current_tab <- reactiveVal(tab_keys[[1]])

      tab_label <- function(key) {
        if (identical(key, "custom")) i18n$t("opt_consist_custom") else i18n$t(paste0("opt_", key))
      }

      output$panel_tabs <- renderUI({
        cd_tab_strip(ns, tabs = set_names(map_chr(tab_keys, tab_label), tab_keys), active = current_tab())
      })

      # cd_coverage_plot_toolbar_ui() resolves to the exact same ids cd_coverage_plot_ui(..., toolbar_inline =
      # TRUE) already mounted for that tab (cd_tabbed_charts_ui(), above), wherever this renders it. Raw content only,
      # NOT wrapped in cd_chart_toolbar() here too -- cd_tabbed_charts_ui()'s own cd_chart_card() call already does
      # that once, around this whole uiOutput(); wrapping it a second time would double the Ask AI button/
      # divider/expand toggle.
      output$panel_toolbar <- renderUI({
        cd_coverage_plot_toolbar_ui(ns(current_tab()))
      })

      lapply(tab_keys, function(key) {
        observeEvent(input[[paste0("tab_", key)]], {
          current_tab(key)
          cd_update_tab_panes(session, "indicator_tabs", selected = key)
        }, ignoreInit = TRUE)
      })

      observeEvent(selected_tab(),
        {
          req(selected_tab())
          current_tab(selected_tab())
          cd_update_tab_panes(session, "indicator_tabs", selected = selected_tab()) # value we set above
        },
        ignoreInit = TRUE
      )

      return(reactive(current_tab()))
    }
  )
}

#' The indicator of a tab of charts
#'
#' The `serverInput` function given to [cd_tabbed_charts_server()] receives the indicator of its tab
#' as a string, and for the Custom tab as a reactive that returns the indicator the reader chose.
#' `cd_tab_indicator()` gives one way to read both.
#'
#' @param indicator What `serverInput` received: an indicator's code, or a reactive that returns
#'   one.
#'
#' @return A function with no arguments that returns the indicator's code. For the Custom tab it
#'   must be called where a reactive can be read (in a `reactive()`, a render function or a
#'   `plot_fun`).
#'
#' @examples
#' ind <- cd_tab_indicator("penta3")
#' ind()
#'
#' \dontrun{
#' # in a page's server: one serverInput for the indicators' tabs and the Custom tab
#' cd_tabbed_charts_server("panel",
#'   serverInput = function(id, current_indicator) {
#'     ind <- cd_tab_indicator(current_indicator)
#'     cd_coverage_plot_server(
#'       id = id,
#'       filename = reactive(paste0(ind(), "_coverage")),
#'       data_fn = reactive(cache()$get_filtered_coverage(ind(), "national")),
#'       sheet_name = reactive(i18n$t(paste0("opt_", ind()))),
#'       i18n = i18n
#'     )
#'   }
#' )
#' }
#'
#' @concept Countdown app layout
#' @export
cd_tab_indicator <- function(indicator) {
  if (is.function(indicator)) indicator else function() indicator
}
