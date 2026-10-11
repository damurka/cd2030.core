# Generate PHC performance scatter data

Pairs a health system input (facility density or health workforce
density) with a service coverage index for each admin level 1 unit, for
[`plot.cd_phc_scatter()`](plot.cd_phc_scatter.md). The service coverage
index is the mean of the MCH preventive services index and the curative
services index.

## Usage

``` r
generate_phc_scatter_data(
  .data,
  x_indicator = c("ratio_fac_pop", "ratio_hstaff_pop")
)
```

## Arguments

- .data:

  A `cd_health_system_metric` object, as returned by
  [`calculate_health_system_metrics()`](calculate_health_system_metrics.md)
  with `admin_level = "adminlevel_1"`.

- x_indicator:

  Independent variable ('ratio_fac_pop' or 'ratio_hstaff_pop').

## Value

A tibble of class `cd_phc_scatter` with one row per admin level 1 unit
and the columns `adminlevel_1`, the column named by `x_indicator`,
`service_coverage` and `is_outlier` (`TRUE` when `service_coverage` is
below the first quartile or above the third quartile). The attribute
`indicator` holds `x_indicator`.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
metrics <- calculate_health_system_metrics(data, admin_level = "adminlevel_1")

generate_phc_scatter_data(metrics, x_indicator = "ratio_fac_pop")
#> # A tibble: 8 × 4
#>   adminlevel_1  ratio_fac_pop service_coverage is_outlier
#>   <chr>                 <dbl>            <dbl> <lgl>     
#> 1 Rift Valley            1.68            0.249 FALSE     
#> 2 Western                1.28            0.236 TRUE      
#> 3 Eastern                2.31            0.267 FALSE     
#> 4 North Eastern          1.11            0.170 TRUE      
#> 5 Nyanza                 1.75            0.295 FALSE     
#> 6 Central                2.16            0.299 TRUE      
#> 7 Coast                  1.60            0.267 FALSE     
#> 8 Nairobi                1.62            0.303 TRUE      

# against the density of health workers
workforce <- generate_phc_scatter_data(metrics, x_indicator = "ratio_hstaff_pop")
plot(workforce)

```
