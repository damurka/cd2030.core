# Create Dot Plots for Equity Analysis

`equiplot` generates a dot plot to visualize the distribution of
variables across different groups (e.g., countries, regions, or
interventions). It is designed for equity analysis by plotting values
for variables like health intervention coverage across subgroups,
allowing insights into disparities.

## Usage

``` r
equiplot(
  .data,
  variables,
  group_by,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  legend_title = NULL,
  legend_labels = NULL,
  reverse_y_axis = FALSE,
  connect_dots = TRUE,
  dot_size = NULL
)
```

## Arguments

- .data:

  A data frame with one row per group and one column per variable
  (values in percent, plotted on a 0-100 scale).

- variables:

  Character vector of the column names to plot as dots; each becomes a
  coloured series.

- group_by:

  The column (unquoted or as a string) whose values form the rows of the
  plot (y axis).

- title, subtitle, caption:

  Optional plot title, subtitle and caption. Each must be a single
  string or `NULL`.

- x_title:

  Optional x-axis title. Defaults to a percentage label.

- legend_title:

  Optional title of the colour legend.

- legend_labels:

  Optional named vector or list mapping variable names to display labels
  (for example translated labels).

- reverse_y_axis:

  Logical. Whether to reverse the order of the groups on the y axis.
  Default is `FALSE`.

- connect_dots:

  Logical. Whether to draw a line connecting the dots of each group.
  Default is `TRUE`.

- dot_size:

  Optional dot size, clamped to 1-5. Defaults to 4.

## Value

A `ggplot` object.
