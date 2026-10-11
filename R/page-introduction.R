#' Introduction page
#'
#' The app's opening screen: one card that shows the app's introduction text in the chosen
#' language. The text is the Markdown file `0_intro_<language>.md` in the app's help folder, which
#' an app sets with `options(cd2030.help_dir = )` (by default `"help"`). When there is no file for
#' the language, the English one (`0_intro_en.md`) is shown. The page reads nothing from the
#' dataset.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for the card's title.
#'
#' @return `introduction_ui()` returns the page's UI as Shiny tags. `introduction_server()` is
#'   called for its side effects.
#'
#' @examples
#' \dontrun{
#' # the folder that holds 0_intro_en.md, 0_intro_fr.md and so on
#' options(cd2030.help_dir = system.file("intro", package = "cd2030.rmncah"))
#'
#' # in the app's UI, and in its server function
#' introduction_ui("introduction", i18n = i18n)
#' introduction_server("introduction", selected_language = reactive(input$selected_language))
#' }
#'
#' @concept Countdown app pages
#' @export
introduction_ui <- function(id, i18n) {
  ns <- NS(id)

  cd_card(title = i18n$t('title_global_intro_main'),
      status = 'success',
      solidHeader = TRUE,
      width = 12,
      div(class = "cd-stack", uiOutput(ns("localized_markdown")))
  )
}

#' @rdname introduction_ui
#' @param selected_language A reactive that returns the code of the language picked in the app
#'   (for example `"en"`). While it does not hold one non-empty string, the page uses the language
#'   the app's translator is set to, and English if that cannot be read.
#' @export
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

