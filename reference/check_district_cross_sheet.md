# Check that districts match between the Admin sheet and the others

Compares the districts in the Admin sheet with the districts in all the
other sheets, in both directions. Run it on the unmerged sheets: merging
keeps only the districts of one sheet, so a district that is missing
from that sheet would be dropped without notice.

## Usage

``` r
check_district_cross_sheet(parts, admin_sheet_name)
```

## Arguments

- parts:

  A named list of cleaned per-sheet tibbles
  (`load_excel_parts()$parts`).

- admin_sheet_name:

  A string. The name of the Admin sheet within `parts`.

## Value

`NULL` if the districts match, or if the Admin sheet has no `district`
column. Otherwise a character vector with one or two messages, each
named `"x"`: one that lists the districts found in another sheet but not
in the Admin sheet, each with the sheets it was found in, and one that
lists the Admin sheet districts found in no other sheet.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
check_district_cross_sheet(sheets$parts, sheets$admin_sheet_name)
#> NULL

# A district renamed in the Admin sheet only
parts <- sheets$parts
parts[[sheets$admin_sheet_name]]$district[1] <- "Baringo County"
check_district_cross_sheet(parts, sheets$admin_sheet_name)
#>                                                                                                                                                                 x 
#> "District(s) present in the data but missing from Admin_data: Baringo (Service_data_1, Service_data_2, Service_data_3, Reporting_completeness, Population_data)." 
#>                                                                                                                                                                 x 
#>                                                                                         "District(s) in Admin_data not found in any other sheet: Baringo County." 
```
