# Plot S3 method for PHC Performance Scatter

Plot S3 method for PHC Performance Scatter

## Usage

``` r
# S3 method for class 'cd_phc_scatter'
plot(
  x,
  title = NULL,
  x_axis = NULL,
  y_axis = NULL,
  quad_labels = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  An object of class `cd_phc_scatter`

- title:

  (Optional) Custom title for the entire plot.

- x_axis:

  (Optional) Custom label for the x-axis.

- y_axis:

  (Optional) Custom label for the y-axis.

- quad_labels:

  (Optional) Named list to override quadrant text. Expected keys:
  `high_high`, `low_high`, `high_low`, `low_low`.

- ...:

  Additional arguments

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.
