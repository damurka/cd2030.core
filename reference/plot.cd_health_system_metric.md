# Plot Health Metrics for Admin 1 Units

Plots individual health system indicators by admin 1 level and compares
with national value or target.

## Usage

``` r
# S3 method for class 'cd_health_system_metric'
plot(
  x,
  indicator = c("ratio_fac_pop", "ratio_hos_pop", "ratio_bed_pop", "ratio_hstaff_pop",
    "skill_mix"),
  national_value = NA_real_,
  title = NULL,
  x_axis = NULL,
  y_axis = NULL,
  legend_labels = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  Data frame containing admin 1 level indicators.

- indicator:

  A single metric to plot. Options include ratio_fac_pop, ratio_hos_pop,
  ratio_bed_pop, ratio_hstaff_pop, skill_mix.

- national_value:

  A numeric value representing the national average to plot as a
  vertical line. Can be NA.

- title:

  (Optional) Custom title for the plot.

- x_axis:

  (Optional) Custom label for the x-axis.

- y_axis:

  (Optional) Custom label for the y-axis.

- legend_labels:

  (Optional) A named list to override default legend labels (e.g. for
  translation).

- ...:

  Chart options (see
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html))
  given by name, applied as with `options`.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

## Value

A ggplot object.
