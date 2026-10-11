# Calculate indicator ratios and adequacy flags

Computes ratios for specified pairs of indicators dynamically and flags
whether each calculated ratio falls within an adequate range, per
district and year. This function is an intermediate utility used to
standardize ratio calculations and adequacy checks across indicator
pairs.

## Usage

``` r
calculate_ratios_and_adequacy(
  .data,
  ratio_pairs = NULL,
  adequate_range = .cd_method$data_quality$ratio_adequate_range,
  region = NULL
)
```

## Arguments

- .data:

  A data frame of type `cd_data`.

- ratio_pairs:

  A named list of indicator pairs for which ratios should be calculated.

  - Each pair should be a character vector of length two, with the first
    element as the numerator and the second as the denominator. Default
    is:
    `list("ratioAP" = c("anc1", "penta1"), "ratioPP" = c("penta1", "penta3"), "ratioOO" = c("opv1", "opv3"))`.

  - Each name in the list becomes the name of the resulting ratio
    column.

- adequate_range:

  A numeric vector of length two specifying the inclusive lower and
  upper bounds for the adequate range, typically between `1` and `1.5`.
  Ratios within this range are flagged as adequate.

- region:

  Optional. Restrict analysis to one region (`adminlevel_1`).

## Value

A data frame with columns for:

- **Summed indicators by district and year**: Summed values for each
  indicator across districts within the specified `year`, based on input
  in `ratio_pairs`.

- **Ratios**: Each ratio is calculated as the sum of the specified
  numerator divided by the sum of the specified denominator for each
  pair.

- **Adequacy flags**: For each ratio, an adequacy flag (e.g.,
  `adeq_ratioAP`) is generated, set to `1` if the ratio falls within the
  `adequate_range`, and `0` otherwise.

- The output is aggregated by year and includes means of ratios and
  adequacy flags.

## Details

This function standardizes ratio calculations by dynamically computing
ratios and adequacy flags for specified pairs of indicators. It operates
in three main stages:

1.  **Summing Indicators**: Calculates the sum of each indicator by
    `district` and `year`.

2.  **Calculating Ratios**: Divides the summed numerator by the summed
    denominator for each pair in `ratio_pairs`, creating a column for
    each ratio.

3.  **Checking Adequacy**: Flags each ratio as adequate if it falls
    within the specified `adequate_range`, returning `1` for adequate
    and `0` otherwise.

## See also

[`calculate_ratios_summary()`](calculate_ratios_summary.md) and
[`calculate_district_ratios_summary()`](calculate_district_ratios_summary.md),
which summarise the result.

## Examples

``` r
if (FALSE) { # \dontrun{
# Calculate ratios and adequacy checks using custom ranges
calculate_ratios_and_adequacy(data,
  ratio_pairs = list(
    "ratioAP" = c("anc1", "penta1"),
    "ratioPP" = c("penta1", "penta3")
  ),
  adequate_range = c(1, 1.5)
)
} # }
```
