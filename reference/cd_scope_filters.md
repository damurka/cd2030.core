# Filter bar of a scope

The filter bar holding the admin level and region chips a scope asks
for. [`cd_scoped_page_ui()`](cd_scoped_page_ui.md) uses it. Call it
yourself in a page that lays out its own body but still takes its
geography from a scope, and pair it with
[`cd_scope_server()`](cd_scope_server.md).

## Usage

``` r
cd_scope_filters(ns, i18n, scope)
```

## Arguments

- ns:

  The page's namespace function, `NS(id)`.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- scope:

  The page's scope, from [`cd_scope()`](cd_scope.md).

## Value

The UI as Shiny tags (a filter bar), or `NULL` for a `"national"` scope,
which has no filters.

## Details

The chips are an admin level filter
([`cd_admin_level_ui()`](cd_admin_level_ui.md)) with the id
`ns("scope")`. So in the page's module server, call
`cd_scope_server("scope", ...)` with the same scope.

## Examples

``` r
if (FALSE) { # \dontrun{
scope <- cd_scope("level_region")

my_page_ui <- function(id, i18n) {
  ns <- NS(id)
  cd_page_ui(id, i18n, filters = cd_scope_filters(ns, i18n, scope), my_cards(ns))
}
} # }
```
