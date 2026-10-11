# Create a CacheConnection object

`init_CacheConnection` initializes a `CacheConnection` either from a
provided `.rds` file path or directly from a `cd_data` object. Only one
of the arguments should be non-NULL.

## Usage

``` r
init_CacheConnection(
  rds_path = NULL,
  countdown_data = NULL,
  data_path = NULL,
  wizard_parts = NULL,
  indicator_group = c("auto", "rmncah", "vaccine", "custom"),
  read_only = FALSE
)
```

## Arguments

- rds_path:

  Optional character. Path to an RDS file to load the cache from.

- countdown_data:

  Optional `cd_data` object to initialize in-memory cache.

- data_path:

  Optional character. Path to the original source file (e.g. the `.xlsx`
  `countdown_data` was parsed from). The cache is kept beside it, as a
  `.rds` file with the same name.

- wizard_parts:

  Optional [`load_excel_parts()`](load_excel_parts.md) result: the
  sheets of an upload that the Load Data wizard has read but not yet
  merged. Use it instead of `rds_path` or `countdown_data`.

- indicator_group:

  Character. Specifies the indicator group to use (auto, rmncah,
  vaccine, custom).

- read_only:

  Logical. `TRUE` never writes the cache back to its `.rds`: for reading
  a dataset another process (the app) owns, e.g. the AI's copy.

## Value

An instance of the `CacheConnection` class.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

# in memory: no file is written
cache <- init_CacheConnection(countdown_data = data)
cache$country
#> [1] "Kenya"
cache$data_years
#> [1] 2019 2020 2021 2022 2023

if (FALSE) { # \dontrun{
# the dataset an app saved, opened without ever writing to it
cache <- init_CacheConnection(rds_path = "kenya_rmncah.rds", read_only = TRUE)
} # }
```
