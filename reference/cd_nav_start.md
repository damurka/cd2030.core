# The standard sidebar sections of a Countdown app

The parts of the sidebar every Countdown app shares. An app builds its
nav tree from them, adds its own groups, and passes the list to
[`cd_app()`](cd_app.md) as `nav_sections`. Each link opens the screen
whose id is the link's tab name (the names are listed below), so the app
must have a page with that id.

## Usage

``` r
cd_nav_start()

cd_nav_quality()

cd_nav_denominators()

cd_nav_national(extra = list())

cd_nav_subnational()
```

## Arguments

- extra:

  A list of more nav items (`cd_nav_item()`) for the National Analysis
  group, placed after the coverage target link and before the inequality
  group. The RMNCAH app adds its Continuum of Care page this way.
  Default [`list()`](https://rdrr.io/r/base/list.html), none.

## Value

`cd_nav_start()`, `cd_nav_quality()` and `cd_nav_denominators()` each
return a nav section, as `cd_nav_section()` makes one: a list with the
section's `label` and its `items`.

`cd_nav_national()` and `cd_nav_subnational()` each return a nav item,
as `cd_nav_item()` makes one: a group whose `children` are the links.

## Details

- `cd_nav_start()`: the "start" section, with the Introduction
  (`introduction`) and Load Data (`upload_data`) screens.

- `cd_nav_quality()`: the data quality section. One group holds
  `reporting_rate`, `outlier_detection`, `data_completeness`,
  `internal_consistency` and `overall_score`. A second group holds
  `data_adjustment` and `data_adjustment_changes`.

- `cd_nav_denominators()`: the denominators section, with
  `denominator_assessment` and `denominator_selection`.

- `cd_nav_national()`: the National Analysis group, with
  `national_coverage`, `national_target`, the items in `extra`, and a
  group for inequality holding `national_inequality` and
  `equity_assessment`.

- `cd_nav_subnational()`: the Sub-National Analysis group, with
  `subnational_coverage`, `subnational_inequality` and
  `subnational_target`.

The first three are whole sections. The last two are groups of links:
put them inside a section of the app's own, made with
`cd_nav_section()`.

Everything from the denominators down is marked
`requires_adjustment = TRUE`: those links stay locked until the data is
adjusted.

The labels are translated with the translator the app registered with
`cd_use_i18n()`, so call these after it.

## Examples

``` r
if (FALSE) { # \dontrun{
nav <- list(
  cd_nav_start(),
  cd_nav_quality(),
  cd_nav_denominators(),
  cd_nav_section("lbl_nav_section_analysis", cd_nav_national(), cd_nav_subnational())
)
} # }
```
