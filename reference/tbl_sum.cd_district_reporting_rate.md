# Summary for district-level reporting rates by year

Provides a custom summary for the `cd_district_reporting_rate` object,
displaying a message with the threshold used in calculating
district-level reporting rates by year. This summary serves to validate
which districts meet the defined threshold for reporting completeness.

## Usage

``` r
# S3 method for class 'cd_district_reporting_rate'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_district_reporting_rate` object containing district-level
  reporting rates.

- ...:

  Additional arguments for compatibility with the S3 method.

## Value

A character vector describing the reporting threshold applied and
summarizing district reporting rates by year.

## Examples

``` r
data <- load_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

# the summary is the header printed above the table, with the threshold used
calculate_district_reporting_rate(data, threshold = 90)
#> # Table 1b: District reporting rates meeting threshold >= 90 by year
#> # A tibble: 5 × 6
#>    year low_anc_rr low_idelv_rr low_vacc_rr low_opd_rr low_mean_rr
#>   <int>      <dbl>        <dbl>       <dbl>      <dbl>       <dbl>
#> 1  2019         79           79          83         79          80
#> 2  2020         91           91          91         85          90
#> 3  2021        100          100          94         96          97
#> 4  2022         94           94          94         89          93
#> 5  2023         98           98          98         91          96
```
