# Plot National Health System Metrics

Creates a horizontal bar plot for either health system performance or
density metrics at national level.

## Usage

``` r
plot_national_health_metric(.data, metric = c("performance", "density"))
```

## Arguments

- .data:

  A one-row data frame containing national-level metrics.

- metric:

  Either 'performance' or 'density'.

## Value

A ggplot object.
