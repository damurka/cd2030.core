# Summary for `cd_outlier`

Provides a custom summary for the `cd_outlier` object, displaying the
percentage of monthly indicator values not considered extreme outliers,
aggregated by year. This summary is essential for assessing data quality
and trends across indicators.

## Usage

``` r
# S3 method for class 'cd_outlier'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_outlier` object containing aggregated data quality metrics for
  monthly values.

- ...:

  Additional arguments for compatibility with S3 methods.

## Value

A character vector summarizing the content and purpose of the data,
indicating the proportion of values meeting the criteria for
non-outliers by year.

## Examples

``` r
data <- load_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

# the summary is the header printed above the table
calculate_outliers_summary(data, admin_level = "national")
#> # Table 2a: Percentage of monthly values that are not extreme outliers, by year
#> # A tibble: 5 × 28
#>    year anc1_outlier5std anc4_outlier5std anc_1trimester_outli…¹ bcg_outlier5std
#>   <int>            <dbl>            <dbl>                  <dbl>           <dbl>
#> 1  2019              100              100                    100             100
#> 2  2020               92               92                    100             100
#> 3  2021              100               92                    100             100
#> 4  2022              100              100                    100             100
#> 5  2023              100              100                    100             100
#> # ℹ abbreviated name: ¹​anc_1trimester_outlier5std
#> # ℹ 23 more variables: csection_outlier5std <dbl>, hiv_test_outlier5std <dbl>,
#> #   ideliv_outlier5std <dbl>, ifa90_outlier5std <dbl>,
#> #   instlivebirths_outlier5std <dbl>, ipt2_outlier5std <dbl>,
#> #   ipt3_outlier5std <dbl>, low_bweight_outlier5std <dbl>,
#> #   maternal_deaths_outlier5std <dbl>, measles1_outlier5std <dbl>,
#> #   measles2_outlier5std <dbl>, neonatal_deaths_outlier5std <dbl>, …
```
