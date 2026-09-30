# Flag calendar months that different rows/sheets label with different raw text

[`load_excel_parts()`](load_excel_parts.md) already normalizes every
sheet's `month` column independently, before `merge_data()` ever runs –
so the merge itself no longer silently drops data over a raw-text
join-key mismatch (a real, confirmed bug this fixes: one sheet labeling
a year in French while its sibling sheets labeled the same year in
English left every one of those sibling sheets' columns `NA` for that
whole period). That fix is silent by design – it makes the DATA correct,
it doesn't tell the user anything was off. This check surfaces the
underlying anomaly itself: more than one distinct `raw_month` string
mapping to the same canonical calendar month is a real signal about how
the file was put together (e.g. a historical import already translated
to English, stitched together with a current year still in its original
language) – informational, not blocking, since the data is already
handled correctly either way, but worth knowing.

## Usage

``` r
check_month_language_consistency(parts, service_sheet_names)
```

## Arguments

- parts:

  Named list of cleaned per-sheet tibbles.

- service_sheet_names:

  Names of the service-data sheets within `parts`.

## Value

A tibble, one row per canonical month with more than one distinct raw
text seen for it: `month`, `variants` (the distinct `raw_month` strings
observed, comma-separated).
