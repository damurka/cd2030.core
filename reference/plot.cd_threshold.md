# Plot Target Threshold Attainment Over Time

Generates a grouped bar chart showing the percentage of administrative
regions that meet specific health coverage or dropout thresholds over
time.

## Usage

``` r
# S3 method for class 'cd_threshold'
plot(
  x,
  title = NULL,
  x_axis = NULL,
  y_axis = NULL,
  legend_title = NULL,
  x_labels = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  A `cd_threshold` object returned by
  [`calculate_threshold()`](calculate_threshold.md).

- title:

  (Optional) A scalar character string to override the default plot
  title. Defaults to `NULL`.

- x_axis:

  (Optional) A scalar character string to override the default x-axis
  label. Defaults to `NULL`.

- y_axis:

  (Optional) A scalar character string to override the default y-axis
  label. Defaults to `NULL`.

- legend_title:

  (Optional) A scalar character string to override the default legend
  title. Defaults to `NULL`.

- x_labels:

  (Optional) A named list or vector to translate the raw indicator names
  on the x-axis (e.g.,
  `list(penta1 = "Penta 1", dropout_penta13 = "Penta 1-3 Dropout")`).

- ...:

  Additional arguments passed to the plotting function.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

## Value

A `ggplot` object displaying a grouped bar chart of threshold
attainment.
