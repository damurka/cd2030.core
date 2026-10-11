# Calculate health system metrics

Aggregates data at national, admin level 1, or district level and
computes ratios and performance scores.

## Usage

``` r
calculate_health_system_metrics(
  .data,
  admin_level = c("national", "adminlevel_1", "district")
)
```

## Arguments

- .data:

  A data frame with health system indicators and population data.

- admin_level:

  One of 'national', 'adminlevel_1', or 'district'.

## Value

A summarized data frame with calculated metrics: ratios (facility, beds,
workforce, service use) and performance scores.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

national <- calculate_health_system_metrics(data, admin_level = "national")
national[c("year", "ratio_fac_pop", "ratio_bed_pop", "ratio_hstaff_pop", "score_total")]
#> # A tibble: 1 × 5
#>    year ratio_fac_pop ratio_bed_pop ratio_hstaff_pop score_total
#>   <int>         <dbl>         <dbl>            <dbl>       <dbl>
#> 1  2023          1.72          10.6             7.92        33.9

regions <- calculate_health_system_metrics(data, admin_level = "adminlevel_1")
regions[c("adminlevel_1", "ratio_fac_pop", "ratio_hstaff_pop", "score_total")]
#> # A tibble: 8 × 4
#>   adminlevel_1  ratio_fac_pop ratio_hstaff_pop score_total
#>   <chr>                 <dbl>            <dbl>       <dbl>
#> 1 Rift Valley            1.68             7.32        31.6
#> 2 Western                1.28             7.67        30.0
#> 3 Eastern                2.31             9.07        41.2
#> 4 North Eastern          1.11             5.89        21.7
#> 5 Nyanza                 1.75             8.16        37.5
#> 6 Central                2.16             9.48        40.0
#> 7 Coast                  1.60             9.39        32.7
#> 8 Nairobi                1.62             5.48        32.0
```
