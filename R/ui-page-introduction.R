introduction_ui <- function(id, i18n) {
  ns <- NS(id)

  cd_card(title = i18n$t('title_global_intro_main'),
      status = 'success',
      solidHeader = TRUE,
      width = 12,
      div(class = "cd-stack", uiOutput(ns("localized_markdown")))
  )
}

introduction_server <- function(id, selected_language) {
  stopifnot(is.reactive(selected_language))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns

      output$localized_markdown <- renderUI({
        # the language picked, else the one on screen (the picker has not sent one yet when the app starts)
        lang <- selected_language()
        if (!is.character(lang) || length(lang) != 1 || !nzchar(lang)) {
          lang <- tryCatch(cd_i18n()$get_translation_language(), error = function(e) "en")
        }
        help_dir <- getOption("cd2030.help_dir", "help")
        file_path <- file.path(help_dir, paste0("0_intro_", lang, ".md"))
        if (!file.exists(file_path)) file_path <- file.path(help_dir, "0_intro_en.md")
        includeMarkdown(file_path)
      })
    }
  )
}

