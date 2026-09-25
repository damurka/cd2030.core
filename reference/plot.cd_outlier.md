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
  ...
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

- ...:

  Not used.

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
