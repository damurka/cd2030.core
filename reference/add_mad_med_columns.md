# Add Median and MAD Columns for Indicators

`add_mad_med_columns` calculates and appends the median and Median
Absolute Deviation (MAD) for specified indicators in a dataset. These
statistics are calculated per group, allowing the user to dynamically
group data (e.g., by `district`) and exclude data from the most recent
year in the dataset.

## Usage

``` r
add_mad_med_columns(.data, indicators, group_by = "district")
```

## Arguments

- .data:

  A `cd_data` tibble containing health indicator data.

- indicators:

  A character vector specifying the names of the indicator columns for
  which the median and MAD should be calculated.

- group_by:

  A character string or vector specifying the column(s) to group by when
  calculating the median and MAD (default is `'district'`).

## Value

A tibble with additional columns for each indicator, named
`{indicator}_med` and `{indicator}_mad`, containing the calculated
median and MAD, respectively.

## Details

- The median and MAD are calculated for each group specified by
  `group_by`.

- Only data from years prior to the most recent year in the dataset are
  considered.

- Missing values in the calculated statistics are replaced using
  [`robust_max()`](https://aphrcwaro.github.io/cd2030.core/reference/robust_max.md),
  ensuring that meaningful fallback values are provided.

## See also

- [`add_outlier5std_column()`](https://aphrcwaro.github.io/cd2030.core/reference/add_outlier5std_column.md)
  for generating outlier flags based on these columns.

- [`robust_max()`](https://aphrcwaro.github.io/cd2030.core/reference/robust_max.md)
  for calculating max value

## Examples

``` r
if (FALSE) { # \dontrun{
# Add median and MAD columns for 'indicator1'
add_mad_med_columns(data,
  indicators = "indicator1",
  group_by = "district"
)
} # }
```
