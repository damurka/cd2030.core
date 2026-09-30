# Plot Family Planning Estimation Tool (FPET) Data

Generates a line and ribbon plot for FPET indicators (e.g., mCPR, Demand
Satisfied) displaying median estimates and 95% credible intervals.

## Usage

``` r
# S3 method for class 'cd_fpet_data'
plot(
  x,
  title = NULL,
  x_axis = NULL,
  y_axis = NULL,
  caption = NULL,
  indicator_labels = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  An object of class `cd_fpet_data`.

- title:

  (Optional) Custom translated title.

- x_axis:

  (Optional) Custom translated x-axis label.

- y_axis:

  (Optional) Custom translated y-axis label.

- caption:

  (Optional) Custom translated caption.

- indicator_labels:

  (Optional) A named list mapping raw indicator names to translated
  legend labels.

- ...:

  Additional arguments.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.
