# Check that every month value is a recognized month, before merging

Checks the service sheets, before they are merged, for rows whose month
could not be read as a calendar month, for example because of a typo or
a month name in a language that is not supported.

## Usage

``` r
check_month_validity_presheet(parts, service_sheet_names)
```

## Arguments

- parts:

  A named list of cleaned per-sheet tibbles
  (`load_excel_parts()$parts`).

- service_sheet_names:

  A character vector. The names of the service data sheets within
  `parts`.

## Value

`NULL` if every month is recognized, or if the service sheets have no
`month` column. Otherwise a character vector of length one, named `"x"`,
with the message.

## Details

A row is a problem when its `month` is `NA`. If the sheets have a
`raw_month` column (the month text as it was in the workbook, which
[`load_excel_parts()`](load_excel_parts.md) keeps), the message lists
the distinct unrecognized values. If they do not, or if those values are
all missing, the message gives the number of affected rows instead.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
check_month_validity_presheet(sheets$parts, sheets$service_sheet_names)
#> NULL

# A month the workbook misspells is read as missing
parts <- sheets$parts
sheet <- sheets$service_sheet_names[1]
typo <- parts[[sheet]]$month == "March"
parts[[sheet]]$raw_month[typo] <- "Mrch"
parts[[sheet]]$month[typo] <- NA
check_month_validity_presheet(parts, sheets$service_sheet_names)
#>                                                                         x 
#> "Unrecognized month value(s) (typo, different language, etc.): \"Mrch\"." 
```
