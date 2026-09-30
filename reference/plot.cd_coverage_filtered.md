# Plot National Coverage Data

This function generates a line plot to visualize immunization coverage
data across years, allowing comparison between different estimates
(e.g., DHIS2 estimates, WUENIC estimates, and Survey estimates).

## Usage

``` r
# S3 method for class 'cd_coverage_filtered'
plot(
  x,
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

  A data frame of type `cd_coverage_filtered`, containing year-wise
  coverage data for the specified indicator.

- title:

  (Optional) A scalar character string to override the default plot
  title. Defaults to `NULL`.

- x_axis:

  (Optional) A scalar character string to override the default x-axis
  label. Defaults to `NULL`.

- y_axis:

  (Optional) A scalar character string to override the default y-axis
  label. Defaults to `NULL`.

- caption:

  (Optional) A scalar character string to override the default
  denominator caption. Defaults to `NULL`.

- labels:

  (Optional) A named list or vector to override the legend keys for
  translation. Valid keys: `dhis2`, `wuenic`, `survey`, `ci`. Defaults
  to `NULL`.

- ...:

  Chart options by name (see
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html));
  other arguments are ignored.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes the user changed. Applied last,
  so it wins over `title` and the other arguments above. Any chart
  option can also be given by name in `...`.

## Value

A `ggplot` object displaying a line plot of the coverage data.
