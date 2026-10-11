# Bayesian page server for the page registry

The server an app lists for its Bayesian pages in its page registry. It
calls [`bayesian_server()`](bayesian_ui.md) with an `active` that also
starts the background workers
([`cd_start_bayes_workers()`](cd_start_bayes_workers.md)) each time it
is read as `TRUE`, which happens first when the page is opened with data
loaded. Starting them a second time does nothing, so the workers are
started once and only for sessions that open the page.

## Usage

``` r
bayesian_page_server(id, cache, i18n, admin_level, active = reactive(TRUE))
```

## Arguments

- id:

  The module's id. A page's id is also its entry in the app's page
  registry.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- admin_level:

  A string, not a reactive: the level the models are fitted at,
  `"national"` or `"adminlevel_1"` (admin level 1). The registry gives
  it through the page's `server_args`.

- active:

  A reactive that is `TRUE` once the page has been opened with data
  loaded. The page does no work before that.

## Value

What [`bayesian_server()`](bayesian_ui.md) returns: a reactive that
holds the key of the tab shown (an indicator's name, or `"custom"`).

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry; server_args gives the admin level
cd_page_def(
  id = "bayesian_national",
  ui = bayesian_ui,
  server = bayesian_page_server,
  title = "title_bayesian_analysis",
  section = "title_bayesian_analysis",
  subtitle = "sub_bayesian",
  server_args = list("national")
)

# the same page at admin level 1 is a second entry: id = "bayesian_subnational" and
# server_args = list("adminlevel_1")
} # }
```
