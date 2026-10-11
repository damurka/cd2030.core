# Plot percent of districts with complete data

Visualizes the percentage of districts with complete data for a selected
indicator over time.

## Usage

``` r
# S3 method for class 'cd_missing_district'
plot(
  x,
  indicator = NULL,
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

  A `cd_missing_district` (or compatible) object containing
  district-level completeness summaries. Must include a `year` column
  and corresponding `mis_{indicator}` columns.

- indicator:

  A character string specifying the indicator to plot. Must be one of
  the values returned by
  [`get_all_indicators()`](get_all_indicators.md).

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

A `ggplot` object.

## Details

The function produces a column chart showing the percent of districts
with complete data for the selected indicator by year.

## Examples

``` r
if (FALSE) { # \dontrun{
plot(missing_summary, indicator = "penta1")
} # }
```
