# Get the current indicator group definition

Returns the **merged** definition for a group (built-in overlaid with
any override). If `group` is omitted, uses
[`get_selected_group()`](https://aphrcwaro.github.io/cd2030.core/reference/get_selected_group.md).

## Usage

``` r
get_indicator_groups(group = get_selected_group())
```

## Arguments

- group:

  Group name. Defaults to the globally selected group.

## Value

A named list of categories -\> character vector of indicators.

## Examples

``` r
get_indicator_groups("rmncah")
#> $anc
#> [1] "anc1"           "anc_1trimester" "anc4"           "ipt2"          
#> [5] "ipt3"           "syphilis_test"  "ifa90"          "hiv_test"      
#> 
#> $idelv
#>  [1] "sba"              "instdeliveries"   "instlivebirths"   "csection"        
#>  [5] "low_bweight"      "pnc48h"           "total_stillbirth" "stillbirth_f"    
#>  [9] "stillbirth_m"     "maternal_deaths"  "neonatal_deaths" 
#> 
#> $vacc
#> [1] "penta1"   "penta3"   "measles1" "measles2" "bcg"     
#> 
#> $opd
#> [1] "opd_total"  "opd_under5"
#> 
#> $ipd
#> [1] "ipd_total"  "ipd_under5"
#> 
```
