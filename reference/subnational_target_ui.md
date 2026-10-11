# Sub-national coverage target page

Shows how much of one region meets the coverage targets. One filter
chooses an admin level 1 region; the page waits until one is chosen, and
the unit counted is always the district. The page is the target charts
and table ([`target_ui()`](target_ui.md)) for that region: by year, the
percentage of the region's districts that meet each target group's
target (the dataset's `get_filtered_threshold()`), and a table of the
areas of the region whose coverage of a chosen indicator reaches the
target (the dataset's `get_high_performers()`).

## Usage

``` r
subnational_target_ui(id, i18n)

subnational_target_server(id, cache, i18n, active = reactive(TRUE))
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

`subnational_target_ui()` returns the page's UI as Shiny tags.
`subnational_target_server()` returns what
[`target_server()`](target_ui.md) returns: a reactive that holds the key
of the tab shown.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "subnational_target",
  ui = subnational_target_ui,
  server = subnational_target_server,
  title = "title_nav_global_coverage",
  section = "title_nav_subnational_analysis",
  subtitle = "sub_target_subnational"
)
} # }
```
