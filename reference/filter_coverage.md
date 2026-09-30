# Filter and Reshape Coverage Data

`filter_coverage` extracts specific coverage indicators and denominators
from a combined coverage dataset, applies regional filtering, and
reshapes the data for analysis and visualisation.

## Usage

``` r
filter_coverage(
  .data,
  indicator,
  denominator = c("dhis2", "anc1", "penta1", "penta1derived", "anc1derived"),
  region = NULL
)
```

## Arguments

- .data:

  A `cd_coverage` data frame with combined immunization coverage data.

- indicator:

  Coverage indicators to include (e.g., `"penta3"`, `"measles1"`).

- denominator:

  Denominator sources for coverage calculations (e.g., `"dhis2"`).

- region:

  Name of the subnational unit (at the data's `admin_level`) to keep.
  Required for subnational data that was not already calculated for a
  single region; must be `NULL` for national data or data calculated for
  a region. Default is `NULL`.

## Value

A reshaped data frame with filtered indicators and denominators.

## Examples

``` r
if (FALSE) { # \dontrun{
filter_coverage(combined_data, c("penta3", "measles1"), "dhis2", "Central Province")
} # }
```
