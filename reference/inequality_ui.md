# Sub-national inequality charts

The body of the inequality pages: one card of charts with a tab for each
of the app's default indicators
([`cd_default_indicator_set()`](cd_default_indicator_set.md)) and a
Custom tab for any other analysis indicator. A tab plots, by year, the
coverage of every sub-national unit beside the reference coverage held
in the inequality table, with the denominator selected for the
indicator. It reads the dataset's `get_filtered_inequality()`:
`cache()$inequality_admin1` for admin level 1 with no region, and
`cache()$inequality_district` otherwise, limited to the region's
districts when a region is given. Both tables measure units against the
national value; when a region is given the legend names the reference
after the region. The piece has no filters of its own: the page gives it
the admin level and region.

## Usage

``` r
inequality_ui(id, i18n, title_key = "title_inequ_national")

inequality_server(
  id,
  cache,
  i18n,
  admin_level,
  region = reactive(NULL),
  active = reactive(TRUE)
)
```

## Arguments

- id:

  The module's id.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- title_key:

  The translation key of the card's title. By default the national
  page's.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- admin_level:

  A reactive that returns the level of the units compared:
  `"adminlevel_1"` (admin level 1) or `"district"`.

- region:

  A reactive that returns the name of an admin level 1 region, to
  compare its districts, or `NULL` to compare every unit of the country.
  A region is accepted only with `"adminlevel_1"`.

- active:

  A reactive that is `TRUE` once the page has been opened with data
  loaded. The charts do no work before that.

## Value

`inequality_ui()` returns the card's UI as Shiny tags.
`inequality_server()` returns a reactive that holds the key of the tab
shown: an indicator's name, or `"custom"`. The national inequality page
uses it to show the same tab on its maps.

## Examples

``` r
if (FALSE) { # \dontrun{
# the charts in a page module, for the admin level 1 areas of the country
my_page_ui <- function(id, i18n) {
  ns <- NS(id)
  cd_page_ui(id, i18n, inequality_ui(ns("inequality"), i18n, title_key = "title_inequ_national"))
}
my_page_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  moduleServer(id, function(input, output, session) {
    shown <- inequality_server("inequality", cache, i18n, reactive("adminlevel_1"), active = active)
    observe(message("Tab shown: ", shown()))
  })
}
} # }
```
