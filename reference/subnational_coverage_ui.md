# Sub-national coverage page

Shows coverage by year for one region or one district: the estimate from
the health facility data, with the denominator selected for the
indicator, beside the survey and WUENIC estimates. Two filters choose
the admin level (admin level 1 or district) and then the area at that
level; the charts wait until an area is chosen. The page is the coverage
charts ([`coverage_ui()`](coverage_ui.md)) for that area: one card with
a tab for each indicator in `cd_cfg("nat_cov_indicators")` and a Custom
tab. The data come from the dataset's `get_filtered_coverage()`, which
reads `cache()$calculate_coverage()` for the chosen level.

## Usage

``` r
subnational_coverage_ui(id, i18n)

subnational_coverage_server(id, cache, i18n, active = reactive(TRUE))
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

`subnational_coverage_ui()` returns the page's UI as Shiny tags.
`subnational_coverage_server()` returns what
[`coverage_server()`](coverage_ui.md) returns: a reactive that holds the
key of the tab shown.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "subnational_coverage",
  ui = subnational_coverage_ui,
  server = subnational_coverage_server,
  title = "title_nav_subnational_coverage",
  section = "title_nav_subnational_analysis",
  subtitle = "sub_cov_subnational"
)
} # }
```
