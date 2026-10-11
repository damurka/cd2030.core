# Plot comparison with linear fit and R-squared

Creates a scatter plot to compare two indicators over multiple years,
including a linear regression line and a diagonal reference line. The
plot is faceted by year, and displays R-squared values for each year to
assess the relationship between indicators.

## Usage

``` r
# S3 method for class 'cd_data'
plot_comparison(
  .data,
  x_var,
  y_var,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  legend_labels = NULL,
  call = caller_env(),
  options = NULL
)
```

## Arguments

- .data:

  A `cd_data` object containing merged data for the specified
  indicators.

- x_var:

  Character. Name of the variable to plot on the x-axis (e.g., 'anc1').

- y_var:

  Character. Name of the variable to plot on the y-axis (e.g.,
  'penta1').

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

  Optional named list or vector overriding the legend labels. Recognised
  names are `district`, `linear_fit` and `diagonale`; unnamed entries
  keep their defaults. Default is `NULL`.

- call:

  The calling environment.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A ggplot2 object showing the comparison plot of two indicators with
linear regression and R-squared values.

## Details

This function calculates R-squared values for each year and displays
them in each facet, helping assess the relationship between the two
indicators over time. The diagonal reference line is added to aid in
visualizing deviations from a perfect 1:1 relationship.

Common indicator comparisons include:

- ANC1 vs PENTA1

- PENTA1 vs PENTA3

- OPV1 vs OPV3

## Examples

``` r
if (FALSE) { # \dontrun{
plot_comparison(cd_data, x_var = "anc1", y_var = "penta1")
} # }
```
