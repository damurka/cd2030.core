# List All Vaccine and Related Coverage Indicators

Returns a vector of standard vaccine and related indicators used in
coverage and dropout analysis. This includes routine immunizations,
tracer indicators, and derived dropout/coverage metrics commonly used in
DHIS2-based health reporting.

## Usage

``` r
list_vaccine_indicators()
```

## Value

A character vector of vaccine indicator names

## Examples

``` r
list_vaccine_indicators()
#> [1] "penta1"   "penta3"   "measles1" "measles2" "bcg"     
```
