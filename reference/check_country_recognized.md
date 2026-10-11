# Check that the country in the Admin sheet is recognized

Checks that the country named in the Admin sheet is one the package
supports. Run it before the sheets are merged to report an unrecognized
country early. [`new_countdown()`](new_countdown.md) stops with an error
on the same problem.

## Usage

``` r
check_country_recognized(parts, admin_sheet_name)
```

## Arguments

- parts:

  A named list of cleaned per-sheet tibbles
  (`load_excel_parts()$parts`).

- admin_sheet_name:

  A string. The name of the Admin sheet within `parts`.

## Value

`NULL` if the country is recognized, if the Admin sheet has no `country`
column, or if the column does not hold exactly one value. Otherwise a
character vector of length one, named `"x"`, with a message that gives
the unrecognized name.

## Details

The check applies only when the `country` column holds exactly one
distinct value, ignoring missing values. More than one value is reported
by [`check_single_country()`](check_single_country.md). The name is
recognized when it is close to a name in the package's list of
countries.

## See also

[`check_required_columns_presheet()`](check_required_columns_presheet.md)

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
check_country_recognized(sheets$parts, sheets$admin_sheet_name)
#> NULL

# A country the package has no reference data for
parts <- sheets$parts
parts[[sheets$admin_sheet_name]]$country <- "Atlantis"
check_country_recognized(parts, sheets$admin_sheet_name)
#>                                                                x 
#> "The country name \"Atlantis\" in Admin_data is not recognized." 
```
