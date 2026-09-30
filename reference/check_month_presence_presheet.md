# Check every district-year has all 12 calendar months present, pre-merge

Service sheets already carry `district`/`year`/`month` natively – reuses
[`check_month_presence()`](check_month_presence.md) unchanged, just
called against the row-bound service sheets instead of merged
`countdown_data`.

## Usage

``` r
check_month_presence_presheet(parts, service_sheet_names)
```

## Arguments

- parts:

  Named list of cleaned per-sheet tibbles.

- service_sheet_names:

  Names of the service-data sheets within `parts`.
