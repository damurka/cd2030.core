# Outlier detection page

The data quality page on extreme values in the monthly data. Its first
card has three tabs for the chosen indicator: a heat map of the outlier
summary by admin level 1 area or district, a bar chart by indicator and
a bar chart by area. Below it are a table of the districts and months
flagged as outliers in the year picked on the table (the reported value
with its median and median absolute deviation), and a trend chart of
those outliers for one region and that year. The filters are the
indicator and the admin level with its region. The trend chart has its
own region filter, which follows the page's region.

## Usage

``` r
outlier_detection_ui(id, i18n)

outlier_detection_server(id, cache, i18n, active = reactive(TRUE))
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

`outlier_detection_ui()` returns the page's UI as Shiny tags.
`outlier_detection_server()` is called for its side effects.

## Details

The page reads `outliers_admin1`, `outliers_district` and
`list_outlier_units` from the dataset, and calls its
[`calculate_outliers_summary()`](calculate_outliers_summary.md) when a
region is chosen. The heat map's Excel download also writes
`outliers_national` and `district_outliers_summary`.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "outlier_detection",
  ui = outlier_detection_ui,
  server = outlier_detection_server,
  title = "title_outlier_main",
  section = "lbl_nav_section_quality",
  subtitle = "sub_outlier_main"
)
} # }
```
