# Plot Completeness of Facility Reporting Ratios

Calculates and plots the estimated completeness of facility reporting
for maternal deaths or stillbirths based on UN estimates and assumed
community-to-institution ratios.

## Usage

``` r
# S3 method for class 'cd_mortality_ratio_summarised'
plot(x, labels = NULL, ..., options = NULL)
```

## Arguments

- x:

  A `cd_mortality_ratio_summarised ` object from completeness
  estimation.

- labels:

  (Optional) A named list to override the default English text, e.g.
  with translations. Valid keys: `title`, `x_axis`, `y_axis`, and the
  legend entries `lower`, `best` and `upper` (the UN lower bound, best
  estimate and upper bound). Defaults to `NULL`.

- ...:

  Additional arguments (not used).

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

## Value

A ggplot object with ratio lines, labels, and reference points.
