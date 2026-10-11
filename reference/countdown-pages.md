# The Countdown pages, wizard, filters and app frame

The Shiny pieces every Countdown app (cd2030.rmncah, cd2030.vaxx, and
apps on a custom indicator group) is built from, on datasuite.ui's
interface kit. This page is the guide to them: what there is and how the
pieces fit. Each function has its own help page, with its arguments and
what it returns, next to its code: pages in `R/page-<page id>.R` (a
page's part in `R/page-<page id>--<part>.R`), the Load Data wizard in
`R/wizard-*.R`, filters in `R/filter-*.R`, layout in `R/layout-*.R`,
chart and table cards in `R/chart-*.R` and the app itself in
`R/app-*.R`. The kit's own components are described in datasuite.ui's
`docs/COMPONENTS.md`.

## Details

**The app.**
`cd_app(app_name, app_version, theme, nav_sections, registry, i18n, language, selected_file, upload_ui, upload_server)`
returns the Shiny app: datasuite.ui's `app_frame()` with the
Introduction and Load Data screens, the dataset header (with its
denominator row, [`cd_denominator_header()`](cd_denominator_header.md))
and the app's pages. An app's `run_app()` sets its options, builds its
translator, lists its pages and nav tree, and calls it – see
`cd2030.rmncah::run_app()` for a complete one. The standard sidebar
sections are [`cd_nav_start()`](cd_nav_start.md),
[`cd_nav_quality()`](cd_nav_start.md),
[`cd_nav_denominators()`](cd_nav_start.md),
[`cd_nav_national()`](cd_nav_start.md) and
[`cd_nav_subnational()`](cd_nav_start.md).

**Per-app settings.** An app sets `options(cd2030.config = list(...))`
once; the pages read it with `cd_cfg(key, default)`. Keys:
`nat_cov_indicators`, `target_indicators`, `equity_indicators`,
`cov_trend_indicators`, `sub_derived_indicators`,
`survey_comp_indicators`, `adjustment_indicators`, `k_factors`,
`reporting_rate_indicators`, `reporting_rate_facet_ncol`,
`consistency_pairs`, `has_maternal` (see `R/app-config.R`). The
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
the chosen language; [`cd_app()`](cd_app.md) adds it.

**The Load Data wizard.** [`cd_upload_data_ui()`](cd_upload_data_ui.md)
/ [`cd_upload_data_server()`](cd_upload_data_ui.md) are the Load Data
screen ([`cd_app()`](cd_app.md)'s default): the page header and the
wizard, the same for every app, which describes its own part of it with
`options(cd2030.wizard = list(national_rates_groups, reference_uploads))`
(see `R/wizard-config.R`). `upload_box_*`, `wizard_steps_*` and
`wizard_landing_*` make the screen; its steps are `wizard_step_defs`
(upload, data quality, survey files, national rates, shapefile, survey
and map mappings), each with a `step_*_complete()` test, and
[`compute_step_states()`](compute_step_states.md) works out which are
done, blocked or optional. The steps' pages are `national_rates_*`,
`survey_upload_*`, `reference_estimates_*`, `shapefile_step_*`,
`map_survey_*` and `map_shapefile_*`; `cd_wizard_*` build their fields.

**Filters and building blocks.** `cd_admin_level_*`, `cd_indicator_*`,
`cd_denominator_*`, `cd_population_*`,
[`cd_years_input()`](cd_years_input.md) /
[`cd_years_sync()`](cd_years_sync.md), the scoped page
([`cd_scope()`](cd_scope.md), `cd_scoped_page_*`,
[`cd_scope_filters()`](cd_scope_filters.md)), tabbed charts
(`cd_tabbed_charts_*`), tables (`cd_table_*`), a flextable in a card
with its picture and Excel downloads (`cd_table_card_*`) and the
coverage chart card (`cd_coverage_plot_*`).

## See also

[`cd_app()`](cd_app.md) to build an app;
[`reporting_rate_ui()`](reporting_rate_ui.md) for a page;
[`cd_upload_data_ui()`](cd_upload_data_ui.md) for the Load Data wizard;
[`cd_table_ui()`](cd_table_ui.md), [`cd_scope()`](cd_scope.md) and
[`cd_admin_level_ui()`](cd_admin_level_ui.md) for building blocks.

## Examples

``` r
if (FALSE) { # \dontrun{
# an app's run_app(): its options, its translator, its pages and nav tree, then cd_app()
options(cd2030.selected_group = "rmncah", cd2030.app_group = "rmncah")
set_selected_group("rmncah")
options(cd2030.config = list(
  reporting_rate_indicators = c("opt_anc" = "anc_rr", "opt_vacc" = "vacc_rr"),
  has_maternal = TRUE
))
options(cd2030.wizard = list(national_rates_groups = list(
  cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
    cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
    cd_wizard_national_rate_fields()
  )
)))

i18n <- shiny.i18n::init_i18n(translation_json_path = cd_translations("translation.json"))
i18n$set_translation_language("en")
cd_use_i18n(i18n)

pages <- list(
  cd_page_def(
    id = "reporting_rate", ui = reporting_rate_ui, server = reporting_rate_server,
    title = "title_rr_main", section = "lbl_nav_section_quality", subtitle = "sub_rr_main",
    help = c("apps/countdown/data-quality", "reporting-rate")
  )
)
cd_use_pages(pages)

cd_app(
  app_name = "My Countdown app", app_version = "1.0.0", theme = "rmncah",
  nav_sections = list(cd_nav_start(), cd_nav_quality()),
  registry = pages, i18n = i18n, language = "en", selected_file = NA,
  upload_ui = cd_upload_data_ui, upload_server = cd_upload_data_server
)
} # }
```
