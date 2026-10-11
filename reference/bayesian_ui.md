# Bayesian coverage model page

The Bayesian coverage model page, shared by the apps and used at
national level and at admin level 1. It has one card of charts with a
tab for each indicator the app lists (`cd_cfg("bayes_indicators")`, by
default [cd_bayes_indicators](cd_bayes_indicators.md)), the only ones
the model takes; each tab plots the model's coverage estimates by year.
A model takes minutes to fit, so the fit runs in a background worker
([`cd_bayes_fit_task()`](cd_bayes_fit_task.md)) and the chart shows its
loader meanwhile. A fit starts only when its tab is shown, from the
dataset's `bayes_model_inputs()`; the result is kept in the dataset
(`keep_bayes_model()`) and read back with `bayes_model_cached()`, so it
is fitted once for an admin level, indicator and denominator. While the
model's packages are missing
([`cd_bayes_packages_missing()`](cd_bayes_packages_missing.md)) the page
shows a notice and fits nothing: inside DataSuite the notice has a
button that asks it to install them, elsewhere it shows the R command to
run.

## Usage

``` r
bayesian_ui(id, i18n, label)

bayesian_server(id, cache, i18n, admin_level, active = reactive(TRUE))
```

## Arguments

- id:

  The module's id. A page's id is also its entry in the app's page
  registry.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- label:

  Not used.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- admin_level:

  A string, not a reactive: the level the models are fitted at,
  `"national"` or `"adminlevel_1"` (admin level 1).

- active:

  A reactive that is `TRUE` once the page has been opened with data
  loaded. The page does no work before that.

## Value

`bayesian_ui()` returns the page's UI as Shiny tags. `bayesian_server()`
returns a reactive that holds the key of the tab shown: an indicator's
name, or `"custom"`.

## Details

The page has no filters of its own. Apps register it with
[`bayesian_page_server()`](bayesian_page_server.md), which also starts
the workers.

## Examples

``` r
if (FALSE) { # \dontrun{
# a page of your own with the same charts: start the workers, then call the server.
# The id must be a page in the app's page registry.
my_bayes_ui <- function(id, i18n) bayesian_ui(id, i18n)
my_bayes_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  cd_start_bayes_workers()
  bayesian_server(id, cache, i18n, "adminlevel_1", active = active)
}
} # }
```
