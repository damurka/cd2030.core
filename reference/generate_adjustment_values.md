# Generate Adjusted and Unadjusted Service Counts by Year

`generate_adjustment_values` calculates yearly unadjusted and adjusted
service counts for each indicator within a `cd_data` dataset, applying
the specified adjustment type. It provides a comparison of raw and
adjusted values for analysis purposes.

## Usage

``` r
generate_adjustment_values(
  .data,
  adjustment = c("default", "custom", "none"),
  k_factors = NULL
)
```

## Arguments

- .data:

  A `cd_data` dataframe containing service data for adjustments.

- adjustment:

  A character string specifying the adjustment type:

  - `"default"`: Applies preset k-factors (e.g., 0.25) for each
    indicator group.

  - `"custom"`: Uses user-specified `k_factors` values for each
    indicator group.

  - `"none"`: Skips adjustments, returning only the raw data.

- k_factors:

  A named numeric vector of custom k-factor values between 0 and 1 for
  each indicator group (e.g., `c(anc = 0.3, idelv = 0.2, ...)`).
  Required if `adjustment = "custom"`.

## Value

A `cd_adjustment_values` tibble containing:

- Columns for unadjusted values, suffixed with `_raw`.

- Columns for adjusted values, suffixed with `_adj`.

- A `year` column indicating the year of each count.

## Details

This function performs the following steps:

1.  **Data Validation**: Ensures `.data` is of the `cd_data` class and
    `adjustment` is correctly specified.

2.  **Unadjusted Summation**: Calculates the yearly sums of unadjusted
    service counts.

3.  **Adjusted Summation**: Applies
    [`adjust_service_data()`](https://aphrcwaro.github.io/cd2030.core/reference/adjust_service_data.md)
    to compute adjusted values, then calculates the yearly sums.

4.  **Combining Results**: Merges unadjusted and adjusted yearly counts
    for comparison.

## See also

[`adjust_service_data()`](https://aphrcwaro.github.io/cd2030.core/reference/adjust_service_data.md)
for the detailed adjustment function.

## Examples

``` r
if (FALSE) { # \dontrun{
# Generate adjustment values with default k-factors
adjustment_values_default <- generate_adjustment_values(data, adjustment = "default")

# Generate adjustment values with custom k-factors
custom_k <- c(anc = 0.3, idelv = 0.2, pnc = 0.35, vacc = 0.4, opd = 0.3, ipd = 0.25)
adjustment_values_custom <-
  generate_adjustment_values(data, adjustment = "custom", k_factors = custom_k)

# Generate unadjusted values only
unadjusted_values <- generate_adjustment_values(data, adjustment = "none")
} # }
```
