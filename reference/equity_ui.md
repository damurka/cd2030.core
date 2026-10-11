# Equity assessment page

Shows how survey coverage of an indicator differs between groups of the
population, as an equiplot for each survey. One filter chooses the
grouping: place of residence (urban and rural), mother's education or
wealth quintile; the page reads the matching survey table of the dataset
(`cache()$area_survey`, `cache()$education_survey` or
`cache()$wiq_survey`). The charts sit in one card with a tab for each
indicator the app lists (`cd_cfg("equity_indicators")`) and a Custom
tab, where any analysis indicator can be picked except those in
`cd_cfg("equity_custom_exclude")`.

## Usage

``` r
equity_ui(id, i18n)

equity_server(id, cache, i18n, active = reactive(TRUE))
```

## Arguments

- id:

  The module's id. A page's id is also its entry in the app's page
  registry.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- active:

  A reactive that is `TRUE` once the page has been opened with data
  loaded. The page does no work before that.

## Value

`equity_ui()` returns the page's UI as Shiny tags. `equity_server()`
returns a reactive that holds the key of the tab shown: an indicator's
name, or `"custom"`.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "equity_assessment",
  ui = equity_ui,
  server = equity_server,
  title = "title_nav_equity",
  section = "title_nav_national_analysis",
  subtitle = "sub_equity"
)
} # }
```
