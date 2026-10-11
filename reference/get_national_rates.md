# Get the rates the denominators use from survey data

Takes the most recent survey value of ANC1 coverage, Penta1 coverage and
the stillbirth, neonatal and post-neonatal mortality rates, and converts
each to a proportion. A rate the survey data does not have is filled
with the value given in the matching argument. The result has the rates
that [`calculate_indicator_coverage()`](calculate_indicator_coverage.md)
takes as arguments.

## Usage

``` r
get_national_rates(
  .data,
  admin_level = c("national", "adminlevel_1", "district"),
  anc1survey = .cd_method$denominators$anc1survey,
  dpt1survey = .cd_method$denominators$dpt1survey,
  sbr = .cd_method$denominators$sbr,
  nmr = .cd_method$denominators$nmr,
  pnmr = .cd_method$denominators$pnmr,
  twin = .cd_method$denominators$twin,
  preg_loss = .cd_method$denominators$preg_loss,
  subnational_map = NULL
)
```

## Arguments

- .data:

  A `cd_survey_data` object with `year` and `r_*` columns (`r_anc1` and
  `r_penta1` in percent, and optionally `r_sbr`, `r_nmr` and `r_pnmr`
  per 1,000). National survey data for `admin_level = "national"`,
  regional survey data (with an `adminlevel_1` column) otherwise.

- admin_level:

  Character. The administrative level of the survey data: `"national"`,
  `"adminlevel_1"` or `"district"`.

- anc1survey:

  Numeric. ANC1 coverage (a proportion) to use where the survey has no
  value.

- dpt1survey:

  Numeric. Penta1 coverage (a proportion) to use where the survey has no
  value.

- sbr:

  Numeric. Stillbirth rate (a proportion) to use where the survey has no
  value.

- nmr:

  Numeric. Neonatal mortality rate (a proportion) to use where the
  survey has no value.

- pnmr:

  Numeric. Post-neonatal mortality rate (a proportion) to use where the
  survey has no value.

- twin:

  Numeric. Twin birth rate (a proportion). It is not read from the
  survey data, so this value is always the one returned.

- preg_loss:

  Numeric. Pregnancy loss rate (a proportion). It is not read from the
  survey data, so this value is always the one returned.

- subnational_map:

  Optional. A data frame mapping survey regions to `adminlevel_1` units,
  used for subnational levels. Default is `NULL`.

## Value

A tibble with one row for national data, or one row per unit for
subnational data, and the columns `pnmr`, `nmr`, `sbr`, `preg_loss`,
`twin`, `anc1survey` and `dpt1survey`, all as proportions. Subnational
results also have the admin column or columns.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
rates <- get_national_rates(cache$national_survey)
rates
#> # A tibble: 1 × 7
#>     pnmr    nmr   sbr preg_loss  twin anc1survey dpt1survey
#>    <dbl>  <dbl> <dbl>     <dbl> <dbl>      <dbl>      <dbl>
#> 1 0.0121 0.0230  0.02      0.03 0.015      0.980      0.971

# A stillbirth rate of your own, used because the survey has none
get_national_rates(cache$national_survey, sbr = 0.015)$sbr
#> [1] 0.015

# The rates of each survey region
regional <- get_national_rates(cache$regional_survey, admin_level = "adminlevel_1")
regional
#> # A tibble: 55 × 8
#>    adminlevel_1       pnmr    nmr   sbr preg_loss  twin anc1survey dpt1survey
#>    <chr>             <dbl>  <dbl> <dbl>     <dbl> <dbl>      <dbl>      <dbl>
#>  1 Baringo         0.0175  0.0329  0.02      0.03 0.015      0.993      0.980
#>  2 Bomet           0.00916 0.0166  0.02      0.03 0.015      0.966      0.985
#>  3 Bungoma         0.0147  0.0246  0.02      0.03 0.015      0.986      0.987
#>  4 Busia           0.0121  0.0218  0.02      0.03 0.015      0.994      0.973
#>  5 Elgeyo Marakwet 0.00508 0.0270  0.02      0.03 0.015      0.993      0.949
#>  6 Embu            0.0114  0.0242  0.02      0.03 0.015      0.969      0.97 
#>  7 Garissa         0.0126  0.0284  0.02      0.03 0.015      0.779      0.633
#>  8 Homa Bay        0.0108  0.0316  0.02      0.03 0.015      0.982      0.975
#>  9 Isiolo          0.024   0.025   0.02      0.03 0.015      0.993      0.968
#> 10 Kajiado         0.0117  0.0138  0.02      0.03 0.015      0.991      0.919
#> # ℹ 45 more rows
```
