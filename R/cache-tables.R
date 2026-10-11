# The tables a dataset keeps: what each is computed from, and how.
#
# CacheConnection computes a table the first time it is asked for and keeps it (in memory and in the dataset's file)
# until something it was computed from changes. This list is the one place that says what that is. From it come:
#   - the table's active binding (`private$kept()`): take a reactive dependency on what it reads, compute it when it
#     is not there, keep it;
#   - what a setter clears (`private$changed("<field>")`): every table computed from that field, directly or through
#     another kept table. No setter names the tables it clears.
# Before, each table's dependencies were written three times by hand (its binding's depend() calls, the setters'
# invalidate_*() cascades and cache-definitions.R) and the three disagreed: a setting cleared tables it does not
# enter (a new performance threshold rebuilt 11 tables that came out the same) and left others as they were (the
# coverage tables after a new survey year).
#
# `reads`: the fields (settings and data) and the other kept tables the computation reads.
# `compute`: function(self), the dataset. NULL for a store filled from outside (the Bayesian models, fitted in
#   another process and kept with keep_bayes_model()): it is cleared like a table, never computed here.
# `when`: function(self); the table is computed only when TRUE (it has nothing to be computed from before the data
#   is adjusted).
.cd_kept <- function(reads, compute = NULL, when = NULL) {
  list(reads = reads, compute = compute, when = when)
}

.cd_has_adjusted <- function(self) !is.null(self$adjusted_data)

