# Visualize summary of outlier detection

Plots annual trends or heat maps of non-outlier rates for immunization
indicators at subnational levels.

## Usage

``` r
# S3 method for class 'cd_outlier'
plot(
  x,
  selection_type = c("region", "indicator", "heat_map"),
  indicator = NULL,
  threshold = .cd_method$data_quality$reporting_threshold,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  indicator_labels = NULL,
  options = NULL
)
```

## Arguments

- x:

  A `cd_outlier` object with precomputed outlier flags.

- selection_type:

  One of `"region"`, `"indicator"`, or `"heat_map"`:

  - `"region"`: Non-outlier rates by year and region.

  - `"indicator"`: Yearly average non-outlier rate per indicator.

  - `"heat_map"`: Year-by-unit heat map of all or selected indicators.

- indicator:

  Optional. Specific indicator name (e.g., `"penta3"`). Required for
  `"region"` view.

- threshold:

  Numeric. Upper cut-off (in percent) of the middle colour band; values
  above it are shown as good. Default is `90`.

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

- indicator_labels:

  (Optional) A named vector or list, indicator code -\> label, for the
  axis that names indicators (see
  [`cd_indicator_labels()`](cd_indicator_labels.md), which gives them
  translated). By default the English labels.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A `ggplot` object.

## Details

- Values are assumed to be percentages of non-outliers (i.e., 100 = no
  outliers).

- `"region"` and `"indicator"` use bar plots with gradient fill.

- `"heat_map"` shows indicator values by year and region.

## Examples

``` r
if (FALSE) { # \dontrun{
plot(outlier_data, selection_type = "region", indicator = "penta3")
plot(outlier_data, selection_type = "heat_map")
} # }
```
