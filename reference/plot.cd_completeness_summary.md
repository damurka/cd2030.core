# Plot missing summary

Draws the share of missing values in a completeness summary as a heat
map by unit, for one indicator by year or for all indicators averaged
over the years. With `plot_type = "trend"` it draws the completeness of
one indicator over time, one panel per unit.

## Usage

``` r
# S3 method for class 'cd_completeness_summary'
plot(
  x,
  plot_type = c("heat_map", "trend"),
  indicator = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  indicator_labels = NULL,
  options = NULL
)
```

## Arguments

- x:

  A `cd_completeness_summary` object, as returned by
  [`calculate_completeness_summary()`](calculate_completeness_summary.md).

- plot_type:

  Either `"heat_map"` (missingness by unit, for one or all indicators)
  or `"trend"` (completeness over time for one indicator). Default is
  `"heat_map"`.

- indicator:

  Optional. One of the supported indicators (`'opv1'`, `'penta3'`, etc.)
  to visualize in the plot. If `NULL` all indicators will be shown.

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

- indicator_labels:

  (Optional) A named vector or list, indicator code -\> label, for the
  axis that names indicators (see
  [`cd_indicator_labels()`](cd_indicator_labels.md), which gives them
  translated). By default the English labels.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A `ggplot` object: a heat map or a faceted line chart, depending on
`plot_type`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Region-level summary
plot(missing_data, indicator = "penta3")
} # }
```
