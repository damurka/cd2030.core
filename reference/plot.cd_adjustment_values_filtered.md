# Plot adjusted vs. unadjusted data for health indicators

`plot.cd_adjustment_values_filtered` creates a bar plot to compare the
unadjusted (raw) and adjusted values of health indicators over time. It
allows users to specify the indicator prefix and customize legend labels
for flexibility across different health data.

## Usage

``` r
# S3 method for class 'cd_adjustment_values_filtered'
plot(
  x,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  legend_labels = NULL,
  type = c("stacked", "change", "totals"),
  zoom = TRUE,
  options = NULL
)
```

## Arguments

- x:

  A data frame containing the `year` column and columns for the raw and
  adjusted values of health indicators (e.g., `ideliv_raw`,
  `ideliv_adj`). The indicator plotted is taken from its `indicator`
  attribute.

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

- legend_labels:

  A named list or vector of custom legend labels, with names `raw`
  (unadjusted data) and/or `adjusted`. Supplied entries replace the
  defaults ("N of `indicator` before adjustment" and "N of `indicator`
  after adjustment"). Default is `NULL`.

- type:

  With the adjustment's steps in `x`
  ([`generate_adjustment_values()`](generate_adjustment_values.md) with
  `settings`): `"stacked"` (the default) draws, each year, the reported
  count beside the adjusted count made of its parts – the reported
  count, what completeness added, what filling missing values added, and
  the outliers' correction (a correction that lowers the total drawn
  faded above the bar: the part taken away); `"change"` what each step
  changed, labelled with its share of the reported count; `"totals"` the
  counts side by side. Legend labels: `raw`, `completeness`, `outliers`,
  `missing` (and `adjusted` for `"totals"`).

- zoom:

  `"stacked"`: `TRUE` starts the axis near the smallest bar, so changes
  of a few percent can be seen (a note says where it starts); `FALSE`
  from zero.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A ggplot2 object showing the comparison of unadjusted and adjusted data
for the specified indicator over time.

## Details

This function helps visualize the difference between raw and adjusted
values of a given health indicator, aiding in the assessment of data
completeness and adjustments. The difference and percentage difference
are calculated within the function but are not directly shown on the
plot. Instead, the plot shows the actual unadjusted and adjusted values
side-by-side for each year.

## Examples

``` r
if (FALSE) { # \dontrun{
# Using default legend labels and title
plot.cd_adjustment_values_filtered(adjustments, indicator = "ideliv")

# Custom legend labels and title
plot.cd_adjustment_values_filtered(adjustments,
  indicator = "instlivebirths",
  title = "Customized Title",
  legend_labels = c("Original", "Modified")
)
} # }
```
