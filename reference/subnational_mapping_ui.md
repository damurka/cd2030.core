# Sub-national coverage maps

The maps of the national inequality page: one card with a tab for each
of the app's default indicators
([`cd_default_indicator_set()`](cd_default_indicator_set.md)) and a
Custom tab for any other analysis indicator. A tab draws maps of the
indicator's coverage in each admin level 1 area, with the denominator
selected for the indicator, for the years chosen for mapping
(`cache()$mapping_years`). It reads the dataset's
`get_filtered_mapping_data()`, which joins the admin level 1 coverage to
the map through the dataset's map mapping. The piece has no filters of
its own: the page gives it the colour palette and the tab to show.

## Usage

``` r
subnational_mapping_ui(id, i18n)

subnational_mapping_server(
  id,
  cache,
  i18n,
  palette,
  selected_tab,
  active = reactive(TRUE)
)
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

- palette:

  A reactive that returns the name of the maps' colour palette (for
  example `"Greens"`).

- selected_tab:

  A reactive that returns the key of the tab to show, or `NULL` to leave
  the tabs as they are. When its value changes, the maps switch to that
  tab.

- active:

  A reactive that is `TRUE` once the page has been opened with data
  loaded. The maps do no work before that.

## Value

`subnational_mapping_ui()` returns the card's UI as Shiny tags.
`subnational_mapping_server()` returns a reactive that holds the key of
the tab shown: an indicator's name, or `"custom"`.

## Examples

``` r
if (FALSE) { # \dontrun{
# the maps below the inequality charts, showing the tab the charts show
my_page_ui <- function(id, i18n) {
  ns <- NS(id)
  cd_page_ui(id, i18n,
    inequality_ui(ns("inequality"), i18n),
    cd_map_options(cd_palette_chip(ns("palette"), i18n)),
    subnational_mapping_ui(ns("map"), i18n)
  )
}
my_page_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  moduleServer(id, function(input, output, session) {
    selected_tab <- inequality_server("inequality", cache, i18n, reactive("adminlevel_1"), active = active)
    subnational_mapping_server("map", cache, i18n, reactive(input$palette), selected_tab, active = active)
  })
}
} # }
```
