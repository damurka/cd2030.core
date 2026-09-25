# Calculate Overall Quality Score for Data Quality Metrics

This function calculates an overall quality score based on various data
quality metrics. It summarizes completeness, outlier presence, and
consistency of reporting in immunization health facility data.

## Usage

``` r
calculate_overall_score(
  .data,
  threshold,
  ratio_pairs = list(ratioAP = c("anc1", "penta1"), ratioPP = c("penta1", "penta3")),
  region = NULL
)
```

## Arguments

- .data:

  A data frame of type `cd_data` containing facility data including
  annual reporting rates, completeness, and consistency indicators.

- threshold:

  The data reporting rate threshold.

- ratio_pairs:

  description

## Value

A tibble with calculated scores for each metric, including a summary row
for the annual quality score. The result is ordered by metric codes and
ready for reporting in tabular or graphical form.

## Details

`calculate_overall_score` processes multiple data quality indicators:

- **Completeness metrics**: Percentage of expected reports, districts
  with complete reporting, and districts with no missing values.

- **Outlier metrics**: Percentage of monthly values and districts
  without extreme outliers.

- **Consistency ratios**: Ratios between different immunization
  indicators to ensure internal consistency.

The function calculates averages for the selected metrics and includes a
row summarizing the annual data quality score.

## Examples

``` r
if (FALSE) { # \dontrun{
calculate_overall_score(.data = my_data)
} # }
```
