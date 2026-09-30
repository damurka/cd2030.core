# Generate Service DQA Summary

Generate Service DQA Summary

## Usage

``` r
generate_service_dqa_summary(
  average_reporting_rate,
  district_reporting_rate,
  completeness_national,
  district_completeness,
  outliers_summary,
  district_outliers_summary,
  service_utilization,
  threshold = .cd_method$data_quality$reporting_threshold,
  labels = NULL
)
```

## Arguments

- average_reporting_rate:

  Dataframe. Reporting rate data.

- district_reporting_rate:

  Dataframe. District reporting rate data.

- completeness_national:

  Dataframe. National completeness data.

- district_completeness:

  Dataframe. District completeness data.

- outliers_summary:

  Dataframe. National outliers data.

- district_outliers_summary:

  Dataframe. District outliers summary data.

- service_utilization:

  Dataframe. Output of compute_service_utilization('national').

- threshold:

  Numeric. The threshold to display in the label (default: 90).

- labels:

  List. Optional custom labels for sections and indicators.

## Value

A wide-format tibble with summarized DQA indicators grouped by section.
