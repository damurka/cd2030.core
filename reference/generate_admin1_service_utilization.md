# Generate Service Utilization Admin 1 Data

Generate Service Utilization Admin 1 Data

## Usage

``` r
generate_admin1_service_utilization(
  service_utilization,
  metric_type = c("opd", "ipd")
)
```

## Arguments

- service_utilization:

  Dataframe containing admin1 service utilization.

- metric_type:

  Character. Either "opd" or "ipd".

## Value

A tibble with class `cd_service_util_admin1`.
