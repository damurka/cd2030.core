# What the Countdown AI knows of CacheConnection

Every public member of `CacheConnection` – method or active binding –
with its arguments (defaults, and the values an argument may take when
the code says), its documentation, whether it writes to the dataset,
whether a custom chart may draw from it, and its `definition` (what the
data point is, see [`cache_definition()`](cache_definition.md)); plus
the report kinds. Read from the installed package, so it always matches
the code; countdown-analytics builds its guide for the AI from it.

## Usage

``` r
cache_manifest()
```

## Value

A list (JSON-able with `jsonlite::toJSON(auto_unbox = TRUE)`):
`package`, `version`, `generatedAt`, `members` and `reportKinds`.

## Examples

``` r
m <- cache_manifest()
length(m$members)
#> [1] 203
```
