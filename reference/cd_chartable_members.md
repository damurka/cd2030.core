# The CacheConnection members a custom chart may draw from

Members that return a table: the precomputed results (active bindings
such as `reporting_rate_district`) and the methods that compute one
([`calculate_coverage()`](calculate_coverage.md),
`get_filtered_coverage()`, `decompose_change()`...). Raw data
(`countdown_data`, `adjusted_data`) and settings are left out.

## Usage

``` r
cd_chartable_members()
```

## Value

A character vector of member names.

## Examples

``` r
head(cd_chartable_members())
#> [1] "calculate_indicator_coverage"      "calculate_coverage"               
#> [3] "calculate_inequality"              "calculate_derived_coverage"       
#> [5] "calculate_reporting_rate"          "calculate_district_reporting_rate"
```
