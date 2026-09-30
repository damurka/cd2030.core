# Plot S3 method for Service DQA Summary

Plot S3 method for Service DQA Summary

## Usage

``` r
# S3 method for class 'cd_utilization_dqa'
plot(x, years = NULL, title = NULL, width = NULL, ..., options = NULL)
```

## Arguments

- x:

  The score dataframe (needs class 'cd_utilization_dqa')

- years:

  Vector of years to display (e.g., 2020:2024)

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
