# Add Outlier Flags Based on 5-MAD Bounds

`add_outlier5std_column` calculates and appends outlier flags for
specified indicators in a dataset. An outlier is defined as a value
falling outside the range defined by the median ± 5 times the Median
Absolute Deviation (MAD). This method is applied on a per-group basis,
allowing flexibility for grouping by columns like `district`.

## Usage

``` r
add_outlier5std_column(.data, indicators, group_by = "district")
```

## Arguments

- .data:

  A `cd_data` tibble containing health indicator data.

- indicators:

  A character vector specifying the names of the indicator columns to
  analyze for outliers.

- group_by:

  A character string or vector specifying the column(s) to group by when
  calculating the median and MAD (default is `'district'`).

## Value

A tibble with additional columns for each indicator, named
`{indicator}_outlier5std`, containing a value of `1` if the observation
is an outlier and `0` otherwise.

## Details

- **Median and MAD Calculation**: For each indicator, the median and MAD
  are calculated using data from years prior to the most recent year in
  the dataset. The last year is excluded to prevent potential
  contamination of the baseline statistics.

- **Outlier Definition**: A value is flagged as an outlier if it falls
  outside the range: Lower Bound = median - 5 \* MAD Lower Bound =
  median + 5 \* MAD

- **Grouping**: Calculations are performed separately for each group
  specified by the `group_by` parameter.

- **Generated Columns**: For each indicator, the function generates an
  outlier flag column named `{indicator}_outlier5std`. The column
  contains `1` if the value is an outlier and `0` otherwise.

## See also

[`add_mad_med_columns()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/add_mad_med_columns.md)
for computing and appending the median and MAD columns.

## Examples

``` r
if (FALSE) { # \dontrun{
# Add missing value flags for all indicators
add_outlier5std_column(data,
  indicators = "indicator1",
  group_by = "district"
)
} # }
```
