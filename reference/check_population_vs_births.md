# Check that population live births are not below reported births

Compares, for each district-year, the estimated live births in the
Population sheet with the institutional births reported in the service
sheets. Not every birth happens in a facility, so an estimate that is
lower than what facilities reported points to a problem in one of the
two figures.

## Usage

``` r
check_population_vs_births(
  parts,
  population_sheet_name,
  service_sheet_names,
  margin = 0.1
)
```

## Arguments

- parts:

  A named list of cleaned per-sheet tibbles
  (`load_excel_parts()$parts`).

- population_sheet_name:

  A string. The name of the Population sheet within `parts`.

- service_sheet_names:

  A character vector. The names of the service data sheets within
  `parts`.

- margin:

  A number between 0 and 1. The fraction by which the population figure
  may fall short of the reported figure before it is flagged. Default is
  `0.10` (10%).

## Value

`NULL` if no district-year is flagged, if the Population sheet lacks
`district`, `year` or `live_births`, or if the service sheets have
neither births column. Otherwise a character vector of length one, named
`"x"`, with a message that lists the first 10 flagged district-years and
gives a count of the rest. Its `"rows"` attribute is a tibble of all the
flagged district-years, with columns `district`, `year`, `live_births`
and `total_delivered` (the reported sum).

## Details

The reported figure is the sum over the months of a district-year of
`instlivebirths`, or of `instdeliveries` if the service sheets have no
`instlivebirths` column. A district-year is flagged when `live_births`
is less than `(1 - margin)` times that sum. Only district-years that
have both figures are compared.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
found <- check_population_vs_births(
  sheets$parts, sheets$population_sheet_name, sheets$service_sheet_names
)
found
#>                                                                                                                                                                                                                                x 
#> "District-year(s) where estimated population live births is lower than reported institutional counts, beyond a 10% margin: Kiambu 2019 (population: 56265, reported: 68964); Baringo 2023 (population: 15133, reported: 22639)." 
#> attr(,"rows")
#> # A tibble: 2 × 4
#>   district  year live_births total_delivered
#>   <chr>    <int>       <dbl>           <dbl>
#> 1 Kiambu    2019      56265.           68964
#> 2 Baringo   2023      15133            22639
attr(found, "rows")
#> # A tibble: 2 × 4
#>   district  year live_births total_delivered
#>   <chr>    <int>       <dbl>           <dbl>
#> 1 Kiambu    2019      56265.           68964
#> 2 Baringo   2023      15133            22639

# Flag any shortfall, however small
check_population_vs_births(
  sheets$parts, sheets$population_sheet_name, sheets$service_sheet_names,
  margin = 0
)
#>                                                                                                                                                                                                                                                                                 x 
#> "District-year(s) where estimated population live births is lower than reported institutional counts, beyond a 0% margin: Kiambu 2019 (population: 56265, reported: 68964); Kiambu 2020 (population: 63064, reported: 66464); Baringo 2023 (population: 15133, reported: 22639)." 
#> attr(,"rows")
#> # A tibble: 3 × 4
#>   district  year live_births total_delivered
#>   <chr>    <int>       <dbl>           <dbl>
#> 1 Kiambu    2019      56265.           68964
#> 2 Kiambu    2020      63064            66464
#> 3 Baringo   2023      15133            22639
```
