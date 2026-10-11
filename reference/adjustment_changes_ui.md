# Data adjustment changes page

The page that shows what the adjustment changed, one indicator at a
time. A chart sets each year's reported count beside the adjusted count,
which is made of its parts (completeness, outliers and missing values),
and a table gives the same numbers with the change in percent. A step
the indicator does not get is marked "Off". Above the chart, the page
lists the adjustment's rules as the reports' footnote gives them
([`adjustment_settings_footnote()`](adjustment_settings_footnote.md))
and says whether the data has been adjusted.

## Usage

``` r
adjustment_changes_ui(id, i18n)

adjustment_changes_server(id, cache, i18n, active = reactive(TRUE))
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
  loaded. The page does not work the changes out before that.

## Value

`adjustment_changes_ui()` returns the page's UI as Shiny tags.
`adjustment_changes_server()` is called for its side effects.

## Details

The indicator is chosen with the card's tabs (the app's
`adjustment_indicators` setting) or with the filter for the other
indicators, which wins while it has a value. The area filter is every
area, one region or one district. The page reads
`data_with_excluded_years`, `adjustment_settings`, `countdown_data` and
`adjusted_flag` from the dataset, and works the numbers out with
[`generate_adjustment_values()`](generate_adjustment_values.md).

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "data_adjustment_changes",
  ui = adjustment_changes_ui,
  server = adjustment_changes_server,
  title = "title_adjust_changes",
  section = "lbl_nav_section_quality",
  subtitle = "sub_adjust_changes"
)
} # }
```
