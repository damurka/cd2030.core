# Data adjustment page

The page where the person sets which data is kept for analysis and how
it is corrected. Years can be removed everywhere, and an area's data can
be removed for some or every year. The corrections are for completeness
(by each indicator group's k factor), outliers and missing values, set
for everywhere or with a region's or district's own settings. The page
is one editor
([`datasuite.ui::cd_adjustment_editor()`](https://rdrr.io/pkg/datasuite.ui/man/interface-kit.html)),
which shows beside each setting what the check pages found
([`adjustment_evidence()`](adjustment_evidence.md)). Below it are a
button that downloads the adjusted data as a Stata file and a link to
the Data adjustment changes page
([`adjustment_changes_ui()`](adjustment_changes_ui.md)).

## Usage

``` r
data_adjustment_ui(id, i18n)

data_adjustment_server(id, cache, i18n, active = reactive(TRUE))
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

  Not used. It is accepted so that the app's page registry can pass it
  as it does to every other page.

## Value

`data_adjustment_ui()` returns the page's UI as Shiny tags.
`data_adjustment_server()` is called for its side effects.

## Details

The Adjust data button saves the settings in the dataset
(`set_adjustment_settings()`) and adjusts it (`adjust_data()`). The page
is then read-only until the person chooses Edit. The page reads
`countdown_data`, `performance_threshold`, `adjustment_settings`,
`adjusted_flag` and `adjusted_data` from the dataset.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "data_adjustment",
  ui = data_adjustment_ui,
  server = data_adjustment_server,
  title = "title_adjust_main",
  section = "lbl_nav_section_quality",
  subtitle = "sub_adjust_main"
)
} # }
```
