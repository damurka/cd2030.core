# Denominator assessment page

The page that compares the population figures in the health data (DHIS2)
with the United Nations estimates over the years. One card has three
tabs, each with a chart: total population, births (the DHIS2 live births
and total births) and children under one. The one filter is the
population chip ([`cd_population_ui()`](cd_population_ui.md)), which
shows the dataset's `derivation_population` and saves a change to it
there. The charts read `denominator_metrics` from the dataset.

## Usage

``` r
denominator_assessment_ui(id, i18n)

denominator_assessment_server(id, cache, i18n, active = reactive(TRUE))
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

`denominator_assessment_ui()` returns the page's UI as Shiny tags.
`denominator_assessment_server()` is called for its side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "denominator_assessment",
  ui = denominator_assessment_ui,
  server = denominator_assessment_server,
  title = "title_denom_assessment",
  section = "lbl_nav_section_denominators",
  subtitle = "sub_denom_assessment"
)
} # }
```
