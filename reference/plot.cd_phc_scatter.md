# Plot S3 method for PHC performance scatter

Draws a scatter plot of the service coverage index against facility
density or health workforce density, with one point per admin level 1
unit. Dashed lines at the two medians split the plot into four labelled
quadrants, and the units flagged as outliers are named.

## Usage

``` r
# S3 method for class 'cd_phc_scatter'
plot(
  x,
  quad_labels = NULL,
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

  An object of class `cd_phc_scatter`, as returned by
  [`generate_phc_scatter_data()`](generate_phc_scatter_data.md).

- quad_labels:

  (Optional) Named list to override quadrant text. Expected keys:
  `high_high`, `low_high`, `high_low`, `low_low`.

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
scatter <- cache$generate_phc_scatter_data("ratio_fac_pop")

plot(scatter)

plot(scatter, title = "Facilities and services by region", y_title = "Service index",
     quad_labels = list(low_low = "Few facilities, few services"))

```
