# Get Named Indicator Vector

Each indicator is named by its group

## Usage

``` r
get_named_indicators()
```

## Value

Named character vector of indicators

## Examples

``` r
indicators <- get_named_indicators()
head(indicators)
#>              anc              anc              anc              anc 
#>           "anc1" "anc_1trimester"           "anc4"           "ipt2" 
#>              anc              anc 
#>           "ipt3"  "syphilis_test" 

# the indicators of one category
unname(indicators[names(indicators) == "vacc"])
#> [1] "penta1"   "penta3"   "measles1" "measles2" "bcg"     
```
