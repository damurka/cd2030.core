# A Specialized Dot Plot for Area of Residence Analysis

Plots rural and urban survey estimates of an indicator by year.

## Usage

``` r
equiplot_area(
  .data,
  indicator,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  legend_title = NULL,
  legend_labels = NULL,
  dot_size = NULL,
  ...,
  options = NULL
)
```

## Arguments

- .data:

  Equity survey data with `year`, `level` and `r_<indicator>` columns.

- indicator:

  Character. The indicator to plot; its `r_<indicator>` column is used.

- title, subtitle, caption:

  Optional plot title, subtitle and caption.

- x_title:

  Optional x-axis title. Defaults to the indicator name followed by
  "Coverage".

- legend_title:

  Optional legend title. Defaults to a title describing the grouping
  (for example `"Area of residence"`).

- legend_labels:

  Optional named vector or list mapping group names to display labels.

- dot_size:

  Optional dot size, clamped to 1-5. Defaults to 4.

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
