# Plot Adjusted vs. Unadjusted Data for Health Indicators

`plot.cd_adjustment_values` creates a bar plot to compare the unadjusted
(raw) and adjusted values of health indicators over time. It allows
users to specify the indicator prefix and customize legend labels for
flexibility across different health data.

## Usage

``` r
# S3 method for class 'cd_adjustment_values'
plot(x, indicator = NULL, title = NULL, legend_labels = NULL, ...)
```

## Arguments

- x:

  A data frame containing the `year` column and columns for the raw and
  adjusted values of health indicators (e.g., `ideliv_raw`,
  `ideliv_adj`).

- indicator:

  A character string specifying the prefix of the indicator to plot
  (e.g., `"ideliv"`). Only the provided indicators will be plotted.

- title:

  A character string for the plot title. If `NULL`, a default title
  based on the indicator is generated.

- legend_labels:

  A character vector of length 2 specifying custom labels for the
  legend. The first element is used for the unadjusted (raw) data, and
  the second element is for the adjusted data. If `NULL`, default labels
  ("N of `indicator` before adjustment" and "N of `indicator` after
  adjustment") are generated.

- ...:

  Additional arguments (currently not used).

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
plot.cd_adjustment_values(adjustments, indicator = "ideliv")

# Custom legend labels and title
plot.cd_adjustment_values(adjustments,
  indicator = "instlivebirths",
  title = "Customized Title",
  legend_labels = c("Original", "Modified")
)
} # }
```
