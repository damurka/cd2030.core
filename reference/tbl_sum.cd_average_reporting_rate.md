# Summary for average reporting rates by year

Provides a custom summary for the `cd_average_reporting_rate` object,
indicating that the data represents annual average reporting rates
across all indicators. This summary is useful for quickly verifying the
consistency of indicator reporting rates.

## Usage

``` r
# S3 method for class 'cd_average_reporting_rate'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_average_reporting_rate` object containing reporting rate data by
  year.

- ...:

  Additional arguments for compatibility with the S3 method.

## Value

A character vector describing the content and purpose of the
`cd_average_reporting_rate` data.

## Examples

``` r
data <- load_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

# the summary is the header printed above the table
calculate_average_reporting_rate(data)
#> # Table 1a: Annual average reporting rates for all indicators, by year
#> # A tibble: 5 × 6
#>    year anc_rr idelv_rr vacc_rr opd_rr mean_rr
#>   <int>  <dbl>    <dbl>   <dbl>  <dbl>   <dbl>
#> 1  2019     94       94      94     95      94
#> 2  2020     96       96      95     96      96
#> 3  2021     96       96      96     96      96
#> 4  2022     97       97      97     96      97
#> 5  2023     97       97      98     97      97
```
