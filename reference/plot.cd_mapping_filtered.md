# Plot subnational coverage maps by indicator

Creates a faceted `ggplot2` map showing subnational coverage levels of a
health indicator, colored using a gradient palette. Coverage values are
drawn from a `cd_mapping_filtered` object, typically filtered for a
specific indicator and denominator.

## Usage

``` r
# S3 method for class 'cd_mapping_filtered'
plot(
  x,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  A `cd_mapping_filtered` object. Created using
  [`select_mapping_data()`](select_mapping_data.md), and must include
  spatial geometry and metadata attributes (`indicator`, `palette`,
  `column`).

- title:

  The chart's title.

- subtitle:

  The line under the title.

- caption:

  The note under the chart.

- x_title:

  The title of the horizontal axis.

- y_title:

  The title of the vertical axis.

- legend_title:

  The title of the legend.

- ...:

  Chart options by name (see
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)):
  background, fonts, sizes, axes, grid, legend, colours. Other arguments
  are ignored.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A `ggplot` object visualizing the spatial distribution of the selected
indicator by region and year.

## See also

[`select_mapping_data()`](select_mapping_data.md),
[`get_mapping_data()`](get_mapping_data.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Assuming `map_data` is filtered with select_mapping_data()
plot(
  map_data,
  title = "Penta 1 Coverage by Region",
  legend = "Coverage (%)",
  caption = "Source: DHIS2 2024"
)
} # }
```
