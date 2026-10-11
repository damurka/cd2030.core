# Summary for `cd_adjustment_values` Objects

Provides a custom summary for objects of class `cd_adjustment_values`,
typically displaying unadjusted and adjusted values in a structured
format.

## Usage

``` r
# S3 method for class 'cd_adjustment_values'
tbl_sum(x, ...)
```

## Arguments

- x:

  An object of class `cd_adjustment_values`, usually created by
  `generate_adjustment_values`, containing unadjusted and adjusted
  service counts.

- ...:

  Additional arguments passed to or from other methods.

## Value

A character vector with a custom table summary for
`cd_adjustment_values` objects.

## Details

This function overrides the default `tbl_sum` method for objects of
class `cd_adjustment_values`. It returns a named character vector
summarizing the table as "Unadjusted and adjusted values" along with any
additional details provided by the
[`NextMethod()`](https://rdrr.io/r/base/UseMethod.html) function.

## See also

[`generate_adjustment_values()`](generate_adjustment_values.md) for
generating the `cd_adjustment_values` object.

## Examples

``` r
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cache$adjust_data()

# the summary is the header printed above the table
cache$adjustment_values
#> # Table 1:  Unadjusted and adjusted values
#> # A tibble: 5 × 113
#>    year anc1_raw anc4_raw anc_1trimester_raw bcg_raw csection_raw hiv_test_raw
#>   <int>    <dbl>    <dbl>              <dbl>   <dbl>        <dbl>        <dbl>
#> 1  2019 1429512    873205                  0 1351021       171856            0
#> 2  2020 1465266    807453                  0 1336635       189120            1
#> 3  2021 1547683.   827824                  0 1408821       201493            0
#> 4  2022 1479978.   858918                  0 1380543       211314            0
#> 5  2023 1500341    918817                  0 1345486       219181            0
#> # ℹ 106 more variables: ideliv_raw <dbl>, ifa90_raw <dbl>,
#> #   instlivebirths_raw <dbl>, ipd_total_raw <dbl>, ipd_under5_raw <dbl>,
#> #   ipt2_raw <dbl>, ipt3_raw <dbl>, low_bweight_raw <dbl>,
#> #   maternal_deaths_raw <dbl>, measles1_raw <dbl>, measles2_raw <dbl>,
#> #   neonatal_deaths_raw <dbl>, opd_total_raw <dbl>, opd_under5_raw <dbl>,
#> #   penta1_raw <dbl>, penta3_raw <dbl>, pnc48h_raw <dbl>, sba_raw <dbl>,
#> #   stillbirth_f_raw <dbl>, stillbirth_m_raw <dbl>, syphilis_test_raw <dbl>, …
```
