# CacheConnection class

An R6 class that handles persistent or in-memory caching of data used in
the Countdown 2030 analysis and reporting workflows.

**Dependency Architecture:**

- **Layer 0 (Core Data):** Raw `countdown_data`, thresholds, external
  surveys (`un_estimates`).

- **Layer 1 (DQA & Adjustments):** Depends on Layer 0. Includes
  `adjusted_data`, reporting rates, completeness, overall scores.

- **Layer 2 (Coverage & Denominators):** Depends on Layer 1. Includes
  derived coverages at national, admin level 1, and district levels.

- **Layer 3 (Inequality & Health Systems):** Depends on Layer 2
  (Coverage). Includes inequalities, mortality ratios, and service
  utilization summaries.

## Format

An [R6::R6Class](https://r6.r-lib.org/reference/R6Class.html) generator
object.

## Public fields

- `data_version`:

  Defines the current internal data version to handle backward
  compatibility.

## Active bindings

- `language`:

  Active Binding: Gets the UI language.

- `cache_path`:

  Active Binding: Gets the physical disk path for the `.rds` cache.

- `countdown_data`:

  Active Binding: Gets the raw, unadjusted countdown tibble.

- `data_years`:

  Active Binding: Gets the years present in the raw data, in ascending
  order. While the Load Data wizard's sheets are not yet merged
  (`wizard_parts` set, no `countdown_data`), the years come from the
  population sheet's `year` column. `NULL` when neither gives any.

- `subnational_regions`:

  Active Binding: Gets the unique admin level 1 and district
  combinations, a data frame with columns `adminlevel_1` and `district`.
  While the Load Data wizard's sheets are not yet merged (`wizard_parts`
  set, no `countdown_data`), they come from the admin sheet's
  `first_admin_level` and `district` columns. `NULL` when neither gives
  any.

- `country`:

  Active Binding: Gets the name of the dataset's country. Readonly.
  While the Load Data wizard's sheets are not yet merged (no
  `countdown_data`), it is the country stored with
  `set_wizard_country()`, which is `NULL` when the country could not be
  worked out.

- `country_iso`:

  Active Binding: Gets the 3-letter ISO code for the country. Readonly.
  While the Load Data wizard's sheets are not yet merged, it is the code
  stored with `set_wizard_country()`, which is `NULL` when the country
  could not be worked out.

- `wizard_parts`:

  Active Binding: Gets the sheets of an upload that the Load Data wizard
  has read but not yet merged (the result of
  [`load_excel_parts()`](load_excel_parts.md)). `NULL` once they are
  merged into `countdown_data` and cleared, and for a dataset that was
  not loaded through the wizard.

- `quality_confirmed`:

  Active Binding: `TRUE` once the data has finished the Load Data wizard
  with its quality checks passed (see `set_quality_confirmed()`). It is
  saved with the dataset. `FALSE` while the wizard is in progress, and
  for a dataset built outside the wizard.

- `wizard_quality_results`:

  Active Binding: Gets the quality check results stored when the Load
  Data wizard finished (see `set_wizard_quality_results()`), which
  [`run_all_quality_checks()`](run_all_quality_checks.md) returns once
  the wizard's sheets are cleared. `NULL` before that, and for a dataset
  that did not go through the wizard.

- `adjusted_data`:

  Active Binding: Gets countdown data with K-factors applied. Adjusts
  automatically if flags are met.

- `data_with_excluded_years`:

  Active Binding: Raw data without the years in `excluded_years`.
  Readonly. `NULL` when there is no `countdown_data` yet (the Load Data
  wizard has not finished).

- `performance_threshold`:

  Active Binding: Gets the integer threshold used for DQA success
  checks.

- `excluded_years`:

  Active Binding: Gets the numeric vector of years blocked from
  modeling.

- `k_factors`:

  Active Binding: Gets the named vector of numeric adjustment ratios.

- `adjustment_settings`:

  Active Binding: The Data Adjustment page's settings (see
  [`adjust_service_data()`](adjust_service_data.md)). When none are
  stored, they are made from `k_factors` and `excluded_years`.

- `adjusted_flag`:

  Active Binding: Gets boolean representing if adjustments are active.

- `derivation_population`:

  Active Binding: Gets the string indicating the origin population
  indicator.

- `reporting_rate_national`:

  Active Binding: Gets the cached national reporting rate dataset.

- `reporting_rate_admin1`:

  Active Binding: Gets the cached region-level reporting rate dataset.

- `reporting_rate_district`:

  Active Binding: Gets the cached district-level reporting rate dataset.

- `district_reporting_rate`:

  Active Binding: Gets percentage of districts passing the reporting
  threshold.

- `completeness_national`:

  Active Binding: Gets non-missing values percentage at national level.

- `completeness_admin1`:

  Active Binding: Gets non-missing values percentage at region level.

- `completeness_district`:

  Active Binding: Gets non-missing values percentage at district level.

- `district_completeness`:

  Active Binding: Gets % of districts passing completeness thresholds.

- `outliers_national`:

  Active Binding: Gets percentage of non-outlier values at national
  level.

- `outliers_admin1`:

  Active Binding: Gets percentage of non-outlier values at region level.

- `outliers_district`:

  Active Binding: Gets percentage of non-outlier values at district
  level.

- `district_outliers_summary`:

  Active Binding: Gets % of districts passing outlier safety checks.

- `list_outlier_units`:

  Active Binding: Generates a table of facilities identified as severe
  outliers.

- `ratios_summary`:

  Active Binding: Summarizes adequacy ratios (like ANC1/Penta1) over
  time.

- `adequacy_ratios`:

  Active Binding: Calculates district-by-district chronological
  indicator consistency.

- `overall_score`:

  Active Binding: Merges DQA tables to formulate the master health score
  grade.

- `denominator_metrics`:

  Active Binding: Compiles demographic targets from DHIS2 and UN data.

- `indicator_coverage_national`:

  Active Binding: Gets national-level indicator coverage calculations.

- `indicator_coverage_admin1`:

  Active Binding: Gets region-level indicator coverage calculations.

- `indicator_coverage_district`:

  Active Binding: Gets district-level indicator coverage calculations.

- `survey_estimates`:

  Active Binding: Extracts and formats targeted rates from the master
  survey.

- `national_estimates`:

  Active Binding: Fetches the configured national baseline estimates
  list.

- `admin1_estimates`:

  Active Binding: Fetches merged regional estimates from survey mapping.

- `survey_years`:

  Active Binding: Fetches a unique list of survey years available.

- `survey_year`:

  Active Binding: Fetches the anchor integer year used for survey
  calculations.

- `start_survey_year`:

  Active Binding: Fetches the chronological starting boundary for
  models.

- `denominator`:

  Active Binding: Fetches standard analysis denominator.

- `maternal_denominator`:

  Active Binding: Fetches maternal-specific analysis denominator.

- `selected_admin_level_1`:

  Active Binding: Dashboard specific Region selection.

- `selected_district`:

  Active Binding: Dashboard specific District selection.

- `mortality_mapping_years`:

  Active Binding: Fetches years requested for mortality charts.

- `utilization_mapping_years`:

  Active Binding: Fetches years requested for utilization charts.

- `mapping_years`:

  Active Binding: Fetches years requested for standard map generation.

- `chart_options`:

  Active Binding: every stored chart option, a named list of
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  (read-only; use `set_chart_options()` / `get_chart_options()`).

- `report_projects`:

  Active Binding: the reports built in the report builder, a named list
  by id (read-only; use `set_report_project()`).

- `report_assets`:

  Active Binding: the pictures the reports use, a named list by id of
  `list(type, data)` (read-only; use `set_report_asset()`).

- `graphs`:

  Active Binding: the saved custom charts, a named list by id of their
  descriptions (read-only; use `set_graph()`).

- `revision`:

  Active Binding: a number that goes up each time a change to the
  dataset is saved, so another process reading the same `.rds` (the AI's
  copy) knows to reload (read-only).

- `read_only`:

  Active Binding: whether this cache never writes its `.rds`
  (read-only).

