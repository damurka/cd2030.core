# Package index

## Data Import & Preparation

Functions to load, register profiles, and prepare Countdown 2030 input
data.

- [`load_data()`](load_data.md) : Load Countdown 2030 data (Excel or
  Stata)

- [`load_cache_data()`](load_cache_data.md) : Initialize or load a
  cached Countdown 2030 connection

- [`new_countdown()`](new_countdown.md) :

  Create a `cd_data` object from cleaned data and resolve the indicator
  group

- [`save_data()`](save_data.md) : Save Processed Countdown 2030 Data to
  File

- [`save_dhis2_excel()`](save_dhis2_excel.md) : Save DHIS2 Data to an
  Excel Workbook

- [`save_dhis2_master_data()`](save_dhis2_master_data.md) : Create a
  Master Dataset from DHIS2 Data

- [`load_excel_parts()`](load_excel_parts.md) : Read & clean every
  Countdown 2030 Excel sheet, without merging them

- [`merge_and_standardize()`](merge_and_standardize.md) :

  Merge and standardize an
  already-[`load_excel_parts()`](../reference/load_excel_parts.md)-ed
  set of sheets

- [`resolve_country_best_effort()`](resolve_country_best_effort.md) :
  Best-effort, non-aborting country resolution from a raw Admin sheet

- [`generate_admin1_keys()`](generate_admin1_keys.md) : Generate a
  simple, stable-within-one-load synthetic key per admin-1 region

- [`read_shapefile_folder()`](read_shapefile_folder.md) : Read a
  user-uploaded shapefile folder

## The Dataset (CacheConnection)

One dataset and everything chosen about it (adjustments, denominators,
surveys, mappings, chart options, reports), saved as an .rds cache next
to the data file. Every page of the apps reads and writes it.

- [`CacheConnection`](CacheConnection.md) : CacheConnection Class
- [`init_CacheConnection()`](init_CacheConnection.md) : Create a
  CacheConnection Object

## External Data Sources

Import relevant global datasets to complement national data.

- [`load_un_estimates()`](load_un_estimates.md) : Load UN Estimates
- [`load_un_mortality_data()`](load_un_mortality_data.md) : Load and
  Filter UN Mortality Estimates
- [`load_wuenic_data()`](load_wuenic_data.md) : Load WUENIC Immunization
  Data
- [`load_survey_data()`](load_survey_data.md) : Load and Process Survey
  Data
- [`load_equity_data()`](load_equity_data.md) : Load and Filter Equity
  Data
- [`load_fpet_data()`](load_fpet_data.md) : Load FPET Data from CSV File
  or Use Provided Data
- [`load_private_sector_data()`](load_private_sector_data.md) : Load and
  Prepare Private Sector Data
- [`load_csection_estimates()`](load_csection_estimates.md) : Load
  C-section Share Estimates

## Indicator Group Management

Manage indicator groups (profiles) including overrides and custom
profiles.

- [`get_indicator_groups()`](get_indicator_groups.md) : Get the current
  indicator group definition
- [`list_indicator_groups()`](list_indicator_groups.md) : List available
  indicator group names
- [`set_selected_group()`](set_selected_group.md) : Set the selected
  indicator group globally
- [`get_selected_group()`](get_selected_group.md) : Get the globally
  selected indicator group
- [`register_indicator_group()`](register_indicator_group.md) : Register
  or override an indicator group (profile)
- [`get_indicator_group_names()`](get_indicator_group_names.md) : Get
  Indicator Group Names
- [`reset_indicator_group()`](reset_indicator_group.md) : Reset (remove)
  a group override
- [`detect_indicator_group()`](detect_indicator_group.md) : Auto-detect
  the best-matching indicator group from a vector of indicators

## Data Quality Assessment

Assess completeness, consistency, and reliability of routine data.

### Load Checks

Checks the Load Data wizard runs on the uploaded sheets (before they are
merged) and on a loaded dataset. Each returns its findings (or NULL) and
never stops the load.

- [`run_all_quality_checks()`](run_all_quality_checks.md) : Run every
  non-structural quality check against an already-loaded cache, without
  aborting
- [`check_admin_columns()`](check_admin_columns.md) : Check the
  Admin_data sheet has the columns every later step assumes exist
- [`check_admin_pairing_consistency()`](check_admin_pairing_consistency.md)
  : Check a district's admin-1 pairing is stable within the Admin sheet
  itself
- [`check_country_recognized()`](check_country_recognized.md) : Check
  the Admin sheet's single country value is actually a recognized
  country name, pre-merge
