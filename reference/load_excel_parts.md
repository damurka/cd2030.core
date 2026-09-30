# Read & clean every Countdown 2030 Excel sheet, without merging them

Split out of what used to be the front half of `.load_excel_data()`
(Phase 3 of the Load Data wizard redesign, `apps/rmncah`): reads and
cleans every sheet, keyed by sheet name, and returns them SEPARATE – no
`merge_data()`/`standardize_data()`/[`new_countdown()`](new_countdown.md)
here. This is what lets the wizard run its Data Quality checks per-sheet
(which sheet a problem actually came from, not just "somewhere in the
merged data") BEFORE committing to a merge. The only things that still
abort immediately, unconditionally, here: the sheets named don't exist
at all, or a sheet is missing the join-key columns
`read_and_clean_sheet()` itself requires (district/year/month) – both
are "there is nothing coherent to even display per-sheet" failures, not
a data-QUALITY finding the way a missing indicator column or a district
name mismatch is (see
[`merge_and_standardize()`](merge_and_standardize.md)'s own Tier A
checks, and `0_data_quality_checks.R`'s new per-sheet checks, for where
those now live instead).

## Usage

``` r
load_excel_parts(
  path,
  start_year = NULL,
  admin_sheet_name = NULL,
  population_sheet_name = NULL,
  reporting_sheet_name = NULL,
  service_sheet_names = NULL
)
```

## Arguments

- path:

  Path to `.xlsx`, `.xls`, or `.dta`.

- start_year:

  Optional integer filter for minimum year.

- admin_sheet_name:

  Excel sheet with admin data. Default `"Admin_data"`.

- population_sheet_name:

  Excel sheet with population data. Default `"Population_data"`.

- reporting_sheet_name:

  Excel sheet with reporting completeness. Default
  `"Reporting_completeness"`.

- service_sheet_names:

  Character vector of service-data sheets. Default: all sheets matching
  `"Service_data"` if not supplied.

## Value

A list: `parts` (named list of cleaned per-sheet tibbles),
`sheet_names`, `sheet_ids`, `admin_sheet_name`, `population_sheet_name`,
`reporting_sheet_name`, `service_sheet_names`, `path`, `start_year` –
everything [`merge_and_standardize()`](merge_and_standardize.md) needs
to finish the job later, and everything the wizard's own per-sheet
quality checks need in the meantime.
