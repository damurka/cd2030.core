# Check that every district-year has all 12 months, before merging

Runs [`check_month_presence()`](check_month_presence.md) on the service
sheets, stacked together, before the sheets are merged. A district-year
passes when its 12 months are present across the service sheets taken
together.

## Usage

``` r
check_month_presence_presheet(parts, service_sheet_names)
```

## Arguments

- parts:

  A named list of cleaned per-sheet tibbles
  (`load_excel_parts()$parts`).

- service_sheet_names:

  A character vector. The names of the service data sheets within
  `parts`.

## Value

`NULL` if no month is missing. Otherwise a character vector of length
one, named `"x"`, with a message that lists the missing months as
`district year/month`. The message lists the first 10 and gives a count
of the rest.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
check_month_presence_presheet(sheets$parts, sheets$service_sheet_names)
#> NULL

# March left out of every service sheet
parts <- sheets$parts
for (sheet in sheets$service_sheet_names) {
  parts[[sheet]] <- parts[[sheet]][parts[[sheet]]$month != "March", ]
}
check_month_presence_presheet(parts, sheets$service_sheet_names)
#>                                                                                                                                                                                                                                        x 
#> "Missing month(s): Baringo 2019/March, Bomet 2019/March, Bungoma 2019/March, Busia 2019/March, Elgeyo Marakwet 2019/March, Embu 2019/March, Garissa 2019/March, Homa Bay 2019/March, Isiolo 2019/March, Kajiado 2019/March (+225 more)." 
```
