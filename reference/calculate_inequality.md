# Analyze Subnational Health Coverage Data with Inequality Metrics

`calculate_inequality` computes subnational health coverage metrics and
evaluates disparities compared to reference averages (either national or
regional).

## Usage

``` r
calculate_inequality(subnational_data, reference_data)
```

## Arguments

- subnational_data:

  A data frame containing pre-calculated subnational health coverage
  data.

- reference_data:

  A data frame containing pre-calculated reference health coverage data
  (e.g., national data if analyzing `adminlevel_1`, or `adminlevel_1`
  data if analyzing `district`).

## Value

A tibble (`cd_inequality` object) containing:

- Subnational health coverage metrics.

- Population shares.

- MADM, MRDM, and related disparity metrics.
