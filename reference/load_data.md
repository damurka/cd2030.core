# Load Countdown 2030 data (Excel or Stata)

Loads a cleaned dataset from an Excel (.xlsx/.xls) or Stata (.dta) file,
optionally **registers** a profile override, and returns a tibble of
class `cd_data`. Group selection is resolved from the data inside
[`new_countdown()`](https://aphrcwaro.github.io/cd2030.core/reference/new_countdown.md):

- `"auto"` detects the best-matching group (built-ins + any overrides)

- `"vaccine"` or `"rmncah"` select built-ins (overrides still apply)

- `"custom"` uses `profile` (must exist after any inline registration)

## Usage

``` r
load_data(
  path,
  indicator_group = c("auto", "vaccine", "rmncah", "custom"),
  profile = NULL,
  on_conflict = c("replace", "merge", "error"),
  start_year = NULL,
  admin_sheet_name = NULL,
  population_sheet_name = NULL,
  reporting_sheet_name = NULL,
  service_sheet_names = NULL
)
```

## Arguments

- path:

  Path to `.xlsx`, `.xls`, or `.dta`.

- indicator_group:

  One of `"auto"`, `"vaccine"`, `"rmncah"`, `"custom"`. Default
  `"auto"`.

- profile:

  Optional. Either a **name** (string) of an existing group, or a
  **definition** to register inline before loading:

  - explicit form:
    `list(name = "rmncah", value = list(hiv = c("hiv_test","pmtct1")))`

  - compact form:
    `list(hiv_profile = list(testing = c("hiv_test"), care = c("art_new")))`

  For `"custom"`, the profile must resolve to **one** concrete name.

- on_conflict:

  Conflict policy when `profile` is a definition: one of `"replace"`,
  `"merge"`, or `"error"`. Default `"replace"`. `"merge"` unions
  indicators per category.

- start_year:

  Optional integer filter for minimum year.

- admin_sheet_name:

  Excel sheet with admin data. Default `"Admin_data"`.

- population_sheet_name:

  Excel sheet with population data. Default `"Population_data"`.

- reporting_sheet_name:

  Excel sheet with reporting completeness. Default
  `"Reporting_completeness"`.

- service_sheet_names:

  Character vector of service-data sheets. Default: all sheets matching
  `"Service_data"` if not supplied.

## Value

A tibble of class `cd_data`.

## Details

The actual **group resolution** occurs in
[`new_countdown()`](https://aphrcwaro.github.io/cd2030.core/reference/new_countdown.md),
using indicators **from the loaded data**. If `profile` is a definition,
it is registered via
[`register_indicator_group()`](https://aphrcwaro.github.io/cd2030.core/reference/register_indicator_group.md)
**before** loading, so auto-detection considers it.

## Examples

``` r
if (FALSE) { # \dontrun{
# Built-in group (explicit)
cd <- load_data("data/country.dta", indicator_group = "rmncah")
attr(cd, "indicator_group")  # "rmncah"

# Auto-detect among built-ins
cd <- load_data("data/country.xlsx", indicator_group = "auto")

# Inline extend rmncah, then auto-detect (merge by category)
cd <- load_data(
  "data/country.xlsx",
  indicator_group = "auto",
  profile = list(name = "rmncah", value = list(hiv = c("hiv_test","pmtct1"))),
  on_conflict = "merge"
)

# Define a brand-new custom profile and select it
cd <- load_data(
  "data/country.xlsx",
  indicator_group = "custom",
  profile = list(my_profile = list(anc = c("anc1","anc4")))
)
} # }
```
