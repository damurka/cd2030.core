# Check every row's month string parsed to a real calendar month

`standardize_data()` turns any month string that doesn't match one of
its 12 recognized patterns into `NA` silently (no warning, the row stays
in the data) – this surfaces that silently-dropped information instead
of letting it pass unnoticed. Relies on `raw_month` (the pre-cleaning
value `standardize_data()` now preserves specifically for this check);
if `.data` doesn't have that column (e.g. a `.dta` master dataset, which
skips `standardize_data()` entirely), this falls back to just checking
for `NA` months with no detail on the original unparseable text.

## Usage

``` r
check_month_validity(.data)
```

## Arguments

- .data:

  The merged, standardized dataset.
