# Which adjustment steps an indicator gets

Whether completeness (a k above 0), outlier correction and filling
missing values apply to an indicator in at least one district of the
data (or of one area), with the settings: a step no district gets is
off.

## Usage

``` r
adjustment_steps_used(
  settings,
  .data,
  indicator,
  area = NULL,
  level = c("adminlevel_1", "district")
)
```

## Arguments

- settings:

  The settings list.

- .data:

  A `cd_data` tibble (its districts and regions).

- indicator:

  The indicator.

- area, level:

  One area only (as
  [`generate_adjustment_values()`](generate_adjustment_values.md));
  `NULL`, all.

## Value

A named logical: `completeness`, `outliers`, `missing`.
