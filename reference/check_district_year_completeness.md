# Check every district appears in every year present in the Population sheet

Pre-merge half of the old
[`check_district_consistency()`](check_district_consistency.md) –
district+year is the Population sheet's own natural grain, no merge
needed.

## Usage

``` r
check_district_year_completeness(population_data)
```

## Arguments

- population_data:

  The raw Population sheet (`parts[[population_sheet_name]]`).
