# Overall score page

The data quality page that brings the checks together in one table: the
completeness of monthly reporting, extreme outliers and the consistency
of annual reporting, with a score for each year of the data. The one
filter is the region: with none chosen the table is for the country,
otherwise it is for that admin level 1 area. The table can be
downloaded.

## Usage

``` r
overall_score_ui(id, i18n)

overall_score_server(id, cache, i18n, active = reactive(TRUE))
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

`overall_score_ui()` returns the page's UI as Shiny tags.
`overall_score_server()` is called for its side effects.

## Details

The page calls the dataset's
[`calculate_overall_score()`](calculate_overall_score.md), and reads its
`performance_threshold` (shown in a row label) and `data_years`.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "overall_score",
  ui = overall_score_ui,
  server = overall_score_server,
  title = "title_score_main",
  section = "lbl_nav_section_quality",
  subtitle = "sub_score_main"
)
} # }
```
