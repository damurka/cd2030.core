# Compute Service Utilization Metrics

Calculates annualized service utilization statistics including
outpatient (OPD), inpatient (IPD), case fatality rates, and under-5
service use, aggregated either at national or admin level 1.

## Usage

``` r
compute_service_utilization(
  .data,
  admin_level = c("national", "adminlevel_1", "district")
)
```

## Arguments

- .data:

  A data frame containing service and population indicators.

- admin_level:

  Either `"national"` or `"adminlevel_1"` to define the aggregation
  level.

## Value

A `cd_service_utilization` object (tibble subclass) with summarized and
derived indicators:

- OPD/IPD totals and rates

- Under-5 service utilization

- Case fatality rates

- Proportion of under-5 deaths

## Examples

``` r
if (FALSE) { # \dontrun{
  compute_service_utilization(dat, admin_level = "national")
} # }
```