- [`check_district_consistency()`](check_district_consistency.md) :
  Check a district's admin-1 pairing and spelling are stable across
  years
- [`check_district_cross_sheet()`](check_district_cross_sheet.md) :
  Check districts match between the Admin sheet and every other sheet,
  both directions
- [`check_district_year_completeness()`](check_district_year_completeness.md)
  : Check every district appears in every year present in the Population
  sheet
- [`check_indicator_emptiness()`](check_indicator_emptiness.md) : Flag
  indicators that are entirely empty across the whole dataset
- [`check_indicator_emptiness_presheet()`](check_indicator_emptiness_presheet.md)
  : Flag indicators entirely empty across every service sheet, pre-merge
- [`check_month_language_consistency()`](check_month_language_consistency.md)
  : Flag calendar months that different rows/sheets label with different
  raw text
- [`check_month_presence()`](check_month_presence.md) : Check every
  district-year has all 12 calendar months present
- [`check_month_presence_presheet()`](check_month_presence_presheet.md)
  : Check every district-year has all 12 calendar months present,
  pre-merge
- [`check_month_validity()`](check_month_validity.md) : Check every
  row's month string parsed to a real calendar month
- [`check_month_validity_presheet()`](check_month_validity_presheet.md)
  : Check every row's month string parses to a real calendar month,
  pre-merge
- [`check_population_service_collision()`](check_population_service_collision.md)
  : Flag district-years where a service indicator looks like it was
  mixed up with population data
- [`check_population_service_collision_presheet()`](check_population_service_collision_presheet.md)
  : Flag district-years where a service indicator looks mixed up with
  population data, pre-merge
- [`check_population_vs_births()`](check_population_vs_births.md) :
  Check that estimated population live births aren't lower than reported
  institutional counts
- [`check_shapefile_admin_names()`](check_shapefile_admin_names.md) :
  Flag dataset admin-1 names that have no matching shapefile region
- [`check_single_country()`](check_single_country.md) : Check the
  Admin_data sheet names exactly one country
- [`check_survey_admin_names()`](check_survey_admin_names.md) : Flag
  dataset admin-1 names that have no matching survey region

### Reporting Rates

- [`calculate_average_reporting_rate()`](calculate_average_reporting_rate.md)
  : Reporting Rate Summary by Administrative Level
- [`calculate_district_reporting_rate()`](calculate_district_reporting_rate.md)
  : District-Level Reporting Rates by Year
- [`plot(`*`<cd_average_reporting_rate>`*`)`](plot.cd_average_reporting_rate.md)
  : Plot Sub-National Reporting Rates by Year and Unit
- [`plot(`*`<cd_district_reporting_rate>`*`)`](plot.cd_district_reporting_rate.md)
  : Plot District Reporting Rate Summary
- [`tbl_sum(`*`<cd_average_reporting_rate>`*`)`](tbl_sum.cd_average_reporting_rate.md)
  : Summary for Average Reporting Rates by Year
- [`tbl_sum(`*`<cd_district_reporting_rate>`*`)`](tbl_sum.cd_district_reporting_rate.md)
  : Summary for District-Level Reporting Rates by Year

### Data Completeness

- [`calculate_completeness_summary()`](calculate_completeness_summary.md)
  : Summarize Data Completeness by Year

- [`calculate_district_completeness_summary()`](calculate_district_completeness_summary.md)
  : District-Level Completeness Summary

- [`plot(`*`<cd_completeness_summary>`*`)`](plot.cd_completeness_summary.md)
  : Plot Missing Summary

- [`tbl_sum(`*`<cd_completeness_summary>`*`)`](tbl_sum.cd_completeness_summary.md)
  :

  Summary for `cd_completeness_summary`

- [`tbl_sum(`*`<cd_district_completeness_summary>`*`)`](tbl_sum.cd_district_completeness_summary.md)
  :

  Summary for `cd_district_completeness_summary`

### Consistency Checks

- [`plot_comparison()`](internal_consistency.md)
  [`plot_comparison_anc1_penta1()`](internal_consistency.md)
  [`plot_comparison_penta1_penta3()`](internal_consistency.md)
  [`plot_comparison_opv1_opv3()`](internal_consistency.md) : Internal
  Consistency Plot Functions for Indicator Comparisons
- [`plot_comparison(`*`<cd_data>`*`)`](plot_comparison.cd_data.md) :
  Plot Comparison with Linear Fit and R-squared

### Outlier Detection

