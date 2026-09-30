# Check the Admin sheet's single country value is actually a recognized country name, pre-merge

[`check_single_country()`](check_single_country.md) (Tier A, above) only
catches more than one distinct value – the
genuinely-one-value-but-unrecognized case is `match_country()`'s job,
which normally only runs at Finish
([`merge_and_standardize()`](merge_and_standardize.md)'s
[`new_countdown()`](new_countdown.md) call) under the deferred-merge
design. Left uncaught pre-merge, a user could walk the entire wizard
only to hit a hard abort on the very last step – this surfaces the same
problem at Data Quality instead, non-abortingly, same as every other
check here.

## Usage

``` r
check_country_recognized(parts, admin_sheet_name)
```

## Arguments

- parts:

  Named list of cleaned per-sheet tibbles.

- admin_sheet_name:

  Name of the admin sheet within `parts`.

## Details

A deliberately NOT-yet-replicated counterpart: "every indicator the
selected group needs is present" (`check_required_columns_exist()`,
`utils.R`) still only runs at Finish. Its check is against columns
`standardize_data()` computes/renames during the merge itself
(reporting-rate `_rr` columns, `instdeliveries` -\> `ideliv`) – checking
for those names against the RAW, pre-standardize sheets produces false
positives (confirmed live: a real, known-good file flagged as "missing"
columns it actually has, just not yet under their final names) that
would incorrectly block a user with no real problem. A correct pre-merge
version would need to replicate `standardize_data()`'s own
rename/compute logic just to know what to look for – a real gap (Finish
can still abort on this), left for follow-up work rather than shipped
half-right.
