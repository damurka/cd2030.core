# Check the Admin_data sheet has the columns every later step assumes exist

`first_admin_level`/`country` are only ever consumed via `any_of()`
downstream (see `read_and_clean_sheet()`'s own `required_columns`, used
only for `drop_na()`, and `standardize_data()`'s
`rename(adminlevel_1 = any_of("first_admin_level"))`), so a sheet
missing either column silently proceeds today with
`adminlevel_1`/`country` never created, surfacing later as a confusing,
unrelated error far from the actual cause. `district` isn't checked here
– it's already covered by `read_and_clean_sheet()`'s own key-column
check.

## Usage

``` r
check_admin_columns(admin_data)
```

## Arguments

- admin_data:

  The raw, cleaned Admin_data sheet (one `read_and_clean_sheet()` call's
  output, before `merge_data()`).
