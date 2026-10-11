# Check that the Admin sheet names one country

Checks that the `country` column of the Admin sheet holds no more than
one distinct value. A dataset must belong to one country, so run this
before the sheets are merged to get a message that lists the values
found.

## Usage

``` r
check_single_country(admin_data)
```

## Arguments

- admin_data:

  A data frame. The cleaned Admin sheet, with a `country` column.

## Value

`NULL` if the sheet has at most one country value. Otherwise a character
vector of length one, named `"x"`, with a message that lists the values.

## Details

Missing values are ignored. A sheet with no country value at all passes
this check.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
admin <- sheets$parts[[sheets$admin_sheet_name]]
check_single_country(admin)
#> NULL

# A row that belongs to another country
admin$country[1] <- "Uganda"
check_single_country(admin)
#>                                                                                   x 
#> "The Admin_data sheet's country column has more than one value: \"Uganda, Kenya\"." 
```
