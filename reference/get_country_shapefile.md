# Load Country Shapefile for Mapping

Loads the shapefile of administrative boundaries for a given country and
level. Ensures geometries are valid and standardized to WGS84
(EPSG:4326).

## Usage

``` r
get_country_shapefile(country_iso, level = c("admin_level_1", "district"))
```

## Arguments

- country_iso:

  A string with the ISO3 code of the country (e.g., `"KEN"`).

- level:

  A character string specifying the admin level. One of:

  - `"admin_level_1"` (default): First-level admin areas

  - `"district"`: District-level admin areas

## Value

An `sf` object containing valid geometries for the specified country and
level.

## Examples

``` r
shapefile <- get_country_shapefile("KEN", level = "admin_level_1")
```
