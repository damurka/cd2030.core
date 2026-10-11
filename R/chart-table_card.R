#' Flextable in a card with picture and Excel downloads
#'
#' A card that shows a formatted table (a flextable) on screen, with two downloads in the card's
#' header: the table as a picture and its data as an Excel workbook. Use it for a table whose layout
#' matters, such as a scorecard. The Overall Score page uses it. For a plain table of data, use
#' [cd_table_ui()].
#'
#' @details The page gives the data and one function that turns it into a flextable. The table on
#' screen and the picture are drawn with the same function, so they always match. The picture is a
#' PNG file. The workbook holds `data()` on one sheet. Both files are named `filename()` followed by
#' the date and time.
#'
#' The table is drawn once `data()` has a value. It is also registered with the app's AI bridge,
#' which can then list it and read its data.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param title The card's title: text that is already translated (`i18n$t("...")`), or a tag.
#' @param ... More arguments for the kit's `cd_chart_card()`, which passes them to `cd_card()`: for
#'   example `status = "success"`.
#' @param width The card's width, passed to the kit's `cd_chart_card()`. Default `12`. The kit's
#'   card takes a width and ignores it: a card is as wide as the place it is put in.
#'
#' @return `cd_table_card_ui()` returns the UI as Shiny tags (the card).
#'
#'   `cd_table_card_server()` returns nothing useful. It is called for what it does.
#'
#' @examples
#' \dontrun{
#' # in a page's ui
#' cd_table_card_ui(ns("score"), i18n, i18n$t("title_score_main"), status = "success")
#'
#' # in the page's server
#' cd_table_card_server("score", i18n,
#'   data = reactive(my_scores(cache())),
#'   table_fun = function(d) flextable::flextable(d),
#'   filename = reactive("overall_score")
#' )
#' }
#'
#' @concept Countdown app charts and tables
#' @export
cd_table_card_ui <- function(id, i18n, title, ..., width = 12) {
  ns <- NS(id)
  cd_chart_card(
    title = title,
    chart_toolbar = tagList(cd_download_button_ui(ns("download_plot")), cd_download_button_ui(ns("download_data"))),
    i18n = i18n,
    width = width,
    ...,
    cd_table_spinner(uiOutput(ns("table")))
  )
}

#' @rdname cd_table_card_ui
#' @param data A reactive that returns what the table shows. It is given to `table_fun` and written
#'   to the Excel workbook.
#' @param table_fun A function `function(data)` that returns the flextable.
#' @param filename A reactive that returns the first part of the downloaded files' name. The date
#'   and time and the extension are added to it.
#' @param sheet The translation key of the workbook's sheet name. Default
#'   `"lbl_score_metric_header"`.
#' @param about What the table is, for the app's AI: `NULL` (the default), a list, or a function
#'   that returns a list. See `datasuite.ui::ai_register_component()`.
#' @export
cd_table_card_server <- function(id, i18n, data, table_fun, filename, sheet = "lbl_score_metric_header", about = NULL) {
  stopifnot(is.reactive(data), is.function(table_fun), is.reactive(filename))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      # DataSuite's chat can list this table and read what it shows (the data its download writes)
      datasuite.ui::ai_register_component(session, output_id = session$ns("table"), type = "table",
                                          data = function() data(), about = about)

      output$table <- renderUI({
        req(data())
        HTML(as.character(htmltools_value(table_fun(data()))))
      })

      cd_download_button_server(
        id = "download_data",
        filename = filename,
        extension = reactive("xlsx"),
        data = data,
        i18n = i18n,
        label = "btn_global_download_data",
        icon = "table",
        button_class = "cd-tool-btn",
        content = function(file, d) {
          wb <- createWorkbook()
          cd_add_sheet(wb, i18n$t(sheet), d)
          saveWorkbook(wb, file, overwrite = TRUE)
        }
      )

      cd_download_button_server(
        id = "download_plot",
        filename = filename,
        extension = reactive("png"),
        data = data,
        i18n = i18n,
        label = "btn_global_download_plot",
        icon = "camera",
        button_class = "cd-tool-btn",
        content = function(file, d) {
          save_as_image(table_fun(d), path = file, zoom = 3)
        }
      )
    }
  )
}
