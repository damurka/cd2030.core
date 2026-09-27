# What each public member of CacheConnection is -- the data points of a Countdown dataset, defined once.
#
# cache_manifest() lists every member with its arguments and help text (read from the code); this file says what each
# one holds or returns, in the methodology's terms: its kind, its grain (what one row is), its unit, where the user
# sets it in the app and which pages show it, the methodology section it comes from, the values it defaults to
# (by reference to cd_methodology_defaults(), never a copied number) and what it is computed from. Columns are
# described at run time from their names (cd_describe_columns()), so they are not repeated here: a data member only
# lists its key columns.
#
# Grains and key columns were checked against a real dataset (every member evaluated on a saved Countdown .rds), and
# `set_on`/`shown_on` against the page modules that call each member. A member that could not be defined with
# confidence has status "draft" and a note saying why. Setters and clearers are defined through the member they
# change (.cd_setter_targets()), so their definitions follow the target's.
#
# Keep it complete: tests/testthat/test-cache-definitions.R fails when a public member has no definition.

# A methodology docs section (the site's own anchors: see the docs corpus, ai/corpus.json in countdown-analytics).
.cd_method_url <- function(page, anchor = NULL) {
  paste0("https://datasuite.damurka.com/en/docs/methodology/", page, "/", if (!is.null(anchor)) paste0("#", anchor))
}

# One definition; NULL fields are dropped so the manifest stays small.
.cd_def <- function(kind, what, grain = NULL, unit = NULL, key_columns = NULL, default = NULL, range = NULL,
                    set_on = NULL, shown_on = NULL, method = NULL, depends_on = NULL, status = "defined", note = NULL) {
  out <- list(kind = kind, what = what, grain = grain, unit = unit,
              columns_from = if (!is.null(grain)) "dictionary", key_columns = key_columns, default = default,
              range = range, set_on = set_on, shown_on = shown_on, method = method, depends_on = depends_on,
              status = status, note = note)
  Filter(Negate(is.null), out)
}

# Page names as the app shows them (the page registry's titles, English).
.cd_pages <- list(
  load = "Load Data",
  load_upload = "Load Data > Upload Data",
  load_quality = "Load Data > Data Quality",
  load_survey = "Load Data > Survey Files",
  load_rates = "Load Data > National Rates",
  load_shapefile = "Load Data > Shapefile",
  load_map_survey = "Load Data > Map Survey",
  load_map_shapefile = "Load Data > Map Shapefile",
  reporting_rate = "Reporting Rate",
  missingness = "Data Missingness",
  consistency = "Internal Consistency",
  outliers = "Outlier Detection",
  score = "Overall Data Quality Score",
  remove_years = "Remove Years",
  adjustment = "Data Adjustment",
  adjustment_changes = "Data Adjustment Changes",
  denom_assessment = "Denominator Assessment",
  denom_selection = "Denominator Selection",
  national_coverage = "National Coverage",
  continuum = "Continuum of Care",
  subnational_coverage = "Sub-National Coverage",
  national_inequality = "National Inequality",
  subnational_inequality = "Sub-National Inequality",
  target = "Coverage Target",
  equity = "Equity Assessment",
  mortality = "Institutional Mortality",
  mortality_mapping = "Mortality Mapping",
  mortality_completeness = "Mortality Completeness",
  util_dqa = "Service Utilization DQA",
  util_national = "National Utilization",
  util_subnational = "Sub-National Utilization",
  mch = "MCH Preventive vs Curative Index",
  hs_national = "National Health System",
  hs_subnational = "Sub-National Health System",
  phc = "PHC Performance",
  private = "Public/Private Share",
  bayesian = "Bayesian Analysis",
  reports = "Reports"
)

# The member each setter or clearer changes (set_x/clear_x change x unless said here).
.cd_setter_targets <- function() {
  c(
    set_cache_path = "cache_path", set_wizard_country = "country", set_mapping_years = "mapping_years",
    set_mortality_mapping_years = "mortality_mapping_years", set_utilization_mapping_years = "utilization_mapping_years",
    set_chart_options = "chart_options", reset_chart_options = "chart_options", set_report_project = "report_projects",
    set_graph = "graphs", set_report_asset = "report_assets", set_report_theme = "report_themes",
    clear_wizard_parts = "wizard_parts", clear_survey_year = "survey_year"
  )
}

# ---- the definitions --------------------------------------------------------------------------------------------

