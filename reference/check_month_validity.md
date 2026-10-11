# Check that every month value is a recognized month

Checks the merged data for rows whose month could not be read as a
calendar month, for example because of a typo or a month name in a
language that is not supported. Such rows have a missing `month` and
would otherwise stay in the data unnoticed.

## Usage

``` r
check_month_validity(.data)
```

## Arguments

- .data:

  A data frame. The merged and standardized dataset, with a `month`
  column and optionally a `raw_month` column.

## Value

`NULL` if every month is recognized, or if `.data` has no `month`
column. Otherwise a character vector of length one, named `"x"`, with
the message.

## Details

A row is a problem when its `month` is `NA`. If `.data` has a
`raw_month` column (the month text as it was in the workbook), the
message lists the distinct unrecognized values. If it does not, as with
a Stata master dataset, or if those values are all missing, the message
gives the number of affected rows instead.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
check_month_validity(data)
#> NULL

# Months that could not be read are missing after loading
data$month[1:3] <- NA
check_month_validity(data)
#>                                                      x 
#> "3 row(s) have a missing or unrecognized month value." 
```