- [`calculate_outliers_summary()`](calculate_outliers_summary.md) :
  Annual Summary of Outlier-Free Reporting Rates

- [`calculate_district_outlier_summary()`](calculate_district_outlier_summary.md)
  : District-Level Outlier Summary by Year

- [`filter_adjustment_value()`](filter_adjustment_value.md) : Filter one
  indicator’s adjustment values

- [`list_outlier_units()`](list_outlier_units.md) : Identify Monthly
  Outliers by District

- [`plot(`*`<cd_outlier>`*`)`](plot.cd_outlier.md) : Visualize Summary
  of Outlier Detection

- [`plot(`*`<cd_outlier_list>`*`)`](plot.cd_outlier_list.md) : Plot
  Outlier Time Series for a Region

- [`tbl_sum(`*`<cd_outliers_summary>`*`)`](tbl_sum.cd_outliers_summary.md)
  :

  Summary for `cd_outliers_summary`

- [`tbl_sum(`*`<cd_district_outliers_summary>`*`)`](tbl_sum.cd_district_outliers_summary.md)
  :

  Summary for `cd_district_outliers_summary`

### Ratio Analysis

- [`calculate_ratios_summary()`](calculate_ratios_summary.md) :
  Calculate Yearly Indicator Ratios Summary with Expected Ratios

- [`calculate_district_ratios_summary()`](calculate_district_ratios_summary.md)
  : Calculate District Adequacy Summary

- [`plot(`*`<cd_ratios_summary>`*`)`](plot.cd_ratios_summary.md) : Plot
  Ratios Summary for Indicator Ratios Summary Object

- [`tbl_sum(`*`<cd_ratios_summary>`*`)`](tbl_sum.cd_ratios_summary.md) :

  Summary for `cd_ratios_summary` Object

- [`tbl_sum(`*`<cd_district_ratios_summary>`*`)`](tbl_sum.cd_district_ratios_summary.md)
  :

  Summary for `cd_district_ratios_summary` Object

### Overall Quality Score

- [`calculate_overall_score()`](calculate_overall_score.md) : Calculate
  Overall Quality Score for Data Quality Metrics
- [`calculate_overall_score1()`](calculate_overall_score1.md) :
  Calculate Overall Quality Score from Summaries
- [`plot(`*`<cd_overall_score>`*`)`](plot.cd_overall_score.md) : Plot S3
  method for Overall Score
- [`plot(`*`<cd_missing_district>`*`)`](plot.cd_missing_district.md) :
  Plot Percent of Districts with Complete Data

## Data Adjustment

Adjust for incomplete reporting and handle extreme values for improved
estimates: the settings (the years and areas removed; completeness,
outliers and missing values everywhere or by region or district) and
what the checks found beside them.

- [`filter_out_years()`](filter_out_years.md) : Filter Dataset by
  Removing Specified Years

- [`generate_adjustment_values()`](generate_adjustment_values.md) :
  Generate Adjusted and Unadjusted Service Counts by Year

- [`adjust_service_data()`](adjust_service_data.md) : Adjust Service
  Data for Coverage Analysis

- [`adjustment_settings_default()`](adjustment_settings_default.md) :
  The Countdown default adjustment settings

- [`adjustment_settings_from_k()`](adjustment_settings_from_k.md) :
  Adjustment settings from the older k-factors and excluded years

- [`adjustment_settings_check()`](adjustment_settings_check.md) : Check
  and tidy adjustment settings

- [`adjustment_settings_footnote()`](adjustment_settings_footnote.md) :
  What the adjustment settings say, as the reports' footnote

- [`adjustment_steps_used()`](adjustment_steps_used.md) : Which
  adjustment steps an indicator gets

- [`adjustment_evidence()`](adjustment_evidence.md) : What the data
  quality checks found, for the Data Adjustment page

- [`plot(`*`<cd_adjustment_values_filtered>`*`)`](plot.cd_adjustment_values_filtered.md)
  : Plot Adjusted vs. Unadjusted Data for Health Indicators

- [`tbl_sum(`*`<cd_adjustment_values>`*`)`](tbl_sum.cd_adjustment_values.md)
  :

  Summary for `cd_adjustment_values` Objects

## Denominator Assessment

Compute populations and denominators required for coverage calculations.

- [`compute_indicator_numerator()`](compute_indicator_numerator.md) :
  Compute Aggregated Numerators for Health Indicators
- [`prepare_population_metrics()`](prepare_population_metrics.md) :
  Compute Population Metrics for DHIS-2 and UN Data
