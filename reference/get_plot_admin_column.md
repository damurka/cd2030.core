# Determine the Administrative Column to Use for Plotting

Returns the appropriate administrative unit column to use on plots based
on the selected administrative level and whether a region is specified.
Used to decide whether to facet or label plots by district or by
adminlevel_1.

## Usage

``` r
get_plot_admin_column(admin_level, region = NULL)
```

## Arguments

- admin_level:

  A string. Either `"adminlevel_1"` or `"district"`.

- region:

  Optional. A region name or `NULL`. If specified, districts will be
  used for plotting.

## Value

A string: either `"district"` or `"adminlevel_1"`.

## Examples

``` r
get_plot_admin_column("adminlevel_1")
#> [1] "adminlevel_1"
#> "adminlevel_1"

get_plot_admin_column("adminlevel_1", region = "Nairobi")
#> [1] "district"
#> "district"

get_plot_admin_column("district")
#> [1] "district"
#> "district"
```
