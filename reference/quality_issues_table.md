# Every data quality result as tables: a summary of the checks, and one row per issue

Every data quality result as tables: a summary of the checks, and one
row per issue

## Usage

``` r
quality_issues_table(results, labels = NULL)
```

## Arguments

- results:

  What [`run_all_quality_checks()`](run_all_quality_checks.md) returns.

- labels:

  Optional named character vector: a check's key (`names(results)`) to
  the name to show for it (the wizard passes its translated ones). A
  check without one gets a plain English name.

## Value

A list of two tibbles. `summary`: `check`, `severity`, `status`
(`"passed"` or `"issue"`), `issues` (how many). `issues`: `check`,
`severity`, `issue`, one row for each thing a check found (each
district-year, each name, each sentence), with nothing shortened.
