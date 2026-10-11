# Consistency checks card

A card of charts that each compare two indicators, drawn by
[`plot_comparison()`](internal_consistency.md). It has one tab for each
indicator pair the app sets (the `consistency_pairs` setting, see
[`consistency_pair_keys()`](consistency_pair_keys.md)), for example ANC1
against Penta1, and a Custom tab where the person picks any two
indicators to compare. It is the second card of the Internal consistency
page ([`internal_consistency_ui()`](internal_consistency_ui.md)). It
reads `countdown_data` from the dataset.

## Usage

``` r
consistency_check_ui(id, i18n)

consistency_check_server(id, cache, i18n, active = reactive(TRUE))
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

`consistency_check_ui()` returns the card's UI as Shiny tags.
`consistency_check_server()` is called for its side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
# the card in a page module, as the Internal consistency page uses it
my_page_ui <- function(id, i18n) {
  ns <- NS(id)
  cd_page_ui(id, i18n, consistency_check_ui(ns("consistency"), i18n))
}
my_page_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  moduleServer(id, function(input, output, session) {
    consistency_check_server("consistency", cache, i18n, active = active)
  })
}
} # }
```
