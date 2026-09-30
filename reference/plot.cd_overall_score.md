# Plot S3 method for Overall Score

Plot S3 method for Overall Score

## Usage

``` r
# S3 method for class 'cd_overall_score'
plot(x, years = NULL, title = NULL, width = NULL, ..., options = NULL)
```

## Arguments

- x:

  The score dataframe (class cs_overall_score)

- years:

  Vector of years to display

- title:

  (Optional) Custom title for the table

- width:

  (Optional) Total width in inches. If NULL, autofit is used.

- ...:

  Additional arguments

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.
