# Best-effort, non-aborting country resolution from a raw Admin sheet

A non-aborting wrapper around `match_country()`, used by the Load Data
wizard (apps/rmncah) so `CacheConnection$country`/`$country_iso` have
something real to return before Finish – see those active bindings' own
comments (`CacheConnection-class.R`) for why this is deliberately
separate from [`check_single_country()`](check_single_country.md)'s real
validation, which still runs (non-blockingly, at the Data Quality step)
regardless: this function's only job is not leaving
`country`/`country_iso` `NULL` for the entire wizard just because
`match_country()` would abort on anything ambiguous.

## Usage

``` r
resolve_country_best_effort(admin_data)
```

## Arguments

- admin_data:

  The raw Admin sheet (`parts[[admin_sheet_name]]`).

## Value

`list(country, country_iso)` – both `NULL` if the admin sheet's own
`country` column doesn't resolve to exactly one confident match.
