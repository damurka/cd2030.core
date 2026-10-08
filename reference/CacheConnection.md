# CacheConnection Class

An R6 class that handles persistent or in-memory caching of data used in
the Countdown 2030 analysis and reporting workflows.

**Dependency Architecture:**

- **Layer 0 (Core Data):** Raw `countdown_data`, thresholds, external
  surveys (`un_estimates`).

- **Layer 1 (DQA & Adjustments):** Depends on Layer 0. Includes
  `adjusted_data`, reporting rates, completeness, overall scores.

- **Layer 2 (Coverage & Denominators):** Depends on Layer 1. Includes
  derived coverages at national, admin1, and district levels.

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

  Active Binding: Extracts unique years present in the raw data. Before
  Finish (`wizard_parts` still set, no `countdown_data` yet), falls back
  to the raw Population sheet's own `year` column – confirmed live this
  matters: several other page modules read `cache()$data_years`
  unconditionally the moment `cache()` itself becomes non-NULL (e.g.
  `modules/1b_remove_years.R`'s own `req(cache()$data_years)`), and
  those page modules are instantiated at app startup the same "always
  running" way the wizard's own step servers are – reachable well before
  Finish, not just after.

- `subnational_regions`:

  Active Binding: Extracts unique admin1 and district combinations.
  Before Finish (`wizard_parts` still set, no `countdown_data` yet),
  falls back to the raw Admin sheet's own `first_admin_level`/`district`
  columns – this is what lets Map Survey/Map Shapefile show the real
  admin1 list mid-wizard, per the wizard redesign's own requirement that
  mapping happens "against the admin1 from admin sheet."

- `country`:

  Active Binding: Gets the text string representing the focal country.
  Readonly. Before Finish, falls back to `wizard_country` – a
  best-effort, non-aborting resolution
  ([`resolve_country_best_effort()`](resolve_country_best_effort.md),
  0_import_load_data.R) computed right after upload, since the real,
  validated `country` attribute only exists once
  [`merge_and_standardize()`](merge_and_standardize.md)'s
  `match_country()` call has actually run. The genuine validation (is
  there cleanly one country value at all) stays
  [`check_single_country()`](check_single_country.md)'s job, surfaced at
  the Data Quality step – this fallback's only job is unblocking
  everything else that needs a country before Finish (the header badge,
  national-rate/survey defaults, the bundled shapefile lookup).

- `country_iso`:

  Active Binding: Gets the 3-letter ISO code for the country. Readonly.
  Same pre-Finish fallback as `country` above.

- `wizard_parts`:

  Active Binding: Gets the Load Data wizard's own in-progress,
  not-yet-merged sheets ([`load_excel_parts()`](load_excel_parts.md)'s
  result) – `NULL` once Finish has merged them into `countdown_data`, or
  for any cache that was never in wizard mode to begin with.

- `quality_confirmed`:

  Active Binding: `TRUE` once this cache's data finished the Load Data
  wizard with its quality checks passed (set once, at Finish – see
  `set_quality_confirmed()` below) – persisted with everything else in
  the `.rds`, so it survives a resume. `FALSE` for a cache still
  mid-wizard, and for any cache built outside the wizard entirely.

- `wizard_quality_results`:

  Active Binding: Gets the frozen, pre-merge quality-check snapshot
  taken at Finish (`NULL` before Finish, and for any cache that never
  went through the wizard) – see `set_wizard_quality_results()`'s own
  comment for why this exists and what reads it
  ([`run_all_quality_checks()`](run_all_quality_checks.md)).

- `adjusted_data`:

  Active Binding: Gets countdown data with K-factors applied. Adjusts
  automatically if flags are met.

- `data_with_excluded_years`:

  Active Binding: Raw data filtered to remove user-excluded years.
  Readonly. `NULL` before Finish (no `countdown_data` yet, mid-wizard) –
  "Remove Years" is a separate, post-Finish page, not something the
  wizard itself needs a pre-merge equivalent for.

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
  [`adjust_service_data()`](adjust_service_data.md)); a dataset saved
  before they existed gets them from its `k_factors` and
  `excluded_years`.

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

  Active Binding: Fetches FPET metrics (loads from global if missing).

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

  Active Binding: Fetches the shapefile to use for this country – a
  user-uploaded override (`set_shapefile()`) if one exists, otherwise
  the package-bundled default for `country_iso`, same
  override-with-fallback pattern as `regional_survey` above. `NULL` if
  `country_iso` isn't known yet (mid-wizard, before the admin sheet's
  country resolves) – there's nothing to fetch a bundled shapefile FOR
  yet.