- `report_themes`:

  Active Binding: the themes made from Office files, a named list by id
  (read-only; use `set_report_theme()`).

- `fpet_data`:

  Active Binding: Fetches FPET metrics (the package's built-in data for
  the country when none was set).

- `un_estimates`:

  Active Binding: Fetches demographic targets set by the UN.

- `un_mortality_estimates`:

  Active Binding: Fetches mortality targets set by the UN.

- `wuenic_estimates`:

  Active Binding: Fetches immunization estimates tracked by WHO.

- `national_survey`:

  Active Binding: Fetches overall national survey raw frame.

- `regional_survey`:

  Active Binding: Fetches regional survey raw frame.

- `shapefile`:

  Active Binding: Fetches the shapefile for the country: the one
  uploaded with `set_shapefile()` when there is one, otherwise the
  package's built-in admin level 1 shapefile for `country_iso`. `NULL`
  when none was uploaded and `country_iso` is not known yet.

- `shapefile_name_field`:

  Active Binding: The column of `shapefile` that holds the admin level 1
  names: `"NAME_1"` (the column of the built-in shapefiles) unless
  `set_shapefile_name_field()` set another.

- `wiq_survey`:

  Active Binding: Fetches wealth inequality (WIQ) survey raw frame.

- `area_survey`:

  Active Binding: Fetches area based (urban/rural) survey frame.

- `education_survey`:

  Active Binding: Fetches maternal education level survey frame.

- `survey_mapping`:

  Active Binding: Retrieves text mapping linking survey regions to raw
  regions.

- `map_mapping`:

  Active Binding: Retrieves mapping linking map coordinates to raw
  regions.

- `sector_national_estimates`:

  Active Binding: Returns cache of national sector breakdown.

- `sector_area_estimates`:

  Active Binding: Returns cache of sub-area sector breakdown.

- `csection_national_estimates`:

  Active Binding: Returns cached national csection estimates.

- `csection_area_estimates`:

  Active Binding: Returns cached sub-area csection estimates.

- `check_inequality_params`:

  Active Binding: Returns boolean if data necessary for inequality
  calculations exists.

- `check_coverage_params`:

  Active Binding: Returns boolean if data necessary for coverage
  calculations exists.

- `check_mortality_params`:

  Active Binding: Returns boolean if data necessary for mortality
  calculations exists.

- `check_sector_params`:

  Active Binding: Returns boolean if data necessary for public/private
  sector calculations exists.

- `inequality_admin1`:

  Active Binding: Automatically calculates and caches Admin level 1
  inequality matrices.

- `inequality_district`:

  Active Binding: Automatically calculates and caches District
  inequality matrices.

- `adjustment_values`:

  Active Binding: The yearly numbers as reported and after each step of
  the dataset's adjustment (completeness, outliers, missing values), for
  every indicator. Computed once and kept.

- `mortality_summary`:

  Active Binding: Calculates mortality summaries combining live births
  and still births.

- `mortality_ratios`:

  Active Binding: Calculates precise mortality ratios comparing internal
  data with UN estimates.

- `service_utilization_national`:

  Active Binding: Caches OPD/IPD utilizations summed to the National
  scale.

- `service_utilization_admin1`:

  Active Binding: Caches OPD/IPD utilizations parsed at admin level 1.

- `health_system_comparison`:

  Active Binding: Summarizes health system efficiency linking resources
  to coverage.

- `health_system_metrics_national`:

  Active Binding: Compiles core indicators (staff density, beds) at the
  National scale.

- `health_system_metrics_admin1`:

  Active Binding: Compiles core indicators (staff density, beds) at the
  Admin level 1 scale.

- `national_private_share`:

  Active Binding: Returns baseline metrics regarding private sector
  operations (National).

- `area_private_share`:

  Active Binding: Returns baseline metrics regarding private sector
  operations (Area/Region).

## Methods

### Public methods

