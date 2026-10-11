# The table a custom chart draws

Checks a custom chart description, reads the data of the dataset member
it names and applies the transforms it lists. The result is the table
the chart is drawn from.

## Usage

``` r
cd_custom_chart_data(cache, spec)
```

## Arguments

- cache:

  A `CacheConnection`.

- spec:

  A custom chart description (report kind `custom_chart`, see
  [`datasuite.ui::report_validate_spec()`](https://rdrr.io/pkg/datasuite.ui/man/report_validate_spec.html)).

## Value

The data frame after the spec's transforms.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

spec <- list(
  title = "Antenatal care reporting rate by region, 2023",
  data = list(member = "reporting_rate_admin1"),
  transform = list(
    list(filter = list(year = 2023)),
    list(select = c("adminlevel_1", "anc_rr"))
  ),
  plot = list(geom = "col", x = "adminlevel_1", y = "anc_rr")
)
cd_custom_chart_data(cache, spec)
#>    adminlevel_1 anc_rr
#> 1   Rift Valley     96
#> 2       Western     98
#> 3       Eastern     98
#> 4 North Eastern     92
#> 5        Nyanza     99
#> 6       Central     98
#> 7         Coast     98
#> 8       Nairobi     98
```
