# Plot S3 method for Bayesian Coverage Model

Leverages the bayescoveragemodel package's internal plotting function
and applies the custom Countdown (CD) theme and translated labels.

## Usage

``` r
# S3 method for class 'cd_bayes_model'
plot(
  x,
  title = NULL,
  x_axis = NULL,
  y_axis = NULL,
  caption = NULL,
  region = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  An object of class `cd_bayes_model` returned by
  [`generate_bayes_model()`](generate_bayes_model.md).

- title:

  (Optional) Custom translated title.

- x_axis:

  (Optional) Custom translated x-axis label.

- y_axis:

  (Optional) Custom translated y-axis label.

- caption:

  (Optional) Custom translated caption.

- region:

  (Optional) Specific region code to plot for subnational data.

- ...:

  Additional arguments.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.
