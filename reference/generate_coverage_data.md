# Generate Coverage Data for Continuum of Care

Processes and shapes raw coverage data into a clean, long format
optimized for continuum-of-care plotting. It dynamically builds regex
patterns based on the spatial level and data type to extract relevant
columns:

- **National**: Extracts Facility, Survey, and WUENIC data.

- **Subnational**: Extracts Facility data only.

The function automatically filters for the absolute latest available
data point per indicator-source combination and converts the `indicator`
column into an ordered factor representing the lifecycle stages to
ensure plots are always ordered correctly.

## Usage

``` r
generate_coverage_data(
  .data,
  type = c("maternal", "child"),
  denominator = c("dhis2", "anc1", "penta1", "penta1derived", "anc1derived")
)
```

## Arguments

- .data:

  A data frame/tibble originating from
  [`calculate_coverage()`](calculate_coverage.md). Must contain an
  `admin_level` attribute.

- type:

  Character. Specifies whether to extract 'maternal' or 'child'
  indicators.

- denominator:

  Character. The denominator to use for the specified indicator type.
  Options include "dhis2", "anc1", "penta1", "penta1derived", or
  "anc1derived".

## Value

A tibble of class `cd_coverage_selected` containing the latest coverage
values, categorized sources, and ordered indicators. Retains
`admin_level` and `admin_col` attributes for downstream plotting.
