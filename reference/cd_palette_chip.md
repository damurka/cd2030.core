# Colour palette chip for a page's maps

A filter chip that chooses the colour palette of the maps on a page. It
belongs in the bar of map options above the maps (`cd_map_options()`).
The page reads the choice as `input$<inputId>` and passes it to the map
plots, which accept these palette names.

## Usage

``` r
cd_palette_chip(inputId, i18n, first = "Greens")
```

## Arguments

- inputId:

  The input's id. Inside a module, pass it through the module's `ns()`.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- first:

  The palette listed first, and so the one the page opens with:
  `"Greens"` (the default), `"Blues"`, `"Reds"` or `"Purples"`. Any
  other value leaves the order as it is, with `"Greens"` first.

## Value

The UI as Shiny tags (the chip). Its value, `input$<inputId>`, is the
chosen palette's name.

## Details

The choices are four sequential RColorBrewer palettes: `"Greens"`,
`"Blues"`, `"Reds"` and `"Purples"`. The chip starts on its first
choice, so `first` decides which palette a page opens with. This is a
plain input, not a module, so there is no server function to call.

## Examples

``` r
if (FALSE) { # \dontrun{
cd_map_options(cd_palette_chip(ns("palette"), i18n, first = "Blues"))
} # }
```
