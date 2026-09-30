# Plot Comparison with Linear Fit and R-squared

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
  x_label = NULL,
  y_label = NULL,
  legend = NULL,
  call = caller_env(),
  ...,
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

  Character. The main title for the plot. Defaults to a title based on
  `x_var` and `y_var`.

- x_label:

  Character. Label for the x-axis. Defaults to the value of `x_var`.

- y_label:

  Character. Label for the y-axis. Defaults to the value of `y_var`.

- legend:

  Optional named list or vector overriding the legend labels. Recognised
  names are `district`, `linear_fit` and `diagonale`; unnamed entries
  keep their defaults. Default is `NULL`.

- call:

  The calling environment.

- ...:

  Additional arguments for customization, such as `size`, `color`, or
  `linetype`, for finer control over plot appearance.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

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
