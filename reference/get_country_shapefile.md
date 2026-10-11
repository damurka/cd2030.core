# Load country shapefile for mapping

Loads the admin level 1 boundaries of a country from the shapefiles that
come with the package. Ensures geometries are valid and standardized to
WGS84 (EPSG:4326).

## Usage

``` r
get_country_shapefile(country_iso, level = c("admin_level_1", "district"))
```

## Arguments

- country_iso:

  A string with the ISO3 code of the country (e.g., `"KEN"`).

- level:

  A character string specifying the admin level: `"admin_level_1"`
  (default) or `"district"`. The package has admin level 1 boundaries
  only, so both values give the admin level 1 areas.

## Value

An `sf` object containing valid geometries of the country's admin level
1 areas.

## Examples

``` r
shapefile <- get_country_shapefile("KEN", level = "admin_level_1")
```
