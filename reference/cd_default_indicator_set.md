# The indicators this app's tabbed chart cards show

The indicators a tabbed chart card
([`cd_tabbed_charts_ui()`](cd_tabbed_charts_ui.md)) gives a tab each
when the page names none.

## Usage

``` r
cd_default_indicator_set()
```

## Value

A character vector of indicator codes.

## Details

Reads `options(cd2030.default_indicators = )`. An app sets it to a
character vector of indicator codes, or to a function with no arguments
that returns one. A function is called each time, so its answer can
follow something that is only known later, such as the indicator group.
When the option is not set, the result is
[cd_default_indicators](cd_default_indicators.md).

## Examples

``` r
cd_default_indicator_set()
#> [1] "anc4"           "instlivebirths" "low_bweight"    "penta3"        
#> [5] "measles1"      

old <- options(cd2030.default_indicators = function() c("penta3", "measles1"))
cd_default_indicator_set()
#> [1] "penta3"   "measles1"
options(old)
```
