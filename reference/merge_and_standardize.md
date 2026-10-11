# Merge and standardize sheets read by `load_excel_parts()`

Merges the separate sheets returned by
[`load_excel_parts()`](load_excel_parts.md) into one dataset,
standardizes its columns and returns it as a `cd_data` tibble. This is
the second half of loading an Excel workbook.

## Usage

``` r
merge_and_standardize(
  parts_result,
  indicator_group = c("auto", "vaccine", "rmncah", "custom"),
  profile = NULL,
  profile_name = NULL,
  validate = TRUE
)
```

## Arguments

- parts_result:

  A list. What [`load_excel_parts()`](load_excel_parts.md) returns.

- indicator_group:

  One of `"auto"`, `"vaccine"`, `"rmncah"`, `"custom"`. Default
  `"auto"`.

- profile:

  Optional. Either a **name** (string) of an existing group, or a
  **definition** to register inline before loading:

  - explicit form:
    `list(name = "rmncah", value = list(hiv = c("hiv_test","pmtct1")))`

  - compact form:
    `list(hiv_profile = list(testing = c("hiv_test"), care = c("art_new")))`

  For `"custom"`, the profile must resolve to **one** concrete name.

- profile_name:

  Optional. The resolved profile (indicator group) name, used when
  resolving the indicator group (for example with
  `indicator_group = "custom"`). Default is `NULL`.

- validate:

  Logical. Whether to stop with an error when the merged data fails a
  data quality check:
  [`check_district_consistency()`](check_district_consistency.md),
  [`check_month_presence()`](check_month_presence.md) or
  [`check_month_validity()`](check_month_validity.md). Default is
  `TRUE`. With `FALSE` a file that has such problems still loads, so the
  caller can run the checks later with
  [`run_all_quality_checks()`](run_all_quality_checks.md). Structural
  checks, such as a missing Admin sheet column, always run.

## Value

A tibble of class `cd_data`.

## Details

Before merging, the function stops with an error if the Admin sheet
fails [`check_admin_columns()`](check_admin_columns.md) or
[`check_single_country()`](check_single_country.md). The merged data
then goes to [`new_countdown()`](new_countdown.md), which resolves the
indicator group and, when `validate` is `TRUE`, stops on a data quality
problem.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
data <- merge_and_standardize(sheets)
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
data
#> ─────────────────────────── Countdown Object Summary ───────────────────────────
#> 
#> ── Data Summary ──
#> 
#> • Number of observations: 2820
#> • Number of variables: 73
#> • Number of years: 5
#> • Number of regions: 8
#> 
#> ── Years Available ──
#> 
#> • 2019
#> • 2020
#> • 2021
#> • 2022
#> • 2023
#> 
#> ── Regions Available ──
#> 
#> • Rift Valley
#> • Western
#> • Eastern
#> • North Eastern
#> • Nyanza
#> • Central
#> • Coast
#> • Nairobi
#> 
#> ── Variable Groups Available ──
#> 
#> * anc: anc1, anc_1trimester, anc4, ipt2, ipt3, syphilis_test, ifa90, hiv_test
#> * idelv: sba, ideliv, instlivebirths, csection, low_bweight, pnc48h,
#> total_stillbirth, stillbirth_f, stillbirth_m, maternal_deaths, neonatal_deaths
#> * vacc: penta1, penta3, measles1, measles2, bcg
#> * opd: opd_total, opd_under5
#> * ipd: ipd_total, ipd_under5
#> ────────────────────────────────────────────────────────────────────────────────
#> # A tibble: 2,820 × 73
#>    country adminlevel_1 district  year month     anc1 anc_1trimester  anc4  ipt2
#>    <chr>   <chr>        <chr>    <int> <ord>    <dbl>          <dbl> <dbl> <dbl>
#>  1 Kenya   Rift Valley  Baringo   2019 January   2006             NA   750    11
#>  2 Kenya   Rift Valley  Baringo   2019 February  1237             NA   676    NA
#>  3 Kenya   Rift Valley  Baringo   2019 March     1511             NA   796    NA
#>  4 Kenya   Rift Valley  Baringo   2019 April     1575             NA   889    NA
#>  5 Kenya   Rift Valley  Baringo   2019 May       1768             NA   878    NA
#>  6 Kenya   Rift Valley  Baringo   2019 June      1559             NA   770    NA
#>  7 Kenya   Rift Valley  Baringo   2019 July      1609             NA   847    13
#>  8 Kenya   Rift Valley  Baringo   2019 August    1525             NA  1003     7
#>  9 Kenya   Rift Valley  Baringo   2019 Septemb…  1550             NA   870    22
#> 10 Kenya   Rift Valley  Baringo   2019 October   1584             NA   852     9
#> # ℹ 2,810 more rows
#> # ℹ 64 more variables: ipt3 <dbl>, ifa90 <dbl>, syphilis_test <dbl>,
#> #   hiv_test <dbl>, sba <dbl>, ideliv <dbl>, instlivebirths <dbl>,
#> #   csection <dbl>, low_bweight <dbl>, pnc48h <dbl>, total_stillbirth <dbl>,
#> #   stillbirth_f <dbl>, stillbirth_m <dbl>, maternal_deaths <dbl>,
#> #   neonatal_deaths <dbl>, bcg <dbl>, penta1 <dbl>, penta3 <dbl>,
#> #   measles1 <dbl>, measles2 <dbl>, opd_total <dbl>, opd_under5 <dbl>, …

# Load even if a data quality check fails, to run the checks afterwards
data <- merge_and_standardize(sheets, validate = FALSE)
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
```
