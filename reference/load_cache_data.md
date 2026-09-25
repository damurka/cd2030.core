# Initialize or load a cached Countdown 2030 connection

Loads data via
[`load_data()`](https://aphrcwaro.github.io/cd2030.core/reference/load_data.md)
for Excel/Stata inputs, or initializes a cache from an `.rds`. Returns a
cache/connection object.

## Usage

``` r
load_cache_data(
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

A cache/connection object as returned by
[`init_CacheConnection()`](https://aphrcwaro.github.io/cd2030.core/reference/init_CacheConnection.md).

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
