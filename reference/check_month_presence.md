# Check that every district-year has all 12 months

Checks that each district has a row for every calendar month of every
year it appears in. A missing month leaves a gap in the monthly series
the analysis relies on.

## Usage

``` r
check_month_presence(.data)
```

## Arguments

- .data:

  A data frame with `district`, `year` and `month` columns, where
  `month` holds English month names. This is usually the merged and
  standardized dataset.

## Value

`NULL` if no month is missing. Otherwise a character vector of length
one, named `"x"`, with a message that lists the missing months as
`district year/month`. The message lists the first 10 and gives a count
of the rest.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
check_month_presence(data)
#> NULL

# One month of one district-year dropped
gap <- data$district == "Baringo" & data$year == 2023 & data$month == "March"
check_month_presence(data[!gap, ])
#>                                       x 
#> "Missing month(s): Baringo 2023/March." 
```
