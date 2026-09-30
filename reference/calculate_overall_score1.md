# Calculate Overall Quality Score from Summaries

Builds the same score table as
[`calculate_overall_score()`](calculate_overall_score.md), but from
summaries that have already been calculated.

## Usage

``` r
calculate_overall_score1(
  average_reporting_rate,
  district_reporting_rate,
  district_completeness,
  outliers_summary,
  district_outliers_summary,
  ratios_summary,
  labels = NULL,
  threshold = .cd_method$data_quality$reporting_threshold
)
```

## Arguments

- average_reporting_rate:

  A `cd_average_reporting_rate` object with a `mean_rr` column by year.

- district_reporting_rate:

  A `cd_district_reporting_rate` object.

- district_completeness:

  A `cd_missing_district` object, as returned by
  [`calculate_district_completeness_summary()`](calculate_district_completeness_summary.md).

- outliers_summary:

  A `cd_outlier` object with a `mean_out_all` column by year.

- district_outliers_summary:

  A `cd_district_outliers_summary` object.

- ratios_summary:

  A `cd_ratios_and_adequacy` object.

- labels:

  Optional named list overriding the default row labels, with `header`,
  `section` and `metric` sub-lists (see
  [`calculate_overall_score()`](calculate_overall_score.md)). Default is
  `NULL`.

- threshold:

  Numeric. The district reporting rate threshold shown in the label of
  row 1b. Default is `90`.

## Value

A tibble with calculated scores for each metric, including a summary row
for the annual quality score.
