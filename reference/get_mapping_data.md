# Get Mapping Data for Subnational Coverage Analysis

Merges coverage data with a country's shapefile to enable spatial
visualization of health indicators. It computes subnational indicator
coverage using UN estimates and survey rates, and joins results with
geographic features.

## Usage

``` r
get_mapping_data(.data, subnational_map = NULL)
```

## Arguments

- .data:

  A `cd_population` object (for example the output of
  [`calculate_indicator_coverage()`](calculate_indicator_coverage.md))
  calculated at `admin_level = "adminlevel_1"`. Must include metadata
  attributes `iso3` (ISO3 country code) and `admin_level`.

- subnational_map:

  Optional. A data frame to join with the shapefile to add metadata.

## Value

A `tibble` of class `"cd_mapping"` that combines the input data with
shapefile geometries.

## Examples

``` r
if (FALSE) { # \dontrun{
coverage <- calculate_indicator_coverage(data, admin_level = "adminlevel_1")
get_mapping_data(coverage)
} # }
```
