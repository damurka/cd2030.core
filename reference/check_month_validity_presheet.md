# Check every row's month string parses to a real calendar month, pre-merge

`month` here is already normalized
([`load_excel_parts()`](load_excel_parts.md) does this on every sheet,
before `merge_data()` ever runs – see its own comment for why) – `NA`
means it genuinely didn't parse, no need to re-run `parse_month_name()`
here. `raw_month` (preserved by that same normalization step) is what
this reports, so a typo or different-language value shows up as the
actual original text, not just `NA`.

## Usage

``` r
check_month_validity_presheet(parts, service_sheet_names)
```

## Arguments

- parts:

  Named list of cleaned per-sheet tibbles.

- service_sheet_names:

  Names of the service-data sheets within `parts`.
