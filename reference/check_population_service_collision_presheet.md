# Flag district-years where a service indicator looks mixed up with population data, pre-merge

[`check_population_service_collision()`](check_population_service_collision.md)
needs `instlivebirths` (service) and `live_births` (population) on the
same rows – pre-merge these live on different sheets, so this does a
narrow, purpose-built `district`+`year` left join (service data is the
left side – every service row is kept regardless of whether a matching
population row exists, unlike `merge_data()`'s admin-anchored join, so
nothing is silently dropped here either) just to bring the two columns
together for this one comparison, then delegates to the existing check.

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

  Named list of cleaned per-sheet tibbles.

- population_sheet_name:

  Name of the population sheet within `parts`.

- service_sheet_names:

  Names of the service-data sheets within `parts`.
