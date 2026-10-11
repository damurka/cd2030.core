#' Indicator filter chip
#'
#' A filter chip that chooses one indicator. A page puts `cd_indicator_ui()` in its filter bar or in
#' a card, calls `cd_indicator_server()` in its server, and reads the chosen indicator from the
#' reactive the server returns. The chip starts on its first choice.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param label The translation key of the chip's label. `NULL` (the default) uses
#'   `"title_global_indicator"`.
#' @param tooltip The translation key of a hint shown with the chip, or `NULL` (the default) for
#'   none.
#' @param indicators A character vector of indicator codes, the chip's choices. Without names, each
#'   indicator's label is the translation of `opt_` followed by its code (`"opt_penta3"`). With
#'   names, the names are the translation keys of the labels. `NULL` (the default) offers every
#'   indicator, as `get_all_indicators()` lists them.
#' @param select_all Logical. `TRUE` adds an "all" choice first, whose value is the empty string
#'   `""`. Default `FALSE`.
#'
#' @return `cd_indicator_ui()` returns the UI as Shiny tags (the chip).
#'
#'   `cd_indicator_server()` returns a reactive holding the chosen indicator's code as a string. It
#'   holds `""` when "all" is chosen, and `NULL` until the chip has reported its first value.
#'
#' @examples
#' \dontrun{
#' # in a page's ui
#' cd_indicator_ui(ns("indicator"), i18n, indicators = c("penta3", "measles1"), select_all = TRUE)
#'
#' # in the page's server
#' indicator <- cd_indicator_server("indicator")
#' observe(print(indicator()))
#' }
#'
#' @concept Countdown app filters
#' @export
cd_indicator_ui <- function(id, i18n, label = NULL, tooltip = NULL, indicators = NULL, select_all = FALSE) {
  ns <- NS(id)
  label <- if (is.null(label)) "title_global_indicator" else label
  choices <- indicators %||% get_all_indicators()
  if (is.null(choices) || is.null(names(choices))) {
    names(choices) <- paste0("opt_", choices)
  }
  if (select_all) {
    choices <- c("opt_global_select_all" = "", choices)
  }

  cd_chip_select(ns("indicator"),
    label = label,
    i18n = i18n,
    choices = choices,
    hint = tooltip
  )
}

#' @rdname cd_indicator_ui
#' @export
cd_indicator_server <- function(id) {
  moduleServer(id = id, module = function(input, output, session) {
    return(reactive(input$indicator))
  })
}
