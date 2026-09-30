# Combine Immunization Coverage Data

`calculate_coverage` integrates immunization coverage data from three
sources: DHIS2 (District Health Information Software), survey-based
estimates, and WUENIC (WHO-UNICEF estimates). The combined dataset is
prepared for analysis at various administrative levels.

## Usage

``` r
calculate_coverage(.data, survey_data, wuenic_data, subnational_map = NULL)
```

## Arguments

- .data:

  A `cd_indicator_coverage` data frame with DHIS2 coverage metrics (as
  returned by
  [`calculate_indicator_coverage()`](calculate_indicator_coverage.md)).
  Its `admin_level` and `region` attributes determine the level of the
  result.

- survey_data:

  A data frame containing survey-based immunization estimates.

- wuenic_data:

  A data frame containing WHO-UNICEF (WUENIC) coverage estimates.

- subnational_map:

  (Optional) A data frame mapping subnational regions to parent regions,
  required for subnational-level analyses. Default is `NULL`.

## Value

A `cd_coverage` data frame containing harmonized coverage estimates for
each year from DHIS2, WUENIC, and survey data. Includes metadata for
administrative levels, regions, and denominators.

## Examples

``` r
if (FALSE) { # \dontrun{
calculate_coverage(precomputed_data, survey_df, wuenic_df)
} # }
```
