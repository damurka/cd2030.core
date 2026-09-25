# Reset (remove) a group override

Removes a user override for `name`. If `name` matches a built-in group,
the built-in remains intact; only the override layer is removed.

## Usage

``` r
reset_indicator_group(name)
```

## Arguments

- name:

  Group name whose override should be removed.

## Value

Invisibly returns `name`.

## Examples

``` r
reset_indicator_group("rmncah")
```
