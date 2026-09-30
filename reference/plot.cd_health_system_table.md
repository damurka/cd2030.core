# Plot S3 method for Health System Metrics

Plot S3 method for Health System Metrics

## Usage

``` r
# S3 method for class 'cd_health_system_table'
plot(
  x,
  year = 2024,
  width = NULL,
  indicator_label = "Indicator",
  value_label = "Value",
  unit_label = "Unit",
  ...,
  options = NULL
)
```

## Arguments

- x:

  An object of class `cd_health_system_table`

- year:

  The year to display in the header (defaults to 2024)

- width:

  (Optional) Total width in inches. If NULL, autofit is used.

- indicator_label:

  (Optional) Translated label for the Indicator column header

- value_label:

  (Optional) Translated label for the Value column header

- unit_label:

  (Optional) Translated label for the Unit column header

- ...:

  Additional arguments

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.
