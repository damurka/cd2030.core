# Find the country of an Admin sheet without raising an error

Looks up the country named in the Admin sheet and returns its name and
ISO3 code. Unlike the lookup in [`new_countdown()`](new_countdown.md),
it does not stop with an error when the country cannot be resolved. Use
it to show the country before the sheets are merged.

## Usage

``` r
resolve_country_best_effort(admin_data)
```

## Arguments

- admin_data:

  A data frame. The cleaned Admin sheet, before the sheets are merged.

## Value

A list with two elements: `country` (the country's name as the package
spells it) and `country_iso` (its ISO3 code), both strings. Both are
`NULL` if the sheet has no `country` column or the country cannot be
resolved.

## Details

The country is resolved only when the `country` column holds exactly one
distinct value, ignoring missing values, and that value is close to a
name in the package's list of countries. This function does not validate
the sheet. Use [`check_single_country()`](check_single_country.md) and
[`check_country_recognized()`](check_country_recognized.md) for that.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
admin <- sheets$parts[[sheets$admin_sheet_name]]
resolve_country_best_effort(admin)
#> $country
#> [1] "Kenya"
#> 
#> $country_iso
#> [1] "KEN"
#> 

# Nothing is returned, and no error raised, for a country that is not recognized
admin$country <- "Atlantis"
resolve_country_best_effort(admin)
#> $country
#> NULL
#> 
#> $country_iso
#> NULL
#> 
```