- [`calculate_indicator_coverage()`](calculate_indicator_coverage.md) :
  Calculate Health Coverage Indicators
- [`calculate_threshold()`](calculate_threshold.md) : Calculate
  Coverage/Dropout Threshold Attainment
- [`filter_high_performers()`](filter_high_performers.md) : Filter
  High-Performing Areas by Coverage
- [`calculate_derived_coverage()`](calculate_derived_coverage.md) :
  Generate Coverage Data with Derived Denominators
- [`plot_line_graph()`](plot_line_graph.md) : Plot Line Graph for
  Multiple Series with Dynamic Y-axis Scaling
- [`plot(`*`<cd_indicator_coverage>`*`)`](plot.cd_indicator_coverage.md)
  : Plot National Denominators and Coverage Indicators
- [`plot(`*`<cd_population_metrics>`*`)`](plot.cd_population_metrics.md)
  : Plot National Population or Births Metrics
- [`plot(`*`<cd_derived_coverage>`*`)`](plot.cd_derived_coverage.md) :
  Plot Derived vs Traditional Coverage Over Time
- [`tbl_sum(`*`<cd_indicator_coverage>`*`)`](tbl_sum.cd_indicator_coverage.md)
  : Table Summary for National Coverage Estimates
- [`tbl_sum(`*`<cd_national_denominators>`*`)`](tbl_sum.cd_national_denominators.md)
  : Summarize National Denominators Data

## Coverage & Inequality

Estimate coverage levels and inequity by geography and subgroup.

- [`filter_coverage()`](filter_coverage.md) : Filter and Reshape
  Coverage Data
- [`calculate_coverage()`](calculate_coverage.md) : Combine Immunization
  Coverage Data
- [`get_coverage_indicators()`](get_coverage_indicators.md) : Get
  Indicators for coverage calculation
- [`generate_coverage_data()`](generate_coverage_data.md) : Generate
  Coverage Data for Continuum of Care
- [`plot(`*`<cd_coverage>`*`)`](plot.cd_coverage.md) : Plot Coverage by
  Region
- [`plot(`*`<cd_coverage_selected>`*`)`](plot.cd_coverage_selected.md) :
  Plot S3 method for Coverage Data
- [`plot(`*`<cd_threshold>`*`)`](plot.cd_threshold.md) : Plot Target
  Threshold Attainment Over Time
- [`calculate_inequality()`](calculate_inequality.md) : Analyze
  Subnational Health Coverage Data with Inequality Metrics
- [`filter_inequality()`](filter_inequality.md) : Filter Subnational
  Inequality Metrics
- [`equiplot()`](equiplot.md) : Create Dot Plots for Equity Analysis
- [`equiplot_area()`](equiplot_area.md) : A Specialized Dot Plot for
  Area of Residence Analysis
- [`equiplot_education()`](equiplot_education.md) : A Specialized Dot
  Plot for Maternal Education Analysis
- [`equiplot_wealth()`](equiplot_wealth.md) : A Specialized Dot Plot for
  Wealth Quintile Analysis
- [`plot(`*`<cd_coverage_filtered>`*`)`](plot.cd_coverage_filtered.md) :
  Plot National Coverage Data
- [`plot(`*`<cd_inequality_filtered>`*`)`](plot.cd_inequality_filtered.md)
  : Plot Subnational Health Coverage Analysis
- [`get_mapping_data()`](get_mapping_data.md) : Get Mapping Data for
  Subnational Coverage Analysis
- [`filter_mapping_data()`](filter_mapping_data.md) : Filter Mapping
  Data for Specific Indicator and Denominator
- [`get_country_shapefile()`](get_country_shapefile.md) : Load Country
  Shapefile for Mapping
- [`plot(`*`<cd_mapping_filtered>`*`)`](plot.cd_mapping_filtered.md) :
  Plot Subnational Coverage Maps by Indicator

## Mortality Analysis

Summarize and explore mortality patterns from administrative and survey
data.

- [`create_mortality_summary()`](create_mortality_summary.md) : Create
  Mortality Summary Object
- [`create_mortality_ratios()`](create_mortality_ratios.md) : Extract
  Latest Mortality Ratios for UN Comparison
- [`filter_mortality_summary()`](filter_mortality_summary.md) : Filter
  and Prepare Mortality Rate Data for Mapping
- [`summarise_completeness_ratio()`](summarise_completeness_ratio.md) :
  Summarize Completeness-Adjusted Mortality Ratio
- [`plot(`*`<cd_mortality_summary>`*`)`](plot.cd_mortality_summary.md) :
  Plot Mortality Rate Indicators
