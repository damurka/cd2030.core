# Adjust Service Data for Coverage Analysis

The `adjust_service_data` function processes DHIS-2 health service data,
correcting for incomplete reporting, applying k-factor adjustments for
accurate scaling, and managing outliers for consistency in data
analysis. This standardization supports reliable comparisons in
immunization coverage and health service utilization studies.

## Usage

``` r
adjust_service_data(
  .data,
  adjustment = c("default", "custom", "none"),
  k_factors = NULL
)
```

## Arguments

- .data:

  A `cd_data` dataframe, typically containing health facility data from
  DHIS-2 with monthly service counts by district.

- adjustment:

  A character string specifying the type of adjustment to apply:

  - **"default"**: Applies a default k-factor of 0.25 across all
    indicator groups.

  - **"custom"**: Uses user-defined `k_factors` for different indicator
    groups, with values between 0 and 1.

  - **"none"**: Returns the data without any adjustments.

- k_factors:

  A named numeric vector of custom k-factor values between 0 and 1 for
  each indicator group (e.g., `c(anc = 0.3, idelv = 0.2, ...)`). Used
  only if `adjustment = "custom"`.

## Value

A `cd_adjusted_data` object containing adjusted service data, where
outliers are flagged and managed, and missing values are imputed.

## Details

This function prepares service data through a series of steps to ensure
data quality and consistency:

1.  **Validation**: Checks the structure of `.data` and ensures that the
    `adjustment` argument is valid. For `custom` adjustments,
    `k_factors` must be specified and contain valid values.

2.  **k-Factor Defaults**: Default k-factor values are set to 0.25 for
    each indicator group, unless overridden by user-provided values in
    `k_factors`.

3.  **Reporting Completeness**: Flags any district-year reporting rates
    below 75% and imputes missing data using district-level medians to
    account for reporting inconsistencies.

4.  **k-Factor Scaling**: Adjusts service counts based on the k-factor
    and reporting rate using the following scaling formula:
    \$\$AdjustedValue = Value \times \left(1 +
    \left(\frac{1}{ReportingRate/100} - 1\right) \times k\right)\$\$
    where `ReportingRate` is the reporting rate in percent, and `k` is
    the k-factor for the indicator group.

5.  **Outlier Detection**: Identifies and flags extreme outliers using
    Hampel's X84 method, marking values that exceed 5 Median Absolute
    Deviations (MAD) from the median.

6.  **Data Imputation**: Replaces remaining missing values with
    district-level medians to ensure data completeness.

## See also

[`new_countdown()`](https://aphrcwaro.github.io/cd2030.core/reference/new_countdown.md)
for creating `cd_data` objects and
[`generate_adjustment_values()`](https://aphrcwaro.github.io/cd2030.core/reference/generate_adjustment_values.md)
for generating adjustment summaries.

## Examples

``` r
if (FALSE) { # \dontrun{
# Default adjustment
adjusted_data <- adjust_service_data(data, adjustment = "default")

# Custom adjustment with specific k-factors
custom_k <- c(
  anc = 0.3, idelv = 0.2, pnc = 0.35, vacc = 0.4,
  opd = 0.3, ipd = 0.25
)
adjusted_data_custom <- adjust_service_data(data,
  adjustment = "custom",
  k_factors = custom_k
)

# No adjustment
unadjusted_data <- adjust_service_data(data, adjustment = "none")
} # }
```
