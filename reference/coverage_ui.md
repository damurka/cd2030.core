# Coverage charts for one geography

The body of the national and sub-national coverage pages: one card of
charts with a tab for each indicator the app lists
(`cd_cfg("nat_cov_indicators")`) and a Custom tab for any other analysis
indicator. A tab plots the indicator's coverage by year from the health
facility data, with the denominator selected for that indicator, beside
the survey and WUENIC estimates. It reads the dataset's
`get_filtered_coverage()`, which takes the indicator's rows from
[`calculate_coverage()`](calculate_coverage.md) for the admin level and
region. The tab `"fpet"`, when an app lists it, shows the family
planning estimates instead (`cache()$fpet_data`, from 2010 onwards). The
piece has no filters of its own: the page gives it the admin level and
region.

## Usage

``` r
coverage_ui(id, i18n, key_label)

coverage_server(
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

- key_label:

  The translation key of the card's title.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- admin_level:

  A reactive that returns the level the coverage is worked out at:
  `"national"`, `"adminlevel_1"` (admin level 1) or `"district"`.

- region:

  A reactive that returns the name of the region (or district) to show,
  or `NULL` for none.

- active:

  A reactive that is `TRUE` once the page has been opened with data
  loaded. The charts do no work before that.

## Value

`coverage_ui()` returns the card's UI as Shiny tags. `coverage_server()`
returns a reactive that holds the key of the tab shown: an indicator's
name, or `"custom"`.

## Examples

``` r
if (FALSE) { # \dontrun{
# the charts in a page module, at national level
my_page_ui <- function(id, i18n) {
  ns <- NS(id)
  cd_page_ui(id, i18n, coverage_ui(ns("body"), i18n, "title_coverage_national"))
}
my_page_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  moduleServer(id, function(input, output, session) {
    coverage_server("body", cache, i18n, reactive("national"), active = active)
  })
}

# for one region: the admin level and the region are reactives
coverage_server("body", cache, i18n, reactive("adminlevel_1"), reactive("Nairobi"), active = active)
} # }
```
