# Plot Line Graph for Multiple Series with Dynamic Y-axis Scaling

Plot Line Graph for Multiple Series with Dynamic Y-axis Scaling

## Usage

``` r
plot_line_graph(
  .data,
  x,
  y_vars,
  title,
  y_axis,
  x_axis,
  legend_labels,
  hline = NULL,
  hline_style = "dashed",
  options = NULL,
  ...
)
```

## Arguments

- .data:

  A data frame.

- x:

  The column name for the x-axis (e.g., "year").

- y_vars:

  Vector of column names for the y-axis data.

- title:

  Plot title.

- y_axis:

  Label for the y-axis.

- x_axis:

  Label for the x-axis.

- legend_labels:

  Vector of labels for the legend (must match y_vars length).

- hline:

  Optional numeric value for a horizontal reference line.

- hline_style:

  Style of the horizontal line.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above. Default is `NULL`.

- ...:

  Chart options (see
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html))
  given by name, applied as with `options`.

## Value

A ggplot object.
