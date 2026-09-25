# Plot Completeness of Facility Reporting Ratios

Calculates and plots the estimated completeness of facility reporting
for maternal deaths or stillbirths based on UN estimates and assumed
community-to-institution ratios.

## Usage

``` r
# S3 method for class 'cd_mortality_ratio_summarised'
plot(x, ...)
```

## Arguments

- x:

  A `cd_mortality_ratio_summarised ` object from completeness
  estimation.

- ...:

  Additional arguments (not used).

## Value

A ggplot object with ratio lines, labels, and reference points.
