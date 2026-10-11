# Plot filtered institutional mortality rates

Visualizes institutional mortality rates (`MMR` or `SBR`) across regions
using filled geographic polygons. Facets the map by year and applies a
color gradient by value.

## Usage

``` r
# S3 method for class 'cd_mortality_summary_filtered'
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

  A `cd_mortality_summary_filtered` object.

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

A `ggplot2` object: the map, with the chart options applied.

## Details

Takes the default title and legend title from the `indicator` attribute
of `x` and sets the geometry to WGS84 coordinates. Draws the regions as
filled polygons with
[`geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html), one
panel per year, on a sequential colour scale from the palette stored on
`x` (`Reds` by default), with gray for missing values.

## Examples

``` r
if (FALSE) { # \dontrun{
filtered <- select_mortality_summary(mortality_data, "UGA", indicator = "mmr",
                                     plot_year = 2020:2022)
plot(filtered)
} # }
```
