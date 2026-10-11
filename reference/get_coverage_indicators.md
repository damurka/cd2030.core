# Get Indicators for coverage calculation

Flatten all indicators from all groups

## Usage

``` r
get_coverage_indicators()
```

## Value

Character vector of all indicators

## Examples

``` r
get_coverage_indicators()
#>  [1] "anc1"           "anc4"           "anc_1trimester" "bcg"           
#>  [5] "csection"       "hiv_test"       "ideliv"         "ifa90"         
#>  [9] "instlivebirths" "ipt2"           "ipt3"           "low_bweight"   
#> [13] "measles1"       "measles2"       "penta1"         "penta3"        
#> [17] "pnc48h"         "syphilis_test" 

# the vaccine group calculates coverage for every indicator it has
old <- get_selected_group()
set_selected_group("vaccine")
setequal(get_coverage_indicators(), get_all_indicators())
#> [1] TRUE
set_selected_group(old)
```
