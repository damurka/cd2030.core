# Run every non-structural quality check against an already-loaded cache, without aborting

Counterpart to `run_quality_checks()` above (which collects several
checks and aborts once if any fail – the shape
[`new_countdown()`](new_countdown.md)'s Tier B and
[`merge_and_standardize()`](merge_and_standardize.md)'s Tier A both need
at load time). This one never aborts: it runs every non-structural check
and returns a full report, for a caller that wants to show every result
– pass or fail – rather than stop at the first problem. Built for the
Load Data wizard's Data Quality step (apps/rmncah).

## Usage

``` r
run_all_quality_checks(cache)
```

## Arguments

- cache:

  A `CacheConnection` (or anything exposing `$wizard_parts`,
  `$countdown_data`, `$check_survey_admin_names()`,
  `$check_shapefile_admin_names()` the same way).

## Value

A named list, one entry per check: `list(ok, severity, detail)`.
`severity` is one of `"blocking"` (these gate progression past the Data
Quality step), `"informational"` (shown, never block), or `"mapping"`
(survey/shapefile admin-name matches – shown, never block, point instead
at the relevant mapping step).

## Details

Branches on whether `cache` still holds unmerged wizard parts
(`cache$wizard_parts`, set by
[`load_excel_parts()`](load_excel_parts.md) +
`CacheConnection$set_wizard_parts()` – the normal case for a fresh
Excel/Stata upload going through the wizard, Phase 3 of the Load Data
wizard redesign) or already has merged `countdown_data` (a resumed
`.rds`, edit mode, or any non-wizard caller) – the pre-merge branch runs
the sheet-scoped checks above, attributing problems to the specific
sheet they came from; the post-merge branch is the original, unchanged
set of checks against the fully merged data.
