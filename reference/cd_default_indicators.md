# The standard indicators of a tabbed chart card

The indicators a tabbed chart card
([`cd_tabbed_charts_ui()`](cd_tabbed_charts_ui.md)) gives a tab each
when the page names none and the app has not set its own. This is the
RMNCAH app's set. Read the indicators in use with
[`cd_default_indicator_set()`](cd_default_indicator_set.md), which also
takes the app's option into account.

## Usage

``` r
cd_default_indicators
```

## Format

A character vector of five indicator codes: `"anc4"`,
`"instlivebirths"`, `"low_bweight"`, `"penta3"` and `"measles1"`.

## Examples

``` r
cd_default_indicators
#> [1] "anc4"           "instlivebirths" "low_bweight"    "penta3"        
#> [5] "measles1"      
```
