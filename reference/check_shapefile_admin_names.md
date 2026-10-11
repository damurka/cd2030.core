# Flag admin level 1 names with no matching shapefile region

Finds the admin level 1 names in the dataset that have no close match
among the regions of the shapefile. A dataset region without a shapefile
match cannot be shown on a map.

## Usage

``` r
check_shapefile_admin_names(shapefile, countdown_data, name_field = "NAME_1")
```

## Arguments

- shapefile:

  An `sf` object, or `NULL`. The country's shapefile: the one bundled
  with the package or one the user uploaded.

- countdown_data:

  A data frame. The dataset, with an `adminlevel_1` column.

- name_field:

  A string. The column of `shapefile` that holds the admin level 1
  names. Default is `"NAME_1"`, the column the bundled shapefiles use.

## Value

A tibble with one row per unmatched dataset name and columns `name` (the
dataset name), `suggestion` (the closest shapefile name) and `distance`
(the distance between them). It has no rows if every name matches, or if
`shapefile` is `NULL` or has no `name_field` column.

## Details

Names are compared without regard to case or accents, using the
Jaro-Winkler distance. A name is unmatched when its distance to the
closest shapefile name is 0.25 or more. Shapefile regions that match no
dataset name are not reported.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

# The bundled shapefile has the counties, the dataset's regions are the former provinces
check_shapefile_admin_names(cache$shapefile, cache$countdown_data)
#> # A tibble: 6 × 3
#>   name          suggestion distance
#>   <chr>         <chr>         <dbl>
#> 1 Rift Valley   Garissa       0.433
#> 2 Western       West Pokot    0.343
#> 3 Eastern       Makueni       0.381
#> 4 North Eastern Tana River    0.373
#> 5 Central       Mandera       0.381
#> 6 Coast         Mombasa       0.324

# With no shapefile there is nothing to compare
check_shapefile_admin_names(NULL, cache$countdown_data)
#> # A tibble: 0 × 3
#> # ℹ 3 variables: name <chr>, suggestion <chr>, distance <dbl>
```
