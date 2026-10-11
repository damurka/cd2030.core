# List tracer vaccines

Returns a subset of vaccines used in tracer metrics

## Usage

``` r
list_tracer_vaccines()
```

## Value

A character vector of tracer vaccines

## Examples

``` r
list_tracer_vaccines()
#> [1] "bcg"      "measles1" "opv1"     "opv2"     "opv3"     "penta1"   "penta2"  
#> [8] "penta3"  

# those the selected indicator group has
intersect(list_tracer_vaccines(), get_all_indicators())
#> [1] "bcg"      "measles1" "penta1"   "penta3"  
```
