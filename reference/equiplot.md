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
  x_title = NULL,
  legend_title = NULL,
  reverse_y_axis = FALSE,
  connect_dots = TRUE,
  dot_size = NULL
)
```

## Arguments

- .data:

  A data frame containing the data to be plotted.

- variables:

  A vector of column names in `.data` representing the variables to
  plot.

- group_by:

  A column in `.data` to group the data by (e.g., countries or regions).

- x_title:

  Optional. A title for the x-axis.

- legend_title:

  Optional. A title for the legend.

- reverse_y_axis:

  Logical. Whether to reverse the y-axis order. Default is FALSE.

- connect_dots:

  Logical. Whether to connect the dots with lines. Default is TRUE.

- dot_size:

  Optional. Controls the size of the dots (1 to 5, with 5 being the
  largest).

## Value

A ggplot object representing the dot plot.

## Examples

``` r
if (FALSE) { # \dontrun{
equiplot(
  .data = data,
  variables = c("Var1", "Var2", "Var3"),
  group_by = Country,
  x_title = "Percentage (%)",
  legend_title = "Variables",
  reverse_y_axis = TRUE
)
} # }
```
