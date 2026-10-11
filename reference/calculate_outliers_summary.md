# Annual summary of outlier-free reporting rates

`calculate_outliers_summary` computes yearly percentages of non-outlier
values for each health indicator, based on precomputed 5-MAD outlier
flags. Summarizes data quality by administrative level and year.

## Usage

``` r
calculate_outliers_summary(
  .data,
  admin_level = c("national", "adminlevel_1", "district"),
  region = NULL
)
```

## Arguments

- .data:

  A `cd_data` object with `_outlier5std` flag columns (0 = valid, 1 =
  outlier).

- admin_level:

  Character. Aggregation level. One of:

  - `"national"`

  - `"adminlevel_1"`

  - `"district"`

- region:

  Optional. Restrict to a specific region (only when
  `admin_level = "adminlevel_1"`).

## Value

A tibble of class `cd_outlier`.

## Details

Outliers are defined using a Hampel filter with a 5-MAD threshold.

Aggregates the outlier flags by year and administrative level and
computes the share of valid (non-outlier) values per indicator. The IPD
indicators are left out. Adds `mean_out_all`, the average non-outlier
rate across the indicators summarised.

Values are expressed as percentages (0-100).

## Examples

``` r
if (FALSE) { # \dontrun{
calculate_outliers_summary(data, admin_level = "district")
} # }
```
