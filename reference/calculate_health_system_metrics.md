# Calculate Health System Metrics

Aggregates data at national, admin level 1, or district level and
computes ratios and performance scores.

## Usage

``` r
calculate_health_system_metrics(
  .data,
  admin_level = c("national", "adminlevel_1", "district")
)
```

## Arguments

- .data:

  A data frame with health system indicators and population data.

- admin_level:

  One of 'national', 'adminlevel_1', or 'district'.

## Value

A summarized data frame with calculated metrics: ratios (facility, beds,
workforce, service use) and performance scores.
