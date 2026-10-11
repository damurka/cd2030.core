# Internal consistency page

The data quality page on how well related indicators agree with each
other. It has two cards and no filters: the ratio chart
([`calculate_ratios_ui()`](calculate_ratios_ui.md)) and the consistency
checks, which compare pairs of indicators
([`consistency_check_ui()`](consistency_check_ui.md)). Those two pieces
read `ratios_summary` and `countdown_data` from the dataset.

## Usage

``` r
internal_consistency_ui(id, i18n)

internal_consistency_server(id, cache, i18n, active = reactive(TRUE))
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

`internal_consistency_ui()` returns the page's UI as Shiny tags.
`internal_consistency_server()` is called for its side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "internal_consistency",
  ui = internal_consistency_ui,
  server = internal_consistency_server,
  title = "title_consist_main",
  section = "lbl_nav_section_quality",
  subtitle = "sub_consist_main"
)
} # }
```
