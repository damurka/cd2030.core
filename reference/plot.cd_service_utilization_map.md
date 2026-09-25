# Plot Service Utilization Indicators

Visualizes service utilization over time from a
`cd_service_utilization_map` object.

## Usage

``` r
# S3 method for class 'cd_service_utilization_map'
plot(x, ...)
```

## Arguments

- x:

  A `cd_service_utilization_map` object created by
  [`filter_service_utilization_map()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/filter_service_utilization_map.md).

- ...:

  not used

## Value

A `ggplot2` plot object.

## Examples

``` r
if (FALSE) { # \dontrun{
plot(filter_service_utilization_map(dat, indicator = 'opd'))
} # }
```
