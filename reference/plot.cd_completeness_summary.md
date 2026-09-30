# Plot Missing Summary

This method visualizes missing results for immunization indicators

## Usage

``` r
# S3 method for class 'cd_completeness_summary'
plot(
  x,
  plot_type = c("heat_map", "trend"),
  indicator = NULL,
  title = NULL,
  x_axis = NULL,
  y_axis = NULL,
  legend = NULL,
  ...,
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

  Optional plot title. Defaults to a title based on `plot_type`,
  `indicator` and region.

- x_axis, y_axis:

  Optional x- and y-axis titles. Default is `NULL`.

- legend:

  Optional legend title. Default is `NULL`.

- ...:

  Reserved for future use.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

## Value

A `ggplot` or `plotly` object depending on the selection type.

## Examples

``` r
if (FALSE) { # \dontrun{
# Region-level summary
plot(missing_data, indicator = "penta3")
} # }
```
