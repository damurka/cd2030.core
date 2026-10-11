# Get mapping data for subnational coverage analysis

Merges coverage data with a country's shapefile to enable spatial
visualization of health indicators. It joins subnational (admin level 1)
indicator coverage that has already been calculated with the geographic
features of each unit.

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
