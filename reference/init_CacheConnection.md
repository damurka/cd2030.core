# Create a CacheConnection Object

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
  `countdown_data` was parsed from). Used to derive where the cache
  lives – see `CacheConnection$initialize`.

- wizard_parts:

  Optional [`load_excel_parts()`](load_excel_parts.md) result – a third,
  mutually-exclusive mode alongside `rds_path`/`countdown_data` for the
  Load Data wizard's own in-progress state (see
  `CacheConnection$initialize`'s own `wizard_parts` doc).

- indicator_group:

  Character. Specifies the indicator group to use (auto, rmncah,
  vaccine, custom).

- read_only:

  Logical. `TRUE` never writes the cache back to its `.rds`: for reading
  a dataset another process (the app) owns, e.g. the AI's copy.

## Value

An instance of the `CacheConnection` class.
