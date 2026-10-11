# Plot outlier time series for a region

Displays a time-series plot of one indicator for a single region or
district, with outlier highlights.

## Usage

``` r
# S3 method for class 'cd_outlier_list'
plot(
  x,
  indicator = NULL,
  year = NULL,
  region = NULL,
  label = NULL,
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

  A `cd_outlier_list` object from
  [`list_outlier_units()`](list_outlier_units.md).

- indicator:

  The indicator to plot (for example `"penta1"`).

- year:

  Optional single year to plot. If `NULL` (the default), all years are
  shown.

- region:

  The name of the unit to plot.

- label:

  Optional named character vector overriding the legend labels.
  Recognised names are `reported`, `median`, `bounds` and `outliers`.

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

- Plots observed values, median trend, and 5xMAD range.

- Flags outliers in red.

## Examples

``` r
if (FALSE) { # \dontrun{
list_outlier_units(cd_data, "penta1") %>%
  plot(region_name = "Nakuru")
} # }
```
