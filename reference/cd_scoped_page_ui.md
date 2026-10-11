# A whole page that runs an analysis at a scope

Builds a page from an analysis module and a scope: the page's header and
body, the scope's filter bar, and the analysis module inside. Pages that
run the same analysis at a different geography then differ only in the
scope they pass (see [`cd_scope()`](cd_scope.md)), and the filter bar
and its wiring are written once.

## Usage

``` r
cd_scoped_page_ui(id, i18n, scope, inner_ui, ...)

cd_scoped_page_server(
  id,
  cache,
  i18n,
  scope,
  inner_server,
  active = reactive(TRUE)
)
```

## Arguments

- id:

  The module's id, which is also the page's id in the app's page
  registry.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- scope:

  The page's scope, from [`cd_scope()`](cd_scope.md). Give the ui and
  the server the same one.

- inner_ui:

  The analysis module's ui function, called as
  `inner_ui(id, i18n, ...)`.

- ...:

  More arguments for `inner_ui`.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- inner_server:

  The analysis module's server function, called as
  `inner_server(id, cache, i18n, admin_level, region, active = active)`.

- active:

  A reactive that is `TRUE` once the page has been opened with data
  loaded. It is passed to `inner_server`, which is expected to do no
  work before that. Default `reactive(TRUE)`.

## Value

`cd_scoped_page_ui()` returns the page's UI as Shiny tags.

`cd_scoped_page_server()` returns what `inner_server` returns.

## Details

The analysis module is the app's own pair of functions:

- `inner_ui(id, i18n, ...)` returns the page's cards.

- `inner_server(id, cache, i18n, admin_level, region, active = )` takes
  the admin level and the region as two reactives (see
  [`cd_scope_server()`](cd_scope_server.md) for what they hold).

Both are called with the id `"body"` inside the page's namespace. The
page's title, section and subtitle come from the app's page registry, so
`id` must be the id of a registered page.

## Examples

``` r
if (FALSE) { # \dontrun{
scope <- cd_scope("region", fixed_level = "district")

subnational_target_ui <- function(id, i18n) {
  cd_scoped_page_ui(id, i18n, scope, target_ui)
}
subnational_target_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  cd_scoped_page_server(id, cache, i18n, scope, target_server, active)
}
} # }
```
