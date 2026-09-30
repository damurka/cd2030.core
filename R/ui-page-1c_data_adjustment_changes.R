# Data Adjustment Changes: what the adjustment changed, indicator by indicator -- each year's reported count beside the
# adjusted count made of its parts (completeness, missing values, the outliers' correction), and the same in a table
# (a step the indicator does not get, "Off") -- for every area or one region or district; and the adjustment's rules
# as the reports' footnote gives them.

adjustment_changes_ui <- function(id, i18n) {
  ns <- NS(id)

  cd_page_ui(id, i18n,
    filters = cd_filter_bar(
      cd_chip_select(ns("area"), "lbl_adj_changes_area", i18n = i18n,
                     options = list(list(key = "", text = cd_text(i18n, "lbl_adj_all_areas")))),
      cd_chip_select(ns("other"), "lbl_adj_changes_other", i18n = i18n,
                     options = list(list(key = "", text = cd_text(i18n, "lbl_adj_changes_none"))))
    ),
    uiOutput(ns("rules")),
    cd_chart_card(
      title = uiOutput(ns("title")),
      chart_toolbar = cd_plot_toolbar_ui(ns("chart")),
      i18n = i18n,
      width = 12,
      tabs = uiOutput(ns("tabs")),
      div(
        class = "cd-stack",
        cd_plot_ui(ns("chart"), toolbar_inline = TRUE),
        cd_table_spinner(reactableOutput(ns("table")))
      )
    )
  )
}

