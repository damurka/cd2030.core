#' The Countdown pages, wizard, filters and app frame
#'
#' @description
#' The Shiny pieces every Countdown app (cd2030.rmncah, cd2030.vaxx, and apps on a custom indicator group) is built
#' from, on datasuite.ui's interface kit. They have no help page each; their arguments are described where they are
#' defined (`R/ui-*.R`), and the kit's own components in datasuite.ui's `docs/COMPONENTS.md`.
#'
#' @details
#' **The app.** `cd_app(app_name, app_version, theme, nav_sections, registry, i18n, language, selected_file,
#' upload_ui, upload_server)` returns the Shiny app: datasuite.ui's `app_frame()` with the Introduction and Load Data
#' screens, the dataset header (with its denominator row, `cd_denominator_header()`) and the app's pages. An app's
#' `run_app()` sets its options, builds its translator, lists its pages and nav tree, and calls it -- see
#' `cd2030.rmncah::run_app()` for a complete one. The standard sidebar sections are `cd_nav_start()`,
#' `cd_nav_quality()`, `cd_nav_denominators()`, `cd_nav_national()` and `cd_nav_subnational()`.
#'
#' **Per-app settings.** An app sets `options(cd2030.config = list(...))` once; the pages read it with
#' `cd_cfg(key, default)`. Keys: `nat_cov_indicators`, `target_indicators`, `equity_indicators`,
#' `cov_trend_indicators`, `sub_derived_indicators`, `survey_comp_indicators`, `adjustment_indicators`, `k_factors`,
#' `reporting_rate_indicators`, `reporting_rate_facet_ncol`, `consistency_pairs`, `has_maternal` (see
#' `R/ui-core-config.R`). The indicator group is pinned with `set_selected_group()` and
#' `options(cd2030.app_group = ...)`; the Introduction page's help comes from `options(cd2030.help_dir = ...)`.
#'
#' **Pages.** Each is a `<stem>_ui(id, i18n)` / `<stem>_server(id, cache, i18n, ...)` pair taking the dataset
#' ([CacheConnection]) as a reactive:
#' * data quality: `data_quality`, `reporting_rate`, `data_completeness`, `outlier_detection`, `consistency_check`,
#'   `internal_consistency`, `overall_score`, `calculate_ratios`;
#' * adjustment: `remove_years`, `data_adjustment`, `adjustment_changes`;
#' * denominators: `denominator_assessment`, `denominator_selection`, `subnational_denominator`;
#' * national and sub-national analysis: `national_coverage`, `subnational_coverage`, `coverage`, `coverage_trends`,
#'   `national_inequality`, `subnational_inequality`, `inequality`, `equity`, `national_target`, `subnational_target`,
#'   `target`, `survey_comparison`, `subnational_mapping`.
#'
#' The Introduction page (`introduction_ui(id, i18n)`, `introduction_server(id, selected_language)`) shows the app's
#' help in the chosen language; `cd_app()` adds it.
#'
#' **The Load Data wizard.** `upload_box_*`, `wizard_steps_*` and `wizard_landing_*` make the screen; its steps are
#' `wizard_step_defs` (upload, data quality, survey files, national rates, shapefile, survey and map mappings), each with
#' a `step_*_complete()` test, and `compute_step_states()` works out which are done, blocked or optional. The steps'
#' pages are `national_rates_*`, `survey_upload_*`, `reference_estimates_*`, `shapefile_step_*`, `map_survey_*` and
#' `map_shapefile_*`; `cd_wizard_*` build their fields.
#'
#' **Filters and building blocks.** `cd_admin_level_*`, `cd_indicator_*`, `cd_denominator_*`, `cd_population_*`,
#' `cd_years_input()` / `cd_years_sync()`, the scoped page (`cd_scope()`, `cd_scoped_page_*`, `cd_scope_filters()`),
#' tabbed charts (`cd_tabbed_charts_*`), tables (`cd_table_*`) and the coverage chart card (`cd_coverage_plot_*`).
#'
#' @name countdown-pages
#' @keywords internal
#' @aliases adjustment_changes_server adjustment_changes_ui calculate_ratios_server calculate_ratios_ui cd_admin_level_choices cd_admin_level_server
#' @aliases cd_admin_level_ui cd_admin_parts cd_app cd_cfg cd_coverage_plot_server cd_coverage_plot_toolbar_ui
#' @aliases cd_coverage_plot_ui cd_default_indicator_set cd_default_indicators cd_denominator_chip_keys cd_denominator_choices cd_denominator_header
#' @aliases cd_denominator_options cd_denominator_row cd_denominator_server cd_denominator_ui cd_has_maternal cd_indicator_server
#' @aliases cd_indicator_ui cd_nav_denominators cd_nav_national cd_nav_quality cd_nav_start cd_nav_subnational
#' @aliases cd_only_denominators cd_palette_chip cd_population_server cd_population_ui cd_rate_status_cell cd_saved_copy_name
#' @aliases cd_scope_filters cd_scope_server cd_scoped_page_server cd_scoped_page_ui cd_tabbed_charts_server cd_tabbed_charts_ui
#' @aliases cd_table_server cd_table_ui cd_wizard_check_group cd_wizard_config cd_wizard_field_group cd_wizard_indicator_group
#' @aliases cd_wizard_national_rate_fields cd_wizard_rate_field cd_wizard_survey_field cd_years_input cd_years_sync compute_step_states
#' @aliases consistency_check_server consistency_check_ui consistency_pair_keys consistency_pair_label coverage_server coverage_trends_server
#' @aliases coverage_trends_ui coverage_ui data_adjustment_server data_adjustment_ui data_completeness_server data_completeness_ui
#' @aliases data_quality_server data_quality_ui den_indicators denominator_assessment_server denominator_assessment_ui denominator_selection_server
#' @aliases denominator_selection_ui equity_server equity_ui get_national_rates inequality_server inequality_ui
#' @aliases internal_consistency_server internal_consistency_ui introduction_server introduction_ui list_missing_units map_shapefile_server
#' @aliases map_shapefile_ui map_survey_server map_survey_ui mapping_modal_server mapping_modal_ui mapping_provenance_banner
#' @aliases national_coverage_server national_coverage_ui national_inequality_server national_inequality_ui national_rates_required_fields national_rates_server
#' @aliases national_rates_ui national_target_server national_target_ui nr_field nr_group outlier_detection_server
#' @aliases outlier_detection_ui overall_score_server overall_score_ui push_upload_on_remount reference_estimates_server reference_estimates_ui
#' @aliases remove_years_server remove_years_ui reporting_rate_server reporting_rate_ui restore_default_control rr_indicators
#' @aliases shapefile_step_server shapefile_step_ui step_map_mapping_complete step_national_rates_complete step_quality_complete step_shapefile_complete
#' @aliases step_shapefile_touched step_survey_files_complete step_survey_mapping_complete step_upload_complete subnational_coverage_server subnational_coverage_ui
#' @aliases subnational_denominator_server subnational_denominator_ui subnational_inequality_server subnational_inequality_ui subnational_mapping_server subnational_mapping_ui
#' @aliases subnational_target_server subnational_target_ui survey_comparison_server survey_comparison_ui survey_estimates_required_fields survey_fields
#' @aliases survey_upload_server survey_upload_ui target_server target_ui upload_box_server upload_box_ui
#' @aliases wizard_fields wizard_landing_server wizard_landing_ui wizard_step_defs wizard_steps_server wizard_steps_ui
NULL

