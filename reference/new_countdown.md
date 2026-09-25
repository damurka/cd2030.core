# Create a `cd_data` object from cleaned data and resolve the indicator group

Validates required columns, resolves the concrete indicator group name
from the **data** (`"auto"` detection supported), ensures the selected
group's indicators are fully present, sets the global selection, and
returns a `cd_data`.

## Usage

``` r
new_countdown(
  .data,
  class = NULL,
  indicator_group = c("auto", "vaccine", "rmncah", "custom"),
  profile_name = NULL,
  profile = NULL
)
```

## Arguments

- .data:

  Tibble after cleaning/merge.

- indicator_group:

  One of `"auto"`, `"vaccine"`, `"rmncah"`, `"custom"`.

- profile:

  For `"custom"`, the group name to select (must exist). Ignored
  otherwise.

## Value

A tibble with class `cd_data` and `attr(, "indicator_group")` set to the
resolved name. Also sets `options(cd2030.selected_group)` via
[`set_selected_group()`](https://aphrcwaro.github.io/cd2030.core/reference/set_selected_group.md).

## Examples

``` r
if (FALSE) { # \dontrun{
x <- .load_excel_data("data/country.xlsx", indicator_group = "auto")
cd <- new_countdown(x, indicator_group = "auto")
attr(cd, "indicator_group")
} # }
```
