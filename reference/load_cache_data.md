# Initialize or load a cached Countdown 2030 connection

Loads data via [`load_data()`](load_data.md) for Excel/Stata inputs, or
initializes a cache from an `.rds`. Returns a cache/connection object.

## Usage

``` r
load_cache_data(
  path,
  indicator_group = c("auto", "vaccine", "rmncah", "custom"),
  profile = NULL,
  on_conflict = c("replace", "merge", "error"),
  create_cache = FALSE,
  start_year = NULL,
  admin_sheet_name = NULL,
  population_sheet_name = NULL,
  reporting_sheet_name = NULL,
  service_sheet_names = NULL,
  validate = TRUE
)
```

## Arguments

- path:

  Path to `.xlsx`, `.xls`, `.dta`, or `.rds`.

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

- create_cache:

  Logical. For Excel/Stata inputs, whether to pass `path` to the
  connection as its data path so a cache file is created or loaded next
  to it. Default is `FALSE` (no cache file). Ignored for `.rds` inputs.

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

- validate:

  Logical. Whether to stop with an error when the merged data fails a
  data quality check:
  [`check_district_consistency()`](check_district_consistency.md),
  [`check_month_presence()`](check_month_presence.md) or
  [`check_month_validity()`](check_month_validity.md). Default is
  `TRUE`. With `FALSE` a file that has such problems still loads, so the
  caller can run the checks later with
  [`run_all_quality_checks()`](run_all_quality_checks.md). Structural
  checks, such as a missing Admin sheet column, always run.

## Value

A cache/connection object as returned by
[`init_CacheConnection()`](init_CacheConnection.md).

## Examples

``` r
if (FALSE) { # \dontrun{
# From Excel
con <- load_cache_data("data/country.xlsx", indicator_group = "auto")

# From Stata
con <- load_cache_data("data/country.dta", indicator_group = "rmncah")

# From pre-saved RDS
con <- load_cache_data("data/cd_data.rds", indicator_group = "rmncah")
} # }
```
