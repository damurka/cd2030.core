# Flag dataset admin-1 names that have no matching shapefile region

Same direction as
[`check_survey_admin_names()`](check_survey_admin_names.md) and for the
same reason: a dataset region with no shapefile match can't be shown on
a map at all, which is the actual problem worth flagging – not a
shapefile region with no dataset match, which is just an unused polygon.

## Usage

``` r
check_shapefile_admin_names(shapefile, countdown_data, name_field = "NAME_1")
```

## Arguments

- shapefile:

  The country's shapefile (`sf` object – either the package-bundled one,
  with its own `NAME_1` column, see
  [`get_country_shapefile()`](get_country_shapefile.md), or a
  user-uploaded one via
  [`read_shapefile_folder()`](read_shapefile_folder.md), whose admin-1
  name column is whatever `name_field` says).

- countdown_data:

  The dataset (`countdown_data`-shaped).

- name_field:

  Name of the column in `shapefile` holding admin-1 names. Default
  `"NAME_1"`, matching the bundled shapefile – a real uploaded one won't
  necessarily use that name, hence the parameter
  (`CacheConnection$shapefile_name_field`, set when the user picks it at
  upload).

## Value

A tibble of dataset admin-1 names with no shapefile match, each with its
closest suggestion (see `match_admin_names()`).
