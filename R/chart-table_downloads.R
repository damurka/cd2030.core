#' Table cell showing a rate with its status
#'
#' Draws one cell of a table of rates, such as reporting rates: a small coloured shape that says how
#' good the rate is, followed by the rate rounded to a whole number. The shape differs with the
#' status as well as the colour, so the status never depends on colour alone. Use it as the `cell`
#' of a `reactable::colDef()`, for example in the `columns` of [cd_table_server()].
#'
#' @details The status has fixed limits: a red triangle below 70, an amber diamond from 70 to below
#' 90, and a green circle from 90.
#'
#' @param value The rate, a single number on a scale of 0 to 100. `NULL` or `NA` gives an empty
#'   cell.
#'
#' @return The cell as a Shiny tag (a `span` holding the shape and the number), or `""` when `value`
#'   is `NULL` or `NA`.
#'
#' @examples
#' cd_rate_status_cell(64.2)
#' cd_rate_status_cell(95)
#' cd_rate_status_cell(NA)
#'
#' # as the cell of a table column
#' reactable::colDef(cell = cd_rate_status_cell)
#'
#' @concept Countdown app charts and tables
#' @export
cd_rate_status_cell <- function(value) {
  if (is.null(value) || is.na(value)) return("")
  shape <- if (value < 70) {
    tags$path(d = "M5 9.5L9.5 1.5h-9z", fill = "#c0392b")
  } else if (value < 90) {
    tags$path(d = "M5 .5L9.5 5 5 9.5.5 5z", fill = "#b57f0c")
  } else {
    tags$circle(cx = "5", cy = "5", r = "4.5", fill = "#1b7f5a")
  }
  span(
    class = "cd-status-cell",
    tags$svg(width = "10", height = "10", viewBox = "0 0 10 10", `aria-hidden` = "true", shape),
    .cd_table_number(value, "rate")
  )
}

#' Table card with a year or indicator control
#'
#' A card that shows a data frame as a table, with a control above it (a year chip or an indicator
#' chip) and a download of the data as an Excel workbook in the card's header. The module translates
#' the column headings it knows, rounds the numbers and aligns them. Use it for the table that goes
#' with a page's charts. For a formatted table (a flextable), use [cd_table_card_ui()].
#'
#' @details
#' **The control.** Give `control_type` the same value in the ui and the server call.
#' * `"year"`: a chip listing the dataset's years (`cache()$data_years`), which starts on the first
#'   of them. When the data has a `year` column, the table shows only the rows of the chosen year.
#' * `"indicator"`: an indicator chip ([cd_indicator_ui()]) offering every indicator. The module
#'   does not filter by it. The page reads the chosen indicator from the reactive the server returns
#'   and builds `data` from it.
#'
#' **The columns.** These headings are translated without the page doing anything: `year`,
#' `adminlevel_1`, `district` and `month`; columns whose name starts with `cov_` (coverage); columns
#' whose name ends with `_med` or `_mad` (median and MAD of an indicator) and the indicator's own
#' column beside them; and, with the indicator control, the column named after the chosen indicator.
#' Every other column keeps its name unless `columns` gives it a heading. Numbers are shown rounded
#' to whole numbers and aligned to the right, except `year` and `month`.
#'
#' **The download.** The file is an Excel workbook named `filename()`, then the control's value,
#' then the date and time. What it holds depends on the arguments:
#' * With `excel_write_fun`, that function writes the workbook from `data()`.
#' * Else with `excel_sheet`, `data()` is written on one sheet with that name, under `excel_title`
#'   when it is given.
#' * With neither, the data the table is drawn from (`data()` after `data_transform`) is written on
#'   one sheet named "Data".
#'
#' With a year control the download holds the year the control is on, as the table does and as the file's name
#' says.
#'
#' The table is also registered with the app's AI bridge, which can then list it and read its data.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param title_key The translation key of the card's title.
#' @param control_type The control above the table: `"year"` (the default) or `"indicator"`.
#' @param width The card's width, passed to the kit's `cd_table_card()`. Default `6`. The kit's card
#'   takes a width and ignores it: a card is as wide as the place it is put in.
#'
#' @return `cd_table_ui()` returns the UI as Shiny tags (the card).
#'
#'   `cd_table_server()` returns a reactive holding the control's value: the chosen year as a
#'   string, or the chosen indicator's code.
#'
#' @examples
#' \dontrun{
#' # in a page's ui
#' cd_table_ui(ns("rates"), i18n, "title_rr_main", control_type = "year")
#'
#' # in the page's server
#' year <- cd_table_server("rates", cache, i18n,
#'   data = reactive(my_rates(cache())),
#'   columns = list(anc_rr = reactable::colDef(name = "ANC", cell = cd_rate_status_cell)),
#'   filename = reactive("reporting_rate"),
#'   excel_sheet = "title_rr_main"
#' )
#' }
#'
#' @concept Countdown app charts and tables
#' @export
cd_table_ui <- function(id, i18n, title_key, control_type = c("year", "indicator"), width = 6) {
  ns <- NS(id)
  control_type <- arg_match(control_type)
  
  left_control_ui <- if (control_type == "year") {
    cd_chip_select(ns("control_input"), "title_global_year", options = list(), i18n = i18n)
  } else if (control_type == "indicator") {
    cd_indicator_ui(id = ns("control_input"), i18n = i18n)
  } else {
    NULL
  }

  cd_table_card(
    title = i18n$t(title_key),
    width = width,
    i18n = i18n,
    status = "success",
    # Download moved to the header toolbar (cd_table_toolbar(), content_dashboard.R) -- explicit user request,
    # matches project/ReportingRate.dc.html's own table card exactly (its only header control is this same
    # download-as-Excel icon button). left_control_ui (the Year/indicator chip) stays in the body, same as the
    # mockup's own body-row placement for it.
    table_toolbar = cd_download_button_ui(ns("download_data")),
    div(
      class = "cd-stack",
      # The control on the left, "This table only" on the right -- project/ReportingRate.dc.html's own table card.
      div(class = "cd-table-controls", left_control_ui, span(class = "cd-table-hint", i18n$t("lbl_table_only"))),
      cd_table_spinner(reactableOutput(ns("table")))
    )
  )
}