.cd_kept_tables <- list(
  # -- data quality: from the data as loaded -------------------------------------------------------------------
  reporting_rate_national = .cd_kept("countdown_data", function(self) self$calculate_reporting_rate("national")),
  reporting_rate_admin1 = .cd_kept("countdown_data", function(self) self$calculate_reporting_rate("adminlevel_1")),
  reporting_rate_district = .cd_kept("countdown_data", function(self) self$calculate_reporting_rate("district")),
  district_reporting_rate = .cd_kept(c("countdown_data", "performance_threshold"),
                                     function(self) self$calculate_district_reporting_rate()),
  completeness_national = .cd_kept(c("countdown_data", "performance_threshold"),
                                   function(self) self$calculate_completeness_summary("national")),
  completeness_admin1 = .cd_kept(c("countdown_data", "performance_threshold"),
                                 function(self) self$calculate_completeness_summary("adminlevel_1")),
  completeness_district = .cd_kept(c("countdown_data", "performance_threshold"),
                                   function(self) self$calculate_completeness_summary("district")),
  district_completeness = .cd_kept("countdown_data", function(self) self$calculate_district_completeness_summary()),
  outliers_national = .cd_kept("countdown_data", function(self) self$calculate_outliers_summary("national")),
  outliers_admin1 = .cd_kept("countdown_data", function(self) self$calculate_outliers_summary("adminlevel_1")),
  outliers_district = .cd_kept("countdown_data", function(self) self$calculate_outliers_summary("district")),
  district_outliers_summary = .cd_kept("countdown_data", function(self) self$calculate_district_outlier_summary()),
  list_outlier_units = .cd_kept("countdown_data", function(self) list_outlier_units(.data = self$countdown_data)),
  adequacy_ratios = .cd_kept("countdown_data", function(self) self$calculate_ratios_and_adequacy()),
  ratios_summary = .cd_kept(c("adequacy_ratios", "survey_estimates"),
                            function(self) calculate_ratios_summary(self$adequacy_ratios, self$survey_estimates)),
  overall_score = .cd_kept(
    c("reporting_rate_national", "district_reporting_rate", "district_completeness", "outliers_national",
      "district_outliers_summary", "adequacy_ratios", "performance_threshold"),
    function(self) self$calculate_overall_score(admin_level = "national")
  ),

  # -- denominators and coverage: from the adjusted data -------------------------------------------------------
  denominator_metrics = .cd_kept(
    c("adjusted_data", "un_estimates"),
    function(self) prepare_population_metrics(self$adjusted_data, un_estimates = self$un_estimates),
    when = .cd_has_adjusted
  ),
  # The regional surveys enter at every level (each region's own rates); they are read from start_survey_year on.
  # national_estimates carries ANC1 and Penta1 from survey_estimates.
  indicator_coverage_national = .cd_kept(
    c("adjusted_data", "derivation_population", "un_estimates", "national_estimates", "survey_estimates",
      "regional_survey", "survey_mapping", "survey_year", "start_survey_year"),
    function(self) self$calculate_indicator_coverage("national")
  ),
  indicator_coverage_admin1 = .cd_kept(
    c("adjusted_data", "derivation_population", "un_estimates", "national_estimates", "survey_estimates",
      "regional_survey", "survey_mapping", "survey_year", "start_survey_year"),
    function(self) self$calculate_indicator_coverage("adminlevel_1")
  ),
  indicator_coverage_district = .cd_kept(
    c("adjusted_data", "derivation_population", "un_estimates", "national_estimates", "survey_estimates",
      "regional_survey", "survey_mapping", "survey_year", "start_survey_year"),
    function(self) self$calculate_indicator_coverage("district")
  ),
  inequality_admin1 = .cd_kept(c("indicator_coverage_national", "indicator_coverage_admin1"),
                               function(self) self$calculate_inequality(admin_level = "adminlevel_1")),
  inequality_district = .cd_kept(c("indicator_coverage_national", "indicator_coverage_district"),
                                 function(self) self$calculate_inequality(admin_level = "district")),
  # A model is fitted on the coverage with its surveys and WUENIC (calculate_coverage()) and on the overall score,
  # and kept under its level, indicator and denominator.
  bayesian_models = .cd_kept(c("indicator_coverage_national", "indicator_coverage_admin1", "national_survey",
                               "regional_survey", "wuenic_estimates", "survey_mapping", "start_survey_year",
                               "overall_score")),

  # -- the adjustment, step by step ----------------------------------------------------------------------------
  # The yearly numbers as reported and after each step of the dataset's adjustment (the whole adjustment run with
  # its steps kept): one computation for every indicator a report compares, not one for each.
  adjustment_values = .cd_kept(c("countdown_data", "adjusted_data"),
                               function(self) generate_adjustment_values(self$data_with_excluded_years, settings = self$adjustment_settings),
                               when = function(self) !is.null(self$countdown_data)),

  # -- mortality, utilization, health systems ------------------------------------------------------------------
  mortality_summary = .cd_kept("adjusted_data", function(self) create_mortality_summary(self$adjusted_data),
                               when = .cd_has_adjusted),
  mortality_ratios = .cd_kept(c("mortality_summary", "un_mortality_estimates"),
                              function(self) create_mortality_ratios(self$mortality_summary, self$un_mortality_estimates)),
  service_utilization_national = .cd_kept("adjusted_data", function(self) self$compute_service_utilization("national")),
  service_utilization_admin1 = .cd_kept("adjusted_data", function(self) self$compute_service_utilization("adminlevel_1")),
  health_system_comparison = .cd_kept(
    c("adjusted_data", "indicator_coverage_admin1", "indicator_coverage_district"),
    function(self) calculate_health_system_comparison(self$adjusted_data, self$indicator_coverage_admin1,
                                                      self$indicator_coverage_district),
    when = .cd_has_adjusted
  ),
  health_system_metrics_national = .cd_kept("adjusted_data",
                                            function(self) calculate_health_system_metrics(self$adjusted_data, "national"),
                                            when = .cd_has_adjusted),
  health_system_metrics_admin1 = .cd_kept("adjusted_data",
                                          function(self) calculate_health_system_metrics(self$adjusted_data, "adminlevel_1"),
                                          when = .cd_has_adjusted)
)

# The kept tables computed from any of `fields`, directly or through another kept table (never `fields` themselves).
.cd_kept_dependents <- function(fields) {
  found <- character()
  frontier <- fields
  while (length(frontier)) {
    reached <- names(.cd_kept_tables)[vapply(.cd_kept_tables, function(t) any(t$reads %in% frontier), logical(1))]
    frontier <- setdiff(reached, found)
    found <- c(found, frontier)
  }
  found
}
