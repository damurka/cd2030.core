# Check that each district has one admin level 1 name in the Admin sheet

Checks that no district is listed in the Admin sheet under more than one
admin level 1 unit. This is the part of
[`check_district_consistency()`](check_district_consistency.md) that can
run before the sheets are merged.

## Usage

``` r
check_admin_pairing_consistency(admin_data)
```

## Arguments

- admin_data:

  A data frame. The cleaned Admin sheet, before the sheets are merged,
  with `district` and `first_admin_level` columns.

## Value

`NULL` if every district has one admin level 1 name, or if the sheet
lacks either column. Otherwise a character vector of length one, named
`"x"`, with a message that lists the districts.

## Details

Admin level 1 names are compared without regard to case or extra spaces.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
admin <- sheets$parts[[sheets$admin_sheet_name]]
check_admin_pairing_consistency(admin)
#> NULL

# The first district listed a second time, under another region
again <- admin[1, ]
again$first_admin_level <- "Western"
check_admin_pairing_consistency(rbind(admin, again))
#>                                                                            x 
#> "District(s) with an inconsistent admin-1 name in the Admin sheet: Baringo." 
```
