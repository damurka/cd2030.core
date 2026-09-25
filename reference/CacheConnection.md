# CacheConnection Class

An R6 class that handles persistent or in-memory caching of data used in
the Countdown 2030 analysis and reporting workflows. It supports
tracking of various internal data objects, reactive updates (for Shiny
apps), note-taking for report annotations, and saving/loading from
`.rds` files.

## Format

An [R6::R6Class](https://r6.r-lib.org/reference/R6Class.html) generator
object.

## Active bindings

- `language`:

  Get the UI language.

- `cache_path`:

  Get cache path.

- `countdown_data`:

  Get countdown data.

- `country`:

  Get country name.

- `country_iso`:

  Get country ISO3 code.

- `default_national_estimates`:

  Get the national rates.

- `adjusted_data`:

  Gets adjusted data.

- `data_with_excluded_years`:

  Get data with excluded years removed.

- `performance_threshold`:

  Gets performance threshold.

- `excluded_years`:

  Gets excluded years.

- `k_factors`:

  Gets k-factors.

- `adjusted_flag`:

  Gets adjusted flag.

- `survey_estimates`:

  Gets survey estimates.

- `national_estimates`:

  Gets national estimates.

- `survey_years`:

  Get survey years.

- `survey_source`:

  Gets survey source of information.

- `survey_year`:

  Gets survey year of survey estimates.

- `start_survey_year`:

  Gets start survey year.

- `denominator`:

  Gets denominator.

- `maternal_denominator`:

  Gets denominator.

- `selected_admin_level_1`:

  Gets selected region.

- `selected_district`:

  Gets selected district.

- `mortality_mapping_years`:

  Gets mapping years.

- `utilization_mapping_years`:

  Gets mapping years.

- `mapping_years`:

  Gets mapping years.

- `fpet_data`:

  Gets UN estimates.

- `un_estimates`:

  Gets UN estimates.

- `un_mortality_estimates`:

  Gets UN mortality estimates.

- `wuenic_estimates`:

  Gets WUENIC estimates.

- `national_survey`:

  Gets national survey.

- `regional_survey`:

  Gets regional survey.

- `wiq_survey`:

  Gets WIQ survey.

- `area_survey`:

  Gets area survey.

- `education_survey`:

  Gets education survey.

- `survey_mapping`:

  Gets survey mapping.

- `map_mapping`:

  Gets map mapping.

- `sector_national_estimates`:

  Gets map mapping.

- `sector_area_estimates`:

  Gets map mapping.

- `csection_national_estimates`:

  Gets map mapping.

- `csection_area_estimates`:

  Gets map mapping.

- `check_inequality_params`:

  checks if inputs for inequality calculations are available

- `check_coverage_params`:

  checks if inputs for coverage calculations are available

- `check_mortality_params`:

  checks if inputs for mortality calculations are available

- `check_sector_params`:

  checks if inputs for mortality calculations are available Update a
  field (with change tracking)

## Methods

### Public methods

- [`CacheConnection$new()`](#method-CacheConnection-new)

- [`CacheConnection$load_from_disk()`](#method-CacheConnection-load_from_disk)

- [`CacheConnection$save_to_disk()`](#method-CacheConnection-save_to_disk)

- [`CacheConnection$append_page_note()`](#method-CacheConnection-append_page_note)

- [`CacheConnection$adjust_data()`](#method-CacheConnection-adjust_data)

- [`CacheConnection$get_notes()`](#method-CacheConnection-get_notes)

- [`CacheConnection$calculate_indicator_coverage()`](#method-CacheConnection-calculate_indicator_coverage)

- [`CacheConnection$calculate_inequality()`](#method-CacheConnection-calculate_inequality)

- [`CacheConnection$calculate_coverage()`](#method-CacheConnection-calculate_coverage)

- [`CacheConnection$get_mapping_data()`](#method-CacheConnection-get_mapping_data)

- [`CacheConnection$calculate_health_system_comparison()`](#method-CacheConnection-calculate_health_system_comparison)

- [`CacheConnection$create_mortality_summary()`](#method-CacheConnection-create_mortality_summary)

- [`CacheConnection$create_mortality_ratios()`](#method-CacheConnection-create_mortality_ratios)

- [`CacheConnection$lbr_mean()`](#method-CacheConnection-lbr_mean)

- [`CacheConnection$summarise_completeness_ratio()`](#method-CacheConnection-summarise_completeness_ratio)

- [`CacheConnection$filter_mortality_summary()`](#method-CacheConnection-filter_mortality_summary)

- [`CacheConnection$compute_service_utilization()`](#method-CacheConnection-compute_service_utilization)

- [`CacheConnection$filter_service_utilization()`](#method-CacheConnection-filter_service_utilization)

- [`CacheConnection$get_denominator()`](#method-CacheConnection-get_denominator)

- [`CacheConnection$reactive()`](#method-CacheConnection-reactive)

- [`CacheConnection$set_language()`](#method-CacheConnection-set_language)

- [`CacheConnection$set_cache_path()`](#method-CacheConnection-set_cache_path)

- [`CacheConnection$set_countdown_data()`](#method-CacheConnection-set_countdown_data)

- [`CacheConnection$set_adjusted_data()`](#method-CacheConnection-set_adjusted_data)

- [`CacheConnection$set_performance_threshold()`](#method-CacheConnection-set_performance_threshold)

- [`CacheConnection$set_excluded_years()`](#method-CacheConnection-set_excluded_years)

- [`CacheConnection$set_k_factors()`](#method-CacheConnection-set_k_factors)

- [`CacheConnection$set_adjusted_flag()`](#method-CacheConnection-set_adjusted_flag)

- [`CacheConnection$set_survey_estimates()`](#method-CacheConnection-set_survey_estimates)

- [`CacheConnection$set_national_estimates()`](#method-CacheConnection-set_national_estimates)

- [`CacheConnection$set_survey_source()`](#method-CacheConnection-set_survey_source)

- [`CacheConnection$set_survey_year()`](#method-CacheConnection-set_survey_year)

- [`CacheConnection$set_start_survey_year()`](#method-CacheConnection-set_start_survey_year)

- [`CacheConnection$set_denominator()`](#method-CacheConnection-set_denominator)

- [`CacheConnection$set_maternal_denominator()`](#method-CacheConnection-set_maternal_denominator)

- [`CacheConnection$set_selected_admin_level_1()`](#method-CacheConnection-set_selected_admin_level_1)

- [`CacheConnection$set_selected_district()`](#method-CacheConnection-set_selected_district)

- [`CacheConnection$set_mapping_years()`](#method-CacheConnection-set_mapping_years)

- [`CacheConnection$set_mortality_mapping_years()`](#method-CacheConnection-set_mortality_mapping_years)

- [`CacheConnection$set_utilization_mapping_years()`](#method-CacheConnection-set_utilization_mapping_years)

- [`CacheConnection$set_fpet_data()`](#method-CacheConnection-set_fpet_data)

- [`CacheConnection$set_un_estimates()`](#method-CacheConnection-set_un_estimates)

- [`CacheConnection$set_un_mortality_estimates()`](#method-CacheConnection-set_un_mortality_estimates)

- [`CacheConnection$set_wuenic_estimates()`](#method-CacheConnection-set_wuenic_estimates)

- [`CacheConnection$set_national_survey()`](#method-CacheConnection-set_national_survey)

- [`CacheConnection$set_regional_survey()`](#method-CacheConnection-set_regional_survey)

- [`CacheConnection$set_wiq_survey()`](#method-CacheConnection-set_wiq_survey)

- [`CacheConnection$set_area_survey()`](#method-CacheConnection-set_area_survey)

- [`CacheConnection$set_education_survey()`](#method-CacheConnection-set_education_survey)

- [`CacheConnection$set_survey_mapping()`](#method-CacheConnection-set_survey_mapping)

- [`CacheConnection$set_map_mapping()`](#method-CacheConnection-set_map_mapping)

- [`CacheConnection$set_sector_national_estimates()`](#method-CacheConnection-set_sector_national_estimates)

- [`CacheConnection$set_sector_area_estimates()`](#method-CacheConnection-set_sector_area_estimates)

- [`CacheConnection$set_csection_national_estimates()`](#method-CacheConnection-set_csection_national_estimates)

- [`CacheConnection$set_csection_area_estimates()`](#method-CacheConnection-set_csection_area_estimates)

- [`CacheConnection$clone()`](#method-CacheConnection-clone)

------------------------------------------------------------------------

### Method `new()`

Initialize a CacheConnection instance.

#### Usage

    CacheConnection$new(rds_path = NULL, countdown_data = NULL)

#### Arguments

- `rds_path`:

  Path to the RDS file (can be NULL).

- `countdown_data`:

  Countdown data of class `cd_data`. Load data from disk.

------------------------------------------------------------------------

### Method `load_from_disk()`

#### Usage

    CacheConnection$load_from_disk()

#### Returns

None. Updates internal state. Save data to disk (only if changed and RDS
path is not NULL)

------------------------------------------------------------------------

### Method `save_to_disk()`

#### Usage

    CacheConnection$save_to_disk()

#### Returns

None. Updates file.

------------------------------------------------------------------------

### Method `append_page_note()`

Append a note to a page.

#### Usage

    CacheConnection$append_page_note(
      page_id,
      object_id,
      note,
      parameters = list(),
      include_in_report = FALSE,
      include_plot_table = FALSE,
      single_entry = FALSE
    )

#### Arguments

- `page_id`:

  Page ID.

- `object_id`:

  Object ID.

- `note`:

  Note text.

- `parameters`:

  Named list of parameters.

- `include_in_report`:

  Logical flag.

- `include_plot_table`:

  Logical flag.

- `single_entry`:

  Logical flag for uniqueness.

------------------------------------------------------------------------

### Method `adjust_data()`

Adjusts data.

#### Usage

    CacheConnection$adjust_data()

------------------------------------------------------------------------

### Method `get_notes()`

Retrieve notes for a given page/object.

#### Usage

    CacheConnection$get_notes(page_id, object_id = NULL, parameters = NULL)

#### Arguments

- `page_id`:

  Page ID.

- `object_id`:

  Object ID.

- `parameters`:

  Named list of parameters.

------------------------------------------------------------------------

### Method [`calculate_indicator_coverage()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_indicator_coverage.md)

Run coverage calculation using stored model parameters.

#### Usage

    CacheConnection$calculate_indicator_coverage(admin_level, region = NULL)

#### Arguments

- `admin_level`:

  Administrative level ("adminlevel_1" or "district").

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### Method [`calculate_inequality()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_inequality.md)

Run inequality calculation using stored model parameters.

#### Usage

    CacheConnection$calculate_inequality(admin_level, region = NULL)

#### Arguments

- `admin_level`:

  Administrative level ("adminlevel_1" or "district").

- `region`:

  Optional region filter.

------------------------------------------------------------------------

### Method [`calculate_coverage()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_coverage.md)

Run coverage calculation using stored model parameters.

#### Usage

    CacheConnection$calculate_coverage(admin_level)

#### Arguments

- `admin_level`:

  Administrative level ("adminlevel_1" or "district").

------------------------------------------------------------------------

### Method [`get_mapping_data()`](https://aphrcwaro.github.io/cd2030.core/reference/get_mapping_data.md)

Run coverage calculation using stored model parameters.

#### Usage

    CacheConnection$get_mapping_data(admin_level)

#### Arguments

- `admin_level`:

  Administrative level ("adminlevel_1" or "district").

------------------------------------------------------------------------

### Method [`calculate_health_system_comparison()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_health_system_comparison.md)

Run coverage calculation using stored model parameters.

#### Usage

    CacheConnection$calculate_health_system_comparison()

------------------------------------------------------------------------

### Method [`create_mortality_summary()`](https://aphrcwaro.github.io/cd2030.core/reference/create_mortality_summary.md)

Creates mortality summary

#### Usage

    CacheConnection$create_mortality_summary()

------------------------------------------------------------------------

### Method [`create_mortality_ratios()`](https://aphrcwaro.github.io/cd2030.core/reference/create_mortality_ratios.md)

creates mortality ratios from the mortality summary

#### Usage

    CacheConnection$create_mortality_ratios(.data)

#### Arguments

- `.data`:

  A `cd_mortality_summary` object

------------------------------------------------------------------------

### Method `lbr_mean()`

generates the mean institutional livebirths

#### Usage

    CacheConnection$lbr_mean()

------------------------------------------------------------------------

### Method [`summarise_completeness_ratio()`](https://aphrcwaro.github.io/cd2030.core/reference/summarise_completeness_ratio.md)

creates mortality ratios completeness summary

#### Usage

    CacheConnection$summarise_completeness_ratio(.data, indicator)

#### Arguments

- `.data`:

  A `cd_mortality_ratio` object

- `indicator`:

  The indicator to generate the summary

------------------------------------------------------------------------

### Method [`filter_mortality_summary()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_mortality_summary.md)

Return the appropriate summary based on the indicator type to plot.

#### Usage

    CacheConnection$filter_mortality_summary(.data, indicator, map_years = NULL)

#### Arguments

- `.data`:

  A `cd_mortality_summary` object.

- `indicator`:

  Character. Indicator name.

- `map_years`:

  the years to include in a map

#### Returns

Character. Either the maternal or vaccination denominator.

------------------------------------------------------------------------

### Method [`compute_service_utilization()`](https://aphrcwaro.github.io/cd2030.core/reference/compute_service_utilization.md)

Computed service utilization for various indicators.

#### Usage

    CacheConnection$compute_service_utilization(admin_level)

#### Arguments

- `admin_level`:

  The level to aggregate data at.

------------------------------------------------------------------------

### Method [`filter_service_utilization()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_service_utilization.md)

Return the appropriate summary based on the indicator type to plot.

#### Usage

    CacheConnection$filter_service_utilization(.data, indicator, map_years = NULL)

#### Arguments

- `.data`:

  A `cd_service_utilization` object.

- `indicator`:

  Character. Indicator name.

- `map_years`:

  the years to include in a map

------------------------------------------------------------------------

### Method `get_denominator()`

Return the appropriate denominator based on the indicator type.

#### Usage

    CacheConnection$get_denominator(indicator)

#### Arguments

- `indicator`:

  Character. Indicator name.

#### Returns

Character. Either the maternal or vaccination denominator.

------------------------------------------------------------------------

### Method `reactive()`

Return a reactive wrapper (for Shiny).

#### Usage

    CacheConnection$reactive()

------------------------------------------------------------------------

### Method `set_language()`

Set the language.

#### Usage

    CacheConnection$set_language(value)

#### Arguments

- `value`:

  A scalar string representing 2 digit string.

------------------------------------------------------------------------

### Method `set_cache_path()`

Set cache RDS file path.

#### Usage

    CacheConnection$set_cache_path(value)

#### Arguments

- `value`:

  New file path.

------------------------------------------------------------------------

### Method `set_countdown_data()`

Set the countdown data.

#### Usage

    CacheConnection$set_countdown_data(value)

#### Arguments

- `value`:

  A `cd_data` object.

------------------------------------------------------------------------

### Method `set_adjusted_data()`

Set adjusted data.

#### Usage

    CacheConnection$set_adjusted_data(value)

#### Arguments

- `value`:

  A `cd_data` object.

------------------------------------------------------------------------

### Method `set_performance_threshold()`

Set performance threshold.

#### Usage

    CacheConnection$set_performance_threshold(value)

#### Arguments

- `value`:

  A numeric scalar.

------------------------------------------------------------------------

### Method `set_excluded_years()`

Set years to exclude.

#### Usage

    CacheConnection$set_excluded_years(value)

#### Arguments

- `value`:

  Numeric vector.

------------------------------------------------------------------------

### Method `set_k_factors()`

Set K-factors.

#### Usage

    CacheConnection$set_k_factors(value)

#### Arguments

- `value`:

  Named numeric vector.

------------------------------------------------------------------------

### Method `set_adjusted_flag()`

Set adjusted flag.

#### Usage

    CacheConnection$set_adjusted_flag(value)

#### Arguments

- `value`:

  Logical scalar.

------------------------------------------------------------------------

### Method `set_survey_estimates()`

Set survey estimates.

#### Usage

    CacheConnection$set_survey_estimates(value)

#### Arguments

- `value`:

  Named numeric vector.

------------------------------------------------------------------------

### Method `set_national_estimates()`

Set national estimates.

#### Usage

    CacheConnection$set_national_estimates(value)

#### Arguments

- `value`:

  Named list.

------------------------------------------------------------------------

### Method `set_survey_source()`

Set year of survey estimates.

#### Usage

    CacheConnection$set_survey_source(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### Method `set_survey_year()`

Set year of survey estimates.

#### Usage

    CacheConnection$set_survey_year(value)

#### Arguments

- `value`:

  Integer year.

------------------------------------------------------------------------

### Method `set_start_survey_year()`

Set start year of surveys.

#### Usage

    CacheConnection$set_start_survey_year(value)

#### Arguments

- `value`:

  Integer year.

------------------------------------------------------------------------

### Method `set_denominator()`

Set denominator type.

#### Usage

    CacheConnection$set_denominator(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### Method `set_maternal_denominator()`

Set denominator type.

#### Usage

    CacheConnection$set_maternal_denominator(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### Method `set_selected_admin_level_1()`

Set selected region.

#### Usage

    CacheConnection$set_selected_admin_level_1(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### Method `set_selected_district()`

Set selected district.

#### Usage

    CacheConnection$set_selected_district(value)

#### Arguments

- `value`:

  Character scalar.

------------------------------------------------------------------------

### Method `set_mapping_years()`

Set mapping years.

#### Usage

    CacheConnection$set_mapping_years(value)

#### Arguments

- `value`:

  Integer vector.

------------------------------------------------------------------------

### Method `set_mortality_mapping_years()`

Set mapping years.

#### Usage

    CacheConnection$set_mortality_mapping_years(value)

#### Arguments

- `value`:

  Integer vector.

------------------------------------------------------------------------

### Method `set_utilization_mapping_years()`

Set mapping years.

#### Usage

    CacheConnection$set_utilization_mapping_years(value)

#### Arguments

- `value`:

  Integer vector.

------------------------------------------------------------------------

### Method `set_fpet_data()`

Set FPET data.

#### Usage

    CacheConnection$set_fpet_data(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_un_estimates()`

Set UN estimates.

#### Usage

    CacheConnection$set_un_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_un_mortality_estimates()`

Set UN mortality estimates

#### Usage

    CacheConnection$set_un_mortality_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_wuenic_estimates()`

Set WUENIC estimates.

#### Usage

    CacheConnection$set_wuenic_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_national_survey()`

Set national survey.

#### Usage

    CacheConnection$set_national_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_regional_survey()`

Set regional survey.

#### Usage

    CacheConnection$set_regional_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_wiq_survey()`

Set WIQ survey.

#### Usage

    CacheConnection$set_wiq_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_area_survey()`

Set area-level survey.

#### Usage

    CacheConnection$set_area_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_education_survey()`

Set education-level survey.

#### Usage

    CacheConnection$set_education_survey(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_survey_mapping()`

Set survey mapping table.

#### Usage

    CacheConnection$set_survey_mapping(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_map_mapping()`

Set map overlay mapping.

#### Usage

    CacheConnection$set_map_mapping(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_sector_national_estimates()`

Set map overlay mapping.

#### Usage

    CacheConnection$set_sector_national_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_sector_area_estimates()`

Set map overlay mapping.

#### Usage

    CacheConnection$set_sector_area_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_csection_national_estimates()`

Set map overlay mapping.

#### Usage

    CacheConnection$set_csection_national_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `set_csection_area_estimates()`

Set map overlay mapping.

#### Usage

    CacheConnection$set_csection_area_estimates(value)

#### Arguments

- `value`:

  Data frame.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    CacheConnection$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
