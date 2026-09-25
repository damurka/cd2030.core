# Add Missing Value Flags to Health Indicators

`add_missing_column` assesses data quality by identifying missing values
for specified health indicators. It generates new columns for each
indicator, flagging values as 'Missing' (`1`) or 'Non-Missing' (`0`) to
support downstream quality control and analysis.

## Usage

``` r
add_missing_column(.data, indicators)
```

## Arguments

- .data:

  A data frame containing health indicator data.

- indicators:

  A character vector specifying the names of the indicator columns to
  analyze for outliers.

## Value

A data frame containing:

- **Missingness Flags**: For each indicator, a column prefixed with
  `mis_` indicating missingness (`1` for missing, `0` otherwise).

- `district` and `year` columns to maintain grouping information.

## Details

- **Missingness Assessment**: Each indicator is processed to flag
  missing values (`NA`) with `1` (missing) or `0` (non-missing). The
  resulting columns are prefixed with `mis_` followed by the original
  indicator name (e.g., `mis_indicator1`).

- **Group Preservation**: The output retains the `district` and `year`
  columns to ensure grouping information remains intact.

## Examples

``` r
if (FALSE) { # \dontrun{
# dd missing value flags for all indicators
add_missing_column(data)
} # }
```
