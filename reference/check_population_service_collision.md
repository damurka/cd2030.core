# Flag district-years where a service indicator looks like it was mixed up with population data

`instlivebirths` (institutional live births, a monthly service
indicator) is expected to vary month to month; `live_births` (the
Population_data sheet's own live-births figure) is joined in by
`district`+`year` only, so it's constant across all 12 months of a given
district-year. A district-year where `instlivebirths` is identical to
`live_births` in every month is the signature of the two having been
pasted into the wrong sheet.

## Usage

``` r
check_population_service_collision(.data)
```

## Arguments

- .data:

  The dataset (`countdown_data`-shaped).

## Value

A tibble of flagged `district`/`year` rows, or a zero-row tibble if none
found.
