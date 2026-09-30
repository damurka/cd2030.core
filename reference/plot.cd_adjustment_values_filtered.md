# Plot Adjusted vs. Unadjusted Data for Health Indicators

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
  x_axis = NULL,
  y_axis = NULL,
  legend_labels = NULL,
  ...,
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

  A character string for the plot title. If `NULL`, a default title
  based on the indicator is generated.

- x_axis, y_axis:

  Optional x- and y-axis titles. Default is `NULL`.

- legend_labels:

  A named list or vector of custom legend labels, with names `raw`
  (unadjusted data) and/or `adjusted`. Supplied entries replace the
  defaults ("N of `indicator` before adjustment" and "N of `indicator`
  after adjustment"). Default is `NULL`.

- ...:

  Additional arguments (currently not used).

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

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

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
