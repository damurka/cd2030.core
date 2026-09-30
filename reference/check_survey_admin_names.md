# Flag dataset admin-1 names that have no matching survey region

Checked in this direction (not the other way around) because it's the
dataset's own regions that need coverage: a region present in
`countdown_data` but missing from the survey can't get a regional/equity
estimate at all. A survey region with no dataset match is just unused
data, not something that blocks anything.

## Usage

``` r
check_survey_admin_names(regional_survey, countdown_data)
```

## Arguments

- regional_survey:

  The `regional_survey` data (has its own `adminlevel_1` column).

- countdown_data:

  The dataset (`countdown_data`-shaped).

## Value

A tibble of dataset admin-1 names with no survey match, each with its
closest suggestion (see `match_admin_names()`).
