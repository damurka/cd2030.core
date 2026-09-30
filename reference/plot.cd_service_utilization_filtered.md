# Plot Service Utilization Indicators

Visualizes service utilization over time from a
`cd_service_utilization_filtered` object.

## Usage

``` r
# S3 method for class 'cd_service_utilization_filtered'
plot(x, labels = NULL, ..., options = NULL)
```

## Arguments

- x:

  A `cd_service_utilization_filtered` object created by
  [`filter_service_utilization()`](filter_service_utilization.md).

- labels:

  (Optional) A named list to override the default English text of the
  chart drawn, e.g. with translations. Valid keys: `title`, `x_axis`,
  `y_axis`, and the legend entries `y1` and `y2` of its two series (for
  `opd` and `ipd`: under-5 and all ages). Defaults to `NULL`.

- ...:

  not used

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

## Value

A `ggplot2` plot object.

## Examples

``` r
if (FALSE) { # \dontrun{
plot(filter_service_utilization(dat, indicator = 'opd'))
} # }
```
