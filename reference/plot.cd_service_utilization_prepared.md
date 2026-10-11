# Plot filtered service utilization indicators

Generates a faceted map of service utilization metrics across
subnational units (admin level 1) for each available year. Uses spatial
polygons filled by the selected indicator.

## Usage

``` r
# S3 method for class 'cd_service_utilization_prepared'
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

  A `cd_service_utilization_prepared` object returned by
  [`prepare_mapping_service_utlization()`](prepare_mapping_service_utlization.md).

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

A `ggplot2` object representing faceted service utilization maps by
year.

## Details

Reads the indicator stored on `x` (`ratio_opd_u5_pop` or
`ratio_ipd_u5_pop`) and sets the data to WGS84 coordinates. Draws the
units with
[`geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html), filled
on a sequential colour scale from the palette stored on `x` (purple by
default), with one panel per year and the package's map theme.

## Examples

``` r
if (FALSE) { # \dontrun{
plot(filtered)
} # }
```
