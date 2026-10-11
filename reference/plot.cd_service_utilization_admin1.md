# Plot S3 method for service utilization at admin level 1

Draws a horizontal bar for each admin level 1 unit showing its
under-five OPD visits per child or IPD admissions per 100 children in
the latest year. The bars are ordered by value and labelled with it.

## Usage

``` r
# S3 method for class 'cd_service_utilization_admin1'
plot(
  x,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  Object of class cd_service_utilization_admin1, as returned by
  [`generate_admin1_service_utilization()`](generate_admin1_service_utilization.md).

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

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A `ggplot` object, with the chart options applied.

## Examples

``` r
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cache$adjust_data()

plot(cache$generate_admin1_service_utilization("opd"))

plot(cache$generate_admin1_service_utilization("ipd"), title = "Admissions of children under five",
     x_title = "Admissions per 100 children", show_legend = FALSE)

```