.cd_cache_definitions <- function() {
  P <- .cd_pages
  m <- .cd_method_url
  dq <- function(anchor = NULL) m("data-quality", anchor)
  quality_pages <- c(P$reporting_rate, P$missingness, P$consistency, P$outliers, P$score)
  dqa_levels <- "national: one row per year; adminlevel_1: per adminlevel_1 x year; district: per district x year"

  defs <- list(
    # ---- the dataset and its state ----------------------------------------------------------------------------
    language = .cd_def("state", "The language of the app's labels for this dataset (two-letter code: en, fr, pt).",
      unit = "language code", set_on = "the language switcher in the app header"),
    cache_path = .cd_def("state", "Where this dataset is saved: the path of its .rds file (the saved copy the app works on).",
      unit = "file path", set_on = paste(P$load, "(Finish writes the saved copy)")),
    countdown_data = .cd_def("data",
      "The HMIS data as loaded: for each district and month, the service counts, the reporting rates (anc_rr, idelv_rr, vacc_rr, opd_rr, ipd_rr) and the population and health-system figures, merged from the uploaded sheets. Nothing is removed or adjusted in it.",
      grain = "one row per district x year x month", unit = "counts (as reported)",
      key_columns = c("country", "adminlevel_1", "district", "year", "month"),
      set_on = paste(P$load, "(Finish merges the uploaded sheets)"), shown_on = c(quality_pages, P$remove_years),
      method = m("analysis-setup", "hmis-data")),
    data_years = .cd_def("value", "The years present in the loaded data, in order.", unit = "years",
      depends_on = "countdown_data", shown_on = c(P$score, P$remove_years, P$util_dqa, P$util_national, P$hs_national, P$mortality_mapping, P$reports)),
    subnational_regions = .cd_def("data", "The dataset's geography: every district with the first-level region (adminlevel_1) it belongs to.",
      grain = "one row per adminlevel_1 x district", key_columns = c("adminlevel_1", "district"), depends_on = "countdown_data",
      shown_on = "the region and district filters of every sub-national page"),
    country = .cd_def("value", "The country the dataset is for (its name), from the Admin sheet.", unit = "country name",
      depends_on = "countdown_data", shown_on = "the app header and the reports"),
    country_iso = .cd_def("value", "The country's ISO3 code; it selects the built-in reference data (UN estimates, WUENIC, surveys, shapefile) for the country.",
      unit = "ISO3 code", depends_on = "countdown_data"),
    wizard_parts = .cd_def("state", "The uploaded sheets while the Load Data wizard is in progress, before Finish merges them into countdown_data; NULL afterwards.",
      set_on = P$load_upload, shown_on = P$load_quality),
    quality_confirmed = .cd_def("state", "Whether this dataset finished the Load Data wizard with its quality checks passed (set at Finish). Older datasets and ones built outside the wizard have NULL or FALSE.",
      unit = "logical", set_on = paste(P$load, "(Finish)")),
    wizard_quality_results = .cd_def("state", "The quality checks as they were at Finish, on the uploaded sheets, so the Data Quality step shows the same results when revisited.",
      set_on = paste(P$load, "(Finish)"), shown_on = P$load_quality, method = m("analysis-setup", "checks-on-the-uploaded-data")),
    revision = .cd_def("state", "A number that goes up each time a change to the dataset is saved, so another reader of the same .rds (the AI's copy) knows to reload.",
      unit = "count"),
    read_only = .cd_def("state", "Whether this copy of the dataset never writes its .rds (the AI's copy is read-only).", unit = "logical"),

    # ---- data preparation ---------------------------------------------------------------------------------------
    excluded_years = .cd_def("setting", "Years removed from the analysis because their data are unreliable; every result after Remove Years leaves them out.",
      unit = "years", set_on = paste(P$remove_years, "(Select years to remove)"), shown_on = c(P$remove_years, P$adjustment),
      method = m("data-adjustment", "remove-years")),
    data_with_excluded_years = .cd_def("data", "countdown_data without the excluded years: the data the adjustment starts from.",
      grain = "one row per district x year x month", unit = "counts (as reported)",
      key_columns = c("country", "adminlevel_1", "district", "year", "month"), depends_on = c("countdown_data", "excluded_years"),
      shown_on = c(P$adjustment, P$adjustment_changes), method = m("data-adjustment", "remove-years")),
    k_factors = .cd_def("setting", "The completeness adjustment factor k for each service group (anc, idelv, vacc, and opd/ipd for RMNCAH): the assumed ratio of service volume in non-reporting facilities to that in reporting ones.",
      unit = "factor (0 to 1)", default = "adj_k_start", range = "adj_k_options",
      set_on = paste(P$adjustment, "(K-Factors)"), shown_on = c(P$adjustment, P$adjustment_changes, P$reports),
      method = m("data-adjustment", "configuring-the-k-factor")),
    adjusted_flag = .cd_def("state", "Whether the data have been adjusted (TRUE once Adjust data has run with the current years and k-factors).",
      unit = "logical", set_on = paste(P$adjustment, "(Adjust data)"), shown_on = c(P$adjustment, P$adjustment_changes)),
    adjusted_data = .cd_def("data",
      "The adjusted numerators: data_with_excluded_years with each count corrected for incomplete reporting with k (reporting rates below the cutoff replaced first) and extreme outliers replaced; carries each indicator's median, MAD and outlier flag. Every coverage, mortality, utilization and health-system result is computed from it.",
      grain = "one row per district x year x month", unit = "counts (adjusted)",
      key_columns = c("country", "adminlevel_1", "district", "year", "month"),
      default = c("adj_reporting_rate_cutoff", "adj_outlier_mad_multiplier"),
      depends_on = c("data_with_excluded_years", "k_factors"), set_on = paste(P$adjustment, "(Adjust data)"),
      shown_on = c(P$adjustment, P$adjustment_changes), method = m("data-adjustment", "numerator-adjustment-formulas-and-parameters")),

    # ---- data quality -------------------------------------------------------------------------------------------
    performance_threshold = .cd_def("setting", "The reporting completeness threshold: a district counts as reporting well in a year when its reporting rate is at least this.",
      unit = "%", default = "dq_reporting_threshold", range = "dq_reporting_threshold_picks",
      set_on = paste(P$reporting_rate, "(Performance Threshold)"), shown_on = c(P$reporting_rate, P$score, P$util_dqa, P$reports),
      method = dq("reporting-completeness")),
    reporting_rate_national = .cd_def("data", "The average reporting rate of each service group (ANC, institutional delivery, vaccination, OPD) and their mean, each year, nationally.",
      grain = "one row per year", unit = "%", key_columns = "year", depends_on = "countdown_data",
      shown_on = c(P$reporting_rate, P$score), method = dq("reporting-completeness")),
    reporting_rate_admin1 = .cd_def("data", "The average reporting rate of each service group and their mean, each year, per first-level region.",
      grain = "one row per adminlevel_1 x year", unit = "%", key_columns = c("adminlevel_1", "year"), depends_on = "countdown_data",
      shown_on = P$reporting_rate, method = dq("reporting-completeness")),
    reporting_rate_district = .cd_def("data", "The average reporting rate of each service group and their mean, each year, per district.",
      grain = "one row per district x year", unit = "%", key_columns = c("adminlevel_1", "district", "year"), depends_on = "countdown_data",
      shown_on = P$reporting_rate, method = dq("reporting-completeness")),
    district_reporting_rate = .cd_def("data", "The share of districts whose reporting rate reaches the threshold, for each service group and on average, each year.",
      grain = "one row per year", unit = "% of districts", key_columns = "year", default = "dq_reporting_threshold",
      depends_on = c("countdown_data", "performance_threshold"), shown_on = c(P$reporting_rate, P$score), method = dq("reporting-completeness")),
    completeness_national = .cd_def("data", "The share of monthly values that are not missing, for each indicator and on average, each year, nationally.",
      grain = "one row per year", unit = "% non-missing", key_columns = "year", depends_on = "countdown_data",
      shown_on = c(P$missingness, P$util_dqa), method = dq("data-missingness")),
    completeness_admin1 = .cd_def("data", "The share of monthly values that are not missing, for each indicator, each year, per first-level region.",
      grain = "one row per adminlevel_1 x year", unit = "% non-missing", key_columns = c("adminlevel_1", "year"), depends_on = "countdown_data",
      shown_on = P$missingness, method = dq("data-missingness")),
    completeness_district = .cd_def("data", "The share of monthly values that are not missing, for each indicator, each year, per district.",
      grain = "one row per district x year", unit = "% non-missing", key_columns = c("adminlevel_1", "district", "year"), depends_on = "countdown_data",
      shown_on = P$missingness, method = dq("data-missingness")),
    district_completeness = .cd_def("data", "The share of districts with no missing values, for each indicator and on average, each year.",
      grain = "one row per year", unit = "% of districts", key_columns = "year", depends_on = "countdown_data",
      shown_on = c(P$missingness, P$score), method = dq("data-missingness")),
    outliers_national = .cd_def("data", "The share of monthly values that are not extreme outliers (more than the outlier bound in MADs from the district's median), for each indicator, each year, nationally.",
      grain = "one row per year", unit = "% non-outlier", key_columns = "year", default = c("dq_outlier_mad_multiplier", "dq_outlier_baseline"),
      depends_on = "countdown_data", shown_on = c(P$outliers, P$score), method = dq("outlier-detection")),
    outliers_admin1 = .cd_def("data", "The share of monthly values that are not extreme outliers, for each indicator, each year, per first-level region.",
      grain = "one row per adminlevel_1 x year", unit = "% non-outlier", key_columns = c("adminlevel_1", "year"), default = "dq_outlier_mad_multiplier",
      depends_on = "countdown_data", shown_on = P$outliers, method = dq("outlier-detection")),
    outliers_district = .cd_def("data", "The share of monthly values that are not extreme outliers, for each indicator, each year, per district.",
      grain = "one row per district x year", unit = "% non-outlier", key_columns = c("adminlevel_1", "district", "year"), default = "dq_outlier_mad_multiplier",
      depends_on = "countdown_data", shown_on = P$outliers, method = dq("outlier-detection")),
    district_outliers_summary = .cd_def("data", "The share of districts with no extreme outlier in the year, for each indicator and on average.",
      grain = "one row per year", unit = "% of districts", key_columns = "year", default = "dq_outlier_mad_multiplier",
      depends_on = "countdown_data", shown_on = c(P$outliers, P$score), method = dq("outlier-detection")),
    list_outlier_units = .cd_def("data", "Every district-month with each indicator's value, its median and MAD, and its extreme-outlier flag (1 = more than the bound in MADs from the median).",
      grain = "one row per district x year x month", unit = "counts; flags 0/1", key_columns = c("adminlevel_1", "district", "year", "month"),
      default = "dq_outlier_mad_multiplier", depends_on = "countdown_data", shown_on = P$outliers, method = dq("outlier-detection")),
    adequacy_ratios = .cd_def("data", "The internal consistency ratios (ANC1/Penta1, Penta1/Penta3, and OPV1/OPV3 for immunization) each year, with the share of districts whose ratio is in the adequate range.",
      grain = "one row per year", unit = "ratio; % of districts", key_columns = "year", default = c("dq_ratio_adequate_range", "dq_ratio_pairs"),
      depends_on = "countdown_data", shown_on = c(P$consistency, P$score), method = dq("internal-consistency")),
    ratios_summary = .cd_def("data", "The consistency ratios each year next to the ratios expected from the survey coverage (the extra row), as the Internal Consistency page compares them.",
      grain = "one row per year, plus the expected ratios", unit = "ratio", key_columns = "year",
      default = c("dq_ratio_expected_coverage_anc1", "dq_ratio_expected_coverage_penta1", "dq_ratio_expected_coverage_penta3"),
      depends_on = c("adequacy_ratios", "survey_estimates"), shown_on = c(P$consistency, P$reports), method = dq("ratio-calculations")),
    overall_score = .cd_def("data", "The overall data quality score table: each metric of the score (1a-1c completeness, 2a-2b outliers, 3a-3d consistency) by year, and the annual score.",
      grain = "one row per score metric (columns are years)", unit = "% (ratios for 3a-3b)", key_columns = c("no", "Data Quality Metrics"),
      default = c("dq_score_components_rmncah", "dq_score_components_vaccine", "dq_reporting_threshold"),
      depends_on = c("reporting_rate_national", "district_reporting_rate", "district_completeness", "outliers_national", "district_outliers_summary", "adequacy_ratios"),
      shown_on = c(P$score, P$reports), method = dq("overall-quality-score")),

    # ---- denominators and coverage ------------------------------------------------------------------------------
    denominator_metrics = .cd_def("data", "The population figures compared on the Denominator Assessment page: DHIS2 projections (total population, births, live births, under-1) next to the UN estimates, with the UN growth rate, nationally each year.",
      grain = "one row per year (national)", unit = "counts; % growth", key_columns = c("iso3", "year"),
      depends_on = c("adjusted_data", "un_estimates"), shown_on = c(P$denom_assessment, P$reports),
      method = m("denominators", "population-trend-comparison")),
    derivation_population = .cd_def("setting", "The population the growth-projected denominators (ANC1/Penta1 population growth) are built from: one of totbirths_dhis2, totlivebirths_dhis2, totunder1_dhis2, totpop_dhis2, un_population, un_births, un_under1.",
      unit = "column name", set_on = paste(P$denom_assessment, "(Select Best Population)"), shown_on = c(P$denom_assessment, P$reports),
      method = m("denominators", "computing-the-derived-denominators"), note = "Starts as totlivebirths_dhis2."),
    denominator = .cd_def("setting", "The denominator chosen for the immunization and child indicators (one of the denominator ids: dhis2, anc1, penta1, anc1derived, penta1derived, un).",
      unit = "denominator id", set_on = paste(P$denom_selection, "(Select Best Vaccination Denominator)"),
      shown_on = c(P$denom_selection, P$national_coverage, P$continuum, P$national_inequality, P$target, P$reports),
      method = m("denominators", "selecting-the-best-denominator-option"), note = "Starts as penta1."),
    maternal_denominator = .cd_def("setting", "The denominator chosen for the maternal and newborn indicators (a denominator id, as for denominator).",
      unit = "denominator id", set_on = paste(P$denom_selection, "(Select Best Maternal Denominator)"),
      shown_on = c(P$denom_selection, P$national_coverage, P$continuum, P$phc, P$reports),
      method = m("denominators", "selecting-the-best-denominator-option"), note = "Starts as anc1; RMNCAH only."),
    survey_estimates = .cd_def("setting", "The national survey coverage of the indicators the denominators and consistency checks need (anc1, penta1, penta3, bcg, measles1, instlivebirths, and anc4, csection, low_bweight or opv1, opv3 by indicator group), from the most recent survey.",
      unit = "% (low_bweight: proportion)", range = "0 to 100 (National Rates fields)",
      set_on = paste(P$load_rates, "(pre-filled from the national survey)"), shown_on = c(P$load_rates, P$consistency),
      method = m("analysis-setup", "survey-params")),
    national_estimates = .cd_def("setting", "The national rates used to compute the denominators: neonatal (nmr) and post-neonatal (pnmr) mortality, stillbirth rate (sbr), twin rate, pregnancy loss, and the ANC1 and Penta1 survey coverage (from survey_estimates).",
      unit = "proportion", range = "0 to 0.05 for the rates (National Rates fields)", default = "den_app_twin_preg_loss",
      set_on = P$load_rates, shown_on = P$load_rates, depends_on = "survey_estimates",
      method = m("analysis-setup", "survey-params"), note = "nmr, pnmr and sbr have no starting value in the app; twin and pregnancy loss start from den_app_twin_preg_loss."),
    admin1_estimates = .cd_def("data", "The same rates per first-level region, from the regional survey where it has them, else the national rates.",
      grain = "one row per adminlevel_1", unit = "proportion", key_columns = "adminlevel_1",
      depends_on = c("regional_survey", "national_estimates"), method = m("analysis-setup", "survey-params")),
    survey_year = .cd_def("setting", "The year of the survey the ANC1/Penta1 coverage comes from: the base year the derived denominators start from.",
      unit = "year", default = "den_survey_year", set_on = paste(P$load_rates, "(Recent Survey Year)"),
      shown_on = c(P$load_rates, P$denom_selection, P$reports), method = m("denominators", "computing-the-derived-denominators")),
    start_survey_year = .cd_def("setting", "The first survey year used: survey data before it are left out of the comparisons.",
      unit = "year", set_on = paste(P$load_rates, "(Survey Data Start Year)"), shown_on = P$load_rates),
    survey_years = .cd_def("value", "The years that have national survey data.", unit = "years", depends_on = "national_survey",
      shown_on = P$load_rates),
    indicator_coverage_national = .cd_def("data", "Coverage of every indicator by every denominator, nationally each year: the adjusted numerators, the population figures, the denominators (tot<population>_<denominator>) and the coverage (cov_<indicator>_<denominator>).",
      grain = "one row per year (national)", unit = "counts; coverage %", key_columns = c("iso3", "year"),
      default = c("den_nmr", "den_pnmr", "den_sbr", "den_twin", "den_preg_loss", "den_anc1survey", "den_dpt1survey"),
      depends_on = c("adjusted_data", "derivation_population", "national_estimates", "un_estimates", "survey_year"),
      shown_on = c(P$denom_selection, P$national_coverage), method = m("denominators", "denominator-options")),
    indicator_coverage_admin1 = .cd_def("data", "Coverage of every indicator by every denominator, per first-level region each year (no UN denominator below national).",
      grain = "one row per adminlevel_1 x year", unit = "counts; coverage %", key_columns = c("adminlevel_1", "year"),
      depends_on = c("adjusted_data", "derivation_population", "national_estimates", "regional_survey", "survey_mapping"),
      shown_on = c(P$denom_selection, P$subnational_coverage), method = m("subnational", "subnational-coverage")),
    indicator_coverage_district = .cd_def("data", "Coverage of every indicator by every denominator, per district each year.",
      grain = "one row per district x year", unit = "counts; coverage %", key_columns = c("adminlevel_1", "district", "year"),
      depends_on = c("adjusted_data", "derivation_population", "national_estimates", "regional_survey", "survey_mapping"),
      shown_on = c(P$subnational_coverage, P$reports), method = m("subnational", "subnational-coverage")),

    # ---- reference data (built in, or uploaded to replace the built-in) -----------------------------------------
    un_estimates = .cd_def("reference", "The UN population estimates for the country (population, births, under-1 and under-5 population, women 15-49, growth, crude birth and death rates, total fertility), each year: built in, or uploaded to replace them.",
      grain = "one row per year", unit = "counts; rates", key_columns = c("iso3", "year"),
      set_on = paste(P$load_upload, "(Additional reference data)"), shown_on = P$denom_assessment,
      method = m("analysis-setup", "embedded-datasets")),
    un_mortality_estimates = .cd_def("reference", "The UN estimates of maternal mortality (MMR), neonatal mortality and stillbirth rates with their bounds, each year: built in, or uploaded.",
      grain = "one row per year", unit = "per 100,000 live births (MMR); per 1,000 (NMR, SBR)", key_columns = c("iso3", "year"),
      set_on = paste(P$load_upload, "(Additional reference data)"), shown_on = c(P$mortality, P$mortality_completeness),
      method = m("analysis-setup", "embedded-datasets")),
    wuenic_estimates = .cd_def("reference", "The WHO/UNICEF estimates of national immunization coverage (WUENIC) for each vaccine, each year: built in, or uploaded.",
      grain = "one row per year", unit = "%", key_columns = c("iso3", "year"),
      set_on = paste(P$load_upload, "(Additional reference data)"), shown_on = P$national_coverage,
      method = m("analysis-setup", "embedded-datasets")),
    national_survey = .cd_def("reference", "The national household survey estimates (coverage r_<indicator> with standard error se_, bounds ll_/ul_) for each survey year: built in, or uploaded.",
      grain = "one row per survey year", unit = "%", key_columns = c("iso3", "year", "source"),
      set_on = P$load_survey, shown_on = c(P$load_rates, P$national_coverage, P$denom_selection),
      method = m("analysis-setup", "survey-files-and-shapefile")),
    regional_survey = .cd_def("reference", "The survey estimates per first-level region (same columns as national_survey): built in, or uploaded.",
      grain = "one row per survey region x survey year", unit = "%", key_columns = c("iso3", "adminlevel_1", "year", "source"),
      set_on = P$load_survey, shown_on = c(P$load_map_survey, P$denom_selection, P$subnational_coverage),
      method = m("analysis-setup", "survey-files-and-shapefile")),
    wiq_survey = .cd_def("reference", "The survey estimates by household wealth quintile (Q1 poorest to Q5 richest): built in, or uploaded.",
      grain = "one row per quintile x survey year", unit = "%", key_columns = c("iso3", "year", "level", "source"),
      set_on = P$load_survey, shown_on = c(P$equity, P$reports), method = m("equity", "rationale-and-approach")),
    area_survey = .cd_def("reference", "The survey estimates by area of residence (urban, rural): built in, or uploaded.",
      grain = "one row per area x survey year", unit = "%", key_columns = c("iso3", "year", "level", "source"),
      set_on = P$load_survey, shown_on = c(P$equity, P$reports), method = m("equity", "rationale-and-approach")),
    education_survey = .cd_def("reference", "The survey estimates by the mother's education (none, primary, secondary+): built in, or uploaded.",
      grain = "one row per education level x survey year", unit = "%", key_columns = c("iso3", "year", "level", "source"),
      set_on = P$load_survey, shown_on = c(P$equity, P$reports), method = m("equity", "rationale-and-approach")),
    shapefile = .cd_def("reference", "The map of the country's first-level regions: the built-in one, or one uploaded to replace it.",
      grain = "one row per map region", unit = "geometry", key_columns = "the name field (shapefile_name_field)",
      set_on = P$load_shapefile, shown_on = c(P$load_map_shapefile, P$national_inequality, P$mortality_mapping, P$util_national),
      method = m("analysis-setup", "survey-files-and-shapefile")),
    shapefile_name_field = .cd_def("setting", "Which column of the shapefile holds the region names (NAME_1 for the built-in shapefile).",
      unit = "column name", set_on = P$load_shapefile, shown_on = c(P$load_shapefile, P$load_map_shapefile)),
    survey_mapping = .cd_def("mapping", "How the survey's region names match the dataset's first-level regions (adminlevel_1); NULL until the names are matched.",
      grain = "one row per survey region", key_columns = "adminlevel_1", set_on = P$load_map_survey,
      shown_on = P$load_map_survey, method = m("analysis-setup", "survey-files-and-shapefile")),
    map_mapping = .cd_def("mapping", "How the shapefile's region names match the dataset's first-level regions; NULL until the names are matched.",
      grain = "one row per map region", key_columns = "the shapefile's name field and adminlevel_1", set_on = P$load_map_shapefile,
      shown_on = P$load_map_shapefile, method = m("analysis-setup", "survey-files-and-shapefile")),
    fpet_data = .cd_def("reference", "The Family Planning Estimation Tool (FPET) projections for the country: each indicator's median and uncertainty bounds, each year.",
      grain = "one row per indicator x year", unit = "%", key_columns = c("iso3", "year", "indicator"),
      shown_on = c(P$national_coverage, P$reports), method = m("coverage", "family-planning-projections")),
    national_private_share = .cd_def("reference", "The survey shares of care received in the private and public sectors, nationally (built in).",
      grain = "one row per indicator", unit = "%", key_columns = c("iso", "year", "source", "indic"),
      shown_on = c(P$private, P$reports), method = m("health-system", "input-indicators-and-analytical-benchmarks")),
    area_private_share = .cd_def("reference", "The survey shares of care received in the private and public sectors, by area of residence (built in).",
      grain = "one row per indicator x area", unit = "%", key_columns = c("iso", "year", "source", "indic", "area"),
      shown_on = c(P$private, P$reports), method = m("health-system", "input-indicators-and-analytical-benchmarks")),
    sector_national_estimates = .cd_def("reference", "Public/private sector estimates, nationally, when given to the dataset.",
      status = "draft", note = "Not set from the app (no page calls its setter) and empty in the datasets checked; its columns are not known."),
    sector_area_estimates = .cd_def("reference", "Public/private sector estimates by area, when given to the dataset.",
      status = "draft", note = "Not set from the app and empty in the datasets checked."),
    csection_national_estimates = .cd_def("reference", "C-section estimates, nationally, when given to the dataset.",
      status = "draft", note = "Not set from the app and empty in the datasets checked."),
    csection_area_estimates = .cd_def("reference", "C-section estimates by area, when given to the dataset.",
      status = "draft", note = "Not set from the app and empty in the datasets checked."),

    # ---- readiness checks ---------------------------------------------------------------------------------------
    check_inequality_params = .cd_def("check", "Whether everything coverage by denominator and inequality need is present: adjusted data, a survey year, UN estimates and the national rates.",
      unit = "logical", depends_on = c("adjusted_data", "survey_year", "un_estimates", "national_estimates")),
    check_coverage_params = .cd_def("check", "Whether everything the survey comparisons need is present: the inequality inputs plus WUENIC and the national and regional surveys.",
      unit = "logical", depends_on = c("check_inequality_params", "wuenic_estimates", "national_survey", "regional_survey")),
    check_mortality_params = .cd_def("check", "Whether the mortality analysis can run: adjusted data and the UN mortality estimates are present.",
      unit = "logical", depends_on = c("adjusted_data", "un_mortality_estimates")),
    check_sector_params = .cd_def("check", "Whether the four public/private and c-section estimate tables are present.",
      unit = "logical", depends_on = c("sector_national_estimates", "sector_area_estimates", "csection_national_estimates", "csection_area_estimates")),

    # ---- equity, mortality, utilization, health system ------------------------------------------------------------
    inequality_admin1 = .cd_def("data", "Coverage by first-level region with the inequality measures against the national value for every indicator and denominator: difference from national, population share, MADM and MRDM (mean absolute and mean relative difference from the national mean), each year.",
      grain = "one row per adminlevel_1 x year", unit = "coverage %; differences in percentage points", key_columns = c("iso3", "adminlevel_1", "year"),
      depends_on = c("indicator_coverage_admin1", "indicator_coverage_national"), shown_on = c(P$national_inequality, P$reports),
      method = m("subnational", "inequality")),
    inequality_district = .cd_def("data", "The same inequality measures per district, against the national value.",
      grain = "one row per district x year", unit = "coverage %; differences in percentage points", key_columns = c("iso3", "adminlevel_1", "district", "year"),
      depends_on = c("indicator_coverage_district", "indicator_coverage_national"), shown_on = c(P$subnational_inequality, P$reports),
      method = m("subnational", "inequality")),
    mortality_summary = .cd_def("data", "Institutional mortality per first-level region and year: live births, stillbirths (total, fresh), maternal and neonatal deaths, and the institutional rates (iMMR, iSBR, neonatal) and ratios (stillbirths and neonatal deaths per maternal death).",
      grain = "one row per adminlevel_1 x year (and national)", unit = "counts; per 100,000 live births (iMMR); per 1,000 (iSBR)", key_columns = c("adminlevel_1", "year"),
      default = c("mort_mmr_low", "mort_sbr_low"), depends_on = "adjusted_data",
      shown_on = c(P$mortality, P$mortality_mapping, P$reports), method = m("mortality", "immr-and-isbr-review")),
    mortality_ratios = .cd_def("data", "The latest national institutional MMR and SBR next to the UN estimates (best, lower and upper), for the completeness comparison.",
      grain = "one row per indicator (latest year)", unit = "per 100,000 live births (MMR); per 1,000 (SBR)", key_columns = c("iso3", "year", "indicator"),
      default = "mort_completeness_ratios", depends_on = c("mortality_summary", "un_mortality_estimates"),
      shown_on = P$mortality_completeness, method = m("mortality", "computing-reporting-completeness")),
    service_utilization_national = .cd_def("data", "Outpatient and inpatient service use nationally each year: visits and admissions (total and under-5), per population, under-5 shares, case fatality and the reporting rates.",
      grain = "one row per year", unit = "counts; per capita; %", key_columns = "year", depends_on = "adjusted_data",
      shown_on = c(P$util_dqa, P$util_national, P$reports), method = m("service-utilisation", "outpatient-service-utilization")),
    service_utilization_admin1 = .cd_def("data", "The same service-use measures per first-level region each year.",
      grain = "one row per adminlevel_1 x year", unit = "counts; per capita; %", key_columns = c("adminlevel_1", "year"), depends_on = "adjusted_data",
      shown_on = c(P$util_subnational, P$mch, P$reports), method = m("service-utilisation", "inpatient-service-utilization")),
    health_system_metrics_national = .cd_def("data", "The health-system inputs nationally: facilities, hospitals, beds and health workforce, their densities per population, and service use, for the latest year.",
      grain = "one row per year", unit = "counts; per 10,000 or 100,000 population", key_columns = "year", depends_on = "adjusted_data",
      shown_on = c(P$hs_national, P$hs_subnational, P$reports), method = m("health-system", "input-indicators-and-analytical-benchmarks")),
    health_system_metrics_admin1 = .cd_def("data", "The same health-system inputs and densities per first-level region.",
      grain = "one row per adminlevel_1 x year", unit = "counts; per 10,000 or 100,000 population", key_columns = c("adminlevel_1", "year"), depends_on = "adjusted_data",
      shown_on = c(P$hs_subnational, P$phc, P$private, P$reports), method = m("health-system", "input-indicators-and-analytical-benchmarks")),
    health_system_comparison = .cd_def("data", "Health-system inputs next to service coverage (dis_cov_<indicator>_<denominator>) per district and region, for the latest year: the data behind the PHC performance comparison.",
      grain = "one row per district (latest year)", unit = "coverage %; densities", key_columns = c("adminlevel_1", "district", "year"),
      depends_on = c("adjusted_data", "indicator_coverage_admin1", "indicator_coverage_district"), shown_on = P$phc,
      method = m("health-system", "health-systems-outputs-by-inputs-at-the-sub-national-level")),

    # ---- settings of the page views ----------------------------------------------------------------------------
    selected_admin_level_1 = .cd_def("state", "A first-level region kept as a view selection.", unit = "region name",
      status = "draft", note = "No page sets it in the current apps; kept for older datasets."),
    selected_district = .cd_def("state", "A district kept as a view selection.", unit = "district name",
      status = "draft", note = "No page sets it in the current apps; kept for older datasets."),
    mapping_years = .cd_def("setting", "The years the coverage maps show.", unit = "years",
      set_on = paste(P$national_inequality, "(map years)"), shown_on = c(P$national_inequality, P$reports)),
    mortality_mapping_years = .cd_def("setting", "The years the mortality maps show.", unit = "years",
      set_on = P$mortality_mapping, shown_on = P$mortality_mapping),
    utilization_mapping_years = .cd_def("setting", "The years the service utilization maps show.", unit = "years",
      set_on = P$util_national, shown_on = P$util_national),

    # ---- what the user builds -----------------------------------------------------------------------------------
    chart_options = .cd_def("store", "What the user changed about how charts look: the dataset's default options and each chart's own, by chart id.",
      set_on = "the chart options menu of every chart", shown_on = "every chart, and the reports"),
    report_projects = .cd_def("store", "The reports built in the report builder (or saved by the AI), by id: name, language, design, cover and blocks.",
      set_on = P$reports, shown_on = P$reports, method = m("dissemination", "preparing-reports-for-stakeholders")),
    report_assets = .cd_def("store", "The pictures the reports use, by id (a block's src is asset:<id>).", set_on = P$reports, shown_on = P$reports),
    report_themes = .cd_def("store", "The report themes made from Office files, by id.", set_on = P$reports, shown_on = P$reports),
    graphs = .cd_def("store", "The saved custom charts, by id: where each draws its data from, its transforms and its plot (a description, never code); they redraw with the data and can go in any report.",
      set_on = "the AI (countdown_graph with save) or the report builder", shown_on = P$reports)
  )

  # ---- methods: calculations the pages and reports call -----------------------------------------------------------
  methods <- list(
    load_from_disk = .cd_def("action", "Reads the dataset's saved .rds into this object."),
    save_to_disk = .cd_def("action", "Writes the dataset to its .rds when something changed (never for a read-only copy)."),
    adjust_data = .cd_def("action", "Recomputes adjusted_data from data_with_excluded_years and the k-factors, and marks the data as adjusted.",
      depends_on = c("data_with_excluded_years", "k_factors"), set_on = paste(P$adjustment, "(Adjust data)"),
      method = m("data-adjustment", "numerator-adjustment-formulas-and-parameters")),
    reactive = .cd_def("action", "The dataset as a Shiny reactive, so pages redraw when it changes."),
    calculate_indicator_coverage = .cd_def("method", "Coverage of every indicator by every denominator at a level (national, adminlevel_1 or district), optionally for one region: what indicator_coverage_* hold, computed on demand.",
      grain = "national: per year; adminlevel_1: per adminlevel_1 x year; district: per district x year", unit = "counts; coverage %",
      key_columns = c("adminlevel_1", "district", "year"), depends_on = c("adjusted_data", "national_estimates", "derivation_population", "survey_year"),
      method = m("denominators", "denominator-options")),
    calculate_inequality = .cd_def("method", "The inequality measures for a level against the level above: what inequality_admin1 and inequality_district hold, computed on demand (optionally for one region).",
      grain = "per region or district x year", unit = "coverage %; percentage points", key_columns = c("adminlevel_1", "district", "year"),
      depends_on = c("indicator_coverage_national", "indicator_coverage_admin1"), method = m("subnational", "inequality")),
    calculate_coverage = .cd_def("method", "Coverage of every indicator by every denominator next to the survey estimates and WUENIC, at a level: the table the coverage charts compare.",
      grain = "one row per year and source (national); per region or district x year", unit = "coverage %",
      key_columns = c("country", "iso", "adminlevel_1", "district", "year"), depends_on = c("indicator_coverage_national", "national_survey", "regional_survey", "wuenic_estimates"),
      shown_on = c(P$national_coverage, P$reports), method = m("coverage", "national-coverage-trends")),
    generate_coverage_data = .cd_def("method", "The continuum of care: coverage of the maternal (type maternal) or child (type child) indicators along the continuum, with the chosen denominator, in long form.",
      grain = "one row per year x indicator x source", unit = "coverage %", key_columns = c("year", "indicator", "source"),
      depends_on = c("calculate_coverage", "denominator", "maternal_denominator"), shown_on = c(P$continuum, P$reports),
      method = m("coverage", "maternal-and-newborn-continuum-of-care")),
    get_mapping_data = .cd_def("method", "Regional coverage joined to the map regions (through map_mapping) for the coverage maps.",
      grain = "one row per adminlevel_1 x year", unit = "coverage %; geometry", key_columns = c("adminlevel_1", "year"),
      depends_on = c("indicator_coverage_admin1", "map_mapping", "shapefile"), shown_on = P$national_inequality),
    lbr_mean = .cd_def("value", "The mean national coverage of institutional live births over the years, with the maternal denominator: the completeness assumption of the mortality comparison.",
      unit = "%", depends_on = c("indicator_coverage_national", "maternal_denominator"), shown_on = P$mortality_completeness,
      method = m("mortality", "computing-reporting-completeness")),
    summarise_completeness_ratio = .cd_def("method", "The institutional MMR (or SBR) as a share of the UN estimate for each assumed completeness ratio: how complete death reporting would have to be to match the UN level.",
      grain = "one row per completeness ratio", unit = "per 100,000 live births", key_columns = "ciratio",
      default = "mort_completeness_ratios", depends_on = c("mortality_ratios", "lbr_mean"), shown_on = c(P$mortality_completeness, P$reports),
      method = m("mortality", "computing-reporting-completeness")),
    filter_mortality_summary = .cd_def("method", "One mortality indicator by region for the chosen years, joined to the map, for the mortality maps.",
      grain = "one row per adminlevel_1 x year", unit = "per 100,000 live births (iMMR); per 1,000 (iSBR)", key_columns = c("adminlevel_1", "year"),
      depends_on = c("mortality_summary", "mortality_mapping_years", "map_mapping"), shown_on = c(P$mortality_mapping, P$reports),
      method = m("mortality", "immr-and-isbr-review")),
    compute_service_utilization = .cd_def("method", "The service-use measures at a level (national or adminlevel_1): what service_utilization_* hold, computed on demand.",
      grain = "per year, or per adminlevel_1 x year", unit = "counts; per capita; %", key_columns = c("adminlevel_1", "year"),
      depends_on = "adjusted_data", method = m("service-utilisation", "description-of-analytical-steps")),
    filter_service_utilization = .cd_def("method", "The service-use measures for one indicator at a level, optionally for one region.",
      grain = "per year (or per region x year)", unit = "counts; per capita; %", key_columns = c("adminlevel_1", "year"),
      depends_on = c("service_utilization_national", "service_utilization_admin1"), shown_on = c(P$util_national, P$reports),
      method = m("service-utilisation", "outpatient-service-utilization")),
    prepare_mapping_service_utlization = .cd_def("method", "OPD or IPD use per region for the chosen years, joined to the map.",
      grain = "one row per adminlevel_1 x year", unit = "per capita; geometry", key_columns = c("adminlevel_1", "year"),
      depends_on = c("service_utilization_admin1", "utilization_mapping_years", "map_mapping"), shown_on = c(P$util_national, P$reports)),
    get_denominator = .cd_def("value", "The chosen denominator for an indicator: maternal_denominator for maternal and newborn indicators, denominator for the others.",
      unit = "denominator id", depends_on = c("denominator", "maternal_denominator"),
      method = m("denominators", "selecting-the-best-denominator-option")),
    decompose_change = .cd_def("method", "Which districts (or regions) drive a change in an indicator's coverage between two years: each unit's counts and denominators in both years, its coverage change and its contribution in percentage points, split into service delivery and denominator, with a reporting-rate flag.",
      grain = "one row per district (or adminlevel_1)", unit = "counts; coverage %; percentage points", key_columns = c("adminlevel_1", "district"),
      depends_on = c("indicator_coverage_district", "indicator_coverage_admin1", "reporting_rate_district"),
      method = m("subnational", "subnational-coverage")),
    get_chart_options = .cd_def("value", "The chart options that apply to one chart: the dataset's default options with the chart's own on top.",
      depends_on = "chart_options"),
    is_default = .cd_def("value", "Whether a field is still at its built-in value (nothing uploaded or set for it).", unit = "logical"),
    calculate_reporting_rate = .cd_def("method", "The average reporting rate of each service group at a level, optionally for one region: what reporting_rate_* hold, on demand.",
      grain = dqa_levels, unit = "%", key_columns = c("adminlevel_1", "district", "year"), depends_on = "countdown_data",
      shown_on = P$reporting_rate, method = dq("reporting-completeness")),
    calculate_district_reporting_rate = .cd_def("method", "The share of districts reaching the reporting threshold, optionally within one region: what district_reporting_rate holds, on demand.",
      grain = "one row per year", unit = "% of districts", key_columns = "year", default = "dq_reporting_threshold",
      depends_on = c("countdown_data", "performance_threshold"), shown_on = c(P$reporting_rate, P$reports), method = dq("reporting-completeness")),
    calculate_completeness_summary = .cd_def("method", "The share of non-missing monthly values at a level: what completeness_* hold, on demand.",
      grain = dqa_levels, unit = "% non-missing", key_columns = c("adminlevel_1", "district", "year"), depends_on = "countdown_data",
      shown_on = P$missingness, method = dq("data-missingness")),
    calculate_district_completeness_summary = .cd_def("method", "The share of districts with no missing values, optionally within one region: what district_completeness holds, on demand.",
      grain = "one row per year", unit = "% of districts", key_columns = "year", depends_on = "countdown_data",
      shown_on = P$missingness, method = dq("data-missingness")),
    list_missing_units = .cd_def("method", "The district-months where an indicator is missing, optionally within one region.",
      grain = "one row per district x year x month", key_columns = c("adminlevel_1", "district", "year", "month"),
      depends_on = "countdown_data", shown_on = P$missingness, method = dq("data-missingness")),
    calculate_outliers_summary = .cd_def("method", "The share of monthly values that are not extreme outliers at a level: what outliers_* hold, on demand.",
      grain = dqa_levels, unit = "% non-outlier", key_columns = c("adminlevel_1", "district", "year"), default = "dq_outlier_mad_multiplier",
      depends_on = "countdown_data", shown_on = P$outliers, method = dq("outlier-detection")),
    calculate_district_outlier_summary = .cd_def("method", "The share of districts with no extreme outlier, optionally within one region: what district_outliers_summary holds, on demand.",
      grain = "one row per year", unit = "% of districts", key_columns = "year", default = "dq_outlier_mad_multiplier",
      depends_on = "countdown_data", shown_on = P$outliers, method = dq("outlier-detection")),
    calculate_ratios_and_adequacy = .cd_def("method", "The consistency ratios with the share of districts in the adequate range, optionally within one region: what adequacy_ratios holds, on demand.",
      grain = "one row per year", unit = "ratio; % of districts", key_columns = "year", default = "dq_ratio_adequate_range",
      depends_on = "countdown_data", shown_on = P$consistency, method = dq("internal-consistency")),
    check_population_service_collision = .cd_def("method", "District-years where a service count looks like population data (a sign the sheets were mixed up).",
      grain = "one row per district x year flagged", key_columns = c("district", "year"), depends_on = "countdown_data",
      shown_on = P$load_quality, method = m("analysis-setup", "checks-on-the-uploaded-data")),
    check_indicator_emptiness = .cd_def("method", "The indicators with no value anywhere in the dataset.", unit = "indicator names",
      depends_on = "countdown_data", shown_on = P$load_quality, method = m("analysis-setup", "checks-on-the-uploaded-data")),
    check_survey_admin_names = .cd_def("method", "The survey region names that do not match a region of the dataset (and are not matched yet), with the closest dataset name and its distance.",
      grain = "one row per unmatched name", key_columns = "name", depends_on = c("regional_survey", "survey_mapping", "subnational_regions"),
      shown_on = c(P$load_survey, P$load_map_survey), method = m("analysis-setup", "survey-files-and-shapefile")),
    check_shapefile_admin_names = .cd_def("method", "The shapefile region names that do not match a region of the dataset (and are not matched yet), with the closest dataset name and its distance.",
      grain = "one row per unmatched name", key_columns = "name", depends_on = c("shapefile", "shapefile_name_field", "map_mapping", "subnational_regions"),
      shown_on = c(P$load_shapefile, P$load_map_shapefile), method = m("analysis-setup", "survey-files-and-shapefile")),
    calculate_overall_score = .cd_def("method", "The overall data quality score table, nationally or for one region: what overall_score holds, on demand.",
      grain = "one row per score metric (columns are years)", unit = "%", key_columns = c("no", "Data Quality Metrics"),
      default = c("dq_score_components_rmncah", "dq_score_components_vaccine"), depends_on = c("reporting_rate_national", "district_reporting_rate", "district_completeness", "outliers_national", "district_outliers_summary", "adequacy_ratios"),
      shown_on = c(P$score, P$reports), method = dq("overall-quality-score")),
    calculate_service_dqa_summary = .cd_def("method", "The data quality table for the service-use data (OPD, IPD): reporting, completeness and outliers by year, nationally or for one region.",
      grain = "one row per quality metric (columns are years)", unit = "%", key_columns = c("no", "indicator_label"),
      depends_on = c("reporting_rate_national", "completeness_national", "outliers_national", "service_utilization_national"),
      shown_on = c(P$util_dqa, P$reports), method = m("service-utilisation", "description-of-analytical-steps")),
    generate_admin1_service_utilization = .cd_def("method", "Under-5 OPD (or IPD) use per capita per region, for the regional utilization chart.",
      grain = "one row per adminlevel_1 x year", unit = "per capita", key_columns = c("adminlevel_1", "year"),
      depends_on = "service_utilization_admin1", shown_on = P$util_national, method = m("service-utilisation", "outpatient-service-utilization")),
    generate_admin1_mch_curative_index = .cd_def("method", "The MCH preventive services index and the curative services index per region.",
      grain = "one row per adminlevel_1 x year", unit = "index", key_columns = c("adminlevel_1", "year"),
      depends_on = "service_utilization_admin1", shown_on = c(P$mch, P$reports), method = m("service-utilisation", "mch-preventive-vs-curative-index")),
    get_filtered_coverage = .cd_def("method", "One indicator's coverage with its chosen denominator next to the survey and WUENIC estimates, by year: the table under the National Coverage chart.",
      grain = "one row per estimate (columns are years)", unit = "coverage %", key_columns = "estimates",
      depends_on = c("calculate_coverage", "get_denominator"), shown_on = c(P$national_coverage, P$reports),
      method = m("coverage", "national-coverage-trends")),
    get_filtered_inequality = .cd_def("method", "One indicator's coverage per region (or district) with its chosen denominator and the inequality measures: the data of the inequality charts.",
      grain = "one row per region or district x year", unit = "coverage %; percentage points", key_columns = c("adminlevel_1", "district", "year"),
      depends_on = c("inequality_admin1", "inequality_district", "get_denominator"), shown_on = c(P$national_inequality, P$reports),
      method = m("subnational", "inequality")),
    get_filtered_mapping_data = .cd_def("method", "One indicator's regional coverage with its chosen denominator for the chosen years, joined to the map.",
      grain = "one row per adminlevel_1 x year", unit = "coverage %; geometry", key_columns = c("adminlevel_1", "year"),
      depends_on = c("get_mapping_data", "mapping_years", "get_denominator"), shown_on = c(P$national_inequality, P$reports)),
    get_base_indicator_coverage = .cd_def("method", "The coverage table at a level (indicator_coverage_* or, for one region, computed): the numerators, populations, denominators and coverage before the survey comparison.",
      grain = "per year, region x year or district x year", unit = "counts; coverage %", key_columns = c("adminlevel_1", "district", "year"),
      depends_on = c("indicator_coverage_national", "indicator_coverage_admin1", "indicator_coverage_district"),
      method = m("denominators", "denominator-options")),
    get_filtered_threshold = .cd_def("method", "The share of districts (or regions) reaching the global coverage target for an indicator group (anc4, instlivebirths, vaccine, dropout), each year.",
      grain = "one row per year", unit = "% of units", key_columns = "year",
      default = c("cov_target_vaccine_national", "sub_target_vaccine", "cov_target_anc4", "cov_target_instlivebirths", "cov_target_dropout"),
      depends_on = c("get_base_indicator_coverage", "get_denominator"), shown_on = c(P$target, P$reports),
      method = m("subnational", "global-coverage-targets")),
    calculate_derived_coverage = .cd_def("method", "One indicator's coverage under each of the six denominators next to the survey value (with its bounds), by year: the table behind the Denominator Selection charts.",
      grain = "one row per year", unit = "coverage %", key_columns = "year", depends_on = "calculate_coverage",
      shown_on = c(P$denom_selection, P$reports), method = m("denominators", "selecting-the-best-denominator-option")),
    get_high_performers = .cd_def("method", "The regions (or districts) whose coverage of an indicator reaches its target, each year.",
      grain = "one row per unit x year reaching the target", unit = "coverage %", key_columns = c("adminlevel_1", "district", "year"),
      default = c("cov_target_vaccine_national", "sub_target_vaccine", "cov_target_anc4", "cov_target_instlivebirths", "cov_target_dropout", "cov_target_other"),
      depends_on = c("get_base_indicator_coverage", "get_denominator"), shown_on = P$target, method = m("subnational", "global-coverage-targets")),
    get_regional_estimates = .cd_def("method", "The national rates with a region's own survey values in their place, for calculations restricted to one region.",
      unit = "proportion", depends_on = c("national_estimates", "subnational_regions"), status = "draft",
      note = "Fails when called for a region: it reads an object (reg_data) that is not defined; the regional rates in use come from admin1_estimates."),
    generate_health_system_table = .cd_def("method", "The national health-system table: facility, hospital and bed densities, workforce density and skills mix, and the private and NGO shares of facilities, each with its unit.",
      grain = "one row per health-system indicator", unit = "per 10,000 or 100,000 population; %", key_columns = c("section", "indicator"),
      depends_on = "health_system_metrics_national", shown_on = c(P$hs_national, P$reports),
      method = m("health-system", "input-indicators-and-analytical-benchmarks")),
    generate_phc_scatter_data = .cd_def("method", "Per region, a health-system density (facilities or workforce) against service coverage, with outliers flagged, for the PHC performance scatter.",
      grain = "one row per adminlevel_1", unit = "density; coverage %", key_columns = "adminlevel_1",
      depends_on = "health_system_metrics_admin1", shown_on = c(P$phc, P$reports),
      method = m("health-system", "health-systems-outputs-by-inputs-at-the-sub-national-level")),
    generate_private_sector_data = .cd_def("method", "Per region, the share of facilities that are public, private for profit and NGO.",
      grain = "one row per adminlevel_1 x facility type", unit = "%", key_columns = c("adminlevel_1", "facility_type"),
      depends_on = "health_system_metrics_admin1", shown_on = c(P$private, P$reports),
      method = m("health-system", "input-indicators-and-analytical-benchmarks")),
    get_bayes_model = .cd_def("method", "The Bayesian model of one indicator's coverage (anc4, anc_1trimester, ideliv, measles1 or penta3) with its chosen denominator, nationally or by region, combining the routine data and the surveys; fitted once and kept in the dataset.",
      depends_on = c("calculate_coverage", "overall_score", "get_denominator"), shown_on = P$bayesian,
      method = m("bayesian-coverage", "method"), status = "draft",
      note = "The model object's structure comes from the Bayesian packages (bayescoveragemodel); not evaluated in the checks here.")
  )

  c(defs, methods)
}

