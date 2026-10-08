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

Its counterpart, "every column the selected group needs is present", is
[`check_required_columns_presheet()`](check_required_columns_presheet.md).
