# Coverage trends by denominator card

A card of the Denominator selection page
([`denominator_selection_ui()`](denominator_selection_ui.md)) with one
tab per indicator (the app's `cov_trend_indicators` setting). Each tab
has a chart of the indicator's coverage over the years, with one line
per denominator the app offers, for the country or for the chosen
region. The card has no filters of its own: the page passes it the admin
level and the region. It calls the dataset's
[`calculate_derived_coverage()`](calculate_derived_coverage.md), and
draws nothing until the dataset's `check_inequality_params` is `TRUE`.

## Usage

``` r
coverage_trends_ui(id, i18n)

coverage_trends_server(
  id,
  cache,
  admin_level,
  region,
  i18n,
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

- admin_level:

  A reactive that returns the admin level of the chart: `"national"`,
  `"adminlevel_1"` or `"district"`.

- region:

  A reactive that returns the name of the chosen region, or `NULL` when
  none is chosen. For an admin level other than national, the chart is
  drawn only once a region is chosen.

- active:

  A reactive that is `TRUE` once the page has been opened with data
  loaded. The card does no work before that.

## Value

`coverage_trends_ui()` returns the card's UI as Shiny tags.
`coverage_trends_server()` is called for its side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
# the card in a page that has an admin level filter, as the Denominator selection page does
my_page_ui <- function(id, i18n) {
  ns <- NS(id)
  cd_page_ui(id, i18n,
    filters = cd_filter_bar(cd_admin_level_ui(ns("admin_level"), i18n, include_national = TRUE)),
    coverage_trends_ui(ns("coverage"), i18n)
  )
}
my_page_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  moduleServer(id, function(input, output, session) {
    admin <- cd_admin_parts(cd_admin_level_server("admin_level", cache, i18n))
    coverage_trends_server("coverage", cache, admin$admin_level, admin$region, i18n, active = active)
  })
}
} # }
```
