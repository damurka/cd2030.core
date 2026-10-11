# Calculate overall quality score from summaries

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

  Numeric. The performance threshold (in percent) shown in the label of
  row 1b. Default is `90`.

## Value

A tibble with calculated scores for each metric, including a summary row
for the annual quality score.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
calculate_overall_score1(
  average_reporting_rate = calculate_average_reporting_rate(data),
  district_reporting_rate = calculate_district_reporting_rate(data, threshold = 90),
  district_completeness = calculate_district_completeness_summary(data),
  outliers_summary = calculate_outliers_summary(data),
  district_outliers_summary = calculate_district_outlier_summary(data),
  ratios_summary = calculate_ratios_and_adequacy(data),
  threshold = 90
)
#> # A tibble: 10 × 8
#>    type          no    `Data Quality Metrics` `2019` `2020` `2021` `2022` `2023`
#>    <chr>         <chr> <chr>                   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
#>  1 1. Completen… 1a    % of expected monthly…  94     96     96     97     97   
#>  2 1. Completen… 1b    % of districts with c…  80     90     97     93     96   
#>  3 1. Completen… 1c    % of districts with n…  72.7   81.8   84.9   84.0   84.7 
#>  4 2. Extreme o… 2a    % of monthly values t…  92     98     99    100    100   
#>  5 2. Extreme o… 2b    % of districts with n…  91.1   88.7   88.8   91.7   87.2 
#>  6 3. Consisten… 3a    Ratio anc1/penta1        1.05   1.11   1.10   1.07   1.06
#>  7 3. Consisten… 3b    Ratio penta1/penta3      1.05   1.04   1.06   1.04   1.04
#>  8 3. Consisten… 3c    % district with anc1/…  70.2   95.7   91.5   87.2   85.1 
#>  9 3. Consisten… 3d    % district with penta…  93.6   89.4   97.9   87.2   93.6 
#> 10 3. Consisten… 4     Annual data quality s…  84.8   91.4   93.6   91.5   91.9 
```
