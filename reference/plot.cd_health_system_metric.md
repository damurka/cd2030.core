# Plot Health Metrics for Admin 1 Units

Plots individual health system indicators by admin 1 level and compares
with national value or target.

## Usage

``` r
# S3 method for class 'cd_health_system_metric'
plot(
  x,
  indicator = c("ratio_fac_pop", "ratio_hos_pop", "ratio_hstaff_pop", "ratio_bed_pop"),
  national_score = NULL,
  target = NULL
)
```

## Arguments

- x:

  Data frame containing admin 1 level indicators.

- indicator:

  A single metric to plot. Options include score\_\* and ratio\_\*.

- national_score:

  National benchmark for dashed comparison line.

- target:

  Optional target value for additional line.

## Value

A ggplot object.
