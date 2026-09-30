# Plot Percent of Districts with Complete Data

Visualizes the percentage of districts with complete data for a selected
indicator over time.

## Usage

``` r
# S3 method for class 'cd_missing_district'
plot(
  x,
  indicator = NULL,
  title = NULL,
  x_axis = NULL,
  y_axis = NULL,
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

  Optional character string to override the default plot title.

- x_axis:

  Optional character string to override the x-axis label.

- y_axis:

  Optional character string to override the y-axis label.

- ...:

  Additional arguments reserved for future use.

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

The function produces a column chart showing the percent of districts
with complete data for the selected indicator by year.

## Examples

``` r
if (FALSE) { # \dontrun{
plot(missing_summary, indicator = "penta1")
} # }
```