#' @rdname cd_table_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param data A reactive that returns the data frame the table shows.
#' @param columns A named list of `reactable::colDef()`, named by column. Each one replaces or adds
#'   to what the module sets for that column (heading, cell, alignment). Entries for columns the
#'   data does not have are dropped. `NULL` (the default) changes nothing.
#' @param filename A reactive that returns the first part of the downloaded file's name. Default
#'   `reactive("download")`.
#' @param label_key The translation key of the download button's label. Default
#'   `"btn_global_download_data"`.
#' @param extension A reactive that returns the downloaded file's extension. Default
#'   `reactive("xlsx")`. The file is an Excel workbook whatever the extension says.
#' @param data_transform A function `function(data)` applied to `data()` before the table is drawn,
#'   for example to choose or rename columns. `NULL` (the default) shows `data()` as it is.
#' @param excel_write_fun A function `function(wb, data)` that writes `data()` into the `openxlsx`
#'   workbook `wb`, adding the sheets it needs. `NULL` (the default) uses `excel_sheet`, or the
#'   plain download described in Details.
#' @param excel_sheet The translation key of the sheet's name, for a download that holds `data()` on
#'   one sheet. Used only when `excel_write_fun` is `NULL`. Default `NULL`.
#' @param excel_title The translation key of a title written above the data on that sheet. Used only
#'   with `excel_sheet`. Default `NULL`, no title.
#' @param about What the table is, for the app's AI: `NULL` (the default), a list, or a function
#'   that returns a list. See `datasuite.ui::ai_register_component()`.
#' @export
cd_table_server <- function(
    id,
    cache,
    i18n,
    data,
    columns = NULL,
    control_type = c("year", "indicator"),
    filename = reactive("download"),
    label_key = "btn_global_download_data",
    extension = reactive("xlsx"),
    data_transform = NULL,
    excel_write_fun = NULL, # function(wb, data) writes workbook
    # or, for the data on one sheet, the translation keys of its sheet name and (optional) title -- see cd_sheet_writer()
    excel_sheet = NULL,
    excel_title = NULL,
    # what this table is, for the app's AI (see datasuite.ui::ai_register_component())
    about = NULL
) {
    if (is.null(excel_write_fun) && !is.null(excel_sheet)) excel_write_fun <- cd_sheet_writer(i18n, excel_sheet, excel_title)
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(data))
  stopifnot(is.reactive(filename))
  stopifnot(is.reactive(extension))
  
  control_type <- arg_match(control_type)
  
  moduleServer(
    id = id,
    module = function(input, output, session) {
      # DataSuite's chat can list this table and read what it shows (the data its download writes)
      datasuite.ui::ai_register_component(session, output_id = session$ns("table"), type = "table",
        data = function() {
          d <- data()
          if (!is.null(data_transform) && is.function(data_transform)) d <- data_transform(d)
          d
        },
        about = about)

      selected_value <- if (control_type == "year") {
        
        # The years come from the cache. They are pushed once the chip is on the page (a message to a chip that
        # has not mounted is lost). Reading the current choice inside isolate() keeps this from re-running, and
        # overwriting the user's pick, every time they choose a year.
        chip_mounted <- cd_mounted(input, "control_input")
        observe({
          req(chip_mounted(), cache(), cache()$data_years)
          years <- as.character(cache()$data_years)
          keep <- isolate(input$control_input)
          cd_update_input("control_input", session,
                       options = cd_plain_options(years),
                       value = if (!is.null(keep) && keep %in% years) keep else years[[1]])
        })
        
        reactive({ input$control_input })
        
      } else if (control_type == "indicator") {
        
        # Call your custom server module to get the selected indicator
        cd_indicator_server("control_input")
        
      } else {
        reactive({ NULL })
      }
      
      output$table <- renderReactable({
        req(data())

        dt <- if (!is.null(data_transform) && is.function(data_transform)) {
          data() %>% data_transform()
        } else {
          data()
        }
        
        if (control_type == "year" && "year" %in% names(dt)) {
          req(selected_value())
          dt <- dt %>% 
            filter(year == as.integer(selected_value()))
        }
        
        base_cols <- list(
          year = colDef(
            name = i18n$t("title_global_year"),
            aggregate = "unique" 
          ),
          adminlevel_1 = colDef(
            name = i18n$t("opt_adminlevel_1")
          ),
          district = colDef(
            name = i18n$t("opt_district")
          ),
          month = colDef(
            name = i18n$t("lbl_axis_x_outlier_trend")
          )
        )
        
        # ---------------------------------------------------------
        # THE MAGIC: Auto-detecting & Auto-translating Columns
        # ---------------------------------------------------------
        
        # A) Auto-detect "cov_" columns
        cov_cols <- grep("^cov_", names(dt), value = TRUE)
        if (length(cov_cols) > 0) {
          cov_defs <- set_names(lapply(cov_cols, function(c) {
            indicator <- i18n$t(paste0("opt_", str_remove(str_remove(c, "_[^_]*$"), "^cov_")))
            colDef(name = as.character(str_glue(i18n$t("lbl_axis_y_coverage"))))
          }), cov_cols)
          base_cols <- utils::modifyList(base_cols, cov_defs)
        }
        
        # B) Auto-detect "_med" and "_mad" columns (Extreme Outliers Table)
        med_cols <- grep("_med$", names(dt), value = TRUE)
        if (length(med_cols) > 0) {
          
          # Median columns (with str_glue interpolation)
          med_defs <- set_names(lapply(med_cols, function(x) {
            base_ind <- sub("_med$", "", x)
            indicator <- i18n$t(paste0("opt_", base_ind)) # This creates the '{indicator}' variable for str_glue
            colDef(name = as.character(str_glue(i18n$t("opt_median"))))
          }), med_cols)
          base_cols <- utils::modifyList(base_cols, med_defs)
          
          # MAD columns (with str_glue interpolation)
          mad_cols <- grep("_mad$", names(dt), value = TRUE)
          mad_defs <- set_names(lapply(mad_cols, function(x) {
            base_ind <- sub("_mad$", "", x)
            indicator <- i18n$t(paste0("opt_", base_ind)) # This creates the '{indicator}' variable for str_glue
            colDef(name = as.character(str_glue(i18n$t("opt_mad"))))
          }), mad_cols)
          base_cols <- utils::modifyList(base_cols, mad_defs)
          
          # The Base Indicator column itself
          base_inds <- sub("_med$", "", med_cols)
          ind_defs <- set_names(lapply(base_inds, function(x) colDef(name = i18n$t(paste0("opt_", x)))), base_inds)
          base_cols <- utils::modifyList(base_cols, ind_defs)
        }
        
        # C) If it's pure indicator selection, translate the standalone indicator column
        if (control_type == "indicator") {
          ind_val <- selected_value()
          if (ind_val %in% names(dt)) {
            base_cols[[ind_val]] <- colDef(name = i18n$t(paste0("opt_", ind_val)))
          }
        }
        
        final_cols <- if (is.null(columns)) base_cols else modifyList(base_cols, columns)
        final_cols <- final_cols[names(final_cols) %in% names(dt)]

        # Numbers right-aligned, per project/ReportingRate.dc.html's table -- unless the caller already set one.
        for (nm in names(final_cols)) {
          # year/month are identifiers, left-aligned like the design's own Year column, not figures.
          if (is.numeric(dt[[nm]]) && !nm %in% c("year", "month") && is.null(final_cols[[nm]]$align)) {
            final_cols[[nm]]$align <- "right"
          }
        }

        # the options and the number format every data table has (R/table-style.R)
        .cd_reactable(dt, columns = final_cols)
      })

      # A table given no writer downloads what it shows, on one sheet. (Its button is on the page either way: with
      # no server behind it, it stayed "recalculating" for as long as the page was open.)
      # The download holds the year the control is on: the file's name carries it, and the table shows it.
      for_year <- function(d) {
        if (control_type == "year" && is.data.frame(d) && "year" %in% names(d)) {
          req(selected_value())
          d <- d %>% filter(year == as.integer(selected_value()))
        }
        d
      }
      download_data <- reactive(for_year(data()))
      if (!is.function(excel_write_fun)) {
        download_data <- reactive({
          d <- data()
          if (is.function(data_transform)) d <- data_transform(d)
          for_year(d)
        })
        excel_write_fun <- function(wb, d) {
          addWorksheet(wb, "Data")
          writeData(wb, "Data", d)
        }
      }
      cd_download_button_server(
        id = "download_data",
        filename = reactive(paste0(filename(), "_", selected_value())),
        extension = extension,
        data = download_data,
        i18n = i18n,
        label = label_key,
        icon = "table",
        button_class = "cd-tool-btn cd-tool-btn--data",
        content = function(file, d) {
          wb <- createWorkbook()
          excel_write_fun(wb, d) # IMPORTANT: d is already evaluated data (not reactive)
          saveWorkbook(wb, file, overwrite = TRUE)
        }
      )
      
      return(selected_value)
    }
  )
}
