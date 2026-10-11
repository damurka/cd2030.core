# Check that every district has every year in the Population sheet

Checks that each district in the Population sheet has a row for every
year the sheet covers. This is the part of
[`check_district_consistency()`](check_district_consistency.md) that can
run before the sheets are merged.

## Usage

``` r
check_district_year_completeness(population_data)
```

## Arguments

- population_data:

  A data frame. The cleaned Population sheet, before the sheets are
  merged, with `district` and `year` columns.

## Value

`NULL` if every district appears in every year, or if the sheet lacks
either column. Otherwise a character vector of length one, named `"x"`,
with a message that lists the districts missing from at least one year.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
population <- sheets$parts[[sheets$population_sheet_name]]
check_district_year_completeness(population)
#> NULL

# A district with no population row for one year
gap <- population$district == "Baringo" & population$year == 2023
check_district_year_completeness(population[!gap, ])
#>                                                                                                x 
#> "District(s) missing from at least one year present elsewhere in the Population sheet: Baringo." 
```
