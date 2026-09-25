# Plot Line Graph for Multiple Series with Dynamic Y-axis Scaling

Generates a line graph for specified y variables over a shared x-axis,
with dynamic scaling of the y-axis based on the data.

## Usage

``` r
plot_line_graph(
  .data,
  x,
  y_vars,
  y_labels,
  title,
  y_axis_title,
  hline = NULL,
  hline_style = "dashed"
)
```

## Arguments

- .data:

  A data frame containing the variables to plot.

- x:

  The unquoted column name for the x-axis variable (e.g., `year`).

- y_vars:

  A character vector of column names for the y variables to plot.

- y_labels:

  A character vector of labels for the y variables (must match the
  length of `y_vars`).

- title:

  The title of the plot.

- y_axis_title:

  The title of the y-axis.

- hline:

  An optional numeric value to draw a horizontal line.

- hline_style:

  The line style for the horizontal line, default is "dashed".

## Value

A ggplot object.
