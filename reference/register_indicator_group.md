# Register or override an indicator group (profile)

Adds or modifies a group definition by **name**. If the name already
exists, use `on_conflict = "replace"` to replace the entire definition,
or `on_conflict = "merge"` to **union** indicators *per category*.

## Usage

``` r
register_indicator_group(
  name,
  value,
  on_conflict = c("replace", "merge", "error")
)
```

## Arguments

- name:

  A non-empty string: the group/profile name to create or modify.

- value:

  A **named list**: each element is a category containing a character
  vector of indicator codes.

- on_conflict:

  One of `"replace"`, `"merge"`, or `"error"`. `"merge"` performs a
  union per category (`sort(unique(c(old, new)))`).

## Value

Invisibly returns `name`.

## Details

Reserved names `"auto"` and `"custom"` cannot be registered.

- If `name` matches a built-in (e.g. `"rmncah"`), the override will be
  layered on top of the built-in according to `on_conflict`.

- The merged, live view is available via `.get_all_groups()` or
  [`get_indicator_groups()`](https://aphrcwaro.github.io/cd2030.core/reference/get_indicator_groups.md).

## Examples

``` r
# Replace RMNCAH completely
register_indicator_group(
  "rmncah",
  list(anc = c("anc1","anc4"), idelv = c("sba")),
  on_conflict = "replace"
)

# Extend RMNCAH by merging into existing categories (union)
register_indicator_group(
  "rmncah",
  list(hiv = c("hiv_test","pmtct1")),
  on_conflict = "merge"
)
```
