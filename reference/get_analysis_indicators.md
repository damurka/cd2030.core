# Get Indicators excluding indicators without denominator

Flatten all indicators from all groups

## Usage

``` r
get_analysis_indicators()
```

## Value

Character vector of all indicators

## Examples

``` r
get_analysis_indicators()
#>  [1] "anc1"           "anc4"           "anc_1trimester" "bcg"           
#>  [5] "csection"       "hiv_test"       "ideliv"         "ifa90"         
#>  [9] "instlivebirths" "ipt2"           "ipt3"           "low_bweight"   
#> [13] "measles1"       "measles2"       "penta1"         "penta3"        
#> [17] "pnc48h"         "syphilis_test" 

# what the selected group has and the analysis leaves out
setdiff(get_all_indicators(), get_analysis_indicators())
#>  [1] "ipd_total"        "ipd_under5"       "maternal_deaths"  "neonatal_deaths" 
#>  [5] "opd_total"        "opd_under5"       "sba"              "stillbirth_f"    
#>  [9] "stillbirth_m"     "total_stillbirth"
```
