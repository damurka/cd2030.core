# Plot subnational health coverage analysis

Generates a plot to visualize health coverage data across subnational
units, distinguishing between the national mean and subnational
coverage. The Mean Absolute Difference to the Mean (MADM) is displayed
as an indicator on the y-axis.

## Usage

``` r
# S3 method for class 'cd_inequality_filtered'
plot(
  x,
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

  A `cd_inequality_filtered` object returned by
  [`select_inequality()`](select_inequality.md).

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

  (Optional) A named list or vector to override the legend keys and MADM
  label for translation. Valid keys: `subnational`, `national`, `madm`.
  Defaults to `NULL`.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A `ggplot` object displaying the subnational health coverage plot.

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
inequality <- cache$get_filtered_inequality("penta3", "adminlevel_1")

plot(inequality)
#> Warning: Removed 35 rows containing missing values or values outside the scale range
#> (`geom_point()`).

plot(inequality, title = "Penta3 coverage by region", y_title = "Coverage (%)",
     legend_labels = list(subnational = "Regions", national = "Kenya"))
#> Warning: Removed 35 rows containing missing values or values outside the scale range
#> (`geom_point()`).

```
