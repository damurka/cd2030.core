# National coverage target page

Shows how much of the country meets the coverage targets. One filter
chooses the admin level (admin level 1 or district). The page is the
target charts and table ([`target_ui()`](target_ui.md)) for the whole
country: by year, the percentage of regions or districts that meet each
target group's target (the dataset's `get_filtered_threshold()`), and a
table of the areas whose coverage of a chosen indicator reaches the
target (the dataset's `get_high_performers()`).

## Usage

``` r
national_target_ui(id, i18n)

national_target_server(id, cache, i18n, active = reactive(TRUE))
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

`national_target_ui()` returns the page's UI as Shiny tags.
`national_target_server()` returns what
[`target_server()`](target_ui.md) returns: a reactive that holds the key
of the tab shown.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "national_target",
  ui = national_target_ui,
  server = national_target_server,
  title = "title_nav_global_coverage",
  section = "title_nav_national_analysis",
  subtitle = "sub_target_national"
)
} # }
```
