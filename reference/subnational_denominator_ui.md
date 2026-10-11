# Sub-national coverage by denominator card

A card of the Denominator selection page
([`denominator_selection_ui()`](denominator_selection_ui.md)) with one
tab per indicator (the app's `sub_derived_indicators` setting). Each tab
has a chart of the indicator's coverage in each admin level 1 area, for
each denominator the app offers. The card has no filters. It calls the
dataset's
[`calculate_derived_coverage()`](calculate_derived_coverage.md) for
admin level 1 and reads its `survey_year`, which the chart's title
names.

## Usage

``` r
subnational_denominator_ui(id, i18n)

subnational_denominator_server(id, cache, i18n, active = reactive(TRUE))
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

- active:

  A reactive that is `TRUE` once the page has been opened with data
  loaded. The card does no work before that.

## Value

`subnational_denominator_ui()` returns the card's UI as Shiny tags.
`subnational_denominator_server()` is called for its side effects.
