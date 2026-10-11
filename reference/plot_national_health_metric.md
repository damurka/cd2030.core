# Plot national health system metrics

Creates a horizontal bar plot for either health system performance or
density metrics at national level.

## Usage

``` r
plot_national_health_metric(.data, metric = c("performance", "density"))
```

## Arguments

- .data:

  A one-row data frame containing national-level metrics.

- metric:

  Either 'performance' or 'density'.

## Value

A ggplot object.

## Examples

``` r
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cache$adjust_data()
national <- cache$health_system_metrics_national

plot_national_health_metric(national, metric = "performance")

plot_national_health_metric(national, metric = "density")

```
