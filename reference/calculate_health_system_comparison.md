# Compare health system metrics across levels

Returns a merged dataset of health coverage and system metrics at
district and admin level 1 for the latest year.

## Usage

``` r
calculate_health_system_comparison(
  .data,
  admin1_coverage_data,
  admin2_coverage_data
)
```

## Arguments

- .data:

  A `cd_data` object containing raw health system inputs including year,
  population, and facility indicators.

- admin1_coverage_data:

  A coverage data frame at admin level 1 (with `year`, `adminlevel_1`
  and `cov_*` columns), such as the output of
  [`calculate_indicator_coverage()`](calculate_indicator_coverage.md)
  for `admin_level = "adminlevel_1"`. Its latest year defines the year
  kept in the result.

- admin2_coverage_data:

  A coverage data frame at district level (with `year`, `adminlevel_1`,
  `district` and `cov_*` columns), such as the output of
  [`calculate_indicator_coverage()`](calculate_indicator_coverage.md)
  for `admin_level = "district"`.

## Value

A data frame with admin level 1 and district metrics joined side by side
for comparison.

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

comparison <- calculate_health_system_comparison(
  cache$adjusted_data,
  admin1_coverage_data = cache$indicator_coverage_admin1,
  admin2_coverage_data = cache$indicator_coverage_district
)
comparison[c("adminlevel_1", "district", "ad1_ratio_fac_pop", "dis_ratio_fac_pop")]
#> # A tibble: 47 × 4
#>    adminlevel_1 district      ad1_ratio_fac_pop dis_ratio_fac_pop
#>    <chr>        <chr>                     <dbl>             <dbl>
#>  1 Central      Kiambu                     2.16              1.56
#>  2 Central      Kirinyaga                  2.16              2.86
#>  3 Central      Laikipia                   2.16              1.91
#>  4 Central      Muranga                    2.16              1.96
#>  5 Central      Nyandarua                  2.16              2.03
#>  6 Central      Nyeri                      2.16              3.51
#>  7 Central      Tharaka Nithi              2.16              3.22
#>  8 Coast        Kilifi                     1.60              1.29
#>  9 Coast        Kwale                      1.60              1.21
#> 10 Coast        Lamu                       1.60              2.81
#> # ℹ 37 more rows
```