- [`plot(`*`<cd_mortality_summary_filtered>`*`)`](plot.cd_mortality_summary_filtered.md)
  : Plot Filtered Institutional Mortality Rates
- [`plot(`*`<cd_mortality_ratio_summarised>`*`)`](plot.cd_mortality_ratio_summarised.md)
  : Plot Completeness of Facility Reporting Ratios
- [`plot_mortality_plausibility()`](plot_mortality_plausibility.md) :
  Plot Subnational Mortality Plausibility

## Health Service Utilization

Analyze use of health services and trends over time.

- [`compute_service_utilization()`](compute_service_utilization.md) :
  Compute Service Utilization Metrics
- [`filter_service_utilization()`](filter_service_utilization.md) :
  Filter Service Utilization Data for a Specific Region and Indicator
- [`prepare_private_sector_plot_data()`](prepare_private_sector_plot_data.md)
  : Prepare Private Sector Plot Data
- [`get_excel_version()`](get_excel_version.md) : Format Service
  Utilization Data for Excel Export
- [`plot(`*`<cd_service_utilization_filtered>`*`)`](plot.cd_service_utilization_filtered.md)
  : Plot Service Utilization Indicators
- [`plot(`*`<cd_private_sector_plot_data>`*`)`](plot.cd_private_sector_plot_data.md)
  : Plot Private Sector Prevalence by Sector and Area/National Level
- [`prepare_mapping_service_utlization()`](prepare_mapping_service_utlization.md)
  : Filter and Prepare Service Utilization Data for Mapping
- [`plot(`*`<cd_service_utilization_prepared>`*`)`](plot.cd_service_utilization_prepared.md)
  : Plot Filtered Service Utilization Indicators
- [`generate_admin1_service_utilization()`](generate_admin1_service_utilization.md)
  : Generate Service Utilization Admin 1 Data
- [`plot(`*`<cd_service_utilization_admin1>`*`)`](plot.cd_service_utilization_admin1.md)
  : Plot S3 method for Service Utilization Admin1
- [`generate_admin1_mch_curative_index()`](generate_admin1_mch_curative_index.md)
  : Generate MCH vs Curative Index Data
- [`plot(`*`<cd_mch_curative_index>`*`)`](plot.cd_mch_curative_index.md)
  : Plot S3 method for MCH vs Curative Index
- [`generate_service_dqa_summary()`](generate_service_dqa_summary.md) :
  Generate Service DQA Summary
- [`plot(`*`<cd_utilization_dqa>`*`)`](plot.cd_utilization_dqa.md) :
  Plot S3 method for Service DQA Summary

## Health System Performance

Generate national and sub-national service readiness metrics.

- [`calculate_health_system_metrics()`](calculate_health_system_metrics.md)
  : Calculate Health System Metrics
- [`calculate_health_system_comparison()`](calculate_health_system_comparison.md)
  : Compare Health System Metrics Across Levels
- [`plot(`*`<cd_health_system_metric>`*`)`](plot.cd_health_system_metric.md)
  : Plot Health Metrics for Admin 1 Units
- [`plot(`*`<cd_health_system_comparison>`*`)`](plot.cd_health_system_comparison.md)
  : Compare District vs Admin 1 Health Metrics
- [`plot_national_health_metric()`](plot_national_health_metric.md) :
  Plot National Health System Metrics
- [`generate_health_system_table()`](generate_health_system_table.md) :
  Generate Health System Metrics Data
- [`plot(`*`<cd_health_system_table>`*`)`](plot.cd_health_system_table.md)
  : Plot S3 method for Health System Metrics
- [`generate_phc_scatter_data()`](generate_phc_scatter_data.md) :
  Generate PHC Performance Scatter Data
- [`plot(`*`<cd_phc_scatter>`*`)`](plot.cd_phc_scatter.md) : Plot S3
  method for PHC Performance Scatter
- [`generate_private_sector_data()`](generate_private_sector_data.md) :
  Generate Private Sector Ownership Data
- [`plot(`*`<cd_private_sector>`*`)`](plot.cd_private_sector.md) : Plot
  S3 method for Private Sector Ownership

## Family Planning (FPET)

Generate and interpret FPET (Family Planning Estimation Tool) estimates.

- [`generate_fpet_summary()`](generate_fpet_summary.md) : Load and
  Generate FPET Output
- [`interpret()`](interpret.md) : Generic Interpretation Method
- [`plot(`*`<cd_fpet_data>`*`)`](plot.cd_fpet_data.md) : Plot Family
  Planning Estimation Tool (FPET) Data
