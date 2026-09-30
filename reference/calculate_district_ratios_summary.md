# Calculate District Adequacy Summary

This function calculates and summarizes the adequacy of specified
indicator ratios by year, evaluating the consistency of key health
indicators across districts. It computes the percentage of districts
meeting the adequacy criteria for each indicator ratio, based on the
specified range.

## Usage

``` r
calculate_district_ratios_summary(.data)
```

## Arguments

- .data:

  A data frame containing indicator data by district and year. The data
  frame should include all indicators specified in `ratio_pairs`.

## Value

A tibble of class `cd_district_ratios_summary`, containing the summary
of adequacy checks by year. Each column represents the percentage of
districts meeting the adequacy criteria for the specified ratio, with
overall metrics included for data interpretation and quality monitoring.

## Details

- The function dynamically calculates ratios between the specified
  indicator pairs.

- For each year, it computes the percentage of districts where the
  calculated ratio for each indicator pair falls within the adequate
  range.

- The summary table aids in monitoring indicator consistency across
  districts and over time, providing insights into areas where health
  service delivery may vary.

## Examples

``` r
if (FALSE) { # \dontrun{
# Calculate adequacy summary for ANC1/Penta1 and other indicator ratios
calculate_district_ratio_summary(cd_data)
} # }
```
