#' Data adjustment page
#'
#' The page where the person sets which data is kept for analysis and how it is corrected. Years can
#' be removed everywhere, and an area's data can be removed for some or every year. The corrections
#' are for completeness (by each indicator group's k factor), outliers and missing values, set for
#' everywhere or with a region's or district's own settings. The page is one editor
#' (`datasuite.ui::cd_adjustment_editor()`), which shows beside each setting what the check pages
#' found ([adjustment_evidence()]). Below it are a button that downloads the adjusted data as a
#' Stata file and a link to the Data adjustment changes page ([adjustment_changes_ui()]).
#'
#' The Adjust data button saves the settings in the dataset (`set_adjustment_settings()`) and
#' adjusts it (`adjust_data()`). The page is then read-only until the person chooses Edit. The page
#' reads `countdown_data`, `performance_threshold`, `adjustment_settings`, `adjusted_flag` and
#' `adjusted_data` from the dataset.
#'
#' @param id The module's id. A page's id is also its entry in the app's page registry.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `data_adjustment_ui()` returns the page's UI as Shiny tags. `data_adjustment_server()`
#'   is called for its side effects.
#'
#' @examples
#' \dontrun{
#' # the page's entry in an app's page registry
#' cd_page_def(
#'   id = "data_adjustment",
#'   ui = data_adjustment_ui,
#'   server = data_adjustment_server,
#'   title = "title_adjust_main",
#'   section = "lbl_nav_section_quality",
#'   subtitle = "sub_adjust_main"
#' )
#' }
#'
#' @concept Countdown app pages
#' @export
data_adjustment_ui <- function(id, i18n) {
  ns <- NS(id)

  cd_page_ui(id, i18n,
    uiOutput(ns("editor")),
    div(
      class = "cd-adj-after",
      cd_download_button_ui(ns("download_data")),
      actionLink(ns("see_changes"), i18n$t("lbl_adj_see_changes"), class = "cd-adj-after__link")
    )
  )
}

#' Indicator groups for the adjustment editor
#'
#' Lists each indicator group with the indicators the adjustment corrects and what the checks found
#' for them. The inpatient group (`"ipd"`) has `ipd_total` and `ipd_under5` only, and gets the
#' outlier correction but not the missing value one. A group with no such indicator is left out.
#'
#' @param evidence What [adjustment_evidence()] returned, or an empty list when there is none.
#'
#' @return A list with one entry per group: `id`, `label` (a translation key), `k` (whether the
#'   group has a k factor), `missing` (whether missing values are corrected), `rr` and `below` (from
#'   the evidence) and `indicators`, a list of `list(id, label, outliers, missing)`.
#' @noRd
.adj_editor_groups <- function(evidence) {
  groups <- get_indicator_groups()
  adjusted <- unique(get_adjustment_indicators())
  k_groups <- names(cd_cfg("k_factors"))
  out <- list()
  for (g in names(groups)) {
    inds <- if (g == "ipd") intersect(groups[[g]], c("ipd_total", "ipd_under5")) else intersect(groups[[g]], adjusted)
    if (!length(inds)) next
    ev <- evidence$groups[[g]] %||% list()
    out[[length(out) + 1]] <- list(
      id = g,
      label = paste0("lbl_adj_group_", g),
      k = g %in% k_groups,
      missing = g != "ipd",
      rr = ev$rr,
      below = ev$below,
      indicators = lapply(inds, function(ind) {
        e <- evidence$indicators[[ind]] %||% list()
        list(id = ind, label = paste0("opt_", ind), outliers = e$outliers, missing = if (g != "ipd") e$missing)
      })
    )
  }
  out
}

#' @rdname data_adjustment_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active Not used. It is accepted so that the app's page registry can pass it as it does to
#'   every other page.
#' @export
data_adjustment_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))

  moduleServer(
    id = id,
    module = function(input, output, session) {

      # what the checks found (the data before adjustment, the removed years left out)
      evidence <- reactive({
        req(cache(), cache()$countdown_data)
        tryCatch(adjustment_evidence(cache()$countdown_data, threshold = cache()$performance_threshold), error = function(e) NULL)
      })

      # the default the page offers ("Back to the Countdown default"): the method's k for every group
      defaults <- adjustment_settings_default()

      output$editor <- renderUI({
        req(cache(), cache()$countdown_data)
        ev <- evidence() %||% list()
        d <- cache()$countdown_data
        cd_adjustment_editor(
          session$ns("editor"),
          i18n = i18n,
          years = sort(unique(as.numeric(d$year))),
          groups = .adj_editor_groups(ev),
          areas = ev$areas %||% list(),
          settings = isolate(cache()$adjustment_settings),
          defaults = defaults,
          adjusted = isolate(isTRUE(cache()$adjusted_flag)),
          rr_year = ev$year,
          threshold = ev$threshold %||% .cd_method$data_quality$reporting_threshold,
          rr_cutoff = .cd_method$adjustment$reporting_rate_cutoff,
          k_choices = .cd_method$adjustment$k_options
        )
      })

      # Adjust data: the settings saved in the dataset, the data adjusted with them; the editor told what happened
      observeEvent(input$editor, {
        ev <- input$editor
        req(cache(), is.list(ev), identical(ev$event, "adjust"))
        cd_update_adjustment_editor(session, "editor", i18n = i18n, busy = TRUE, message = list(type = "info", text = "msg_adj_busy"))
        ok <- tryCatch({
          cache()$set_adjustment_settings(ev$settings)
          cache()$adjust_data()
          TRUE
        }, error = function(e) {
          cd_update_adjustment_editor(session, "editor", i18n = i18n, busy = FALSE,
                                      message = list(type = "error", text = paste(cd_plain_text(i18n, "msg_adj_failed"), clean_error_message(e))))
          FALSE
        })
        if (ok) {
          cd_update_adjustment_editor(session, "editor", i18n = i18n, settings = cache()$adjustment_settings, adjusted = TRUE, busy = FALSE,
                                      message = list(type = "success", text = "msg_adj_done"))
        }
      }, ignoreInit = TRUE)

      observeEvent(input$see_changes, cd_navigate_to(session, "data_adjustment_changes"))

      modified_data <- reactive({
        req(cache(), cache()$adjusted_flag)
        cache()$adjusted_data
      })

      cd_download_button_server(
        id = 'download_data',
        filename = reactive('master_adj_dataset'),
        extension = reactive('dta'),
        i18n = i18n,
        content = function(file, data) {
          haven::write_dta(data, file)
        },
        data = modified_data,
        label = "btn_adjust_download"
      )

    }
  )
}
