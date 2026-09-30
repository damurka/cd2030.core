# What a CacheConnection data point is

The definition of one public member of
[CacheConnection](CacheConnection.md): what it holds or returns in the
methodology's terms, its kind (`data`, `setting`, `reference`,
`mapping`, `check`, `value`, `store`, `state`, `method`, `action`), its
grain (what one row is) and key columns, its unit, where the user sets
it in the app (`set_on`) and which pages show it (`shown_on`), the
methodology docs section it comes from (`method`), the defaults it
follows (ids of
[`cd_methodology_defaults()`](cd_methodology_defaults.md)), and what it
is computed from (`depends_on`). Columns are described from their names
by the data dictionary, not here. `status` is `"draft"` (with a `note`)
where the definition is not certain.
[`cache_manifest()`](cache_manifest.md) includes every member's
definition.

## Usage

``` r
cache_definition(name = NULL)
```

## Arguments

- name:

  A member name, e.g. `"adjusted_data"`; `NULL` for all of them.

## Value

A list (one definition), a named list of all of them, or `NULL` when
`name` is not a public member.

## Examples

``` r
cache_definition("adjusted_data")$what
#> [1] "The adjusted numerators: data_with_excluded_years with each count corrected for incomplete reporting with k (reporting rates below the cutoff replaced first) and extreme outliers replaced; carries each indicator's median, MAD and outlier flag. Every coverage, mortality, utilization and health-system result is computed from it."
```
