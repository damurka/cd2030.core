# Write every data quality result to an Excel workbook

Two sheets: `Summary` (each check, whether it passed, how many issues)
and `Issues` (one row per issue).

## Usage

``` r
write_quality_issues(results, path, labels = NULL)
```

## Arguments

- results:

  A named list. What
  [`run_all_quality_checks()`](run_all_quality_checks.md) returns.

- path:

  Where to write the `.xlsx`.

- labels:

  An optional named character vector that maps a check's key
  (`names(results)`) to the name to show for it, for example a
  translated name. A check without a label gets a plain English name.

## Value

`path`, invisibly.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
results <- run_all_quality_checks(cache)
file <- write_quality_issues(results, tempfile(fileext = ".xlsx"))
openxlsx::read.xlsx(file, sheet = "Issues")
#>                   check      severity
#> 1      Empty indicators informational
#> 2 Shapefile admin names       mapping
#> 3 Shapefile admin names       mapping
#> 4 Shapefile admin names       mapping
#> 5 Shapefile admin names       mapping
#> 6 Shapefile admin names       mapping
#> 7 Shapefile admin names       mapping
#>                                                              issue
#> 1                                                   anc_1trimester
#> 2 name: Central      ; suggestion: Mandera   ; distance: 0.3809524
#> 3 name: Coast        ; suggestion: Mombasa   ; distance: 0.3238095
#> 4 name: Eastern      ; suggestion: Makueni   ; distance: 0.3809524
#> 5 name: North Eastern; suggestion: Tana River; distance: 0.3728938
#> 6 name: Rift Valley  ; suggestion: Garissa   ; distance: 0.4329004
#> 7 name: Western      ; suggestion: West Pokot; distance: 0.3428571
```
