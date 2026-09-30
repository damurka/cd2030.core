# Plot S3 method for Private Sector Ownership

Plot S3 method for Private Sector Ownership

## Usage

``` r
# S3 method for class 'cd_private_sector'
plot(x, title = NULL, x_axis = NULL, y_axis = NULL, ..., options = NULL)
```

## Arguments

- x:

  An object of class `cd_private_sector`

- title:

  (Optional) Custom title for the plot.

- x_axis:

  (Optional) Custom label for the x-axis.

- y_axis:

  (Optional) Custom label for the y-axis.

- ...:

  Additional arguments

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.
