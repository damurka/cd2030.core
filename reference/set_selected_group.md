# Set the selected indicator group globally

Persists the selected group in session state and as an option
(`options(cd2030.selected_group = <name>)`). Downstream helpers can
retrieve it with
[`get_selected_group()`](https://aphrcwaro.github.io/cd2030.core/reference/get_selected_group.md).

## Usage

``` r
set_selected_group(group)
```

## Arguments

- group:

  Group name. Must exist in `.get_all_groups()`.

## Value

Invisibly returns the resolved group name.

## Examples

``` r
set_selected_group("rmncah")
get_selected_group()
#> [1] "rmncah"
```
