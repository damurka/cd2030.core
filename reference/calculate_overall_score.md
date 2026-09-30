# Calculate Overall Quality Score for Data Quality Metrics

This function calculates an overall quality score based on various data
quality metrics. It summarizes completeness, outlier presence, and
consistency of reporting in immunization health facility data.

## Usage

``` r
calculate_overall_score(
  .data,
  threshold,
  ratio_pairs = NULL,
  region = NULL,
  labels = NULL
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

- region:

  Optional name of an `adminlevel_1` region. If supplied, all metrics
  are calculated for that region only. Default is `NULL`.

- labels:

  Optional named list overriding the default row labels. May contain
  `header` (`h1`, `h2`, `h3`), `section` (`r1a`, `r1b`, `r1c`, `r2a`,
  `r2b`, `score`) and `metric` (for example `r_anc1_penta1`,
  `ok_anc1_penta1`) sub-lists; only the supplied entries are replaced.
  Default is `NULL`.

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
