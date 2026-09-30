# Plot Coverage by Region

Generates a bar chart comparing indicator coverage across regions,
highlighting a specific region and categorizing performance as lower,
average, or higher.

## Usage

``` r
# S3 method for class 'cd_coverage'
plot(
  x,
  indicator = NULL,
  denominator = NULL,
  year = NULL,
  region = NULL,
  title = NULL,
  x_axis = NULL,
  y_axis = NULL,
  caption = NULL,
  labels = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  Data frame containing the coverage data.

- indicator:

  Character string specifying the indicator (e.g., 'penta1').

- denominator:

  Character string specifying the denominator ('penta1', 'anc1',
  'dhis2', 'penta1derived', 'anc1derived').

- year:

  Integer representing the year to plot.

- region:

  Character string for the specific region to highlight in yellow.

- title:

  (Optional) Scalar character for a custom plot title.

- x_axis:

  (Optional) Scalar character for a custom x-axis label.

- y_axis:

  (Optional) Scalar character for a custom y-axis label.

- caption:

  (Optional) Scalar character for a custom plot caption.

- labels:

  (Optional) Named list to override the default category labels (e.g.,
  `list(lower = "Low", average = "Avg", higher = "High")`).

- ...:

  Additional arguments.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.
