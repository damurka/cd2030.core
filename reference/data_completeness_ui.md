# Data completeness page

The data quality page on missing values. Its first card has three tabs:
a heat map of completeness by admin level 1 area or district, a chart of
district completeness for the chosen indicator, and a line chart of the
indicator's completeness over the years. Below it is a table of the
units with missing values in the year picked on the table. The filters
are the indicator, which can also be set to all indicators, and the
admin level with its region. With all indicators chosen, the table lists
the missing units of every indicator, with a column that names the
indicator.

## Usage

``` r
data_completeness_ui(id, i18n)

data_completeness_server(id, cache, i18n, active = reactive(TRUE))
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

`data_completeness_ui()` returns the page's UI as Shiny tags.
`data_completeness_server()` is called for its side effects.

## Details

The page reads `completeness_admin1`, `completeness_district` and
`district_completeness` from the dataset, and calls its
[`list_missing_units()`](list_missing_units.md), and its
[`calculate_completeness_summary()`](calculate_completeness_summary.md)
and
[`calculate_district_completeness_summary()`](calculate_district_completeness_summary.md)
when a region is chosen. The heat map's Excel download writes
`completeness_national` and `district_completeness`.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "data_completeness",
  ui = data_completeness_ui,
  server = data_completeness_server,
  title = "title_complete_main",
  section = "lbl_nav_section_quality",
  subtitle = "sub_complete_main"
)
} # }
```
