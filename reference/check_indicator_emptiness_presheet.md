# Flag indicators that have no data, before merging

Runs [`check_indicator_emptiness()`](check_indicator_emptiness.md) on
the service sheets, stacked together, before the sheets are merged. An
indicator is flagged when it is missing in every row of every service
sheet.

## Usage

``` r
check_indicator_emptiness_presheet(parts, service_sheet_names)
```

## Arguments

- parts:

  A named list of cleaned per-sheet tibbles
  (`load_excel_parts()$parts`).

- service_sheet_names:

  A character vector. The names of the service data sheets within
  `parts`.

## Value

A character vector of the names of the empty indicators. It has length
zero if there are none.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
check_indicator_emptiness_presheet(sheets$parts, sheets$service_sheet_names)
#> [1] "anc_1trimester"
```
