# Indicators the Bayesian coverage model can be fitted for

The indicators the Bayesian coverage model has a survey series for. They
are the default tabs of the Bayesian page
([`bayesian_ui()`](bayesian_ui.md)). An app shows only the ones its data
has by setting `bayes_indicators` in `options(cd2030.config = )`, which
the page reads with `cd_cfg("bayes_indicators")` (the vaccine app:
penta3 and measles1).

## Usage

``` r
cd_bayes_indicators
```

## Format

A character vector of five indicator names: `"anc4"`,
`"anc_1trimester"`, `"ideliv"`, `"measles1"` and `"penta3"`.

## Examples

``` r
cd_bayes_indicators
#> [1] "anc4"           "anc_1trimester" "ideliv"         "measles1"      
#> [5] "penta3"        

# the tabs an app shows: its own setting, or these
cd_cfg("bayes_indicators", cd_bayes_indicators)
#> [1] "anc4"           "anc_1trimester" "ideliv"         "measles1"      
#> [5] "penta3"        
```
