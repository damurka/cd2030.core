# Check that the Admin sheet has its required columns

Checks that the Admin sheet has the `country` and `first_admin_level`
columns. Run it on the sheet before the sheets are merged, so that a
missing column is reported by name.

## Usage

``` r
check_admin_columns(admin_data)
```

## Arguments

- admin_data:

  A data frame. The cleaned Admin sheet, before the sheets are merged
  (the admin element of `load_excel_parts()$parts`).

## Value

`NULL` if both columns are present. Otherwise a character vector of
length one, named `"x"`, with a message that lists the missing columns.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
admin <- sheets$parts[[sheets$admin_sheet_name]]
check_admin_columns(admin)
#> NULL

# A sheet without its country column
check_admin_columns(admin[setdiff(names(admin), "country")])
#>                                                     x 
#> "The Admin_data sheet is missing column(s): country." 
```
