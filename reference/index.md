# Package index

## Data Import & Preparation

Functions to load, register profiles, and prepare Countdown 2030 input
data.

- [`load_data()`](https://aphrcwaro.github.io/cd2030.core/reference/load_data.md)
  : Load Countdown 2030 data (Excel or Stata)

- [`load_cache_data()`](https://aphrcwaro.github.io/cd2030.core/reference/load_cache_data.md)
  : Initialize or load a cached Countdown 2030 connection

- [`new_countdown()`](https://aphrcwaro.github.io/cd2030.core/reference/new_countdown.md)
  :

  Create a `cd_data` object from cleaned data and resolve the indicator
  group

- [`save_data()`](https://aphrcwaro.github.io/cd2030.core/reference/save_data.md)
  : Save Processed Countdown 2030 Data to File

- [`save_dhis2_excel()`](https://aphrcwaro.github.io/cd2030.core/reference/save_dhis2_excel.md)
  : Save DHIS2 Data to an Excel Workbook

- [`save_dhis2_master_data()`](https://aphrcwaro.github.io/cd2030.core/reference/save_dhis2_master_data.md)
  : Create a Master Dataset from DHIS2 Data

- [`get_dhis2_hfd()`](https://aphrcwaro.github.io/cd2030.core/reference/get_dhis2_hfd.md)
  : Retrieve DHIS2 Health Facility Data

## External Data Sources

Import relevant global datasets to complement national data.

- [`load_un_estimates()`](https://aphrcwaro.github.io/cd2030.core/reference/load_un_estimates.md)
  : Load UN Estimates
- [`load_un_mortality_data()`](https://aphrcwaro.github.io/cd2030.core/reference/load_un_mortality_data.md)
  : Load and Filter UN Mortality Estimates
- [`load_wuenic_data()`](https://aphrcwaro.github.io/cd2030.core/reference/load_wuenic_data.md)
  : Load WUENIC Immunization Data
- [`load_survey_data()`](https://aphrcwaro.github.io/cd2030.core/reference/load_survey_data.md)
  : Load and Process Survey Data
- [`load_equity_data()`](https://aphrcwaro.github.io/cd2030.core/reference/load_equity_data.md)
  : Load and Filter Equity Data
- [`load_fpet_data()`](https://aphrcwaro.github.io/cd2030.core/reference/load_fpet_data.md)
  : Load FPET Data from CSV File or Use Provided Data
- [`load_private_sector_data()`](https://aphrcwaro.github.io/cd2030.core/reference/load_private_sector_data.md)
  : Load and Prepare Private Sector Data
- [`load_csection_estimates()`](https://aphrcwaro.github.io/cd2030.core/reference/load_csection_estimates.md)
  : Load C-section Share Estimates

## Indicator Group Management

Manage indicator groups (profiles) including overrides and custom
profiles.

- [`get_indicator_groups()`](https://aphrcwaro.github.io/cd2030.core/reference/get_indicator_groups.md)
  : Get the current indicator group definition
- [`list_indicator_groups()`](https://aphrcwaro.github.io/cd2030.core/reference/list_indicator_groups.md)
  : List available indicator group names
- [`set_selected_group()`](https://aphrcwaro.github.io/cd2030.core/reference/set_selected_group.md)
  : Set the selected indicator group globally
- [`get_selected_group()`](https://aphrcwaro.github.io/cd2030.core/reference/get_selected_group.md)
  : Get the globally selected indicator group
- [`register_indicator_group()`](https://aphrcwaro.github.io/cd2030.core/reference/register_indicator_group.md)
  : Register or override an indicator group (profile)
- [`get_indicator_group_names()`](https://aphrcwaro.github.io/cd2030.core/reference/get_indicator_group_names.md)
  : Get Indicator Group Names
- [`reset_indicator_group()`](https://aphrcwaro.github.io/cd2030.core/reference/reset_indicator_group.md)
  : Reset (remove) a group override
- [`detect_indicator_group()`](https://aphrcwaro.github.io/cd2030.core/reference/detect_indicator_group.md)
  : Auto-detect the best-matching indicator group from a vector of
  indicators

## Data Quality Assessment

Assess completeness, consistency, and reliability of routine data.

### Reporting Rates

- [`calculate_average_reporting_rate()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_average_reporting_rate.md)
  : Reporting Rate Summary by Administrative Level
- [`calculate_district_reporting_rate()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_district_reporting_rate.md)
  : District-Level Reporting Rates by Year
- [`plot(`*`<cd_average_reporting_rate>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_average_reporting_rate.md)
  : Plot Sub-National Reporting Rates by Year and Unit
- [`plot(`*`<cd_district_reporting_rate>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_district_reporting_rate.md)
  : Plot District Reporting Rate Summary
- [`tbl_sum(`*`<cd_average_reporting_rate>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/tbl_sum.cd_average_reporting_rate.md)
  : Summary for Average Reporting Rates by Year
- [`tbl_sum(`*`<cd_district_reporting_rate>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/tbl_sum.cd_district_reporting_rate.md)
  : Summary for District-Level Reporting Rates by Year

### Data Completeness

- [`calculate_completeness_summary()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_completeness_summary.md)
  : Summarize Data Completeness by Year

- [`calculate_district_completeness_summary()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_district_completeness_summary.md)
  : District-Level Completeness Summary

- [`plot(`*`<cd_completeness_summary>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_completeness_summary.md)
  : Plot Missing Summary

- [`tbl_sum(`*`<cd_completeness_summary>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/tbl_sum.cd_completeness_summary.md)
  :

  Summary for `cd_completeness_summary`

- [`tbl_sum(`*`<cd_district_completeness_summary>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/tbl_sum.cd_district_completeness_summary.md)
  :

  Summary for `cd_district_completeness_summary`

### Consistency Checks

- [`plot_comparison()`](https://aphrcwaro.github.io/cd2030.core/reference/internal_consistency.md)
  [`plot_comparison_anc1_penta1()`](https://aphrcwaro.github.io/cd2030.core/reference/internal_consistency.md)
  [`plot_comparison_penta1_penta3()`](https://aphrcwaro.github.io/cd2030.core/reference/internal_consistency.md)
  [`plot_comparison_opv1_opv3()`](https://aphrcwaro.github.io/cd2030.core/reference/internal_consistency.md)
  : Internal Consistency Plot Functions for Indicator Comparisons
- [`plot_comparison(`*`<cd_data>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot_comparison.cd_data.md)
  : Plot Comparison with Linear Fit and R-squared

### Outlier Detection

- [`calculate_outliers_summary()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_outliers_summary.md)
  : Annual Summary of Outlier-Free Reporting Rates

- [`calculate_district_outlier_summary()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_district_outlier_summary.md)
  : District-Level Outlier Summary by Year

- [`filter_adjustment_value()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_adjustment_value.md)
  : Filter one indicator’s adjustment values

- [`list_outlier_units()`](https://aphrcwaro.github.io/cd2030.core/reference/list_outlier_units.md)
  : Identify Monthly Outliers for a Single Indicator

- [`plot(`*`<cd_outlier>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_outlier.md)
  : Visualize Summary of Outlier Detection

- [`plot(`*`<cd_outlier_list>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_outlier_list.md)
  : Plot Outlier Time Series for a Region

- [`tbl_sum(`*`<cd_outliers_summary>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/tbl_sum.cd_outliers_summary.md)
  :

  Summary for `cd_outliers_summary`

- [`tbl_sum(`*`<cd_district_outliers_summary>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/tbl_sum.cd_district_outliers_summary.md)
  :

  Summary for `cd_district_outliers_summary`

### Ratio Analysis

- [`calculate_ratios_summary()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_ratios_summary.md)
  : Calculate Yearly Indicator Ratios Summary with Expected Ratios

- [`calculate_district_ratios_summary()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_district_ratios_summary.md)
  : Calculate District Adequacy Summary

- [`plot(`*`<cd_ratios_summary>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_ratios_summary.md)
  : Plot Ratios Summary for Indicator Ratios Summary Object

- [`tbl_sum(`*`<cd_ratios_summary>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/tbl_sum.cd_ratios_summary.md)
  :

  Summary for `cd_ratios_summary` Object

- [`tbl_sum(`*`<cd_district_ratios_summary>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/tbl_sum.cd_district_ratios_summary.md)
  :

  Summary for `cd_district_ratios_summary` Object

### Overall Quality Score

- [`calculate_overall_score()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_overall_score.md)
  : Calculate Overall Quality Score for Data Quality Metrics

## Data Adjustment

Adjust for incomplete reporting and handle extreme values for improved
estimates.

- [`filter_out_years()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_out_years.md)
  : Filter Dataset by Removing Specified Years

- [`generate_adjustment_values()`](https://aphrcwaro.github.io/cd2030.core/reference/generate_adjustment_values.md)
  : Generate Adjusted and Unadjusted Service Counts by Year

- [`adjust_service_data()`](https://aphrcwaro.github.io/cd2030.core/reference/adjust_service_data.md)
  : Adjust Service Data for Coverage Analysis

- [`plot(`*`<cd_adjustment_values_filtered>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_adjustment_values_filtered.md)
  : Plot Adjusted vs. Unadjusted Data for Health Indicators

- [`tbl_sum(`*`<cd_adjustment_values>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/tbl_sum.cd_adjustment_values.md)
  :

  Summary for `cd_adjustment_values` Objects

## Denominator Assessment

Compute populations and denominators required for coverage calculations.

- [`compute_indicator_numerator()`](https://aphrcwaro.github.io/cd2030.core/reference/compute_indicator_numerator.md)
  : Compute Aggregated Numerators for Health Indicators
- [`prepare_population_metrics()`](https://aphrcwaro.github.io/cd2030.core/reference/prepare_population_metrics.md)
  : Compute Population Metrics for DHIS-2 and UN Data
- [`calculate_indicator_coverage()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_indicator_coverage.md)
  : Calculate Health Coverage Indicators
- [`filter_indicator_coverage()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_indicator_coverage.md)
  : Filter Indicator Coverage for Plotting
- [`calculate_threshold()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_threshold.md)
  : Calculate Dropout Coverage for Health Indicators Below a Threshold
- [`filter_high_performers()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_high_performers.md)
  : Filter High-Performing Areas by Coverage
- [`calculate_derived_coverage()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_derived_coverage.md)
  : Generate Coverage Data with Derived Denominators
- [`plot_line_graph()`](https://aphrcwaro.github.io/cd2030.core/reference/plot_line_graph.md)
  : Plot Line Graph for Multiple Series with Dynamic Y-axis Scaling
- [`plot(`*`<cd_indicator_coverage>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_indicator_coverage.md)
  : Plot National Denominators and Coverage Indicators
- [`plot(`*`<cd_indicator_coverage_filtered>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_indicator_coverage_filtered.md)
  : Plot Coverage by Denominator Source with Survey Reference
- [`plot(`*`<cd_population_metrics>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_population_metrics.md)
  : Plot National Population or Births Metrics
- [`plot(`*`<cd_derived_coverage>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_derived_coverage.md)
  : Plot Derived vs Traditional Coverage Over Time
- [`tbl_sum(`*`<cd_indicator_coverage>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/tbl_sum.cd_indicator_coverage.md)
  : Table Summary for National Coverage Estimates
- [`tbl_sum(`*`<cd_national_denominators>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/tbl_sum.cd_national_denominators.md)
  : Summarize National Denominators Data

## Coverage & Inequality

Estimate coverage levels and inequity by geography and subgroup.

- [`calculate_coverage()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_coverage.md)
  : Combine Immunization Coverage Data
- [`filter_coverage()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_coverage.md)
  : Filter and Reshape Coverage Data
- [`calculate_inequality()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_inequality.md)
  : Analyze Subnational Health Coverage Data with Inequality Metrics
- [`filter_inequality()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_inequality.md)
  : Filter Subnational Inequality Metrics
- [`equiplot()`](https://aphrcwaro.github.io/cd2030.core/reference/equiplot.md)
  : Create Dot Plots for Equity Analysis
- [`equiplot_area()`](https://aphrcwaro.github.io/cd2030.core/reference/equiplot_area.md)
  : A Specialized Dot Plot for Area of Residence Analysis
- [`equiplot_education()`](https://aphrcwaro.github.io/cd2030.core/reference/equiplot_education.md)
  : A Specialized Dot Plot for Maternal Education Analysis
- [`equiplot_wealth()`](https://aphrcwaro.github.io/cd2030.core/reference/equiplot_wealth.md)
  : A Specialized Dot Plot for Wealth Quintile Analysis
- [`plot(`*`<cd_coverage_filtered>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_coverage_filtered.md)
  : Plot National Coverage Data
- [`plot(`*`<cd_inequality_filtered>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_inequality_filtered.md)
  : Plot Subnational Health Coverage Analysis
- [`get_mapping_data()`](https://aphrcwaro.github.io/cd2030.core/reference/get_mapping_data.md)
  : Get Mapping Data for Subnational Coverage Analysis
- [`filter_mapping_data()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_mapping_data.md)
  : Filter Mapping Data for Specific Indicator and Denominator
- [`get_country_shapefile()`](https://aphrcwaro.github.io/cd2030.core/reference/get_country_shapefile.md)
  : Load Country Shapefile for Mapping
- [`plot(`*`<cd_mapping_filtered>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_mapping_filtered.md)
  : Plot Subnational Coverage Maps by Indicator

## Mortality Analysis

Summarize and explore mortality patterns from administrative and survey
data.

- [`create_mortality_summary()`](https://aphrcwaro.github.io/cd2030.core/reference/create_mortality_summary.md)
  : Create Mortality Summary Object
- [`create_mortality_ratios()`](https://aphrcwaro.github.io/cd2030.core/reference/create_mortality_ratios.md)
  : Extract Latest Mortality Ratios for UN Comparison
- [`filter_mortality_summary()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_mortality_summary.md)
  : Filter and Prepare Mortality Rate Data for Mapping
- [`summarise_completeness_ratio()`](https://aphrcwaro.github.io/cd2030.core/reference/summarise_completeness_ratio.md)
  : Summarize Completeness-Adjusted Mortality Ratio
- [`plot(`*`<cd_mortality_summary>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_mortality_summary.md)
  : Plot Mortality Rate Indicators
- [`plot(`*`<cd_mortality_summary_filtered>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_mortality_summary_filtered.md)
  : Plot Filtered Institutional Mortality Rates
- [`plot(`*`<cd_mortality_ratio_summarised>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_mortality_ratio_summarised.md)
  : Plot Completeness of Facility Reporting Ratios

## Health Service Utilization

Analyze use of health services and trends over time.

- [`compute_service_utilization()`](https://aphrcwaro.github.io/cd2030.core/reference/compute_service_utilization.md)
  : Compute Service Utilization Metrics
- [`filter_service_utilization()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_service_utilization.md)
  : Filter and Prepare Service Utilization Data for Mapping
- [`filter_service_utilization_map()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_service_utilization_map.md)
  : Filter Service Utilization Data for a Specific Region and Indicator
- [`prepare_private_sector_plot_data()`](https://aphrcwaro.github.io/cd2030.core/reference/prepare_private_sector_plot_data.md)
  : Prepare Private Sector Plot Data
- [`get_excel_version()`](https://aphrcwaro.github.io/cd2030.core/reference/get_excel_version.md)
  : Format Service Utilization Data for Excel Export
- [`plot(`*`<cd_service_utilization_map>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_service_utilization_map.md)
  : Plot Service Utilization Indicators
- [`plot(`*`<cd_service_utilization_filtered>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_service_utilization_filtered.md)
  : Plot Filtered Service Utilization Indicators
- [`plot(`*`<cd_private_sector_plot_data>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_private_sector_plot_data.md)
  : Plot Private Sector Prevalence by Sector and Area/National Level

## Health System Performance

Generate national and sub-national service readiness metrics.

- [`calculate_health_system_metrics()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_health_system_metrics.md)
  : Calculate Health System Metrics
- [`calculate_health_system_comparison()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_health_system_comparison.md)
  : Compare Health System Metrics Across Levels
- [`plot(`*`<cd_health_system_metric>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_health_system_metric.md)
  : Plot Health Metrics for Admin 1 Units
- [`plot(`*`<cd_health_system_comparison>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_health_system_comparison.md)
  : Compare District vs Admin 1 Health Metrics
- [`plot_national_health_metric()`](https://aphrcwaro.github.io/cd2030.core/reference/plot_national_health_metric.md)
  : Plot National Health System Metrics

## Family Planning (FPET)

Generate and interpret FPET (Family Planning Estimation Tool) estimates.

- [`generate_fpet_summary()`](https://aphrcwaro.github.io/cd2030.core/reference/generate_fpet_summary.md)
  : Load and Generate FPET Output
- [`interpret()`](https://aphrcwaro.github.io/cd2030.core/reference/interpret.md)
  : Generic Interpretation Method
- [`plot(`*`<cd_fpet>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_fpet.md)
  : Plot FPET Estimates
- [`interpret(`*`<cd_fpet>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/interpret.cd_fpet.md)
  : Interpret FPET Results with Emphasis on Current Estimates

## Reporting

Document findings, generate summaries, and export shareable outputs.

- [`generate_report()`](https://aphrcwaro.github.io/cd2030.core/reference/generate_report.md)
  : Generate and Export Checks Report

## Utility Functions

Utility helpers used internally or across workflows.

- [`add_outlier5std_column()`](https://aphrcwaro.github.io/cd2030.core/reference/add_outlier5std_column.md)
  : Add Outlier Flags Based on 5-MAD Bounds

- [`add_mad_med_columns()`](https://aphrcwaro.github.io/cd2030.core/reference/add_mad_med_columns.md)
  : Add Median and MAD Columns for Indicators

- [`add_missing_column()`](https://aphrcwaro.github.io/cd2030.core/reference/add_missing_column.md)
  : Add Missing Value Flags to Health Indicators

- [`get_all_indicators()`](https://aphrcwaro.github.io/cd2030.core/reference/get_all_indicators.md)
  : Get All Indicators

- [`get_country_iso3()`](https://aphrcwaro.github.io/cd2030.core/reference/get_country_iso3.md)
  : Get Country ISO3 Code

- [`get_country_name()`](https://aphrcwaro.github.io/cd2030.core/reference/get_country_name.md)
  : Get Country Name

- [`get_named_indicators()`](https://aphrcwaro.github.io/cd2030.core/reference/get_named_indicators.md)
  : Get Named Indicator Vector

- [`get_population_column()`](https://aphrcwaro.github.io/cd2030.core/reference/get_population_column.md)
  : Get Population Denominator Column Based on Indicator Only

- [`get_indicator_without_opd_ipd()`](https://aphrcwaro.github.io/cd2030.core/reference/get_indicator_without_opd_ipd.md)
  : Get Indicators excluding indicators without denominator

- [`get_admin_columns()`](https://aphrcwaro.github.io/cd2030.core/reference/get_admin_columns.md)
  : Determine Grouping Columns for Administrative Levels

- [`get_plot_admin_column()`](https://aphrcwaro.github.io/cd2030.core/reference/get_plot_admin_column.md)
  : Determine the Administrative Column to Use for Plotting

- [`is_maternal_indicator()`](https://aphrcwaro.github.io/cd2030.core/reference/is_maternal_indicator.md)
  : Detemine if an indicator is maternal indicator

- [`robust_max()`](https://aphrcwaro.github.io/cd2030.core/reference/robust_max.md)
  : Robust Maximum Value Calculation

- [`print(`*`<cd_data>`*`)`](https://aphrcwaro.github.io/cd2030.core/reference/print.cd_data.md)
  :

  Print Method for `cd_data` Class

- [`with_cd_quiet()`](https://aphrcwaro.github.io/cd2030.core/reference/cd2030-configuration.md)
  [`local_cd_quiet()`](https://aphrcwaro.github.io/cd2030.core/reference/cd2030-configuration.md)
  : Execute Code in Quiet Mode

- [`clean_error_message()`](https://aphrcwaro.github.io/cd2030.core/reference/clean_error_message.md)
  : Clean and Validate Error Messages

- [`CacheConnection`](https://aphrcwaro.github.io/cd2030.core/reference/CacheConnection.md)
  : CacheConnection Class

- [`init_CacheConnection()`](https://aphrcwaro.github.io/cd2030.core/reference/init_CacheConnection.md)
  : Create a CacheConnection Object
