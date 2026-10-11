# Check that districts are consistent across the dataset

Checks two things in the merged data: that each district belongs to one
admin level 1 unit, and that each district appears in every year of the
data. A district that fails either test has usually been renamed or
misspelled in part of the workbook.

## Usage

``` r
check_district_consistency(.data)
```

## Arguments

- .data:

  A data frame. The merged and standardized dataset, with `district`,
  `adminlevel_1` and `year` columns.

## Value

`NULL` if no problem is found. Otherwise a character vector with one or
two messages, each named `"x"`: one that lists the districts with more
than one admin level 1 name, and one that lists the districts missing
from at least one year.

## Details

Admin level 1 names are compared without regard to case or extra spaces,
so `"North East"` and `"north east"` count as the same unit. The years a
district must appear in are all the distinct years in `.data`.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
check_district_consistency(data)
#> NULL

# A district spelled differently in one year
renamed <- data
renamed$district[renamed$district == "Baringo" & renamed$year == 2023] <- "Baringo County"
check_district_consistency(renamed)
#>                                                                                                    x 
#> "District(s) missing from at least one year present elsewhere in the data: Baringo, Baringo County." 
```
