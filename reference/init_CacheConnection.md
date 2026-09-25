# Create a CacheConnection Object

`init_CacheConnection` initializes a `CacheConnection` either from a
provided `.rds` file path or directly from a `cd_data` object. Only one
of the arguments should be non-NULL.

## Usage

``` r
init_CacheConnection(
  rds_path = NULL,
  countdown_data = NULL,
  indicator_group = c("auto", "rmncah", "vaccine", "custom")
)
```

## Arguments

- rds_path:

  Optional character. Path to an RDS file to load the cache from.

- countdown_data:

  Optional `cd_data` object to initialize in-memory cache.

## Value

An instance of the `CacheConnection` class.
