# Generate MCH vs curative index data

Keeps the latest year of subnational service utilization data and its
two service indices: the MCH preventive services index and the curative
services index. The result is ready for
[`plot.cd_mch_curative_index()`](plot.cd_mch_curative_index.md).

## Usage

``` r
generate_admin1_mch_curative_index(service_utilization)
```

## Arguments

- service_utilization:

  Dataframe containing admin level 1 service utilization.

## Value

A tibble with class `cd_mch_curative_index`.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
utilization <- compute_service_utilization(data, admin_level = "adminlevel_1")

index <- generate_admin1_mch_curative_index(utilization)
index
#> # A tibble: 8 × 4
#>   adminlevel_1   year mch_prev_services_index curative_services_index
#>   <chr>         <int>                   <dbl>                   <dbl>
#> 1 Rift Valley    2023                    3.07                    3.35
#> 2 Western        2023                    3.23                    2.55
#> 3 Eastern        2023                    2.98                    3.50
#> 4 North Eastern  2023                    2.36                    2.00
#> 5 Nyanza         2023                    3.50                    3.20
#> 6 Central        2023                    3.48                    4.31
#> 7 Coast          2023                    3.24                    3.56
#> 8 Nairobi        2023                    3.91                    3.84
plot(index)
```
