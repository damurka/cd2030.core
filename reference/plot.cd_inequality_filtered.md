# Plot Subnational Health Coverage Analysis

Generates a plot to visualize health coverage data across subnational
units, distinguishing between the national mean and subnational
coverage. The Mean Absolute Difference to the Mean (MADM) is displayed
as an indicator on the y-axis.

## Usage

``` r
# S3 method for class 'cd_inequality_filtered'
plot(x, ...)
```

## Arguments

- x:

  A `cd_inequality_filtered` object returned by
  [`filter_inequality()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/filter_inequality.md).

- ...:

  Additional arguments passed to the plotting function.

## Value

A `ggplot` object displaying the subnational health coverage plot.

## Examples

``` r
if (FALSE) { # \dontrun{
data <- filter_inequality(.data, "Kenya",
  admin_level = "district",
  indicator = "measles1", denominator = "penta1"
)
plot(data)
} # }
```
