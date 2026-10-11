# Plot health metrics for admin level 1 units

Plots individual health system indicators by admin level 1 and compares
with national value or target.

## Usage

``` r
# S3 method for class 'cd_health_system_metric'
plot(
  x,
  indicator = c("ratio_fac_pop", "ratio_hos_pop", "ratio_bed_pop", "ratio_hstaff_pop",
    "skill_mix"),
  national_value = NA_real_,
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

  Data frame containing admin level 1 indicators.

- indicator:

  A single metric to plot. Options include ratio_fac_pop, ratio_hos_pop,
  ratio_bed_pop, ratio_hstaff_pop, skill_mix.

- national_value:

  A numeric value representing the national average to plot as a
  vertical line. Can be NA.

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

  (Optional) A named list to override default legend labels (e.g. for
  translation).

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
cache$adjust_data()
regions <- cache$health_system_metrics_admin1
national <- cache$health_system_metrics_national

plot(regions, indicator = "ratio_fac_pop", national_value = national$ratio_fac_pop)

plot(regions, indicator = "ratio_hstaff_pop", national_value = national$ratio_hstaff_pop,
     title = "Health workers per 10,000 people", x_title = "Health workers",
     legend_labels = list(threshold_line = "Benchmark (44.5)"))

```
