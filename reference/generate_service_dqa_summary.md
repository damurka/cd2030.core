# Generate service DQA summary

Combines the reporting rate, completeness, outlier and service
utilization results for outpatient (OPD) and inpatient (IPD) services
into one data quality table, with a row per indicator and a column per
year. The rows are numbered and grouped under three section headers,
ready for [`plot.cd_utilization_dqa()`](plot.cd_utilization_dqa.md).

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

  Numeric. The performance threshold (in percent) shown in the label.
  Default is `90`.

- labels:

  List. Optional custom labels for sections and indicators.

## Value

A wide-format tibble with summarized DQA indicators grouped by section.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

generate_service_dqa_summary(
  average_reporting_rate = calculate_average_reporting_rate(data),
  district_reporting_rate = calculate_district_reporting_rate(data),
  completeness_national = calculate_completeness_summary(data),
  district_completeness = calculate_district_completeness_summary(data),
  outliers_summary = calculate_outliers_summary(data),
  district_outliers_summary = calculate_district_outlier_summary(data),
  service_utilization = compute_service_utilization(data, admin_level = "national")
)
#> # A tibble: 11 × 8
#>    header               no    indicator_label `2019` `2020` `2021` `2022` `2023`
#>    <chr>                <chr> <chr>            <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
#>  1 1. Completeness of … 1a    % expected mon…   95     96     96     96     97  
#>  2 1. Completeness of … 1b    % districts wi…   79     85     96     89     91  
#>  3 1. Completeness of … 1c    % non-missing …  100    100    100    100    100  
#>  4 1. Completeness of … 1d    % non-missing …  100    100    100    100    100  
#>  5 1. Completeness of … 1e    % districts wi…  100    100    100    100    100  
#>  6 1. Completeness of … 1f    % districts wi…  100    100    100    100    100  
#>  7 2. Extreme outliers  2a    % OPD monthly …  100    100    100    100    100  
#>  8 2. Extreme outliers  2b    % districts wi…   95.7   93.6  100     97.9   61.7
#>  9 3. Service DQA indi… 3a    Ratio OPD/IPD …   29.9   31.8   34.3   30.0   47.4
#> 10 3. Service DQA indi… 3b    % OPD under 5     14.8   13.8   14.6   14.5   24.3
#> 11 3. Service DQA indi… 3c    % IPD under 5     16.6   13.1   14.4   14.2   16.9
```
