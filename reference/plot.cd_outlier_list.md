# Plot Outlier Time Series for a Region

Displays a time-series plot of one indicator for a single region or
district, with outlier highlights.

## Usage

``` r
# S3 method for class 'cd_outlier_list'
plot(x, region_name = NULL, ...)
```

## Arguments

- x:

  A `cd_outlier_list` object from
  [`list_outlier_units()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/list_outlier_units.md).

- region_name:

  The name of the unit to plot.

- ...:

  Not used.

## Value

A `ggplot` object.

## Details

- Plots observed values, median trend, and 5×MAD range.

- Flags outliers in red.

## Examples

``` r
if (FALSE) { # \dontrun{
list_outlier_units(cd_data, "penta1") %>%
  plot(region_name = "Nakuru")
} # }
```