# The definition of a setter or clearer, from the member it changes.
.cd_setter_definition <- function(name, defs) {
  targets <- .cd_setter_targets()
  target <- if (name %in% names(targets)) targets[[name]] else sub("^(set|clear|reset)_", "", name)
  base <- defs[[target]]
  verb <- if (startsWith(name, "clear_") || startsWith(name, "reset_")) "Clears" else "Sets"
  what <- if (identical(verb, "Clears")) {
    sprintf("Clears `%s`: back to its built-in value, or unset.", target)
  } else {
    sprintf("Sets `%s`%s", target, if (!is.null(base)) paste0(": ", sub("\\.$", "", base$what), ".") else ".")
  }
  .cd_def("action", what, set_on = base$set_on, method = base$method, depends_on = target,
          status = if (is.null(base)) "draft" else "defined",
          note = if (is.null(base)) sprintf("`%s` has no definition of its own.", target))
}

#' What a CacheConnection data point is
#'
#' The definition of one public member of [CacheConnection]: what it holds or returns in the methodology's terms, its
#' kind (`data`, `setting`, `reference`, `mapping`, `check`, `value`, `store`, `state`, `method`, `action`), its grain
#' (what one row is) and key columns, its unit, where the user sets it in the app (`set_on`) and which pages show it
#' (`shown_on`), the methodology docs section it comes from (`method`), the defaults it follows (ids of
#' [cd_methodology_defaults()]), and what it is computed from (`depends_on`). Columns are described from their names
#' by the data dictionary, not here. `status` is `"draft"` (with a `note`) where the definition is not certain.
#' [cache_manifest()] includes every member's definition.
#'
#' @param name A member name, e.g. `"adjusted_data"`; `NULL` for all of them.
#' @return A list (one definition), a named list of all of them, or `NULL` when `name` is not a public member.
#' @examples
#' cache_definition("adjusted_data")$what
#' @export
cache_definition <- function(name = NULL) {
  defs <- .cd_cache_definitions()
  members <- .cd_public_members()
  all <- lapply(stats::setNames(members, members), function(n) {
    if (!is.null(defs[[n]])) return(defs[[n]])
    if (grepl("^(set|clear|reset)_", n)) return(.cd_setter_definition(n, defs))
    NULL
  })
  if (is.null(name)) return(Filter(Negate(is.null), all))
  if (!is.character(name) || length(name) != 1) cd_abort(c("x" = "{.arg name} must be one member name."))
  all[[name]]
}

# Every public member of CacheConnection (methods and active bindings), as cache_manifest() lists them.
.cd_public_members <- function() {
  cls <- get("CacheConnection", envir = asNamespace("cd2030.core"))
  c(setdiff(names(cls$public_methods), c("clone", "initialize")), names(cls$active))
}
