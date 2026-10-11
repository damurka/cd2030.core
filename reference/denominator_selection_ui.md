# Denominator selection page

The page where the person compares the candidate denominators and
chooses the ones the analysis uses. It has three cards: coverage from
each denominator beside the survey estimate
([`survey_comparison_ui()`](survey_comparison_ui.md)), coverage by admin
level 1 area
([`subnational_denominator_ui()`](subnational_denominator_ui.md)) and
coverage over the years
([`coverage_trends_ui()`](coverage_trends_ui.md)). The filters are the
denominator for the vaccination indicators, the denominator for the
maternal indicators (only in an app that has them, see
[`cd_has_maternal()`](cd_has_maternal.md)) and the admin level, which
includes national, with its region. The denominator filters are also
where the choice is made
([`cd_denominator_ui()`](cd_denominator_ui.md)): they show the dataset's
`denominator` and `maternal_denominator`, and a change is saved there.

## Usage

``` r
denominator_selection_ui(id, i18n)

denominator_selection_server(id, cache, i18n, active = reactive(TRUE))
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
  loaded. The page's three cards do no work before that.

## Value

`denominator_selection_ui()` returns the page's UI as Shiny tags.
`denominator_selection_server()` is called for its side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
# the page's entry in an app's page registry
cd_page_def(
  id = "denominator_selection",
  ui = denominator_selection_ui,
  server = denominator_selection_server,
  title = "title_denom_selection",
  section = "lbl_nav_section_denominators",
  subtitle = "sub_denom_selection"
)
} # }
```
