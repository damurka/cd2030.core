# Reporting rate page

The data quality page on how completely facilities report. Its first
card shows the reporting rate of the chosen indicator for each admin
level 1 area or district, as a heat map or as a bar chart (two tabs).
Below it are a chart of the district reporting rates, for the country or
for the chosen region, and a table of the areas whose rate is below the
performance threshold in the year picked on the table. The filters are
the indicator (the app's `reporting_rate_indicators` setting), the
performance threshold and the admin level with its region.

## Usage

``` r
reporting_rate_ui(id, i18n)

reporting_rate_server(id, cache, i18n, active = reactive(TRUE))
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

`reporting_rate_ui()` returns the page's UI as Shiny tags.
`reporting_rate_server()` is called for its side effects.

## Details

The page reads `reporting_rate_admin1`, `reporting_rate_district` and
`district_reporting_rate` from the dataset, and calls its
`calculate_reporting_rate()` and
[`calculate_district_reporting_rate()`](calculate_district_reporting_rate.md)
when a region is chosen. The performance threshold comes from the
dataset's `performance_threshold`, and a change to it is saved there
with `set_performance_threshold()`.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "reporting_rate",
  ui = reporting_rate_ui,
  server = reporting_rate_server,
  title = "title_rr_main",
  section = "lbl_nav_section_quality",
  subtitle = "sub_rr_main"
)
} # }
```
