# Get All Indicators

Flatten all indicators from all groups

## Usage

``` r
get_all_indicators()
```

## Value

Character vector of all indicators

## Examples

``` r
get_all_indicators()
#>  [1] "anc1"             "anc4"             "anc_1trimester"   "bcg"             
#>  [5] "csection"         "hiv_test"         "ideliv"           "ifa90"           
#>  [9] "instlivebirths"   "ipd_total"        "ipd_under5"       "ipt2"            
#> [13] "ipt3"             "low_bweight"      "maternal_deaths"  "measles1"        
#> [17] "measles2"         "neonatal_deaths"  "opd_total"        "opd_under5"      
#> [21] "penta1"           "penta3"           "pnc48h"           "sba"             
#> [25] "stillbirth_f"     "stillbirth_m"     "syphilis_test"    "total_stillbirth"

# the indicators of another group (the selected group is put back afterwards)
old <- get_selected_group()
set_selected_group("vaccine")
get_all_indicators()
#>  [1] "anc1"           "bcg"            "ideliv"         "instlivebirths"
#>  [5] "ipv1"           "ipv2"           "measles1"       "measles2"      
#>  [9] "opv1"           "opv2"           "opv3"           "pcv1"          
#> [13] "pcv2"           "pcv3"           "penta1"         "penta2"        
#> [17] "penta3"         "rota1"          "rota2"         
set_selected_group(old)
```
