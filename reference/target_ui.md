# Coverage target charts and table

The body of the coverage target pages. A card of charts has a tab for
each target group the app lists (`cd_cfg("target_indicators")`, from
`"anc4"`, `"instlivebirths"`, `"vaccine"` and `"dropout"`) and no Custom
tab; a tab plots, by year, the percentage of regions or districts that
meet the group's target, from the dataset's `get_filtered_threshold()`.
Below it, a table lists the areas whose coverage of one indicator
reaches the target, by year, from the dataset's `get_high_performers()`;
the indicator is picked above the table, and the table can be downloaded
as an Excel file. The table's title names admin level 1 or districts,
following the admin level. The piece has no page filters of its own: the
page gives it the admin level and region.

## Usage

``` r
target_ui(id, i18n)

target_server(
  id,
  cache,
  i18n,
  admin_level,
  region = reactive(NULL),
  active = reactive(TRUE)
)
```

## Arguments

- id:

  The module's id.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- admin_level:

  A reactive that returns the level of the units counted:
  `"adminlevel_1"` (admin level 1) or `"district"`.

- region:

  A reactive that returns the name of an admin level 1 region, to count
  only its districts, or `NULL` for the whole country. A region is
  accepted only with `"district"`.

- active:

  A reactive that is `TRUE` once the page has been opened with data
  loaded. The charts and the table do no work before that.

## Value

`target_ui()` returns the charts' card and the table's placeholder as
Shiny tags. `target_server()` returns a reactive that holds the key of
the tab shown (a target group's name).

## Examples

``` r
if (FALSE) { # \dontrun{
# the charts and table in a page whose filter chooses the admin level
scope <- cd_scope("level")

my_page_ui <- function(id, i18n) {
  ns <- NS(id)
  cd_page_ui(id, i18n, filters = cd_scope_filters(ns, i18n, scope), target_ui(ns("body"), i18n))
}
my_page_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  moduleServer(id, function(input, output, session) {
    geo <- cd_scope_server("scope", cache, i18n, scope)
    target_server("body", cache, i18n, geo$admin_level, geo$region, active = active)
  })
}
} # }
```
