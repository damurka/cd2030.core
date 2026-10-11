#' Colour palette chip for a page's maps
#'
#' A filter chip that chooses the colour palette of the maps on a page. It belongs in the bar of map
#' options above the maps (`cd_map_options()`). The page reads the choice as `input$<inputId>` and
#' passes it to the map plots, which accept these palette names.
#'
#' @details The choices are four sequential RColorBrewer palettes: `"Greens"`, `"Blues"`, `"Reds"`
#' and `"Purples"`. The chip starts on its first choice, so `first` decides which palette a page
#' opens with. This is a plain input, not a module, so there is no server function to call.
#'
#' @param inputId The input's id. Inside a module, pass it through the module's `ns()`.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param first The palette listed first, and so the one the page opens with: `"Greens"` (the
#'   default), `"Blues"`, `"Reds"` or `"Purples"`. Any other value leaves the order as it is, with
#'   `"Greens"` first.
#'
#' @return The UI as Shiny tags (the chip). Its value, `input$<inputId>`, is the chosen palette's
#'   name.
#'
#' @examples
#' \dontrun{
#' cd_map_options(cd_palette_chip(ns("palette"), i18n, first = "Blues"))
#' }
#'
#' @concept Countdown app filters
#' @export
cd_palette_chip <- function(inputId, i18n, first = "Greens") {
  palettes <- c("opt_palette_greens" = "Greens", "opt_palette_blues" = "Blues", "opt_palette_reds" = "Reds", "opt_palette_purples" = "Purples")
  palettes <- c(palettes[palettes == first], palettes[palettes != first])
  cd_chip_select(inputId, label = "title_global_palette", i18n = i18n, choices = palettes)
}
