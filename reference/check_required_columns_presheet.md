# Check that the sheets have the columns an indicator group needs

Checks the unmerged sheets for every column the indicator group
requires: the group's indicators, a reporting rate for each of its
categories, and the population columns. It reports the same missing
columns that [`new_countdown()`](new_countdown.md) stops on, before the
sheets are merged.

## Usage

``` r
check_required_columns_presheet(parts, group = get_selected_group())
```

## Arguments

- parts:

  A named list of cleaned per-sheet tibbles
  (`load_excel_parts()$parts`).

- group:

  A string. The indicator group to check against. Default is the
  selected group.

## Value

`NULL` if no required column is missing, or if the sheets have no
columns. Otherwise a character vector with up to three messages, each
named `"x"`: one for the population columns, one for the reporting rate
columns and one for the indicator columns.

## Details

Only the column names are read. They are compared as they will be once
the sheets are merged and standardized, so a column that standardization
renames or computes is not reported as missing. The messages use the
names the workbook uses.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
check_required_columns_presheet(sheets$parts, group = "rmncah")
#> NULL

# A Population sheet without its growth rate column
parts <- sheets$parts
parts[[sheets$population_sheet_name]]$pop_growth_rate <- NULL
check_required_columns_presheet(parts, group = "rmncah")
#>                                                                  x 
#> "The Population_data sheet is missing column(s): pop_growth_rate." 
```
