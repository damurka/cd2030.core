# Summary for `cd_district_outliers_summary`

Provides a summary for the `cd_district_outliers_summary` object,
indicating the percentage of districts without extreme outliers for each
indicator by year. This summary supports monitoring data quality across
districts by showing the proportion of non-extreme values across all
indicators.

## Usage

``` r
# S3 method for class 'cd_district_outliers_summary'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_district_outliers_summary` object containing the percentage of
  districts without extreme outliers for each indicator and year.

- ...:

  Additional arguments for compatibility with S3 methods.

## Value

A character vector describing the purpose and content of the data,
highlighting the percentage of districts with no extreme outliers for
each indicator annually.

## Examples

``` r
data <- load_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

# the summary is the header printed above the table
calculate_district_outlier_summary(data)
#> # Table 2b: Percentage of districts with no extreme outliers, by year
#> # A tibble: 5 × 28
#>    year anc1_outlier5std anc4_outlier5std anc_1trimester_outli…¹ bcg_outlier5std
#>   <int>            <dbl>            <dbl>                  <dbl>           <dbl>
#> 1  2019             97.9            100                      100            93.6
#> 2  2020             76.6             87.2                    100           100  
#> 3  2021             87.2             87.2                    100            97.9
#> 4  2022             97.9            100                      100            97.9
#> 5  2023            100               93.6                    100            25.5
#> # ℹ abbreviated name: ¹​anc_1trimester_outlier5std
#> # ℹ 23 more variables: csection_outlier5std <dbl>, hiv_test_outlier5std <dbl>,
#> #   ideliv_outlier5std <dbl>, ifa90_outlier5std <dbl>,
#> #   instlivebirths_outlier5std <dbl>, ipt2_outlier5std <dbl>,
#> #   ipt3_outlier5std <dbl>, low_bweight_outlier5std <dbl>,
#> #   maternal_deaths_outlier5std <dbl>, measles1_outlier5std <dbl>,
#> #   measles2_outlier5std <dbl>, neonatal_deaths_outlier5std <dbl>, …
```
