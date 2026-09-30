# Plot S3 method for Coverage Data

Plot S3 method for Coverage Data

## Usage

``` r
# S3 method for class 'cd_coverage_selected'
plot(
  x,
  type = NULL,
  title = NULL,
  subtitle = NULL,
  x_axis = NULL,
  y_axis = NULL,
  fill_label = NULL,
  source_labels = NULL,
  indicator_labels = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  An object of class `cd_coverage_selected`.

- type:

  "profile" or "gap" (for national), "dot" or "heatmap" (for
  subnational).

- title:

  (Optional) Custom translated title.

- subtitle:

  (Optional) Custom translated subtitle.

- x_axis:

  (Optional) Custom translated x-axis label.

- y_axis:

  (Optional) Custom translated y-axis label.

- fill_label:

  (Optional) Custom translated legend title (for Heatmap).

- source_labels:

  (Optional) Named list to translate 'facility', 'survey', 'wuenic'.

- indicator_labels:

  (Optional) Named list to translate indicator names (e.g. 'anc4').

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
