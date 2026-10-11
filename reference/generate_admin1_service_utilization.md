# Generate service utilization admin level 1 data

Keeps the latest year of subnational service utilization data and the
under-five utilization rate of one service: OPD visits per child
(`ratio_opd_u5_pop`) or IPD admissions per 100 children
(`ratio_ipd_u5_pop`). The result is ready for
[`plot.cd_service_utilization_admin1()`](plot.cd_service_utilization_admin1.md).

## Usage

``` r
generate_admin1_service_utilization(
  service_utilization,
  metric_type = c("opd", "ipd")
)
```

## Arguments

- service_utilization:

  Dataframe containing admin level 1 service utilization.

- metric_type:

  Character. Either "opd" or "ipd".

## Value

A tibble with class `cd_service_utilization_admin1` and the columns
`adminlevel_1`, `year` and the selected rate. The attribute
`metric_type` holds `metric_type`.

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

# outpatient visits per child under five, by region, in the latest year
generate_admin1_service_utilization(utilization, metric_type = "opd")
#> # A tibble: 8 × 3
#>   adminlevel_1   year ratio_opd_u5_pop
#>   <chr>         <int>            <dbl>
#> 1 Rift Valley    2023             2.91
#> 2 Western        2023             1.95
#> 3 Eastern        2023             2.98
#> 4 North Eastern  2023             1.76
#> 5 Nyanza         2023             2.21
#> 6 Central        2023             3.61
#> 7 Coast          2023             3.06
#> 8 Nairobi        2023             3.14

# inpatient admissions per 100 children under five
admissions <- generate_admin1_service_utilization(utilization, metric_type = "ipd")
plot(admissions)
```
