# Check the Admin_data sheet names exactly one country

[`new_countdown()`](new_countdown.md) later does
`distinct(country) %>% pull(country)` and passes the result straight to
`match_country()`, which itself only handles a length-1 input gracefully
(a longer vector aborts with a generic "contains multiple names"
message, no detail on what the mixed values actually are). Catching it
here, on the raw sheet, gives a specific, actionable message before any
of the rest of the pipeline runs.

## Usage

``` r
check_single_country(admin_data)
```

## Arguments

- admin_data:

  The raw, cleaned Admin_data sheet.
