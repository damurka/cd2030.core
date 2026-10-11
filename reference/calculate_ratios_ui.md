# Indicator ratios card

A card with one chart of the ratios between related indicators (ANC1 to
Penta1, OPV1 to OPV3 and Penta1 to Penta3 have translated labels). It is
the first card of the Internal consistency page
([`internal_consistency_ui()`](internal_consistency_ui.md)) and has no
filters. It reads `ratios_summary` from the dataset.

## Usage

``` r
calculate_ratios_ui(id, i18n)

calculate_ratios_server(id, cache, i18n, active = reactive(TRUE))
```

## Arguments

- id:

  The module's id.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- active:

  A reactive that is `TRUE` once the page has been opened with data
  loaded. The card does no work before that.

## Value

`calculate_ratios_ui()` returns the card's UI as Shiny tags.
`calculate_ratios_server()` is called for its side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
# the card in a page module, as the Internal consistency page uses it
my_page_ui <- function(id, i18n) {
  ns <- NS(id)
  cd_page_ui(id, i18n, calculate_ratios_ui(ns("ratios"), i18n))
}
my_page_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  moduleServer(id, function(input, output, session) {
    calculate_ratios_server("ratios", cache, i18n, active = active)
  })
}
} # }
```
