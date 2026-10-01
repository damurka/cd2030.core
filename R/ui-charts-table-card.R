# A flextable in a chart card: the table on screen (flextable's HTML), and in the card's header its picture
# (save_as_image()) and its data (an Excel workbook). The Overall Score page uses it, and so do rmncah's Service
# Utilization data quality and national health system pages.
#
#   cd_table_card_ui(id, i18n, title, ...)
#   cd_table_card_server(id, i18n, data, table_fun, filename, sheet = "lbl_score_metric_header", about = NULL)
#
# `title`: the card's title (already translated, or a tag). `...`: passed to cd_chart_card() (width, status, ...).
# `data`: a reactive, what the table shows and what the Excel file holds. `table_fun`: function(data) returning the
# flextable; the screen and the picture are drawn with the same one, so they always match. `filename`: a reactive,
# the downloads' name without its extension. `sheet`: the translation key of the workbook's sheet name. `about`: what
# the table is, for the app's AI (see datasuite.ui::ai_register_component()).
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
