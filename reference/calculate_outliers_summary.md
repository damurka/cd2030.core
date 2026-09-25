# Annual Summary of Outlier-Free Reporting Rates

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

## Details

Outliers are defined using a Hampel filter with a 5-MAD threshold.

This function:

- Aggregates outlier flags by year and administrative level

- Computes the share of valid (non-outlier) values per indicator

- Adds overall summary metrics:

  - `mean_out_all`: average non-outlier rate across all indicators

  - `mean_out_four`: average across a subset of key indicators
    (excluding IPD)

Values are expressed as percentages (0–100).

@return A tibble of class `cd_outlier`.

## Examples

``` r
if (FALSE) { # \dontrun{
  calculate_outliers_summary(data, admin_level = "district")
} # }
```
