# Admin level and region of a scope

The server half of [`cd_scope_filters()`](cd_scope_filters.md): it gives
the admin level and the region a scope resolves to, as two reactives
ready to hand to an analysis. Call it inside the page's module server.
[`cd_scoped_page_server()`](cd_scoped_page_ui.md) does this for a whole
scoped page.

## Usage

``` r
cd_scope_server(id, cache, i18n, scope)
```

## Arguments

- id:

  The id of the scope's filter within the page's module. Use `"scope"`,
  the id [`cd_scope_filters()`](cd_scope_filters.md) gives the chips.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- scope:

  The page's scope, from [`cd_scope()`](cd_scope.md).

## Value

A list of two reactives:

- `admin_level`: `"national"` for a national scope. Otherwise the
  scope's `fixed_level` when it has one, else the level of the filter
  (`"adminlevel_1"` or `"district"`).

- `region`: the name of the chosen area, or `NULL` when the scope has no
  region chip.

## Details

For a `"national"` scope nothing is read from the page. For the other
kinds it runs the admin level filter
([`cd_admin_level_server()`](cd_admin_level_ui.md)) with the settings
the scope asks for, so the two reactives wait until that filter has a
value.

## Examples

``` r
if (FALSE) { # \dontrun{
my_page_server <- function(id, cache, i18n) {
  moduleServer(id, function(input, output, session) {
    geo <- cd_scope_server("scope", cache, i18n, cd_scope("level_region"))
    observe(print(list(geo$admin_level(), geo$region())))
  })
}
} # }
```
