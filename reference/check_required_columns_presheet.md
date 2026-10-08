# Check the sheets have every column the selected indicator group needs, before they are merged

What [`new_countdown()`](new_countdown.md) stops on at Finish
(`check_required_columns_exist()`), asked at the Data Quality step
instead: the group's indicators, a reporting rate for each of its
categories, and the population columns. It reads only the sheets' column
names, as they will be once merged and standardized
(`.standardized_column_names()`, which shares `standardize_data()`'s own
list of renames), so a column the merge renames or computes is not
reported as missing – what kept this check out of the step before – and
what it reports is what Finish would.

## Usage

``` r
check_required_columns_presheet(parts, group = get_selected_group())
```

## Arguments

- parts:

  Named list of cleaned per-sheet tibbles.

- group:

  The indicator group to check against. Default: the selected one (the
  wizard sets it at upload).

## Details

Confirmed live on a workbook from the Data Extractor, whose Population
sheet has no `Pop_growth_rate`: it passed every check, and Finish failed
in `standardize_data()` with "`false` must be a vector, not `NULL`" in
the first district.
