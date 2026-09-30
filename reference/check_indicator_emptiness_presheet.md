# Flag indicators entirely empty across every service sheet, pre-merge

Reuses [`check_indicator_emptiness()`](check_indicator_emptiness.md)
unchanged against the row-bound service sheets.

## Usage

``` r
check_indicator_emptiness_presheet(parts, service_sheet_names)
```

## Arguments

- parts:

  Named list of cleaned per-sheet tibbles.

- service_sheet_names:

  Names of the service-data sheets within `parts`.