- `shapefile_name_field`:

  Active Binding: Which column of `self$shapefile` holds admin-1 names –
  `"NAME_1"` (the bundled shapefile's own column) unless a user-uploaded
  one set a different field via `set_shapefile_name_field()`.

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

  Active Binding: Automatically calculates and caches Admin1 inequality
  matrices.

- `inequality_district`:

  Active Binding: Automatically calculates and caches District
  inequality matrices.

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

  Active Binding: Caches OPD/IPD utilizations parsed by Admin 1 level.

- `health_system_comparison`:

  Active Binding: Summarizes health system efficiency linking resources
  to coverage.

- `health_system_metrics_national`:

  Active Binding: Compiles core indicators (staff density, beds) at the
  National scale.

- `health_system_metrics_admin1`:

  Active Binding: Compiles core indicators (staff density, beds) at the
  Admin 1 scale.

- `national_private_share`:

  Active Binding: Returns baseline metrics regarding private sector
  operations (National).

- `area_private_share`:

  Active Binding: Returns baseline metrics regarding private sector
  operations (Area/Region). Invalidate entirely (Usually triggered on
  initial data load) Invalidate downstream computations (Coverage,
  Mortality, etc.) derived from adjustments Invalidate Data Quality
  Cache Invalidate Denominator Cache Invalidate Coverage Cache
  (Automatically cascades to Inequality & Health Systems) Invalidate
  Inequality Cache Invalidate Mortality Cache Invalidate Utilization
  Cache Invalidate Health Systems Cache

## Methods

### Public methods

- [`CacheConnection$new()`](#method-CacheConnection-new)

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

- [`CacheConnection$bayes_model_inputs()`](#method-CacheConnection-bayes_model_inputs)

- [`CacheConnection$keep_bayes_model()`](#method-CacheConnection-keep_bayes_model)

- [`CacheConnection$bayes_estimates()`](#method-CacheConnection-bayes_estimates)

- [`CacheConnection$clone()`](#method-CacheConnection-clone)

------------------------------------------------------------------------

### Method `new()`

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
  the picked `.xlsx`). The cache always lives at
  `<dirname(data_path)>/<stem(data_path)>.rds` – if that file already
  exists, it's loaded instead of `countdown_data` (the fresh parse is
  discarded); otherwise it's created there. This is the only place that
  decides the cache's location and load-vs-create behavior, so every
  caller gets the same behavior regardless of how they got here.

- `wizard_parts`:

  A [`load_excel_parts()`](load_excel_parts.md) result
  (`list(parts, sheet_names, sheet_ids, ...)`) – a third,
  mutually-exclusive mode alongside `rds_path`/`countdown_data`, for the
  Load Data wizard's own in-progress state (Phase 3 of the wizard
  redesign, apps/rmncah): the sheets have been read and cleaned but not
  yet merged/standardized into a real `cd_data` object, so there's no
  `countdown_data` yet – see `wizard_parts`/`country`/`country_iso`'s
  own active bindings below for how the rest of the class degrades
  gracefully until `set_countdown_data()` is finally called (at Finish,
  once [`merge_and_standardize()`](merge_and_standardize.md) has run).

- `read_only`:

  `TRUE` never writes the cache back to its `.rds` (see
  [`init_CacheConnection()`](init_CacheConnection.md)).

------------------------------------------------------------------------

### Method `load_from_disk()`

Load cached data from the designated RDS file on disk.

#### Usage

    CacheConnection$load_from_disk()

------------------------------------------------------------------------

### Method `save_to_disk()`

Save current in-memory state to the assigned RDS file, provided state
has changed.

#### Usage

    CacheConnection$save_to_disk()

------------------------------------------------------------------------

### Method `adjust_data()`

Processes raw data into adjusted data with the adjustment settings
(`adjustment_settings`: the years and areas removed, each indicator's k,
outlier and missing-value switches, everywhere or by area).

#### Usage

    CacheConnection$adjust_data()

------------------------------------------------------------------------

### Method [`calculate_indicator_coverage()`](calculate_indicator_coverage.md)

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

### Method [`calculate_inequality()`](calculate_inequality.md)

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

### Method [`calculate_coverage()`](calculate_coverage.md)

Integrates immunization coverage data from DHIS2, Surveys, and WUENIC.

#### Usage

    CacheConnection$calculate_coverage(admin_level, region = NULL)

#### Arguments

- `admin_level`:

  Administrative level ("national", "adminlevel_1", or "district").

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### Method [`generate_coverage_data()`](generate_coverage_data.md)

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

### Method [`get_mapping_data()`](get_mapping_data.md)

Formats base coverage data with spatial map coordinates for plotting.

#### Usage

    CacheConnection$get_mapping_data(admin_level)

#### Arguments

- `admin_level`:

  Administrative level.

------------------------------------------------------------------------

### Method `lbr_mean()`

Retrieves the mean of institutional livebirths from the national
coverage cache.

#### Usage

    CacheConnection$lbr_mean()

------------------------------------------------------------------------

### Method [`summarise_completeness_ratio()`](summarise_completeness_ratio.md)

Creates mortality completeness ratio summaries.

#### Usage

    CacheConnection$summarise_completeness_ratio(indicator)

#### Arguments

- `indicator`:

  Character. The indicator to generate the summary for.

------------------------------------------------------------------------

### Method [`filter_mortality_summary()`](filter_mortality_summary.md)

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

### Method [`compute_service_utilization()`](compute_service_utilization.md)

Computes service utilization for various indicators (OPD/IPD).

#### Usage

    CacheConnection$compute_service_utilization(admin_level)

#### Arguments

- `admin_level`:

  The level to aggregate data at ("national", "adminlevel_1").

------------------------------------------------------------------------

### Method [`filter_service_utilization()`](filter_service_utilization.md)

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

### Method [`prepare_mapping_service_utlization()`](prepare_mapping_service_utlization.md)

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

### Method `get_denominator()`

Resolves the appropriate denominator column string based on the
indicator category.

#### Usage

    CacheConnection$get_denominator(indicator)

#### Arguments

- `indicator`:

  Character. The indicator name.

------------------------------------------------------------------------

### Method `decompose_change()`

Which units drive a change in an indicator's coverage between two years:
for each district (or region) its count and denominator in both years,
its coverage change, and its contribution in percentage points to the
change at the level above – split into service delivery (its change in
count) and its share of the denominator's change – with its reporting
rate, flagged when reporting was low or fell, since a drop may be
missing reports rather than fewer services. Denominators are the ones
the app's coverage uses (count / coverage), so the parts add up to the
change the app shows.

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

### Method `denominator_comparison()`

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

### Method `reactive()`

Returns a reactive wrapper for use within Shiny applications.

#### Usage

    CacheConnection$reactive()

------------------------------------------------------------------------

### Method `set_language()`

Sets the UI Language.

#### Usage

    CacheConnection$set_language(value)

#### Arguments

- `value`:

  A two-character language string.

------------------------------------------------------------------------

### Method `set_cache_path()`

Sets the caching RDS path and attempts a save to disk immediately.

#### Usage

    CacheConnection$set_cache_path(value)

#### Arguments

- `value`:

  Character string representing the file path.

------------------------------------------------------------------------

### Method `set_countdown_data()`

Sets the core unadjusted countdown data. Wipes all derived caches.

#### Usage

    CacheConnection$set_countdown_data(value)

#### Arguments

- `value`:

  A `cd_data` tibble.

------------------------------------------------------------------------

### Method `set_wizard_parts()`

Sets the Load Data wizard's own in-progress, not-yet-merged sheets
([`load_excel_parts()`](load_excel_parts.md)'s result). Called once,
right after a fresh Excel/Stata upload, by `apps/rmncah`'s own
`upload_box.R` – see `wizard_parts`'s own active-binding comment for
what this unblocks in the meantime, and
[`merge_and_standardize()`](merge_and_standardize.md)/Finish for where
it's cleared.

#### Usage

    CacheConnection$set_wizard_parts(value)

#### Arguments

- `value`:

  The list [`load_excel_parts()`](load_excel_parts.md) returns.

------------------------------------------------------------------------

### Method `clear_wizard_parts()`

Clears the wizard's in-progress parts/country state once Finish has
actually merged them into real `countdown_data` – called right after
`set_countdown_data()` at Finish (`wizard_panels.R`). Not just tidiness:
[`run_all_quality_checks()`](run_all_quality_checks.md) branches on
whether `wizard_parts` is still set, so leaving it behind would keep
routing a now-fully-merged cache through the pre-merge check path if the
wizard's own Data Quality step (or edit mode) is ever revisited
afterward.

#### Usage

    CacheConnection$clear_wizard_parts()

------------------------------------------------------------------------

### Method `set_wizard_country()`

Sets the wizard's best-effort, non-aborting country resolution – see
`country`/`country_iso`'s own active-binding comments for why this is
separate from the real
[`check_single_country()`](check_single_country.md) validation. Uses
`update_field()` directly (not `setter()`, which rejects `NULL`) since
`value$country`/`value$country_iso` being `NULL` – an ambiguous or
unmatched admin sheet – is itself a legitimate, expected result to
store: the `country`/`country_iso` bindings need a real `NULL` back, not
a stray `NA`, to keep matching the
[`is.null()`](https://rdrr.io/r/base/NULL.html) convention every other
consumer already uses. Also runs `initialize_survey_estimates()` once a
real `country_iso` is actually known – the `initialize()`-time call the
non-wizard branch gets was deliberately skipped for wizard mode (see
that branch's own comment) precisely because it needed this to have
already happened.

#### Usage

    CacheConnection$set_wizard_country(value)

#### Arguments

- `value`:

  A `list(country, country_iso)`, as
  [`resolve_country_best_effort()`](resolve_country_best_effort.md)
  returns.

------------------------------------------------------------------------

### Method `set_quality_confirmed()`

Marks this cache's data as having finished the Load Data wizard with its
quality checks passed – set once, at Finish, right before
`set_cache_path()` writes it to disk. See `quality_confirmed`'s own
active-binding comment for what reads this.

#### Usage

    CacheConnection$set_quality_confirmed(value)

#### Arguments

- `value`:

  Logical.

------------------------------------------------------------------------

### Method `set_wizard_quality_results()`

A permanent snapshot of
[`run_all_quality_checks()`](run_all_quality_checks.md)'s own result,
taken once at Finish – right before `clear_wizard_parts()`
(`wizard_panels.R`, apps/rmncah), while `wizard_parts` is still set, so
this captures the exact pre-merge, per-sheet checks the user actually
saw during the walkthrough. Exists because `clear_wizard_parts()`'s own
removal of `wizard_parts` (deliberate – see its own comment) means
[`run_all_quality_checks()`](run_all_quality_checks.md) would otherwise
silently fall through to the POST-merge check path
(`.run_post_merge_quality_checks()`) the moment Data Quality is
revisited after Finish (a landing-page Edit link, or edit mode
generally) – a genuinely different set of checks, computed against the
merged/standardized `countdown_data` instead of the original unmerged
sheets, that can report different numbers than what was shown at upload
time. Confirmed live: this is exactly the bug reported as "data quality
is not giving the actual values given during the uploading".
`wizard_parts` itself can't just be kept around instead – it would grow
stale the moment anything downstream (Remove Years, Data Adjustment)
changes `countdown_data`, which this snapshot, frozen at the one moment
it was genuinely accurate, doesn't have that problem.

#### Usage

    CacheConnection$set_wizard_quality_results(value)

#### Arguments

- `value`:

  The list [`run_all_quality_checks()`](run_all_quality_checks.md)
  returns.

------------------------------------------------------------------------

### Method `set_adjusted_data()`

Sets custom adjusted data. Wipes downstream coverage/health system
metrics.

#### Usage

    CacheConnection$set_adjusted_data(value)

#### Arguments

- `value`:

  A `cd_data` tibble.

------------------------------------------------------------------------

### Method `set_performance_threshold()`

Sets the performance threshold used for DQA score calculations.

#### Usage

    CacheConnection$set_performance_threshold(value)

#### Arguments

- `value`:

  Integer scalar (e.g., 90).

------------------------------------------------------------------------

### Method `set_excluded_years()`

Sets a list of years to manually exclude from modeling.

#### Usage

    CacheConnection$set_excluded_years(value)

#### Arguments

- `value`:

  Numeric vector of years.

------------------------------------------------------------------------

### Method `set_adjustment_settings()`

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

### Method `set_k_factors()`

Sets the correction factors for under-reporting.

#### Usage

    CacheConnection$set_k_factors(value)

#### Arguments

- `value`:

  Named numeric vector of k-factors.

------------------------------------------------------------------------

### Method `set_adjusted_flag()`

Toggles the adjusted flag status.

#### Usage

    CacheConnection$set_adjusted_flag(value)

#### Arguments

- `value`:

  Logical scalar.

------------------------------------------------------------------------

### Method `set_survey_estimates()`

Manually overrides survey estimates. Clears coverage cache.

#### Usage

    CacheConnection$set_survey_estimates(value)

#### Arguments

- `value`:

  Named numeric vector.

------------------------------------------------------------------------

### Method `set_derivation_population()`

Sets the base derivation population indicator (e.g.
totlivebirths_dhis2).

#### Usage

    CacheConnection$set_derivation_population(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### Method `set_national_estimates()`

Sets list of explicit national estimates (nmr, pnmr, etc.).

#### Usage

    CacheConnection$set_national_estimates(value)

#### Arguments

- `value`:

  Named list.

------------------------------------------------------------------------

### Method `set_survey_year()`

Set integer year representing the source survey year.

#### Usage

    CacheConnection$set_survey_year(value)

#### Arguments

- `value`:

  Integer year.

------------------------------------------------------------------------

### Method `clear_survey_year()`

Clears the survey year back to unset. See clear_un_estimates() for why
this bypasses the public setter – set_survey_year()'s own validation
(is_scalar_integerish) rejects NULL outright, so there was no supported
way to un-set an already-entered survey year (e.g. the user clearing the
field by hand) until this.

#### Usage

    CacheConnection$clear_survey_year()

------------------------------------------------------------------------

### Method `set_start_survey_year()`

Set year the survey timeline begins filtering from.

#### Usage

    CacheConnection$set_start_survey_year(value)

#### Arguments

- `value`:

  Integer year.

------------------------------------------------------------------------

### Method `set_denominator()`

Set baseline denominator (e.g. penta1).

#### Usage

    CacheConnection$set_denominator(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### Method `set_maternal_denominator()`

Set maternal specific baseline denominator (e.g. anc1).

#### Usage

    CacheConnection$set_maternal_denominator(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### Method `set_selected_admin_level_1()`

Sets the selected Region for targeted dashboard filtering.

#### Usage

    CacheConnection$set_selected_admin_level_1(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### Method `set_selected_district()`

Sets the selected District for targeted dashboard filtering.

#### Usage

    CacheConnection$set_selected_district(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### Method `set_mapping_years()`

Sets mapping years for generic plots.

#### Usage

    CacheConnection$set_mapping_years(value)

#### Arguments

- `value`:

  Integer vector.

------------------------------------------------------------------------

### Method `set_chart_options()`

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

### Method `set_report_project()`

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

### Method `set_graph()`

Saves a custom chart (report kind `custom_chart`: where its data comes
from, transforms and a plot description – see
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

### Method `set_report_asset()`

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

### Method `set_report_theme()`

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

### Method `get_chart_options()`

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

### Method `reset_chart_options()`

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

### Method `set_mortality_mapping_years()`

Sets mapping years explicitly for mortality dashboards.

#### Usage

    CacheConnection$set_mortality_mapping_years(value)

#### Arguments

- `value`:

  Integer vector.

------------------------------------------------------------------------

### Method `set_utilization_mapping_years()`

Sets mapping years explicitly for utilization dashboards.

#### Usage

    CacheConnection$set_utilization_mapping_years(value)

#### Arguments

- `value`:

  Integer vector.

------------------------------------------------------------------------

### Method `set_fpet_data()`

Sets the Family Planning Estimation Tool (FPET) dataset.

#### Usage

    CacheConnection$set_fpet_data(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_un_estimates()`

Sets the official UN Demographic Estimates dataset. Clears denominators.

#### Usage

    CacheConnection$set_un_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `clear_un_estimates()`

Clears any uploaded UN Demographic Estimates override, reverting the
un_estimates active binding to the package's own built-in default for
the current country (its own %\|\|% fallback). The public setter
validates its input and rejects NULL outright, so this bypasses it via
update_field() directly, the same way invalidate_cached_data() already
resets other fields to NULL internally – there was no supported way to
undo an override before this.

#### Usage

    CacheConnection$clear_un_estimates()

------------------------------------------------------------------------

### Method `set_un_mortality_estimates()`

Sets the UN Mortality specific estimates dataset. Clears mortality
cache.

#### Usage

    CacheConnection$set_un_mortality_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `clear_un_mortality_estimates()`

Clears any uploaded UN Mortality Estimates override, reverting to the
package's built-in default for the current country. See
clear_un_estimates() for why this bypasses the public setter.

#### Usage

    CacheConnection$clear_un_mortality_estimates()

------------------------------------------------------------------------

### Method `set_wuenic_estimates()`

Sets WUENIC estimates dataset. Clears coverage cache.

#### Usage

    CacheConnection$set_wuenic_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `clear_wuenic_estimates()`

Clears any uploaded WUENIC Estimates override, reverting to the
package's built-in default for the current country. See
clear_un_estimates() for why this bypasses the public setter.

#### Usage

    CacheConnection$clear_wuenic_estimates()

------------------------------------------------------------------------

### Method `set_national_survey()`

Sets overall national survey dataset and automatically extracts its
estimates.

#### Usage

    CacheConnection$set_national_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `clear_national_survey()`

Clears an uploaded national survey override, reverting to the package's
own built-in default. See clear_un_estimates() for why this bypasses the
public setter – unlike that one, this deliberately does NOT re-run
extract_national_estimates_from_survey(): any national rate fields it
already filled in are their own, separately edited values now, the same
way clearing un_estimates never un-does anything it once fed into a
downstream calculation either.

#### Usage

    CacheConnection$clear_national_survey()

------------------------------------------------------------------------

### Method `set_regional_survey()`

Sets the disaggregated regional survey dataset.

#### Usage

    CacheConnection$set_regional_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `clear_regional_survey()`

Clears an uploaded regional survey override, reverting to the package's
own built-in default. See clear_un_estimates() for why this bypasses the
public setter.

#### Usage

    CacheConnection$clear_regional_survey()

------------------------------------------------------------------------

### Method `set_shapefile()`

Sets a user-uploaded shapefile override, replacing the package-bundled
default for the current country – see `shapefile`'s own active-binding
comment for the override-with-fallback pattern this mirrors
(`regional_survey`, above).

#### Usage

    CacheConnection$set_shapefile(value)

#### Arguments

- `value`:

  An `sf` object (as
  [`read_shapefile_folder()`](read_shapefile_folder.md) returns).

------------------------------------------------------------------------

### Method `clear_shapefile()`

Clears an uploaded shapefile override, reverting to the package's
built-in default for the current country.

#### Usage

    CacheConnection$clear_shapefile()

------------------------------------------------------------------------

### Method `set_shapefile_name_field()`

Sets which column of the uploaded shapefile holds admin-1 names – a real
uploaded shapefile won't necessarily use the bundled shapefile's own
`NAME_1` convention, so
[`check_shapefile_admin_names()`](check_shapefile_admin_names.md) needs
to be told which one to use.

#### Usage

    CacheConnection$set_shapefile_name_field(value)

#### Arguments

- `value`:

  Character. A column name present in `self$shapefile`.

------------------------------------------------------------------------

### Method `set_wiq_survey()`

Sets wealth quantile (WIQ) survey dataset.

#### Usage

    CacheConnection$set_wiq_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `clear_wiq_survey()`

Clears an uploaded WIQ survey override, reverting to the package's own
built-in default (or NULL, for a country with no bundled equity default
– see the `wiq_survey` active binding). See clear_un_estimates() for why
this bypasses the public setter.

#### Usage

    CacheConnection$clear_wiq_survey()

------------------------------------------------------------------------

### Method `set_area_survey()`

Sets area level (urban/rural) survey dataset.

#### Usage

    CacheConnection$set_area_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `clear_area_survey()`

Clears an uploaded area survey override, reverting to the package's own
built-in default. See clear_un_estimates() for why this bypasses the
public setter.

#### Usage

    CacheConnection$clear_area_survey()

------------------------------------------------------------------------

### Method `set_education_survey()`

Sets education level survey dataset.

#### Usage

    CacheConnection$set_education_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `clear_education_survey()`

Clears an uploaded education survey override, reverting to the package's
own built-in default. See clear_un_estimates() for why this bypasses the
public setter.

#### Usage

    CacheConnection$clear_education_survey()

------------------------------------------------------------------------

### Method `set_survey_mapping()`

Sets survey to countdown nomenclature mapping matrix.

#### Usage

    CacheConnection$set_survey_mapping(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `clear_survey_mapping()`

Clears the survey region mapping back to "unmapped" – unlike
un_estimates/ un_mortality_estimates/wuenic_estimates, this field has no
package-bundled default to fall back to, so clearing it just means "ask
the user to map again," not "use the built-in data."

#### Usage

    CacheConnection$clear_survey_mapping()

------------------------------------------------------------------------

### Method `set_map_mapping()`

Sets map coordinates to countdown nomenclature mapping matrix.

#### Usage

    CacheConnection$set_map_mapping(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `clear_map_mapping()`

Clears the map region mapping back to "unmapped" – see
clear_survey_mapping(), same reasoning (no package-bundled default for
this field either).

#### Usage

    CacheConnection$clear_map_mapping()

------------------------------------------------------------------------

### Method `is_default()`

Checks whether a data field is still at its built-in default – i.e. the
user has not uploaded an override
(un_estimates/un_mortality_estimates/wuenic_estimates, each with a real
package-bundled fallback) or made a mapping (survey_mapping/map_mapping,
which have no default at all, so this is equivalent there to asking
whether anything has been set). There was previously no way to ask this
at all: the active bindings for the first three never return NULL once a
country is set (they fall back to the bundled dataset instead), so
app-layer code checking `is.null(cache$un_estimates)` to mean "nothing
uploaded yet" was always structurally wrong – this checks the underlying
stored value directly, before any fallback is applied.

#### Usage

    CacheConnection$is_default(field_name)

#### Arguments

- `field_name`:

  Character. The field to check (e.g. "un_estimates", "survey_mapping").

#### Returns

Logical. TRUE if nothing has been set for this field (so it's showing
the built-in default, or is simply empty for a field with no default).

------------------------------------------------------------------------

### Method `set_sector_national_estimates()`

Set sector national estimates mapping.

#### Usage

    CacheConnection$set_sector_national_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_sector_area_estimates()`

Set sector area estimates mapping.

#### Usage

    CacheConnection$set_sector_area_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_csection_national_estimates()`

Set c-section national estimates mapping.

#### Usage

    CacheConnection$set_csection_national_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_csection_area_estimates()`

Set c-section area estimates mapping.

#### Usage

    CacheConnection$set_csection_area_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `calculate_reporting_rate()`

Wrapper to calculate average reporting rates from raw countdown data.

#### Usage

    CacheConnection$calculate_reporting_rate(admin_level, region = NULL)

#### Arguments

- `admin_level`:

  Administrative level ("national", "adminlevel_1", "district").

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### Method [`calculate_district_reporting_rate()`](calculate_district_reporting_rate.md)

Wrapper to calculate proportion of districts meeting reporting
thresholds.

#### Usage

    CacheConnection$calculate_district_reporting_rate(region = NULL)

#### Arguments

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### Method [`calculate_completeness_summary()`](calculate_completeness_summary.md)

Wrapper to calculate completeness proportions from raw countdown data.

#### Usage

    CacheConnection$calculate_completeness_summary(admin_level, region = NULL)

#### Arguments

- `admin_level`:

  Administrative level.

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### Method [`calculate_district_completeness_summary()`](calculate_district_completeness_summary.md)

Wrapper to calculate district level completeness details.

#### Usage

    CacheConnection$calculate_district_completeness_summary(region = NULL)

#### Arguments

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### Method [`list_missing_units()`](countdown-pages.md)

Locates missing/non-reporting facility units.

#### Usage

    CacheConnection$list_missing_units(indicator, region = NULL)

#### Arguments

- `indicator`:

  Target indicator name.

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### Method [`calculate_outliers_summary()`](calculate_outliers_summary.md)

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

### Method [`calculate_district_outlier_summary()`](calculate_district_outlier_summary.md)

Flags percentage of districts with acceptable outlier variances.

#### Usage

    CacheConnection$calculate_district_outlier_summary(region = NULL)

#### Arguments

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### Method `calculate_ratios_and_adequacy()`

Calculates adequacy ratios across chronological indicator sequences
(e.g. Penta1 to Penta3).

#### Usage

    CacheConnection$calculate_ratios_and_adequacy(region = NULL)

#### Arguments

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### Method [`check_population_service_collision()`](check_population_service_collision.md)

Flags district-years where a service indicator looks mixed up with
population data.

#### Usage

    CacheConnection$check_population_service_collision()

------------------------------------------------------------------------

### Method [`check_indicator_emptiness()`](check_indicator_emptiness.md)

Flags indicators that are entirely empty across the whole dataset.

#### Usage

    CacheConnection$check_indicator_emptiness()

------------------------------------------------------------------------

### Method [`check_survey_admin_names()`](check_survey_admin_names.md)

Matches survey `adminlevel_1` names against the dataset's own admin-1
names, skipping names already resolved via `survey_mapping`.

#### Usage

    CacheConnection$check_survey_admin_names()

------------------------------------------------------------------------

### Method [`check_shapefile_admin_names()`](check_shapefile_admin_names.md)

Matches the shapefile's own admin-1 name column
(`self$shapefile_name_field` – `self$shapefile`'s uploaded override if
one exists, otherwise the bundled default) against the dataset's own
admin-1 names, skipping names already resolved via `map_mapping`.

#### Usage

    CacheConnection$check_shapefile_admin_names()

------------------------------------------------------------------------

### Method [`calculate_overall_score()`](calculate_overall_score.md)

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

### Method `calculate_service_dqa_summary()`

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

### Method [`generate_admin1_service_utilization()`](generate_admin1_service_utilization.md)

Generates Service Utilization Admin 1 Data mapping format.

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

### Method [`generate_admin1_mch_curative_index()`](generate_admin1_mch_curative_index.md)

Formats Maternal Child Health vs Curative Index data for plotting.

#### Usage

    CacheConnection$generate_admin1_mch_curative_index()

------------------------------------------------------------------------

### Method `get_filtered_coverage()`

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

### Method `get_filtered_inequality()`

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

### Method `get_filtered_mapping_data()`

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

### Method `get_base_indicator_coverage()`

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

### Method `get_filtered_threshold()`

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

### Method [`calculate_derived_coverage()`](calculate_derived_coverage.md)

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

### Method `get_high_performers()`

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

### Method `get_regional_estimates()`

Substitutes national rates with regional estimates for a specific
requested sub-region.

#### Usage

    CacheConnection$get_regional_estimates(admin_level, region)

#### Arguments

- `admin_level`:

  Character. Level of aggregation.

- `region`:

  Character. Region name.

------------------------------------------------------------------------

### Method [`generate_health_system_table()`](generate_health_system_table.md)

Generates a formatted table of core health system metrics.

#### Usage

    CacheConnection$generate_health_system_table(labels = NULL)

#### Arguments

- `labels`:

  Character. Optional custom labels to use on the table headers.

------------------------------------------------------------------------

### Method [`generate_phc_scatter_data()`](generate_phc_scatter_data.md)

Prepares scatter plot data comparing Primary Health Care performance.

#### Usage

    CacheConnection$generate_phc_scatter_data(indicator)

#### Arguments

- `indicator`:

  Character. The independent variable to plot ("ratio_fac_pop" or
  "ratio_hstaff_pop").

------------------------------------------------------------------------

### Method [`generate_private_sector_data()`](generate_private_sector_data.md)

Extracts private versus public sector ownership distributions.

#### Usage

    CacheConnection$generate_private_sector_data(legend_labels = NULL)

#### Arguments

- `legend_labels`:

  Named list. Optional list to override default labels for Private, NGO,
  and Public.

------------------------------------------------------------------------

### Method `get_bayes_model()`

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

### Method `bayes_model_key()`

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

### Method `bayes_model_cached()`

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

### Method `bayes_model_inputs()`

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

### Method `keep_bayes_model()`

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

### Method `bayes_estimates()`

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

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    CacheConnection$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
