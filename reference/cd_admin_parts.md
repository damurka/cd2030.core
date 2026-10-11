# Split the admin level filter's value into two reactives

[`cd_admin_level_server()`](cd_admin_level_ui.md) returns one reactive
holding both the admin level and the region. Pages usually hand the two
to their charts and tables as separate reactives, and this gives one
reactive for each.

## Usage

``` r
cd_admin_parts(admin)
```

## Arguments

- admin:

  The reactive [`cd_admin_level_server()`](cd_admin_level_ui.md)
  returned.

## Value

A list of two reactives:

- `admin_level`: the chosen admin level.

- `region`: the chosen area's name, or `NULL` when the region chip is
  not shown or "all" is chosen.

Both wait (as [`shiny::req()`](https://rdrr.io/pkg/shiny/man/req.html)
does) until `admin()` has a value.

## Examples

``` r
if (FALSE) { # \dontrun{
admin <- cd_admin_level_server("admin_level", cache, i18n)
parts <- cd_admin_parts(admin)
parts$admin_level()
parts$region()
} # }
```
