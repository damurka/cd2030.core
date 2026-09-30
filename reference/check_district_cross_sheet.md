# Check districts match between the Admin sheet and every other sheet, both directions

The direct fix for the root problem this redesign exists for:
`merge_data()` left-joins everything onto the Admin sheet, so a district
that exists in Population_data/Service_data but not in Admin_data was
silently dropped before any check ever ran against the merged result.
This runs on unmerged `parts`, so nothing has been dropped yet.

## Usage

``` r
check_district_cross_sheet(parts, admin_sheet_name)
```

## Arguments

- parts:

  Named list of cleaned per-sheet tibbles (`load_excel_parts()$parts`).

- admin_sheet_name:

  Name of the admin sheet within `parts`.
