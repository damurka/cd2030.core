# The table a CacheConnection member gives

Reads an active binding, or calls a method with `args` (arguments it
doesn't take are left out), and returns the result as a plain data frame
(a map's geometry dropped).

## Usage

``` r
cd_member_data(cache, member, args = list())
```

## Arguments

- cache:

  A `CacheConnection`.

- member:

  A member name, one of
  [`cd_chartable_members()`](cd_chartable_members.md).

- args:

  A named list of arguments for a method.

## Value

A data frame.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

# a precomputed result
cd_member_data(cache, "reporting_rate_national")
#>   year anc_rr idelv_rr vacc_rr opd_rr mean_rr
#> 1 2019     94       94      94     95      94
#> 2 2020     96       96      95     96      96
#> 3 2021     96       96      96     96      96
#> 4 2022     97       97      97     96      97
#> 5 2023     97       97      98     97      97

# a method, with its arguments
rates <- cd_member_data(cache, "calculate_reporting_rate", args = list(admin_level = "adminlevel_1"))
head(rates)
#>   adminlevel_1 year anc_rr idelv_rr vacc_rr opd_rr mean_rr
#> 1  Rift Valley 2019     92       92      93     93      93
#> 2  Rift Valley 2020     95       95      95     95      95
#> 3  Rift Valley 2021     95       95      95     95      95
#> 4  Rift Valley 2022     95       95      95     94      95
#> 5  Rift Valley 2023     96       96      96     97      96
#> 6      Western 2019     95       95      96     96      96
```
