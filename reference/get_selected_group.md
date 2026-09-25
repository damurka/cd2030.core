# Get the globally selected indicator group

Returns the last group set via
[`set_selected_group()`](https://aphrcwaro.github.io/cd2030.core/reference/set_selected_group.md).
If none is set for the session, falls back to
`getOption("cd2030.selected_group", "rmncah")` and caches it.

## Usage

``` r
get_selected_group()
```

## Value

A length-1 character vector (group name).

## Examples

``` r
get_selected_group()
#> [1] "rmncah"
```
