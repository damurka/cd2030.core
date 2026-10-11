# Compare district vs admin level 1 health metrics

Generates scatterplots with linear fit and identity line comparing
district to admin level 1 metrics or coverage vs density.

## Usage

``` r
# S3 method for class 'cd_health_system_comparison'
plot(
  x,
  indicator = c("cov_instdeliveries_hstaff", "ratio_opd_u5_hstaff", "ratio_ipd_u5_hos",
    "ratio_ipd_u5_bed"),
  denominator = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  legend_labels = NULL,
  options = NULL
)
```

## Arguments

- x:

  A data frame from
  [`calculate_health_system_comparison()`](calculate_health_system_comparison.md).

- indicator:

  One of ratio\_\* or cov_instdeliveries\_\* (requires `denominator`).

- denominator:

  Optional for cov\_ indicators. Must be one of 'dhis2', 'anc1',
  'penta1'.

- title:

  The chart's title.

- subtitle:

  The line under the title.

- caption:

  The note under the chart.

- x_title:

  The title of the horizontal axis.

- y_title:

  The title of the vertical axis.

- legend_title:

  The title of the legend.

- ...:

  Chart options by name (see
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)):
  background, fonts, sizes, axes, grid, legend, colours. Other arguments
  are ignored.

- legend_labels:

  (Optional) A named list to override default legend labels (keys:
  'admin', 'linear').

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

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
cache$set_national_estimates(list(sbr = 0.02))
cache$adjust_data()
comparison <- cache$health_system_comparison

plot(comparison, indicator = "ratio_opd_u5_hstaff")

plot(comparison, indicator = "ratio_ipd_u5_bed", title = "Admissions of children and hospital beds",
     legend_labels = list(admin = "Regions", linear = "Trend"))

```
