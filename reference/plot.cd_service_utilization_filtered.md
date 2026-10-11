# Plot service utilization indicators

Visualizes service utilization over time from a
`cd_service_utilization_filtered` object.

## Usage

``` r
# S3 method for class 'cd_service_utilization_filtered'
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

  A `cd_service_utilization_filtered` object created by
  [`select_service_utilization()`](select_service_utilization.md).

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

  (Optional) A named list to override the legend's entries, e.g. with
  translations: `y1` and `y2`, the chart's two series (for `opd` and
  `ipd`: under-5 and all ages). Defaults to `NULL`.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A `ggplot2` plot object.

## Examples

``` r
if (FALSE) { # \dontrun{
plot(select_service_utilization(dat, indicator = 'opd'))
} # }
```
