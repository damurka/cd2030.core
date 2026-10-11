# Plot ratios summary for indicator ratios summary object

Generates a bar plot for a `cd_ratios_summary` object, displaying the
calculated indicator ratios for each year. It allows for visual
comparison across years, showing how each indicator ratio changes over
time.

## Usage

``` r
# S3 method for class 'cd_ratios_summary'
plot(
  x,
  x_labels = NULL,
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

  A `cd_ratios_summary` object created by the `calculate_ratios_summary`
  function. It should contain a `year` column and one or more columns
  with names starting with `"Ratio"`, representing the calculated
  indicator ratios.

- x_labels:

  Optional named list or vector of x-axis category labels, keyed by
  ratio name (`anc1_penta1`, `opv1_opv3`, `penta1_penta3`). Supplied
  entries replace the defaults.

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

A `ggplot` object representing a bar plot of indicator ratios by year.

## Details

This function provides a visual summary of indicator ratios, with each
ratio displayed as a bar for each year. The `Expected Ratio` row is
included if available, allowing for easy comparison of actual ratios
against expected values. The bars are grouped by year, with distinct
colors representing each year for clear differentiation.

## Examples

``` r
if (FALSE) { # \dontrun{
# Assuming `cd_ratios_summary` is the object returned by `calculate_ratios_summary`
plot(cd_ratios_summary)
} # }
```
