# Flag months that are written in more than one way

Finds the calendar months that the service sheets label with more than
one text, for example `"January"` in one sheet and `"Janvier"` in
another. The data loads correctly either way, because the month names
are standardized. The result shows that the workbook mixes languages or
spellings, which is worth knowing about how it was put together.

## Usage

``` r
check_month_language_consistency(parts, service_sheet_names)
```

## Arguments

- parts:

  A named list of cleaned per-sheet tibbles
  (`load_excel_parts()$parts`).

- service_sheet_names:

  A character vector. The names of the service data sheets within
  `parts`.

## Value

A tibble with one row per month that has more than one distinct original
text, and columns `month` (the standardized month name) and `variants`
(the distinct original texts, sorted and separated by commas). It has no
rows if no month qualifies, or if the service sheets lack a `month` or
`raw_month` column.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
check_month_language_consistency(sheets$parts, sheets$service_sheet_names)
#> # A tibble: 0 × 2
#> # ℹ 2 variables: month <chr>, variants <chr>

# One service sheet that names January in French
parts <- sheets$parts
sheet <- sheets$service_sheet_names[2]
parts[[sheet]]$raw_month[parts[[sheet]]$month == "January"] <- "Janvier"
check_month_language_consistency(parts, sheets$service_sheet_names)
#> # A tibble: 1 × 2
#>   month   variants        
#>   <chr>   <chr>           
#> 1 January January, Janvier
```
