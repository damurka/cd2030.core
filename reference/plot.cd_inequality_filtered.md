# Plot Subnational Health Coverage Analysis

Generates a plot to visualize health coverage data across subnational
units, distinguishing between the national mean and subnational
coverage. The Mean Absolute Difference to the Mean (MADM) is displayed
as an indicator on the y-axis.

## Usage

``` r
# S3 method for class 'cd_inequality_filtered'
plot(
  x,
  title = NULL,
  subtitle = NULL,
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

  A `cd_inequality_filtered` object returned by
  [`filter_inequality()`](filter_inequality.md).

- title:

  (Optional) A scalar character string to override the default plot
  title. Defaults to `NULL`.

- subtitle:

  (Optional) A scalar character string to override the default plot
  subtitle. Defaults to `NULL`.

- x_axis:

  (Optional) A scalar character string to override the default x-axis
  label. Defaults to `NULL`.

- y_axis:

  (Optional) A scalar character string to override the default y-axis
  label. Defaults to `NULL`.

- caption:

  (Optional) A scalar character string to override the default
  denominator caption. Defaults to `NULL`.

- legend_labels:

  (Optional) A named list or vector to override the legend keys and MADM
  label for translation. Valid keys: `subnational`, `national`, `madm`.
  Defaults to `NULL`.

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

A `ggplot` object displaying the subnational health coverage plot.
