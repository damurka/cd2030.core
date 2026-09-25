# Determine Grouping Columns for Administrative Levels

Returns the appropriate grouping column(s) based on the specified
administrative level. If a region is specified and
`admin_level = "adminlevel_1"`, districts are included to allow further
disaggregation within that region.

## Usage

``` r
get_admin_columns(admin_level, region = NULL)
```

## Arguments

- admin_level:

  A string. One of `"national"`, `"adminlevel_1"`, or `"district"`.

- region:

  Optional. If provided, must be used only with
  `admin_level = "adminlevel_1"`.

## Value

A character vector of column names to use in grouping. Returns:

- `NULL` for `"national"`

- `"adminlevel_1"` or `c("adminlevel_1", "district")` for
  `"adminlevel_1"`

- `c("adminlevel_1", "district")` for `"district"`

## Examples

``` r
get_admin_columns("national")
#> NULL
#> NULL

get_admin_columns("adminlevel_1")
#> [1] "adminlevel_1"
#> "adminlevel_1"

get_admin_columns("adminlevel_1", region = "Eastern")
#> [1] "adminlevel_1" "district"    
#> c("adminlevel_1", "district")

get_admin_columns("district")
#> [1] "adminlevel_1" "district"    
#> c("adminlevel_1", "district")
```
