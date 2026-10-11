# The denominators this app offers

The choices the denominator chip shows in the running app. Use it
wherever a page must list or check the app's denominators, so that a
page shared between apps never shows one the app does not have.

## Usage

``` r
cd_denominator_options()
```

## Value

A named character vector: the values are the denominator ids and the
names are the translation keys of their labels.

## Details

Reads `options(cd2030.denominator_choices = )`. An app whose indicator
group has fewer denominators sets that option to its own named vector
(the vaccine app leaves out `"anc1derived"`). When the option is not
set, the result is [cd_denominator_choices](cd_denominator_choices.md).

## Examples

``` r
cd_denominator_options()
#>     lbl_denom_dhis2_proj   lbl_denom_anc1_derived lbl_denom_penta1_derived 
#>                  "dhis2"                   "anc1"                 "penta1" 
#>  lbl_denom_penta1_growth    lbl_denom_anc1_growth 
#>          "penta1derived"            "anc1derived" 

old <- options(cd2030.denominator_choices = c("lbl_denom_dhis2_proj" = "dhis2"))
cd_denominator_options()
#> lbl_denom_dhis2_proj 
#>              "dhis2" 
options(old)
```
