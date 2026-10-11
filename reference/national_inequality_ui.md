# National inequality page

Shows how coverage differs between the admin level 1 areas of the
country, in two cards. The first is the inequality charts
([`inequality_ui()`](inequality_ui.md)): each area's coverage by year
against national coverage, from `cache()$inequality_admin1`. The second
is the maps of the same coverage
([`subnational_mapping_ui()`](subnational_mapping_ui.md)), from the
dataset's `get_filtered_mapping_data()`; changing the tab of the charts
changes the tab of the maps too. Two controls above the maps apply to
the maps only: the years to map, which are saved in the dataset
(`set_mapping_years()`), and the colour palette.

## Usage

``` r
national_inequality_ui(id, i18n)

national_inequality_server(id, cache, i18n, active = reactive(TRUE))
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
  loaded. The charts and maps do no work before that.

## Value

`national_inequality_ui()` returns the page's UI as Shiny tags.
`national_inequality_server()` is called for its side effects; its value
(the observer that saves the chosen years) is of no use to a caller.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "national_inequality",
  ui = national_inequality_ui,
  server = national_inequality_server,
  title = "title_inequ_national",
  section = "title_nav_national_analysis",
  subtitle = "sub_inequ_national"
)
} # }
```