adjustment_changes_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns
      tab_indicators <- cd_cfg("adjustment_indicators")
      label_of <- function(ind) cd_plain_text(i18n, paste0("opt_", ind))

      data <- reactive({
        req(cache())
        cache()$data_with_excluded_years
      })

      settings <- reactive({
        req(cache())
        cache()$adjustment_settings
      })

      # the areas (every one, a region, or a district grouped under its region) and the other indicators
      area_mounted <- cd_remounted(input, "area")
      observe({
        req(cache(), area_mounted())
        d <- cache()$countdown_data
        regions <- sort(unique(as.character(d$adminlevel_1)))
        options <- c(
          list(list(key = "", text = cd_text(i18n, "lbl_adj_all_areas"))),
          lapply(regions, function(r) list(key = paste0("r:", r), text = r, group = cd_plain_text(i18n, "lbl_adj_group_regions"))),
          unlist(lapply(regions, function(r) {
            lapply(sort(unique(as.character(d$district[d$adminlevel_1 == r]))), function(ds) list(key = paste0("d:", ds), text = ds, group = r))
          }), recursive = FALSE)
        )
        cd_update_input("area", session, options = options, value = isolate(input$area) %||% "")
      })
      other_mounted <- cd_remounted(input, "other")
      observe({
        req(other_mounted())
        others <- setdiff(unique(c(get_adjustment_indicators(), "ipd_total", "ipd_under5")), tab_indicators)
        options <- c(list(list(key = "", text = cd_text(i18n, "lbl_adj_changes_none"))),
                     lapply(others, function(ind) list(key = ind, text = label_of(ind))))
        cd_update_input("other", session, options = options, value = isolate(input$other) %||% "")
      })

      area <- reactive({
        v <- input$area %||% ""
        if (!nzchar(v)) return(list(area = NULL, level = "adminlevel_1"))
        list(area = sub("^[rd]:", "", v), level = if (startsWith(v, "d:")) "district" else "adminlevel_1")
      })

      # the indicator: a tab, or one of the others (which wins while chosen)
      tab <- reactiveVal(tab_indicators[[1]])
      for (ind in tab_indicators) local({
        key <- ind
        observeEvent(input[[paste0("tab_", key)]], {
          tab(key)
          cd_update_input("other", session, value = "")
        }, ignoreInit = TRUE)
      })
      indicator <- reactive({
        o <- input$other %||% ""
        if (nzchar(o)) o else tab()
      })
      output$tabs <- renderUI({
        cd_tab_strip(ns, tabs = set_names(lapply(tab_indicators, label_of), tab_indicators),
                     active = if (nzchar(input$other %||% "")) "" else tab())
      })

      adjustments <- reactive({
        req(data(), settings(), active())
        a <- area()
        data() %>%
          generate_adjustment_values(settings = settings(), area = a$area, level = a$level)
      })

      one <- reactive({
        req(adjustments(), indicator())
        adjustments() %>% filter_adjustment_value(indicator())
      })

      # the steps the indicator gets here: a step no district gets is Off
      used <- reactive({
        req(data(), settings(), indicator())
        a <- area()
        adjustment_steps_used(settings(), data(), indicator(), area = a$area, level = a$level)
      })

      output$title <- renderUI({
        req(indicator())
        str_glue(i18n$t("title_adj_changes_chart"), indicator = label_of(indicator()))
      })

      # the rules in force, as the reports' footnote says them
      output$rules <- renderUI({
        req(cache())
        groups <- vapply(cd_cfg("k_factors"), function(f) cd_plain_text(i18n, f$label), character(1))
        inds <- get_all_indicators()
        indicator_labels <- set_names(vapply(inds, function(x) cd_plain_text(i18n, paste0("opt_", x)), character(1)), inds)
        lines <- tryCatch(adjustment_settings_footnote(settings(), as.list(groups), as.list(indicator_labels)), error = function(e) character())
        status <- if (isTRUE(cache()$adjusted_flag)) "lbl_adj_changes_adjusted" else "lbl_adj_changes_not_adjusted"
        div(
          class = "cd-adj-rules",
          tags$p(class = "cd-adj-rules__status", i18n$t(status)),
          if (length(lines)) tags$ul(class = "cd-adj-rules__list", lapply(lines, tags$li))
        )
      })

      step_label <- function(key, step) {
        text <- cd_plain_text(i18n, key)
        if (!isTRUE(used()[[step]])) paste0(text, " (", cd_plain_text(i18n, "lbl_adj_changes_off"), ")") else text
      }

      cd_plot_server(
        id = "chart",
        about = .cd_about("adj_comparison", indicator = indicator),
        i18n = i18n,
        plot_data = one,
        plot_filename = reactive(paste0(indicator(), "_adjustment_changes")),
        plot_fun = function(d) {
          plot(d,
            title = str_glue(i18n$t("title_adj_changes_chart"), indicator = label_of(indicator())),
            legend_labels = c(
              raw = cd_plain_text(i18n, "lbl_adj_changes_reported"),
              completeness = step_label("lbl_adjust_step_completeness", "completeness"),
              outliers = step_label("lbl_adjust_step_outliers", "outliers"),
              missing = step_label("lbl_adjust_step_missing", "missing")
            )
          )
        },
        excel_sheet = "title_adjust_visualize"
      )

      # the numbers: each step's change, the adjusted count and the change in percent
      output$table <- reactable::renderReactable({
        d <- one()
        ind <- indicator()
        u <- used()
        v <- function(suffix) d[[paste0(ind, suffix)]]
        num <- function(x) formatC(round(x), format = "d", big.mark = ",")
        signed <- function(x) ifelse(x >= 0, paste0("+", num(x)), paste0("−", num(abs(x))))
        off <- cd_plain_text(i18n, "lbl_adj_changes_off")
        rows <- data.frame(
          year = as.character(d$year),
          reported = num(v("_raw")),
          completeness = if (u[["completeness"]]) signed(v("_completeness") - v("_raw")) else off,
          outliers = if (u[["outliers"]]) signed(v("_outliers") - v("_completeness")) else off,
          missing = if (u[["missing"]]) signed(v("_adj") - v("_outliers")) else off,
          adjusted = num(v("_adj")),
          change = ifelse(v("_raw") > 0, sprintf("%+.1f%%", (v("_adj") - v("_raw")) / v("_raw") * 100), ""),
          stringsAsFactors = FALSE
        )
        col <- function(key, ...) colDef(name = cd_plain_text(i18n, key), align = "right", ...)
        reactable(
          rows,
          compact = TRUE, sortable = FALSE, pagination = FALSE,
          columns = list(
            year = colDef(name = cd_plain_text(i18n, "title_global_year"), align = "left", style = list(fontWeight = 600)),
            reported = col("lbl_adj_changes_reported"),
            completeness = col("lbl_adjust_step_completeness", style = list(color = "#7d3f40")),
            outliers = col("lbl_adjust_step_outliers", style = list(color = "#6b5316")),
            missing = col("lbl_adjust_step_missing", style = list(color = "#1f4f86")),
            adjusted = col("lbl_adj_changes_adjusted_col", style = list(fontWeight = 600)),
            change = col("lbl_adj_changes_change", style = list(fontWeight = 600))
          )
        )
      })

    }
  )
}
