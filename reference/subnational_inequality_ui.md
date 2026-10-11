# Sub-national inequality page

Shows how coverage differs between districts. A filter chooses the admin
level. With admin level 1, a second filter chooses a region, and the
charts show the coverage of that region's districts; they wait until a
region is chosen. With district, there is no second filter and the
charts show every district of the country. The page is the inequality
charts ([`inequality_ui()`](inequality_ui.md)), which read
`cache()$inequality_district` through the dataset's
`get_filtered_inequality()`; that table measures each district against
the national value.

## Usage

``` r
subnational_inequality_ui(id, i18n)

subnational_inequality_server(id, cache, i18n, active = reactive(TRUE))
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

`subnational_inequality_ui()` returns the page's UI as Shiny tags.
`subnational_inequality_server()` returns what
[`inequality_server()`](inequality_ui.md) returns: a reactive that holds
the key of the tab shown.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "subnational_inequality",
  ui = subnational_inequality_ui,
  server = subnational_inequality_server,
  title = "title_inequ_subnational",
  section = "title_nav_subnational_analysis",
  subtitle = "sub_inequ_subnational"
)
} # }
```
