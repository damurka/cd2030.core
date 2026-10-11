# Calculate coverage/dropout threshold attainment

Evaluates administrative regions to determine the percentage that meet
specific coverage targets or fall below specific dropout thresholds for
a given year.

## Usage

``` r
calculate_threshold(
  .data,
  denominator = c("dhis2", "anc1", "penta1", "penta1derived", "anc1derived"),
  indicator = c("anc4", "instlivebirths", "vaccine", "dropout")
)
```

## Arguments

- .data:

  A tibble of class `cd_indicator_coverage`.

- denominator:

  Character. The denominator used (e.g., `'dhis2'`, `'anc1'`).

- indicator:

  Character. The health indicator group to evaluate (`'anc4'`,
  `'instlivebirths'`, `'vaccine'`, `'dropout'`).

## Value

A `cd_threshold` object summarizing the percentage of regions meeting
the criteria by year.

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

# the percentage of regions that reach the target for institutional live births, by year
calculate_threshold(coverage, denominator = "dhis2", indicator = "instlivebirths")
#> # A tibble: 5 × 2
#>    year cov_instlivebirths_dhis2
#>   <int>                    <dbl>
#> 1  2019                     25  
#> 2  2020                     37.5
#> 3  2021                     37.5
#> 4  2022                     37.5
#> 5  2023                    100  

# for the three tracer vaccines, with the penta1 denominator
calculate_threshold(coverage, denominator = "penta1", indicator = "vaccine")
#> # A tibble: 5 × 4
#>    year cov_bcg_penta1 cov_penta3_penta1 cov_measles1_penta1
#>   <int>          <dbl>             <dbl>               <dbl>
#> 1  2019            100               100                 100
#> 2  2020            100               100                 100
#> 3  2021            100               100                 100
#> 4  2022            100               100                 100
#> 5  2023              0               100                 100
```
