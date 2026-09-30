# Plot Mortality Rate Indicators

Produces line plots for national mortality indicators with regional
points for comparison.

## Usage

``` r
# S3 method for class 'cd_mortality_summary'
plot(
  x,
  indicator = c("mmr_inst", "ratio_md_sb", "sbr_inst", "nn_inst"),
  labels = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  A `cd_mortality_summary` object.

- indicator:

  One of `"mmr_inst"`, `"ratio_md_sb"`, `"sbr_inst"`, or `"nn_inst"`.

- labels:

  (Optional) A named list to override the default English text, e.g.
  with translations. Valid keys: `title`, `national` (legend entry for
  the national line) and `regions` (legend entry for the regional
  points). Defaults to `NULL`.

- ...:

  Additional arguments passed to methods.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

## Value

A ggplot object.
