# The charts that have saved options

A table of every chart with options saved in a dataset's cache: which
chart (its [`cd_chart_id()`](cd_chart_id.md), or for the screen the
chart's place in the app), whether they are for the screen or for
reports, how many options are set, and the group it belongs to (the
first two parts of its id, e.g. `coverage_filtered.national`). Use it to
see which chart ids a report will pick options up for.

## Usage

``` r
cd_chart_catalog(cache)
```

## Arguments

- cache:

  A [CacheConnection](CacheConnection.md).

## Value

A tibble with `id`, `target` (`"screen"`, `"report"` or `"dataset"`),
`group`, `n_options` and `options` (a one-line summary).
