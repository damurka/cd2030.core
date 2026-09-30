# Check a district's admin-1 pairing is stable within the Admin sheet itself

Pre-merge half of the old (still-existing, still used post-merge by
[`new_countdown()`](new_countdown.md)'s Tier B)
[`check_district_consistency()`](check_district_consistency.md) – this
half only ever needed the Admin sheet: a district's `adminlevel_1`
pairing can only vary across the merged data if the Admin sheet itself
lists that district more than once with different values, so checking
the raw sheet directly loses no signal.

## Usage

``` r
check_admin_pairing_consistency(admin_data)
```

## Arguments

- admin_data:

  The raw Admin sheet (`parts[[admin_sheet_name]]`, pre-rename – still
  has `first_admin_level`, not `adminlevel_1`).
