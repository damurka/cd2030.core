# Plot Outlier Time Series for a Region

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
  title = NULL,
  x_axis = NULL,
  y_axis = NULL,
  legend = NULL,
  label = NULL,
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

- title:

  Optional plot title. Defaults to a title naming the indicator, unit
  and year.

- x_axis, y_axis:

  Optional x- and y-axis titles. Default to `"Month"` and the indicator
  name.

- legend:

  Optional legend title. Default is `NULL` (no title).

- label:

  Optional named character vector overriding the legend labels.
  Recognised names are `reported`, `median`, `bounds` and `outliers`.

- ...:

  Not used.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

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
