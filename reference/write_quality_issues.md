# Write every data quality result to an Excel workbook

Two sheets: `Summary` (each check, whether it passed, how many issues)
and `Issues` (one row per issue).

## Usage

``` r
write_quality_issues(results, path, labels = NULL)
```

## Arguments

- results:

  What [`run_all_quality_checks()`](run_all_quality_checks.md) returns.

- path:

  Where to write the `.xlsx`.

- labels:

  Optional named character vector: a check's key (`names(results)`) to
  the name to show for it (the wizard passes its translated ones). A
  check without one gets a plain English name.

## Value

`path`, invisibly.
