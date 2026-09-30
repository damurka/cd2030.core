# Data Adjustment: the data kept for analysis (years removed everywhere, an area's data removed for some or every
# year) and how it is corrected -- completeness by each indicator's k, outliers, missing values -- everywhere or with a
# region's or district's own settings (datasuite.ui's cd_adjustment_editor()). Beside each setting, what the check
# pages found (adjustment_evidence()). Adjust data saves the settings in the dataset (set_adjustment_settings()) and
# adjusts it (adjust_data()); the page is then read-only until Edit.

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

# The editor's indicator groups: each group's indicators the adjustment corrects (outliers only for inpatient visits),
# with what the checks found
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

# active: accepted (unused) so the registry can pass it like every other page.
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
