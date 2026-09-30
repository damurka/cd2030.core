# Compute Aggregated Numerators for Health Indicators

`compute_indicator_numerator` aggregates the numerators for specified
health indicators across different administrative levels, such as
national, and and subnational The function groups data by year and the
specified administrative level and calculates the sum of the selected
indicators.

## Usage

``` r
compute_indicator_numerator(
  .data,
  admin_level = c("national", "adminlevel_1", "district"),
  region = NULL,
  show_district = TRUE
)
```

## Arguments

- .data:

  A tibble of class `cd_data` containing health indicator data. The
  dataset must include columns for the relevant indicators, which are
  organized by the `indicator_groups` attribute.

- admin_level:

  Character. Specifies the administrative level for aggregation.
  Available options are: `"national"`, `"adminlevel_1"` and
  `"district"`. Default is `"national"`.

- region:

  Optional name of an `adminlevel_1` region. If supplied, only that
  region's rows are aggregated. Only valid with
  `admin_level = "adminlevel_1"`. Default is `NULL`.

- show_district:

  Logical. When `region` is supplied, whether to aggregate by district
  within the region (`TRUE`, the default) or for the region as a whole.

## Value

A tibble containing yearly aggregated totals for each indicator at the
specified administrative level.

## Examples

``` r
if (FALSE) { # \dontrun{
# Calculate national-level totals for health indicators
national_totals <- compute_indicator_numerator(dhis2_data, admin_level = "national")

# Calculate administrative-level 1 totals for health indicators
region_totals <- compute_indicator_numerator(dhis2_data, admin_level = "adminlevel_1")

# Calculate district-level totals for health indicators
district_totals <- compute_indicator_numerator(dhis2_data, admin_level = "district")
} # }
```
