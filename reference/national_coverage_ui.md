# National coverage page

Shows national coverage by year for each indicator: the estimate from
the health facility data, with the denominator selected for the
indicator, beside the survey and WUENIC estimates. The page is the
coverage charts ([`coverage_ui()`](coverage_ui.md)) at the national
level: one card with a tab for each indicator in
`cd_cfg("nat_cov_indicators")` and a Custom tab. It has no filters. The
data come from the dataset's `get_filtered_coverage()`, which reads
`cache()$calculate_coverage("national")`.

## Usage

``` r
national_coverage_ui(id, i18n)

national_coverage_server(id, cache, i18n, active = reactive(TRUE))
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

`national_coverage_ui()` returns the page's UI as Shiny tags.
`national_coverage_server()` returns what
[`coverage_server()`](coverage_ui.md) returns: a reactive that holds the
key of the tab shown.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "national_coverage",
  ui = national_coverage_ui,
  server = national_coverage_server,
  title = "title_coverage_national",
  section = "title_nav_national_analysis",
  subtitle = "sub_cov_national"
)
} # }
```
