# Flag service births that equal population births, before merging

Runs
[`check_population_service_collision()`](check_population_service_collision.md)
on the unmerged sheets. It finds district-years where the monthly
institutional live births in the service sheets equal the annual live
births in the Population sheet in every month, which suggests that
population figures were entered in a service data sheet.

## Usage

``` r
check_population_service_collision_presheet(
  parts,
  population_sheet_name,
  service_sheet_names
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

## Value

A tibble with columns `district` and `year`, one row per flagged
district-year. It has no rows if nothing is flagged, if the Population
sheet lacks `district`, `year` or `live_births`, or if the service
sheets lack `instlivebirths`.

## Details

The service sheets are stacked and the Population sheet's `live_births`
is added to each service row by `district` and `year`. Every service row
is kept. A district-year is flagged when it has at least three months
with both values present and the two values are equal in all of them.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
check_population_service_collision_presheet(
  sheets$parts, sheets$population_sheet_name, sheets$service_sheet_names
)
#> # A tibble: 0 × 2
#> # ℹ 2 variables: district <chr>, year <int>

# Baringo's 2023 population births entered in every month of the service sheet
parts <- sheets$parts
population <- parts[[sheets$population_sheet_name]]
births <- population$live_births[population$district == "Baringo" & population$year == 2023]
service <- parts[[sheets$service_sheet_names[1]]]
service$instlivebirths[service$district == "Baringo" & service$year == 2023] <- births
parts[[sheets$service_sheet_names[1]]] <- service
check_population_service_collision_presheet(
  parts, sheets$population_sheet_name, sheets$service_sheet_names
)
#> # A tibble: 1 × 2
#>   district  year
#>   <chr>    <int>
#> 1 Baringo   2023
```
