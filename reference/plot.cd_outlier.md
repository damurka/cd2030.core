# Visualize Summary of Outlier Detection

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
  x_axis = NULL,
  y_axis = NULL,
  legend = NULL,
  ...,
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

  Optional plot title. Defaults to a title based on `selection_type`.

- x_axis, y_axis:

  Optional x- and y-axis titles. Default to `"Year"` and a "Percent
  non-outliers" label.

- legend:

  Optional legend title. Defaults to a "Percent non-outliers" label.

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
