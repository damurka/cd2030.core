# Internal consistency plot functions for indicator comparisons

These functions generate scatter plots that compare two health
indicators across years, assessing internal consistency through
visualization of linear regression fits and R-squared values by year.
Each function is designed to compare a specific pair of indicators, with
options for customizing plot titles, axis labels, and the inclusion of
trend information.

`plot_comparison_anc1_penta1()` compares ANC1 and Penta1. Its title is
"Comparison of numbers of ANC1 and Penta1 by year" and its axes are
titled "ANC1" and "Penta1" unless others are given; the two functions
below are the same for their pairs.

`plot_comparison_penta1_penta3()` compares Penta1 and Penta3.

`plot_comparison_opv1_opv3()` compares OPV1 and OPV3.

## Usage

``` r
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
  call = caller_env()
)

plot_comparison_anc1_penta1(
  .data,
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

plot_comparison_penta1_penta3(
  .data,
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

plot_comparison_opv1_opv3(
  .data,
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

- .data:

  A data frame of class `cd_data` that includes the relevant indicators
  for comparison.

- x_var:

  Character. The name of the indicator variable to plot on the x-axis.

- y_var:

  Character. The name of the indicator variable to plot on the y-axis.

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
  names are `district`, `linear_fit` and `diagonale`. Default is `NULL`.

- call:

  The calling environment, used for error handling. Default is
  `caller_env()`.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object; see [cd_plot_arguments](cd_plot_arguments.md).

## Value

A `ggplot2` object, comprising:

- A scatter plot comparing two specified indicators over multiple years.

- A linear regression line for each year, indicating the trend between
  the indicators.

- Optional display of R-squared values per facet, summarizing the
  correlation strength.

- Faceting by year to facilitate a detailed comparison of trends across
  years.

Users can render this `ggplot2` object directly, save it, or further
modify it using the `+` operator.

## Details

- The scatter plot displays the relationship between the two specified
  indicators over multiple years, with each year presented in a separate
  facet.

- A linear regression line is added to each year's plot to help
  visualize the trend.

- R-squared values, calculated per year, are optionally displayed on
  each facet, indicating the strength of the linear relationship between
  the indicators for that year.

- A diagonal reference line is also provided for visual comparison to a
  1:1 relationship, where applicable.

This function is commonly used for consistency checks between indicators
such as:

- ANC1 vs PENTA1

- PENTA1 vs PENTA3

- OPV1 vs OPV3

## Examples

``` r
if (FALSE) { # \dontrun{
# Plot a comparison between ANC1 and PENTA1 indicators
plot_comparison(cd_data, x_var = "anc1", y_var = "penta1")

# Dedicated function for comparing ANC1 and PENTA1 over time
plot_comparison_penta1_anc1(cd_data)
} # }
```
