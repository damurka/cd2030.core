# Flag indicators that are entirely empty across the whole dataset

Same detector `standardize_data()` already uses for its own "empty
columns" log line (`colSums(is.na(data)) == nrow(data)`,
`0_import_load_data.R`), scoped to just the indicator columns for the
currently-selected indicator group
([`get_indicator_groups()`](get_indicator_groups.md)) rather than every
column – an admin/year/month/population column being "empty" isn't a
data-quality signal the same way an indicator column being empty is.

## Usage

``` r
check_indicator_emptiness(.data)
```

## Arguments

- .data:

  The dataset (`countdown_data`-shaped).

## Value

A character vector of indicator names that are 100% empty.
