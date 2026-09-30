# The Countdown pages, wizard, filters and app frame

The Shiny pieces every Countdown app (cd2030.rmncah, cd2030.vaxx, and
apps on a custom indicator group) is built from, on datasuite.ui's
interface kit. They have no help page each; their arguments are
described where they are defined (`R/ui-*.R`), and the kit's own
components in datasuite.ui's `docs/COMPONENTS.md`.

## Details

**The app.**
`cd_app(app_name, app_version, theme, nav_sections, registry, i18n, language, selected_file, upload_ui, upload_server)`
returns the Shiny app: datasuite.ui's `app_frame()` with the
Introduction and Load Data screens, the dataset header (with its
denominator row, `cd_denominator_header()`) and the app's pages. An
app's `run_app()` sets its options, builds its translator, lists its
pages and nav tree, and calls it – see `cd2030.rmncah::run_app()` for a
complete one. The standard sidebar sections are `cd_nav_start()`,
`cd_nav_quality()`, `cd_nav_denominators()`, `cd_nav_national()` and
`cd_nav_subnational()`.

**Per-app settings.** An app sets `options(cd2030.config = list(...))`
once; the pages read it with `cd_cfg(key, default)`. Keys:
`nat_cov_indicators`, `target_indicators`, `equity_indicators`,
`cov_trend_indicators`, `sub_derived_indicators`,
`survey_comp_indicators`, `adjustment_indicators`, `k_factors`,
`reporting_rate_indicators`, `reporting_rate_facet_ncol`,
`consistency_pairs`, `has_maternal` (see `R/ui-core-config.R`). The
indicator group is pinned with
[`set_selected_group()`](set_selected_group.md) and
`options(cd2030.app_group = ...)`; the Introduction page's help comes
from `options(cd2030.help_dir = ...)`.

**Pages.** Each is a `<stem>_ui(id, i18n)` /
`<stem>_server(id, cache, i18n, ...)` pair taking the dataset
([CacheConnection](CacheConnection.md)) as a reactive:

- data quality: `data_quality`, `reporting_rate`, `data_completeness`,
  `outlier_detection`, `consistency_check`, `internal_consistency`,
  `overall_score`, `calculate_ratios`;

- adjustment: `data_adjustment` (the years and areas removed are its
  first section), `adjustment_changes`;

- denominators: `denominator_assessment`, `denominator_selection`,
  `subnational_denominator`;

- national and sub-national analysis: `national_coverage`,
  `subnational_coverage`, `coverage`, `coverage_trends`,
  `national_inequality`, `subnational_inequality`, `inequality`,
  `equity`, `national_target`, `subnational_target`, `target`,
  `survey_comparison`, `subnational_mapping`.

The Introduction page (`introduction_ui(id, i18n)`,
`introduction_server(id, selected_language)`) shows the app's help in
the chosen language; `cd_app()` adds it.

**The Load Data wizard.** `upload_box_*`, `wizard_steps_*` and
`wizard_landing_*` make the screen; its steps are `wizard_step_defs`
(upload, data quality, survey files, national rates, shapefile, survey
and map mappings), each with a `step_*_complete()` test, and
`compute_step_states()` works out which are done, blocked or optional.
The steps' pages are `national_rates_*`, `survey_upload_*`,
`reference_estimates_*`, `shapefile_step_*`, `map_survey_*` and
`map_shapefile_*`; `cd_wizard_*` build their fields.

**Filters and building blocks.** `cd_admin_level_*`, `cd_indicator_*`,
`cd_denominator_*`, `cd_population_*`, `cd_years_input()` /
`cd_years_sync()`, the scoped page ([`cd_scope()`](cd_scope.md),
`cd_scoped_page_*`, `cd_scope_filters()`), tabbed charts
(`cd_tabbed_charts_*`), tables (`cd_table_*`) and the coverage chart
card (`cd_coverage_plot_*`).
