# Filter high-performing areas by coverage

Filters a dataset to retain administrative areas with coverage values
above a specified threshold for a given indicator and denominator.

## Usage

``` r
filter_high_performers(
  .data,
  indicator,
  denominator = c("dhis2", "anc1", "penta1", "penta1derived", "anc1derived"),
  threshold = 90
)
```

## Arguments

- .data:

  An object of class `cd_indicator_coverage`.

- indicator:

  A string specifying the indicator.

- denominator:

  A string. The denominator used in coverage calculation.

- threshold:

  Numeric. Minimum coverage (in percent, compared after rounding) an
  area must reach to be kept. Default is `90`.

## Value

A filtered data frame retaining regions meeting the threshold.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cache$set_national_estimates(list(sbr = 0.02))
cache$adjust_data()
coverage <- cache$indicator_coverage_admin1

filter_high_performers(coverage, indicator = "instlivebirths", denominator = "dhis2")
#> # Table:    National Coverage Estimates
#> # A tibble: 9 × 3
#>   adminlevel_1   year cov_instlivebirths_dhis2
#>   <chr>         <int>                    <dbl>
#> 1 Central        2020                       92
#> 2 Central        2023                      100
#> 3 Coast          2023                      100
#> 4 Eastern        2023                      100
#> 5 Nairobi        2023                      100
#> 6 North Eastern  2023                      100
#> 7 Nyanza         2023                      100
#> 8 Rift Valley    2023                      101
#> 9 Western        2023                      100
filter_high_performers(coverage, indicator = "instlivebirths", denominator = "dhis2", threshold = 100)
#> # Table:    National Coverage Estimates
#> # A tibble: 8 × 3
#>   adminlevel_1   year cov_instlivebirths_dhis2
#>   <chr>         <int>                    <dbl>
#> 1 Central        2023                      100
#> 2 Coast          2023                      100
#> 3 Eastern        2023                      100
#> 4 Nairobi        2023                      100
#> 5 North Eastern  2023                      100
#> 6 Nyanza         2023                      100
#> 7 Rift Valley    2023                      101
#> 8 Western        2023                      100
```