- [`interpret(`*`<cd_fpet_data>`*`)`](interpret.cd_fpet_data.md) :
  Interpret FPET Results with Emphasis on Current Estimates

## Bayesian Coverage Model

Coverage modelled with bayescoveragemodel / bayescoveragedeploy
(suggested packages, from <https://alkemalab.r-universe.dev>).

- [`generate_bayes_model()`](generate_bayes_model.md) : Generate
  Bayesian Coverage Model Object
- [`plot(`*`<cd_bayes_model>`*`)`](plot.cd_bayes_model.md) : Plot S3
  method for Bayesian Coverage Model

## Reports and Charts

Countdown’s content for datasuite.ui’s report builder: the standard
reports, the charts and tables a report can hold, a dataset’s report
context; and the saved chart options every chart is finished with.

- [`report_presets()`](report_presets.md) : The standard reports
- [`report_block_kinds()`](report_block_kinds.md) : The charts and
  tables a report can contain
- [`cd_report_context()`](cd_report_context.md) : The report context of
  a dataset
- [`cd_chart_catalog()`](cd_chart_catalog.md) : The charts that have
  saved options
- [`cd_chart_id()`](cd_chart_id.md) : The id of a chart
- [`cd_finish_plot()`](cd_finish_plot.md) : Finish a plot: apply the
  chart options

## Shiny Apps

The Countdown pages, Load Data wizard, filters and app frame (cd_app())
the apps are built from.

- [`countdown-pages`](countdown-pages.md)
  [`adjustment_changes_server`](countdown-pages.md)
  [`adjustment_changes_ui`](countdown-pages.md)
  [`calculate_ratios_server`](countdown-pages.md)
  [`calculate_ratios_ui`](countdown-pages.md)
  [`cd_admin_level_choices`](countdown-pages.md)
  [`cd_admin_level_server`](countdown-pages.md)
  [`cd_admin_level_ui`](countdown-pages.md)
  [`cd_admin_parts`](countdown-pages.md) [`cd_app`](countdown-pages.md)
  [`cd_cfg`](countdown-pages.md)
  [`cd_coverage_plot_server`](countdown-pages.md)
  [`cd_coverage_plot_toolbar_ui`](countdown-pages.md)
  [`cd_coverage_plot_ui`](countdown-pages.md)
  [`cd_default_indicator_set`](countdown-pages.md)
  [`cd_default_indicators`](countdown-pages.md)
  [`cd_denominator_chip_keys`](countdown-pages.md)
  [`cd_denominator_choices`](countdown-pages.md)
  [`cd_denominator_header`](countdown-pages.md)
  [`cd_denominator_options`](countdown-pages.md)
  [`cd_denominator_row`](countdown-pages.md)
  [`cd_denominator_server`](countdown-pages.md)
  [`cd_denominator_ui`](countdown-pages.md)
  [`cd_has_maternal`](countdown-pages.md)
  [`cd_indicator_server`](countdown-pages.md)
  [`cd_indicator_ui`](countdown-pages.md)
  [`cd_nav_denominators`](countdown-pages.md)
  [`cd_nav_national`](countdown-pages.md)
  [`cd_nav_quality`](countdown-pages.md)
  [`cd_nav_start`](countdown-pages.md)
  [`cd_nav_subnational`](countdown-pages.md)
  [`cd_only_denominators`](countdown-pages.md)
  [`cd_palette_chip`](countdown-pages.md)
  [`cd_population_server`](countdown-pages.md)
  [`cd_population_ui`](countdown-pages.md)
  [`cd_rate_status_cell`](countdown-pages.md)
  [`cd_saved_copy_name`](countdown-pages.md)
  [`cd_scope_filters`](countdown-pages.md)
  [`cd_scope_server`](countdown-pages.md)
  [`cd_scoped_page_server`](countdown-pages.md)
  [`cd_scoped_page_ui`](countdown-pages.md)
  [`cd_tabbed_charts_server`](countdown-pages.md)
  [`cd_tabbed_charts_ui`](countdown-pages.md)
  [`cd_table_server`](countdown-pages.md)
  [`cd_table_ui`](countdown-pages.md)
  [`cd_wizard_check_group`](countdown-pages.md)
  [`cd_wizard_config`](countdown-pages.md)
  [`cd_wizard_field_group`](countdown-pages.md)
  [`cd_wizard_indicator_group`](countdown-pages.md)
  [`cd_wizard_national_rate_fields`](countdown-pages.md)
  [`cd_wizard_rate_field`](countdown-pages.md)
  [`cd_wizard_survey_field`](countdown-pages.md)
  [`cd_years_input`](countdown-pages.md)
  [`cd_years_sync`](countdown-pages.md)
  [`compute_step_states`](countdown-pages.md)
  [`consistency_check_server`](countdown-pages.md)
  [`consistency_check_ui`](countdown-pages.md)
  [`consistency_pair_keys`](countdown-pages.md)
  [`consistency_pair_label`](countdown-pages.md)
  [`coverage_server`](countdown-pages.md)
  [`coverage_trends_server`](countdown-pages.md)
  [`coverage_trends_ui`](countdown-pages.md)
  [`coverage_ui`](countdown-pages.md)
  [`data_adjustment_server`](countdown-pages.md)
  [`data_adjustment_ui`](countdown-pages.md)
  [`data_completeness_server`](countdown-pages.md)
  [`data_completeness_ui`](countdown-pages.md)
  [`data_quality_server`](countdown-pages.md)
  [`data_quality_ui`](countdown-pages.md)
  [`den_indicators`](countdown-pages.md)
  [`denominator_assessment_server`](countdown-pages.md)
  [`denominator_assessment_ui`](countdown-pages.md)
  [`denominator_selection_server`](countdown-pages.md)
  [`denominator_selection_ui`](countdown-pages.md)
  [`equity_server`](countdown-pages.md)
  [`equity_ui`](countdown-pages.md)
  [`get_national_rates`](countdown-pages.md)
  [`inequality_server`](countdown-pages.md)
  [`inequality_ui`](countdown-pages.md)
  [`internal_consistency_server`](countdown-pages.md)
  [`internal_consistency_ui`](countdown-pages.md)
  [`introduction_server`](countdown-pages.md)
  [`introduction_ui`](countdown-pages.md)
  [`list_missing_units`](countdown-pages.md)
  [`map_shapefile_server`](countdown-pages.md)
  [`map_shapefile_ui`](countdown-pages.md)
  [`map_survey_server`](countdown-pages.md)
  [`map_survey_ui`](countdown-pages.md)
  [`mapping_modal_server`](countdown-pages.md)
  [`mapping_modal_ui`](countdown-pages.md)
  [`mapping_provenance_banner`](countdown-pages.md)
  [`national_coverage_server`](countdown-pages.md)
  [`national_coverage_ui`](countdown-pages.md)
  [`national_inequality_server`](countdown-pages.md)
  [`national_inequality_ui`](countdown-pages.md)
  [`national_rates_required_fields`](countdown-pages.md)
  [`national_rates_server`](countdown-pages.md)
  [`national_rates_ui`](countdown-pages.md)
  [`national_target_server`](countdown-pages.md)
  [`national_target_ui`](countdown-pages.md)
  [`nr_field`](countdown-pages.md) [`nr_group`](countdown-pages.md)
  [`outlier_detection_server`](countdown-pages.md)
  [`outlier_detection_ui`](countdown-pages.md)
  [`overall_score_server`](countdown-pages.md)
  [`overall_score_ui`](countdown-pages.md)
  [`push_upload_on_remount`](countdown-pages.md)
  [`reference_estimates_server`](countdown-pages.md)
  [`reference_estimates_ui`](countdown-pages.md)
  [`reporting_rate_server`](countdown-pages.md)
  [`reporting_rate_ui`](countdown-pages.md)
  [`restore_default_control`](countdown-pages.md)
  [`rr_indicators`](countdown-pages.md)
  [`shapefile_step_server`](countdown-pages.md)
  [`shapefile_step_ui`](countdown-pages.md)
  [`step_map_mapping_complete`](countdown-pages.md)
  [`step_national_rates_complete`](countdown-pages.md)
  [`step_quality_complete`](countdown-pages.md)
  [`step_shapefile_complete`](countdown-pages.md)
  [`step_shapefile_touched`](countdown-pages.md)
  [`step_survey_files_complete`](countdown-pages.md)
  [`step_survey_mapping_complete`](countdown-pages.md)
  [`step_upload_complete`](countdown-pages.md)
  [`subnational_coverage_server`](countdown-pages.md)
  [`subnational_coverage_ui`](countdown-pages.md)
  [`subnational_denominator_server`](countdown-pages.md)
  [`subnational_denominator_ui`](countdown-pages.md)
  [`subnational_inequality_server`](countdown-pages.md)
  [`subnational_inequality_ui`](countdown-pages.md)
  [`subnational_mapping_server`](countdown-pages.md)
  [`subnational_mapping_ui`](countdown-pages.md)
  [`subnational_target_server`](countdown-pages.md)
  [`subnational_target_ui`](countdown-pages.md)
  [`survey_comparison_server`](countdown-pages.md)
  [`survey_comparison_ui`](countdown-pages.md)
  [`survey_estimates_required_fields`](countdown-pages.md)
  [`survey_fields`](countdown-pages.md)
  [`survey_upload_server`](countdown-pages.md)
  [`survey_upload_ui`](countdown-pages.md)
  [`target_server`](countdown-pages.md)
  [`target_ui`](countdown-pages.md)
  [`upload_box_server`](countdown-pages.md)
  [`upload_box_ui`](countdown-pages.md)
  [`wizard_fields`](countdown-pages.md)
  [`wizard_landing_server`](countdown-pages.md)
  [`wizard_landing_ui`](countdown-pages.md)
  [`wizard_step_defs`](countdown-pages.md)
  [`wizard_steps_server`](countdown-pages.md)
  [`wizard_steps_ui`](countdown-pages.md) : The Countdown pages, wizard,
  filters and app frame
- [`cd_scope()`](cd_scope.md) : Define the Scope of a Scoped Page

## The Countdown AI

What DataSuite’s Countdown AI reads from the package: CacheConnection’s
members, custom charts.

- [`cache_manifest()`](cache_manifest.md) : What the Countdown AI knows
  of CacheConnection
- [`cache_definition()`](cache_definition.md) : What a CacheConnection
  data point is
- [`cd_chartable_members()`](cd_chartable_members.md) : The
  CacheConnection members a custom chart may draw from
- [`cd_member_data()`](cd_member_data.md) : The table a CacheConnection
  member gives
- [`cd_custom_chart_data()`](cd_custom_chart_data.md) : The table a
  custom chart draws

## Data Dictionary and Methodology

What the package’s ids and column names mean, the denominator options’
labels, and the constants of the Countdown methodology the package runs
with.

- [`cd_dictionary()`](cd_dictionary.md) : The data dictionary: what the
  ids and column names in the package's data mean
- [`cd_describe_columns()`](cd_describe_columns.md) : Read column names
  with the data dictionary
- [`cd_denominator_labels()`](cd_denominator_labels.md) : The
  denominator options' labels
- [`cd_methodology_defaults()`](cd_methodology_defaults.md) : The
  Constants of the Countdown Methodology

## Utility Functions

Utility helpers used internally or across workflows.

- [`add_outlier5std_column()`](add_outlier5std_column.md) : Add Outlier
  Flags Based on 5-MAD Bounds

- [`add_mad_med_columns()`](add_mad_med_columns.md) : Add Median and MAD
  Columns for Indicators

- [`add_missing_column()`](add_missing_column.md) : Add Missing Value
  Flags to Health Indicators

- [`get_all_indicators()`](get_all_indicators.md) : Get All Indicators

- [`get_country_iso3()`](get_country_iso3.md) : Get Country ISO3 Code

- [`get_country_name()`](get_country_name.md) : Get Country Name

- [`get_named_indicators()`](get_named_indicators.md) : Get Named
  Indicator Vector

- [`get_population_column()`](get_population_column.md) : Get Population
  Denominator Column Based on Indicator Only

- [`get_analysis_indicators()`](get_analysis_indicators.md) : Get
  Indicators excluding indicators without denominator

- [`list_tracer_vaccines()`](list_tracer_vaccines.md) : List Tracer
  Vaccines

- [`list_vaccine_indicators()`](list_vaccine_indicators.md) : List All
  Vaccine and Related Coverage Indicators

- [`get_admin_columns()`](get_admin_columns.md) : Determine Grouping
  Columns for Administrative Levels

- [`get_plot_admin_column()`](get_plot_admin_column.md) : Determine the
  Administrative Column to Use for Plotting

- [`is_maternal_indicator()`](is_maternal_indicator.md) : Detemine if an
  indicator is maternal indicator

- [`robust_max()`](robust_max.md) : Robust Maximum Value Calculation

- [`print(`*`<cd_data>`*`)`](print.cd_data.md) :

  Print Method for `cd_data` Class

- [`with_cd_quiet()`](cd2030-configuration.md)
  [`local_cd_quiet()`](cd2030-configuration.md) : Execute Code in Quiet
  Mode

- [`clean_error_message()`](clean_error_message.md) : Clean and Validate
  Error Messages