- [`CacheConnection$new()`](#method-CacheConnection-initialize)

- [`CacheConnection$load_from_disk()`](#method-CacheConnection-load_from_disk)

- [`CacheConnection$save_to_disk()`](#method-CacheConnection-save_to_disk)

- [`CacheConnection$adjust_data()`](#method-CacheConnection-adjust_data)

- [`CacheConnection$calculate_indicator_coverage()`](#method-CacheConnection-calculate_indicator_coverage)

- [`CacheConnection$calculate_inequality()`](#method-CacheConnection-calculate_inequality)

- [`CacheConnection$calculate_coverage()`](#method-CacheConnection-calculate_coverage)

- [`CacheConnection$generate_coverage_data()`](#method-CacheConnection-generate_coverage_data)

- [`CacheConnection$get_mapping_data()`](#method-CacheConnection-get_mapping_data)

- [`CacheConnection$lbr_mean()`](#method-CacheConnection-lbr_mean)

- [`CacheConnection$summarise_completeness_ratio()`](#method-CacheConnection-summarise_completeness_ratio)

- [`CacheConnection$filter_mortality_summary()`](#method-CacheConnection-filter_mortality_summary)

- [`CacheConnection$compute_service_utilization()`](#method-CacheConnection-compute_service_utilization)

- [`CacheConnection$filter_service_utilization()`](#method-CacheConnection-filter_service_utilization)

- [`CacheConnection$prepare_mapping_service_utlization()`](#method-CacheConnection-prepare_mapping_service_utlization)

- [`CacheConnection$get_denominator()`](#method-CacheConnection-get_denominator)

- [`CacheConnection$decompose_change()`](#method-CacheConnection-decompose_change)

- [`CacheConnection$denominator_comparison()`](#method-CacheConnection-denominator_comparison)

- [`CacheConnection$reactive()`](#method-CacheConnection-reactive)

- [`CacheConnection$set_language()`](#method-CacheConnection-set_language)

- [`CacheConnection$set_cache_path()`](#method-CacheConnection-set_cache_path)

- [`CacheConnection$set_countdown_data()`](#method-CacheConnection-set_countdown_data)

- [`CacheConnection$set_wizard_parts()`](#method-CacheConnection-set_wizard_parts)

- [`CacheConnection$clear_wizard_parts()`](#method-CacheConnection-clear_wizard_parts)

- [`CacheConnection$set_wizard_country()`](#method-CacheConnection-set_wizard_country)

- [`CacheConnection$set_quality_confirmed()`](#method-CacheConnection-set_quality_confirmed)

- [`CacheConnection$set_wizard_quality_results()`](#method-CacheConnection-set_wizard_quality_results)

- [`CacheConnection$set_adjusted_data()`](#method-CacheConnection-set_adjusted_data)

- [`CacheConnection$set_performance_threshold()`](#method-CacheConnection-set_performance_threshold)

- [`CacheConnection$set_excluded_years()`](#method-CacheConnection-set_excluded_years)

- [`CacheConnection$set_adjustment_settings()`](#method-CacheConnection-set_adjustment_settings)

- [`CacheConnection$set_k_factors()`](#method-CacheConnection-set_k_factors)

- [`CacheConnection$set_adjusted_flag()`](#method-CacheConnection-set_adjusted_flag)

- [`CacheConnection$set_survey_estimates()`](#method-CacheConnection-set_survey_estimates)

- [`CacheConnection$set_derivation_population()`](#method-CacheConnection-set_derivation_population)

- [`CacheConnection$set_national_estimates()`](#method-CacheConnection-set_national_estimates)

- [`CacheConnection$set_survey_year()`](#method-CacheConnection-set_survey_year)

- [`CacheConnection$clear_survey_year()`](#method-CacheConnection-clear_survey_year)

- [`CacheConnection$set_start_survey_year()`](#method-CacheConnection-set_start_survey_year)

- [`CacheConnection$set_denominator()`](#method-CacheConnection-set_denominator)

- [`CacheConnection$set_maternal_denominator()`](#method-CacheConnection-set_maternal_denominator)

- [`CacheConnection$set_selected_admin_level_1()`](#method-CacheConnection-set_selected_admin_level_1)

- [`CacheConnection$set_selected_district()`](#method-CacheConnection-set_selected_district)

- [`CacheConnection$set_mapping_years()`](#method-CacheConnection-set_mapping_years)

- [`CacheConnection$set_chart_options()`](#method-CacheConnection-set_chart_options)

- [`CacheConnection$set_report_project()`](#method-CacheConnection-set_report_project)

- [`CacheConnection$set_graph()`](#method-CacheConnection-set_graph)

- [`CacheConnection$set_report_asset()`](#method-CacheConnection-set_report_asset)

- [`CacheConnection$set_report_theme()`](#method-CacheConnection-set_report_theme)

- [`CacheConnection$get_chart_options()`](#method-CacheConnection-get_chart_options)

- [`CacheConnection$reset_chart_options()`](#method-CacheConnection-reset_chart_options)

- [`CacheConnection$set_mortality_mapping_years()`](#method-CacheConnection-set_mortality_mapping_years)

- [`CacheConnection$set_utilization_mapping_years()`](#method-CacheConnection-set_utilization_mapping_years)

- [`CacheConnection$set_fpet_data()`](#method-CacheConnection-set_fpet_data)

- [`CacheConnection$set_un_estimates()`](#method-CacheConnection-set_un_estimates)

- [`CacheConnection$clear_un_estimates()`](#method-CacheConnection-clear_un_estimates)

- [`CacheConnection$set_un_mortality_estimates()`](#method-CacheConnection-set_un_mortality_estimates)

- [`CacheConnection$clear_un_mortality_estimates()`](#method-CacheConnection-clear_un_mortality_estimates)

- [`CacheConnection$set_wuenic_estimates()`](#method-CacheConnection-set_wuenic_estimates)

- [`CacheConnection$clear_wuenic_estimates()`](#method-CacheConnection-clear_wuenic_estimates)

- [`CacheConnection$set_national_survey()`](#method-CacheConnection-set_national_survey)

- [`CacheConnection$clear_national_survey()`](#method-CacheConnection-clear_national_survey)

- [`CacheConnection$set_regional_survey()`](#method-CacheConnection-set_regional_survey)

- [`CacheConnection$clear_regional_survey()`](#method-CacheConnection-clear_regional_survey)

- [`CacheConnection$set_shapefile()`](#method-CacheConnection-set_shapefile)

- [`CacheConnection$clear_shapefile()`](#method-CacheConnection-clear_shapefile)

- [`CacheConnection$set_shapefile_name_field()`](#method-CacheConnection-set_shapefile_name_field)

- [`CacheConnection$set_wiq_survey()`](#method-CacheConnection-set_wiq_survey)

- [`CacheConnection$clear_wiq_survey()`](#method-CacheConnection-clear_wiq_survey)

- [`CacheConnection$set_area_survey()`](#method-CacheConnection-set_area_survey)

- [`CacheConnection$clear_area_survey()`](#method-CacheConnection-clear_area_survey)

- [`CacheConnection$set_education_survey()`](#method-CacheConnection-set_education_survey)

- [`CacheConnection$clear_education_survey()`](#method-CacheConnection-clear_education_survey)

- [`CacheConnection$set_survey_mapping()`](#method-CacheConnection-set_survey_mapping)

- [`CacheConnection$clear_survey_mapping()`](#method-CacheConnection-clear_survey_mapping)

- [`CacheConnection$set_map_mapping()`](#method-CacheConnection-set_map_mapping)

- [`CacheConnection$clear_map_mapping()`](#method-CacheConnection-clear_map_mapping)

- [`CacheConnection$is_default()`](#method-CacheConnection-is_default)

- [`CacheConnection$set_sector_national_estimates()`](#method-CacheConnection-set_sector_national_estimates)

- [`CacheConnection$set_sector_area_estimates()`](#method-CacheConnection-set_sector_area_estimates)

- [`CacheConnection$set_csection_national_estimates()`](#method-CacheConnection-set_csection_national_estimates)

- [`CacheConnection$set_csection_area_estimates()`](#method-CacheConnection-set_csection_area_estimates)

- [`CacheConnection$calculate_reporting_rate()`](#method-CacheConnection-calculate_reporting_rate)

- [`CacheConnection$calculate_district_reporting_rate()`](#method-CacheConnection-calculate_district_reporting_rate)

- [`CacheConnection$calculate_completeness_summary()`](#method-CacheConnection-calculate_completeness_summary)

- [`CacheConnection$calculate_district_completeness_summary()`](#method-CacheConnection-calculate_district_completeness_summary)

- [`CacheConnection$list_missing_units()`](#method-CacheConnection-list_missing_units)

- [`CacheConnection$calculate_outliers_summary()`](#method-CacheConnection-calculate_outliers_summary)

- [`CacheConnection$calculate_district_outlier_summary()`](#method-CacheConnection-calculate_district_outlier_summary)

- [`CacheConnection$calculate_ratios_and_adequacy()`](#method-CacheConnection-calculate_ratios_and_adequacy)

- [`CacheConnection$check_population_service_collision()`](#method-CacheConnection-check_population_service_collision)

- [`CacheConnection$check_indicator_emptiness()`](#method-CacheConnection-check_indicator_emptiness)

- [`CacheConnection$check_survey_admin_names()`](#method-CacheConnection-check_survey_admin_names)

- [`CacheConnection$check_shapefile_admin_names()`](#method-CacheConnection-check_shapefile_admin_names)

- [`CacheConnection$calculate_overall_score()`](#method-CacheConnection-calculate_overall_score)

- [`CacheConnection$calculate_service_dqa_summary()`](#method-CacheConnection-calculate_service_dqa_summary)

- [`CacheConnection$generate_admin1_service_utilization()`](#method-CacheConnection-generate_admin1_service_utilization)

- [`CacheConnection$generate_admin1_mch_curative_index()`](#method-CacheConnection-generate_admin1_mch_curative_index)

- [`CacheConnection$get_filtered_coverage()`](#method-CacheConnection-get_filtered_coverage)

- [`CacheConnection$get_filtered_inequality()`](#method-CacheConnection-get_filtered_inequality)

- [`CacheConnection$get_filtered_mapping_data()`](#method-CacheConnection-get_filtered_mapping_data)

- [`CacheConnection$get_base_indicator_coverage()`](#method-CacheConnection-get_base_indicator_coverage)

- [`CacheConnection$get_filtered_threshold()`](#method-CacheConnection-get_filtered_threshold)

- [`CacheConnection$calculate_derived_coverage()`](#method-CacheConnection-calculate_derived_coverage)

- [`CacheConnection$get_high_performers()`](#method-CacheConnection-get_high_performers)

- [`CacheConnection$get_regional_estimates()`](#method-CacheConnection-get_regional_estimates)

- [`CacheConnection$generate_health_system_table()`](#method-CacheConnection-generate_health_system_table)

- [`CacheConnection$generate_phc_scatter_data()`](#method-CacheConnection-generate_phc_scatter_data)

- [`CacheConnection$generate_private_sector_data()`](#method-CacheConnection-generate_private_sector_data)

- [`CacheConnection$get_bayes_model()`](#method-CacheConnection-get_bayes_model)

- [`CacheConnection$bayes_model_key()`](#method-CacheConnection-bayes_model_key)

- [`CacheConnection$bayes_model_cached()`](#method-CacheConnection-bayes_model_cached)

- [`CacheConnection$bayes_national_routine()`](#method-CacheConnection-bayes_national_routine)

- [`CacheConnection$bayes_model_inputs()`](#method-CacheConnection-bayes_model_inputs)

- [`CacheConnection$keep_bayes_model()`](#method-CacheConnection-keep_bayes_model)

- [`CacheConnection$bayes_estimates()`](#method-CacheConnection-bayes_estimates)

- [`CacheConnection$clone()`](#method-CacheConnection-clone)

------------------------------------------------------------------------

### `CacheConnection$new()`

Initialize a CacheConnection instance.

#### Usage

    CacheConnection$new(
      rds_path = NULL,
      countdown_data = NULL,
      data_path = NULL,
      wizard_parts = NULL,
      read_only = FALSE
    )

#### Arguments

- `rds_path`:

  Path to the RDS file to load state from (can be NULL).

- `countdown_data`:

  Countdown data of class `cd_data`.

- `data_path`:

  Path to the original source file `countdown_data` was built from (e.g.
  the picked `.xlsx`). The cache is kept at
  `<dirname(data_path)>/<stem(data_path)>.rds`. If that file already
  exists, it is loaded and `countdown_data` is not used; otherwise it is
  created there.

- `wizard_parts`:

  A [`load_excel_parts()`](load_excel_parts.md) result
  (`list(parts, sheet_names, sheet_ids, ...)`): the sheets of an upload
  that the Load Data wizard has read and cleaned but not yet merged into
  a `cd_data` object. Use it instead of `rds_path` or `countdown_data`.
  Until `set_countdown_data()` is called, `countdown_data` is `NULL`,
  and `data_years` and `subnational_regions` are read from these sheets.

- `read_only`:

  `TRUE` never writes the cache back to its `.rds` (see
  [`init_CacheConnection()`](init_CacheConnection.md)).

------------------------------------------------------------------------

### `CacheConnection$load_from_disk()`

Load cached data from the designated RDS file on disk.

#### Usage

    CacheConnection$load_from_disk()

------------------------------------------------------------------------

### `CacheConnection$save_to_disk()`

Save current in-memory state to the assigned RDS file, provided state
has changed.

#### Usage

    CacheConnection$save_to_disk()

------------------------------------------------------------------------

### `CacheConnection$adjust_data()`

Processes raw data into adjusted data with the adjustment settings
(`adjustment_settings`: the years and areas removed, each indicator's k,
outlier and missing-value switches, everywhere or by area).

#### Usage

    CacheConnection$adjust_data()

------------------------------------------------------------------------

### `CacheConnection$calculate_indicator_coverage()`

Run indicator coverage calculation using stored models and parameters.

#### Usage

    CacheConnection$calculate_indicator_coverage(
      admin_level,
      region = NULL,
      show_district = TRUE
    )

#### Arguments

- `admin_level`:

  Administrative level ("national", "adminlevel_1", or "district").

- `region`:

  Optional region filter.

- `show_district`:

  Logical. Whether to show the district column.

------------------------------------------------------------------------

### `CacheConnection$calculate_inequality()`

Run inequality calculation using subnational coverage compared to
reference data.

#### Usage

    CacheConnection$calculate_inequality(admin_level, region = NULL)

#### Arguments

- `admin_level`:

  Administrative level ("adminlevel_1" or "district").

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$calculate_coverage()`

Integrates immunization coverage data from DHIS2, Surveys, and WUENIC.

#### Usage

    CacheConnection$calculate_coverage(admin_level, region = NULL)

#### Arguments

- `admin_level`:

  Administrative level ("national", "adminlevel_1", or "district").

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$generate_coverage_data()`

Generate Continuum of Care Coverage Data summary format.

#### Usage

    CacheConnection$generate_coverage_data(admin_level, type, region = NULL)

#### Arguments

- `admin_level`:

  Character. The geographic level to calculate and shape.

- `type`:

  Character. The type of data to summarise ('maternal' or 'child').

- `region`:

  Character. Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$get_mapping_data()`

Formats base coverage data with spatial map coordinates for plotting.

#### Usage

    CacheConnection$get_mapping_data(admin_level)

#### Arguments

- `admin_level`:

  Administrative level.

------------------------------------------------------------------------

### `CacheConnection$lbr_mean()`

Retrieves the mean of institutional livebirths from the national
coverage cache.

#### Usage

    CacheConnection$lbr_mean()

------------------------------------------------------------------------

### `CacheConnection$summarise_completeness_ratio()`

Creates mortality completeness ratio summaries.

#### Usage

    CacheConnection$summarise_completeness_ratio(indicator)

#### Arguments

- `indicator`:

  Character. The indicator to generate the summary for.

------------------------------------------------------------------------

### `CacheConnection$filter_mortality_summary()`

Returns the appropriate mortality summary based on the indicator type to
plot.

#### Usage

    CacheConnection$filter_mortality_summary(
      indicator,
      map_years = NULL,
      palette = "Reds"
    )

#### Arguments

- `indicator`:

  Character. Indicator name.

- `map_years`:

  Numeric vector. The years to include in a map.

- `palette`:

  Character. RColorBrewer sequential palette for the map.

------------------------------------------------------------------------

### `CacheConnection$compute_service_utilization()`

Computes service utilization for various indicators (OPD/IPD).

#### Usage

    CacheConnection$compute_service_utilization(admin_level)

#### Arguments

- `admin_level`:

  The level to aggregate data at ("national", "adminlevel_1").

------------------------------------------------------------------------

### `CacheConnection$filter_service_utilization()`

Filters service utilization data for a specific indicator and region.

#### Usage

    CacheConnection$filter_service_utilization(
      admin_level,
      indicator,
      region = NULL
    )

#### Arguments

- `admin_level`:

  Administrative level.

- `indicator`:

  Character. Indicator name.

- `region`:

  Character. Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$prepare_mapping_service_utlization()`

Prepares service utilization data mapping tables.

#### Usage

    CacheConnection$prepare_mapping_service_utlization(
      indicator,
      map_years = NULL,
      palette = "Purples"
    )

#### Arguments

- `indicator`:

  Character. Indicator name ('ipd', 'opd').

- `map_years`:

  Numeric vector. Years to include.

- `palette`:

  Character. RColorBrewer sequential palette for the map.

------------------------------------------------------------------------

### `CacheConnection$get_denominator()`

Resolves the appropriate denominator column string based on the
indicator category.

#### Usage

    CacheConnection$get_denominator(indicator)

#### Arguments

- `indicator`:

  Character. The indicator name.

------------------------------------------------------------------------

### `CacheConnection$decompose_change()`

Shows which units drive a change in an indicator's coverage between two
years. For each district (or region) it gives the count and denominator
in both years, the coverage change, and the unit's contribution in
percentage points to the change at the level above. The contribution is
split into service delivery (the change in count) and the unit's share
of the denominator's change. Each unit also has its reporting rate,
flagged when reporting was low or fell, since a drop may be missing
reports rather than fewer services. Denominators are the ones the app's
coverage uses (count / coverage), so the parts add up to the change the
app shows.

#### Usage

    CacheConnection$decompose_change(
      indicator,
      from_year,
      to_year,
      admin_level = c("district", "adminlevel_1"),
      region = NULL,
      denominator = NULL
    )

#### Arguments

- `indicator`:

  Character. One indicator, e.g. `"anc4"`.

- `from_year, to_year`:

  The two years to compare.

- `admin_level`:

  `"district"` or `"adminlevel_1"`: the units to attribute the change
  to.

- `region`:

  Optional first-level region(s): attribute a region's change to its
  districts.

- `denominator`:

  Optional denominator source (`"dhis2"`, `"anc1"`, `"penta1"`, ...); by
  default the one selected for the indicator (`get_denominator()`).

#### Returns

A data frame, one row per unit, sorted by contribution (the units
pulling the change most first): `num_from`, `num_to`, `den_from`,
`den_to`, `cov_from`, `cov_to`, `cov_change`, `contribution_service`,
`contribution_denominator`, `contribution`, `reporting_from`,
`reporting_to`, `reporting_flag`; attribute `total` has the level
above's coverage in both years and its change.

------------------------------------------------------------------------

### `CacheConnection$denominator_comparison()`

The Denominator Selection comparison as one tidy table: for each
indicator and year, its coverage under each of the six denominator
options next to the survey estimate of that year, and how far apart they
are. The same numbers as the Denominator Selection charts
([`calculate_derived_coverage()`](calculate_derived_coverage.md)), one
row per denominator, so the options can be compared without reshaping.

#### Usage

    CacheConnection$denominator_comparison(
      indicator = NULL,
      admin_level = c("national", "adminlevel_1", "district"),
      region = NULL
    )

#### Arguments

- `indicator`:

  Character. One or more indicators, e.g.
  `c("penta3", "instlivebirths")`. By default the ones the Denominator
  Selection page compares (Penta 3 and institutional live births; BCG
  and Measles 1 as well in the vaccine app).

- `admin_level`:

  `"national"`, `"adminlevel_1"` or `"district"`.

- `region`:

  Optional first-level region(s): only that region (or its districts).

#### Returns

A data frame, one row per indicator x denominator x year (x region or
district): `indicator`, `denominator` (id), `denominator_label`,
`selected` (whether it is the denominator chosen for the indicator),
`coverage`, `survey`, `survey_lower`, `survey_upper` (the survey
estimate of that year and its bounds, when there is one), `difference`
(coverage minus survey, percentage points) and `survey_year` (the base
year the derived denominators start from).

------------------------------------------------------------------------

### `CacheConnection$reactive()`

Returns a reactive wrapper for use within Shiny applications.

#### Usage

    CacheConnection$reactive()

------------------------------------------------------------------------

### `CacheConnection$set_language()`

Sets the UI Language.

#### Usage

    CacheConnection$set_language(value)

#### Arguments

- `value`:

  A two-character language string.

------------------------------------------------------------------------

### `CacheConnection$set_cache_path()`

Sets the caching RDS path and attempts a save to disk immediately.

#### Usage

    CacheConnection$set_cache_path(value)

#### Arguments

- `value`:

  Character string representing the file path.

------------------------------------------------------------------------

### `CacheConnection$set_countdown_data()`

Sets the core unadjusted countdown data. Wipes all derived caches.

#### Usage

    CacheConnection$set_countdown_data(value)

#### Arguments

- `value`:

  A `cd_data` tibble.

------------------------------------------------------------------------

### `CacheConnection$set_wizard_parts()`

Stores the sheets of an upload that the Load Data wizard has read but
not yet merged (the result of
[`load_excel_parts()`](load_excel_parts.md)). `clear_wizard_parts()`
removes them.

#### Usage

    CacheConnection$set_wizard_parts(value)

#### Arguments

- `value`:

  The list [`load_excel_parts()`](load_excel_parts.md) returns.

------------------------------------------------------------------------

### `CacheConnection$clear_wizard_parts()`

Removes the wizard's unmerged sheets and the country stored with
`set_wizard_country()`. Call it after `set_countdown_data()`, once the
sheets have been merged into `countdown_data`.

#### Usage

    CacheConnection$clear_wizard_parts()

------------------------------------------------------------------------

### `CacheConnection$set_wizard_country()`

Stores the country worked out from an upload before its sheets are
merged, so that `country` and `country_iso` have a value in the
meantime. Either element may be `NULL` when the country could not be
worked out. When `country_iso` is given, the survey year, survey
estimates and national rates are filled in from the package's built-in
survey data for that country.

#### Usage

    CacheConnection$set_wizard_country(value)

#### Arguments

- `value`:

  A `list(country, country_iso)`, as
  [`resolve_country_best_effort()`](resolve_country_best_effort.md)
  returns.

------------------------------------------------------------------------

### `CacheConnection$set_quality_confirmed()`

Records whether the data finished the Load Data wizard with its quality
checks passed (see `quality_confirmed`).

#### Usage

    CacheConnection$set_quality_confirmed(value)

#### Arguments

- `value`:

  Logical.

------------------------------------------------------------------------

### `CacheConnection$set_wizard_quality_results()`

Stores the quality check results the Load Data wizard showed for the
uploaded sheets (the result of
[`run_all_quality_checks()`](run_all_quality_checks.md) while
`wizard_parts` is set). They are kept after `clear_wizard_parts()`, so
the Data Quality step shows the same results when it is opened again.

#### Usage

    CacheConnection$set_wizard_quality_results(value)

#### Arguments

- `value`:

  The list [`run_all_quality_checks()`](run_all_quality_checks.md)
  returns.

------------------------------------------------------------------------

### `CacheConnection$set_adjusted_data()`

Sets custom adjusted data. Wipes downstream coverage/health system
metrics.

#### Usage

    CacheConnection$set_adjusted_data(value)

#### Arguments

- `value`:

  A `cd_data` tibble.

------------------------------------------------------------------------

### `CacheConnection$set_performance_threshold()`

Sets the performance threshold used for DQA score calculations.

#### Usage

    CacheConnection$set_performance_threshold(value)

#### Arguments

- `value`:

  Integer scalar (e.g., 90).

------------------------------------------------------------------------

### `CacheConnection$set_excluded_years()`

Sets a list of years to manually exclude from modeling.

#### Usage

    CacheConnection$set_excluded_years(value)

#### Arguments

- `value`:

  Numeric vector of years.

------------------------------------------------------------------------

### `CacheConnection$set_adjustment_settings()`

Sets the adjustment settings (see
[`adjust_service_data()`](adjust_service_data.md)) the Data Adjustment
page edits. Keeps `excluded_years` (its removed years) and `k_factors`
(its k per group, everywhere) in step with them; the adjusted data is
made again by `adjust_data()`.

#### Usage

    CacheConnection$set_adjustment_settings(value)

#### Arguments

- `value`:

  The settings list
  ([`adjustment_settings_check()`](adjustment_settings_check.md) tidies
  and validates it).

------------------------------------------------------------------------

### `CacheConnection$set_k_factors()`

Sets the correction factors for under-reporting.

#### Usage

    CacheConnection$set_k_factors(value)

#### Arguments

- `value`:

  Named numeric vector of k-factors.

------------------------------------------------------------------------

### `CacheConnection$set_adjusted_flag()`

Toggles the adjusted flag status.

#### Usage

    CacheConnection$set_adjusted_flag(value)

#### Arguments

- `value`:

  Logical scalar.

------------------------------------------------------------------------

### `CacheConnection$set_survey_estimates()`

Manually overrides survey estimates. Clears coverage cache.

#### Usage

    CacheConnection$set_survey_estimates(value)

#### Arguments

- `value`:

  Named numeric vector.

------------------------------------------------------------------------

### `CacheConnection$set_derivation_population()`

Sets the base derivation population indicator (e.g.
totlivebirths_dhis2).

#### Usage

    CacheConnection$set_derivation_population(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### `CacheConnection$set_national_estimates()`

Sets list of explicit national estimates (nmr, pnmr, etc.).

#### Usage

    CacheConnection$set_national_estimates(value)

#### Arguments

- `value`:

  Named list.

------------------------------------------------------------------------

### `CacheConnection$set_survey_year()`

Set integer year representing the source survey year.

#### Usage

    CacheConnection$set_survey_year(value)

#### Arguments

- `value`:

  Integer year.

------------------------------------------------------------------------

### `CacheConnection$clear_survey_year()`

Clears the survey year, so that `survey_year` is `NULL`. The tables
computed from it are cleared as well.

#### Usage

    CacheConnection$clear_survey_year()

------------------------------------------------------------------------

### `CacheConnection$set_start_survey_year()`

Set year the survey timeline begins filtering from.

#### Usage

    CacheConnection$set_start_survey_year(value)

#### Arguments

- `value`:

  Integer year.

------------------------------------------------------------------------

### `CacheConnection$set_denominator()`

Set baseline denominator (e.g. penta1).

#### Usage

    CacheConnection$set_denominator(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### `CacheConnection$set_maternal_denominator()`

Set maternal specific baseline denominator (e.g. anc1).

#### Usage

    CacheConnection$set_maternal_denominator(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### `CacheConnection$set_selected_admin_level_1()`

Sets the selected Region for targeted dashboard filtering.

#### Usage

    CacheConnection$set_selected_admin_level_1(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### `CacheConnection$set_selected_district()`

Sets the selected District for targeted dashboard filtering.

#### Usage

    CacheConnection$set_selected_district(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### `CacheConnection$set_mapping_years()`

Sets mapping years for generic plots.

#### Usage

    CacheConnection$set_mapping_years(value)

#### Arguments

- `value`:

  Integer vector.

------------------------------------------------------------------------

### `CacheConnection$set_chart_options()`

Stores what the user changed about how one chart (or, with
`id = "default"`, every chart of this dataset) looks: text, legend,
fonts, sizes. See
[`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html).
Saved with the dataset, so it survives reloads.

#### Usage

    CacheConnection$set_chart_options(id, options)

#### Arguments

- `id`:

  Character. A chart id, by convention `"<page>/<chart>"` (e.g.
  `"national_coverage/anc4"`), or `"default"` for settings that apply to
  every chart (a font, a text scale).

- `options`:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object (or a list of its fields). `NULL` removes what is stored for
  `id`.

#### Returns

Invisibly, TRUE when something changed.

------------------------------------------------------------------------

### `CacheConnection$set_report_project()`

Saves a report built in the report builder (see
[`export_report()`](https://rdrr.io/pkg/datasuite.ui/man/export_report.html)),
or removes it.

#### Usage

    CacheConnection$set_report_project(id, project)

#### Arguments

- `id`:

  Character. The report's id.

- `project`:

  A list: `name`, `design` and `blocks` (see
  [`report_presets()`](report_presets.md)), or `NULL` to remove the
  report.

------------------------------------------------------------------------

### `CacheConnection$set_graph()`

Saves a custom chart (report kind `custom_chart`: where its data comes
from, transforms and a plot description; see
[`datasuite.ui::report_validate_spec()`](https://rdrr.io/pkg/datasuite.ui/man/report_validate_spec.html)),
or removes it. Saved graphs redraw from the data like every other chart
and can be added to any report.

#### Usage

    CacheConnection$set_graph(id, spec)

#### Arguments

- `id`:

  Character. The graph's id.

- `spec`:

  The chart's description, checked with
  [`datasuite.ui::report_validate_spec()`](https://rdrr.io/pkg/datasuite.ui/man/report_validate_spec.html),
  or `NULL` to remove it.

------------------------------------------------------------------------

### `CacheConnection$set_report_asset()`

Saves a picture used by the reports (a block's `src` is then
`"asset:<id>"`), or removes it. Pictures are kept once in the dataset
rather than inside each report; the Word file and the PDF embed their
own copy.

#### Usage

    CacheConnection$set_report_asset(id, asset)

#### Arguments

- `id`:

  Character. The picture's id.

- `asset`:

  A list: `type` (a MIME type such as `"image/png"`) and `data` (a raw
  vector), or `NULL` to remove it.

------------------------------------------------------------------------

### `CacheConnection$set_report_theme()`

Saves a theme made from an Office file (see
[`report_theme_from_file()`](https://rdrr.io/pkg/datasuite.ui/man/report_theme_from_file.html)),
or removes it. Its template (the file itself) is kept as a report asset,
`theme$template` being `"asset:<id>"`.

#### Usage

    CacheConnection$set_report_theme(id, theme)

#### Arguments

- `id`:

  Character. The theme's id.

- `theme`:

  A theme list, or `NULL` to remove it.

------------------------------------------------------------------------

### `CacheConnection$get_chart_options()`

The chart options that apply to one chart: the dataset's `"default"`
options with the chart's own on top.

#### Usage

    CacheConnection$get_chart_options(id = NULL)

#### Arguments

- `id`:

  Character. A chart id (see `set_chart_options()`), or `NULL` for the
  defaults alone.

#### Returns

A
[`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
object (empty when nothing is stored).

------------------------------------------------------------------------

### `CacheConnection$reset_chart_options()`

Forgets stored chart options.

#### Usage

    CacheConnection$reset_chart_options(id = NULL)

#### Arguments

- `id`:

  Character. The chart id to reset, or `NULL` to reset every chart and
  the defaults.

#### Returns

Invisibly, TRUE when something changed.

------------------------------------------------------------------------

### `CacheConnection$set_mortality_mapping_years()`

Sets mapping years explicitly for mortality dashboards.

#### Usage

    CacheConnection$set_mortality_mapping_years(value)

#### Arguments

- `value`:

  Integer vector.

------------------------------------------------------------------------

### `CacheConnection$set_utilization_mapping_years()`

Sets mapping years explicitly for utilization dashboards.

#### Usage

    CacheConnection$set_utilization_mapping_years(value)

#### Arguments

- `value`:

  Integer vector.

------------------------------------------------------------------------

### `CacheConnection$set_fpet_data()`

Sets the Family Planning Estimation Tool (FPET) dataset.

#### Usage

    CacheConnection$set_fpet_data(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$set_un_estimates()`

Sets the official UN Demographic Estimates dataset. Clears denominators.

#### Usage

    CacheConnection$set_un_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$clear_un_estimates()`

Removes an uploaded UN Demographic Estimates dataset. `un_estimates`
then returns the package's built-in estimates for the current country.
The tables computed from the estimates are cleared.

#### Usage

    CacheConnection$clear_un_estimates()

------------------------------------------------------------------------

### `CacheConnection$set_un_mortality_estimates()`

Sets the UN Mortality specific estimates dataset. Clears mortality
cache.

#### Usage

    CacheConnection$set_un_mortality_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$clear_un_mortality_estimates()`

Removes an uploaded UN Mortality Estimates dataset.
`un_mortality_estimates` then returns the package's built-in estimates
for the current country. The tables computed from the estimates are
cleared.

#### Usage

    CacheConnection$clear_un_mortality_estimates()

------------------------------------------------------------------------

### `CacheConnection$set_wuenic_estimates()`

Sets WUENIC estimates dataset. Clears coverage cache.

#### Usage

    CacheConnection$set_wuenic_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$clear_wuenic_estimates()`

Removes an uploaded WUENIC Estimates dataset. `wuenic_estimates` then
returns the package's built-in estimates for the current country. The
tables computed from the estimates are cleared.

#### Usage

    CacheConnection$clear_wuenic_estimates()

------------------------------------------------------------------------

### `CacheConnection$set_national_survey()`

Sets overall national survey dataset and automatically extracts its
estimates.

#### Usage

    CacheConnection$set_national_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$clear_national_survey()`

Removes an uploaded national survey. `national_survey` then returns the
package's built-in survey data for the current country. The survey year,
survey estimates and national rates that were taken from the removed
survey are kept.

#### Usage

    CacheConnection$clear_national_survey()

------------------------------------------------------------------------

### `CacheConnection$set_regional_survey()`

Sets the disaggregated regional survey dataset.

#### Usage

    CacheConnection$set_regional_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$clear_regional_survey()`

Removes an uploaded regional survey. `regional_survey` then returns the
package's built-in survey data for the current country. The tables
computed from the regional survey are cleared.

#### Usage

    CacheConnection$clear_regional_survey()

------------------------------------------------------------------------

### `CacheConnection$set_shapefile()`

Sets an uploaded shapefile, used instead of the package's built-in
shapefile for the current country.

#### Usage

    CacheConnection$set_shapefile(value)

#### Arguments

- `value`:

  An `sf` object (as
  [`read_shapefile_folder()`](read_shapefile_folder.md) returns).

------------------------------------------------------------------------

### `CacheConnection$clear_shapefile()`

Clears an uploaded shapefile override, reverting to the package's
built-in default for the current country.

#### Usage

    CacheConnection$clear_shapefile()

------------------------------------------------------------------------

### `CacheConnection$set_shapefile_name_field()`

Sets which column of the uploaded shapefile holds the admin level 1
names. Without it, `NAME_1` is used, the column of the built-in
shapefiles.
[`check_shapefile_admin_names()`](check_shapefile_admin_names.md) reads
the names from this column.

#### Usage

    CacheConnection$set_shapefile_name_field(value)

#### Arguments

- `value`:

  Character. A column name present in `self$shapefile`.

------------------------------------------------------------------------

### `CacheConnection$set_wiq_survey()`

Sets wealth quantile (WIQ) survey dataset.

#### Usage

    CacheConnection$set_wiq_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$clear_wiq_survey()`

Removes an uploaded wealth quintile (WIQ) survey. `wiq_survey` then
returns the package's built-in survey data for the current country,
which has no rows for a country without any.

#### Usage

    CacheConnection$clear_wiq_survey()

------------------------------------------------------------------------

### `CacheConnection$set_area_survey()`

Sets area level (urban/rural) survey dataset.

#### Usage

    CacheConnection$set_area_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$clear_area_survey()`

Removes an uploaded area (urban/rural) survey. `area_survey` then
returns the package's built-in survey data for the current country.

#### Usage

    CacheConnection$clear_area_survey()

------------------------------------------------------------------------

### `CacheConnection$set_education_survey()`

Sets education level survey dataset.

#### Usage

    CacheConnection$set_education_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$clear_education_survey()`

Removes an uploaded education survey. `education_survey` then returns
the package's built-in survey data for the current country.

#### Usage

    CacheConnection$clear_education_survey()

------------------------------------------------------------------------

### `CacheConnection$set_survey_mapping()`

Sets survey to countdown nomenclature mapping matrix.

#### Usage

    CacheConnection$set_survey_mapping(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$clear_survey_mapping()`

Removes the mapping between the survey's regions and the dataset's
regions. There is no built-in mapping, so `survey_mapping` is `NULL`
until a new one is set. The tables computed from the mapping are
cleared.

#### Usage

    CacheConnection$clear_survey_mapping()

------------------------------------------------------------------------

### `CacheConnection$set_map_mapping()`

Sets map coordinates to countdown nomenclature mapping matrix.

#### Usage

    CacheConnection$set_map_mapping(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$clear_map_mapping()`

Removes the mapping between the shapefile's regions and the dataset's
regions. There is no built-in mapping, so `map_mapping` is `NULL` until
a new one is set.

#### Usage

    CacheConnection$clear_map_mapping()

------------------------------------------------------------------------

### `CacheConnection$is_default()`

Checks whether nothing has been set for a field. For a field with
built-in data (`un_estimates`, `un_mortality_estimates`,
`wuenic_estimates`) this means no dataset was uploaded, although the
active binding still returns the built-in data. For a field without any
(`survey_mapping`, `map_mapping`) it means the field is empty.

#### Usage

    CacheConnection$is_default(field_name)

#### Arguments

- `field_name`:

  Character. The field to check (e.g. "un_estimates", "survey_mapping").

#### Returns

Logical. `TRUE` when nothing has been set for the field.

------------------------------------------------------------------------

### `CacheConnection$set_sector_national_estimates()`

Set sector national estimates mapping.

#### Usage

    CacheConnection$set_sector_national_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$set_sector_area_estimates()`

Set sector area estimates mapping.

#### Usage

    CacheConnection$set_sector_area_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$set_csection_national_estimates()`

Set c-section national estimates mapping.

#### Usage

    CacheConnection$set_csection_national_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$set_csection_area_estimates()`

Set c-section area estimates mapping.

#### Usage

    CacheConnection$set_csection_area_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### `CacheConnection$calculate_reporting_rate()`

Wrapper to calculate average reporting rates from raw countdown data.

#### Usage

    CacheConnection$calculate_reporting_rate(admin_level, region = NULL)

#### Arguments

- `admin_level`:

  Administrative level ("national", "adminlevel_1", "district").

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$calculate_district_reporting_rate()`

Wrapper to calculate proportion of districts meeting reporting
thresholds.

#### Usage

    CacheConnection$calculate_district_reporting_rate(region = NULL)

#### Arguments

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$calculate_completeness_summary()`

Wrapper to calculate completeness proportions from raw countdown data.

#### Usage

    CacheConnection$calculate_completeness_summary(admin_level, region = NULL)

#### Arguments

- `admin_level`:

  Administrative level.

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$calculate_district_completeness_summary()`

Wrapper to calculate district level completeness details.

#### Usage

    CacheConnection$calculate_district_completeness_summary(region = NULL)

#### Arguments

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$list_missing_units()`

Locates missing/non-reporting facility units.

#### Usage

    CacheConnection$list_missing_units(indicator, region = NULL)

#### Arguments

- `indicator`:

  Target indicator name.

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$calculate_outliers_summary()`

Identifies severe outliers across administrative levels using Hampel
method.

#### Usage

    CacheConnection$calculate_outliers_summary(admin_level, region = NULL)

#### Arguments

- `admin_level`:

  Administrative level.

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$calculate_district_outlier_summary()`

Flags percentage of districts with acceptable outlier variances.

#### Usage

    CacheConnection$calculate_district_outlier_summary(region = NULL)

#### Arguments

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$calculate_ratios_and_adequacy()`

Calculates adequacy ratios across chronological indicator sequences
(e.g. Penta1 to Penta3).

#### Usage

    CacheConnection$calculate_ratios_and_adequacy(region = NULL)

#### Arguments

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$check_population_service_collision()`

Flags district-years where a service indicator looks mixed up with
population data.

#### Usage

    CacheConnection$check_population_service_collision()

------------------------------------------------------------------------

### `CacheConnection$check_indicator_emptiness()`

Flags indicators that are entirely empty across the whole dataset.

#### Usage

    CacheConnection$check_indicator_emptiness()

------------------------------------------------------------------------

### `CacheConnection$check_survey_admin_names()`

Matches survey `adminlevel_1` names against the dataset's own admin
level 1 names, skipping names already resolved via `survey_mapping`.

#### Usage

    CacheConnection$check_survey_admin_names()

------------------------------------------------------------------------

### `CacheConnection$check_shapefile_admin_names()`

Matches the shapefile's admin level 1 names (the `shapefile_name_field`
column of `shapefile`) against the dataset's admin level 1 names,
skipping names already resolved in `map_mapping`.

#### Usage

    CacheConnection$check_shapefile_admin_names()

------------------------------------------------------------------------

### `CacheConnection$calculate_overall_score()`

Calculates the aggregate DQA overall score assessing reporting,
completeness, and outliers.

#### Usage

    CacheConnection$calculate_overall_score(
      admin_level = c("national", "adminlevel_1"),
      region = NULL,
      labels = NULL
    )

#### Arguments

- `admin_level`:

  Administrative level ("national" or "adminlevel_1").

- `region`:

  Optional region name (required if admin_level is "adminlevel_1").

- `labels`:

  Optional custom display labels.

------------------------------------------------------------------------

### `CacheConnection$calculate_service_dqa_summary()`

Calculates Service DQA Summary comparing general reporting vs specific
utilization metrics.

#### Usage

    CacheConnection$calculate_service_dqa_summary(
      admin_level = c("national", "adminlevel_1"),
      region = NULL,
      labels = NULL
    )

#### Arguments

- `admin_level`:

  Administrative level ("national" or "adminlevel_1").

- `region`:

  Optional region name (required if admin_level is "adminlevel_1").

- `labels`:

  Optional custom labels.

------------------------------------------------------------------------

### `CacheConnection$generate_admin1_service_utilization()`

Generates Service Utilization Admin level 1 Data mapping format.

#### Usage

    CacheConnection$generate_admin1_service_utilization(
      metric_type = c("opd", "ipd")
    )

#### Arguments

- `metric_type`:

  Character. Either "opd" or "ipd".

#### Returns

A tibble with class `cd_service_util_admin1`.

------------------------------------------------------------------------

### `CacheConnection$generate_admin1_mch_curative_index()`

Formats Maternal Child Health vs Curative Index data for plotting.

#### Usage

    CacheConnection$generate_admin1_mch_curative_index()

------------------------------------------------------------------------

### `CacheConnection$get_filtered_coverage()`

Gets filtered coverage data isolating a specific indicator for charts.

#### Usage

    CacheConnection$get_filtered_coverage(indicator, admin_level, region = NULL)

#### Arguments

- `indicator`:

  Character. The target health indicator.

- `admin_level`:

  Character. Level of aggregation.

- `region`:

  Character. Optional region or district name.

------------------------------------------------------------------------

### `CacheConnection$get_filtered_inequality()`

Gets filtered inequality data targeting a single indicator.

#### Usage

    CacheConnection$get_filtered_inequality(indicator, admin_level, region = NULL)

#### Arguments

- `indicator`:

  Character. The target health indicator.

- `admin_level`:

  Character. Level of aggregation.

- `region`:

  Character. Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$get_filtered_mapping_data()`

Filters mapping spatial data focusing on a specific year and palette.

#### Usage

    CacheConnection$get_filtered_mapping_data(
      indicator,
      admin_level,
      palette,
      plot_year = NULL
    )

#### Arguments

- `indicator`:

  Character. The target health indicator.

- `admin_level`:

  Character. Level of aggregation.

- `palette`:

  Character. Color palette for mapping.

- `plot_year`:

  Integer. Year to plot.

------------------------------------------------------------------------

### `CacheConnection$get_base_indicator_coverage()`

Returns the base denominator and numerator metrics before survey
interpolation.

#### Usage

    CacheConnection$get_base_indicator_coverage(
      admin_level,
      region = NULL,
      show_district = TRUE
    )

#### Arguments

- `admin_level`:

  Character. Level of aggregation.

- `region`:

  Character. Optional region filter.

- `show_district`:

  Optional. Whether to show the district column.

------------------------------------------------------------------------

### `CacheConnection$get_filtered_threshold()`

Evaluates indicator data against set threshold benchmarks (e.g. 80%
coverage).

#### Usage

    CacheConnection$get_filtered_threshold(indicator, target_unit, region = NULL)

#### Arguments

- `indicator`:

  Character. The target health indicator group.

- `target_unit`:

  Character. Evaluated level ("district" or "adminlevel_1").

- `region`:

  Character. Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$calculate_derived_coverage()`

Derives specific complex coverage indicators based on basic survey data.

#### Usage

    CacheConnection$calculate_derived_coverage(
      indicator,
      admin_level,
      region = NULL
    )

#### Arguments

- `indicator`:

  Character. The target health indicator.

- `admin_level`:

  Character. Administrative level.

- `region`:

  Character. Optional region name.

------------------------------------------------------------------------

### `CacheConnection$get_high_performers()`

Identifies regions/districts that exceed benchmark coverage thresholds.

#### Usage

    CacheConnection$get_high_performers(indicator, admin_level, region = NULL)

#### Arguments

- `indicator`:

  Character. The target health indicator.

- `admin_level`:

  Character. Level of aggregation.

- `region`:

  Character. Optional region filter.

------------------------------------------------------------------------

### `CacheConnection$get_regional_estimates()`

The rates for one region, from the survey files: the region's own
mortality rates and survey coverage (its latest survey value of each,
from `regional_survey`, read through `survey_mapping` so the region is
named as in the data). A rate the region's surveys do not give keeps the
national value; the national rates are returned whole only when no
region is asked for or the region is not in the survey files (the
result's `source` attribute says which: `"regional"` or `"national"`).

#### Usage

    CacheConnection$get_regional_estimates(
      admin_level = c("adminlevel_1", "district"),
      region = NULL
    )

#### Arguments

- `admin_level`:

  Character. `"adminlevel_1"` when `region` is a region, `"district"`
  when it is a district (its region's rates are given).

- `region`:

  Character. The region's (or district's) name, as in the data. `NULL`:
  the national rates.

#### Returns

A list like `national_estimates` (proportions: `nmr`, `pnmr`, `sbr`,
`twin_rate`, `preg_loss`, `anc1`, `penta1`), with the region's other
survey coverage values added when it has them.

------------------------------------------------------------------------

### `CacheConnection$generate_health_system_table()`

Generates a formatted table of core health system metrics.

#### Usage

    CacheConnection$generate_health_system_table(labels = NULL)

#### Arguments

- `labels`:

  Character. Optional custom labels to use on the table headers.

------------------------------------------------------------------------

### `CacheConnection$generate_phc_scatter_data()`

Prepares scatter plot data comparing Primary Health Care performance.

#### Usage

    CacheConnection$generate_phc_scatter_data(indicator)

#### Arguments

- `indicator`:

  Character. The independent variable to plot ("ratio_fac_pop" or
  "ratio_hstaff_pop").

------------------------------------------------------------------------

### `CacheConnection$generate_private_sector_data()`

Extracts private versus public sector ownership distributions.

#### Usage

    CacheConnection$generate_private_sector_data(legend_labels = NULL)

#### Arguments

- `legend_labels`:

  Named list. Optional list to override default labels for Private, NGO,
  and Public.

------------------------------------------------------------------------

### `CacheConnection$get_bayes_model()`

Generates or retrieves a pre-calculated Bayesian mathematical model for
an indicator.

#### Usage

    CacheConnection$get_bayes_model(admin_level, indicator)

#### Arguments

- `admin_level`:

  Administrative level ("national", "adminlevel_1").

- `indicator`:

  Character. Indicator name (e.g., 'penta3').

------------------------------------------------------------------------

### `CacheConnection$bayes_model_key()`

The key a Bayesian model is kept under (its admin level, indicator and
denominator).

#### Usage

    CacheConnection$bayes_model_key(admin_level, indicator)

#### Arguments

- `admin_level`:

  Administrative level ("national", "adminlevel_1").

- `indicator`:

  Character. Indicator name (e.g., 'penta3').

------------------------------------------------------------------------

### `CacheConnection$bayes_model_cached()`

The Bayesian model already made for an indicator (by `get_bayes_model()`
or kept with `keep_bayes_model()`), or `NULL`: nothing is fitted.

#### Usage

    CacheConnection$bayes_model_cached(admin_level, indicator)

#### Arguments

- `admin_level`:

  Administrative level ("national", "adminlevel_1").

- `indicator`:

  Character. Indicator name (e.g., 'penta3').

------------------------------------------------------------------------

### `CacheConnection$bayes_national_routine()`

The country's coverage of a model's indicator from the facility data,
with the indicator's denominator: what a sub-national model's charts
show beside the regions
([`plot()`](https://rdrr.io/r/graphics/plot.default.html)'s `national`).

#### Usage

    CacheConnection$bayes_national_routine(indicator)

#### Arguments

- `indicator`:

  Character. One of the model's indicators.

#### Returns

A tibble with `year` and `value` (a proportion), or `NULL` when coverage
cannot be computed yet.

------------------------------------------------------------------------

### `CacheConnection$bayes_model_inputs()`

What [`generate_bayes_model()`](generate_bayes_model.md) needs for an
indicator, to fit it in another R process (a Shiny ExtendedTask, so the
app is not frozen for the minutes a fit takes); its result is kept with
`keep_bayes_model()` under `key`.

#### Usage

    CacheConnection$bayes_model_inputs(admin_level, indicator)

#### Arguments

- `admin_level`:

  Administrative level ("national", "adminlevel_1").

- `indicator`:

  Character. Indicator name (e.g., 'penta3').

#### Returns

A list: `key`, `coverage_data`, `overall_score`, `indicator`,
`denominator`.

------------------------------------------------------------------------

### `CacheConnection$keep_bayes_model()`

Keeps a Bayesian model fitted elsewhere (see `bayes_model_inputs()`).

#### Usage

    CacheConnection$keep_bayes_model(key, model)

#### Arguments

- `key`:

  The key it was fitted for (`bayes_model_inputs()$key`).

- `model`:

  The model ([`generate_bayes_model()`](generate_bayes_model.md)'s
  result).

------------------------------------------------------------------------

### `CacheConnection$bayes_estimates()`

The estimates of the Bayesian models already fitted at an admin level,
as one table ([`bayes_model_estimates()`](bayes_model_estimates.md) of
each, with the denominator it was fitted for). Only the models for the
denominators selected now, as the Bayesian pages show; nothing is fitted
here.

#### Usage

    CacheConnection$bayes_estimates(admin_level)

#### Arguments

- `admin_level`:

  Administrative level ("national", "adminlevel_1").

#### Returns

A tibble, or `NULL` when no model has been fitted at that level.

------------------------------------------------------------------------

### `CacheConnection$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CacheConnection$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
