# Compare District vs Admin 1 Health Metrics

Generates scatterplots with linear fit and identity line comparing
district to admin 1 metrics or coverage vs density.

## Usage

``` r
# S3 method for class 'cd_health_system_comparison'
plot(
  x,
  indicator = c("cov_instdeliveries_hstaff", "ratio_opd_u5_hstaff", "ratio_ipd_u5_hos",
    "ratio_ipd_u5_bed"),
  denominator = NULL,
  title = NULL,
  x_axis = NULL,
  y_axis = NULL,
  caption = NULL,
  legend_labels = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  A data frame from
  [`calculate_health_system_comparison()`](calculate_health_system_comparison.md).

- indicator:

  One of ratio\_\* or cov_instdeliveries\_\* (requires `denominator`).

- denominator:

  Optional for cov\_ indicators. Must be one of 'dhis2', 'anc1',
  'penta1'.

- title:

  (Optional) Custom title for the plot.

- x_axis:

  (Optional) Custom label for the x-axis.

- y_axis:

  (Optional) Custom label for the y-axis.

- caption:

  (Optional) Custom caption text (R-squared will automatically be
  prepended to this).

- legend_labels:

  (Optional) A named list to override default legend labels (keys:
  'admin', 'linear').

- ...:

  Chart options (see
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html))
  given by name, applied as with `options`.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

## Value

A ggplot object.
