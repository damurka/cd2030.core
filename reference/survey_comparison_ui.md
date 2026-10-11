# Coverage against the survey card

A card of the Denominator selection page
([`denominator_selection_ui()`](denominator_selection_ui.md)) with one
tab per indicator (the app's `survey_comp_indicators` setting). Each tab
has a chart that sets the coverage worked out from the facility data
with each denominator beside the survey's estimate. When the data has no
survey coverage for the indicator, the tab shows a message with a button
that opens the Load Data screen instead of the chart. The card has no
filters of its own: the page passes it the admin level and the region.
It calls the dataset's
[`calculate_derived_coverage()`](calculate_derived_coverage.md), reads
its `survey_year`, and draws nothing until its `check_inequality_params`
is `TRUE`.

## Usage

``` r
survey_comparison_ui(id, i18n)

survey_comparison_server(
  id,
  cache,
  admin_level,
  region,
  i18n,
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

  A reactive that returns the admin level the coverage is worked out
  for: `"national"`, `"adminlevel_1"` or `"district"`.

- region:

  A reactive that returns the name of the chosen region, or `NULL` when
  none is chosen.

- active:

  A reactive that is `TRUE` once the page has been opened with data
  loaded. The card does no work before that.

## Value

`survey_comparison_ui()` returns the card's UI as Shiny tags.
`survey_comparison_server()` is called for its side effects.
