# Choices of the admin level chip

The admin levels a page can be shown at, in the form a filter chip takes
them. [`cd_admin_level_ui()`](cd_admin_level_ui.md) builds its level
chip from this, and a page can use it to offer the same levels in a
control of its own.

## Usage

``` r
cd_admin_level_choices(include_national = FALSE)
```

## Arguments

- include_national:

  Logical. `TRUE` puts the national level first, before admin level 1
  and district. Default `FALSE`.

## Value

A named character vector. The values are the levels (`"national"` when
asked for, `"adminlevel_1"`, `"district"`) and the names are the
translation keys of their labels.

## Examples

``` r
cd_admin_level_choices()
#> opt_adminlevel_1     opt_district 
#>   "adminlevel_1"       "district" 
cd_admin_level_choices(include_national = TRUE)
#>     opt_national opt_adminlevel_1     opt_district 
#>       "national"   "adminlevel_1"       "district" 
```
