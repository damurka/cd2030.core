# The constants of the Countdown methodology, defined once.
#
# Every number the documentation quotes about how the package works (the reporting-rate cutoff of the
# adjustment, the 5 x MAD outlier rule, the default mortality rates of the denominators, the coverage
# targets, ...) lives in `.cd_method` below. The functions that use them read them from here (as argument
# defaults or directly), and cd_methodology_defaults() publishes them, so the docs are generated from the
# same values the code runs with (inst/scripts/export-methodology-defaults.R writes the docs' JSON).
#
# Changing a value here changes the package's behaviour. Keep the names stable: the docs and
# cd_methodology_defaults()'s ids depend on them.

.cd_method <- list(
  data_quality = list(
    # 1b: a district counts as reporting well in a year when its reporting rate is at least this (%).
    # The app's starting value (CacheConnection performance_threshold); the Reporting Rate page can change it.
    reporting_threshold = 90,
    # the quick picks the Reporting Rate page offers for that threshold
    reporting_threshold_picks = c(70, 80, 90, 95),
    # 2a/2b and the adjustment: a value is an extreme outlier outside median +/- 5 x MAD
    outlier_mad_multiplier = 5,
    # the median and MAD are computed from every year before the latest one (add_mad_med_columns())
    outlier_baseline = "all years except the latest",
    # 3: a district's ratio (e.g. anc1/penta1) is adequate within this inclusive range
    ratio_adequate_range = c(1, 1.5),
    # the ratio pairs checked for every indicator group, and the ones added for the vaccine group
    ratio_pairs = list(ratioAP = c("anc1", "penta1"), ratioPP = c("penta1", "penta3")),
    ratio_pairs_vaccine = list(ratioOO = c("opv1", "opv3")),
    # the survey coverage the expected ratios are built from when no survey coverage is given (proportions)
    ratio_expected_coverage = c(anc1 = 0.98, penta1 = 0.97, penta3 = 0.89, opv1 = 0.97, opv3 = 0.78, pcv1 = 0.97, rota1 = 0.96),
    # multiplier applied to the expected anc1/penta1 ratio (mortality between the two contacts)
    ratio_anc1_penta1_mortality = 1.07,
    # the rows of the overall score whose mean is the annual data quality score, by indicator group
    score_components = list(
      rmncah = c("1a", "1b", "1c", "2a", "2b", "3c", "3d"),
      vaccine = c("1a", "1b", "1c", "2a", "2b", "3f", "3g", "3h")
    )
  ),
  adjustment = list(
    # adjust_service_data(adjustment = "default"): the k of every indicator group
    k = 0.25,
    k_groups = c("anc", "idelv", "pnc", "vacc", "opd", "ipd"),
    # the k a new dataset starts with in the app (CacheConnection k_factors): no adjustment until chosen
    k_start = 0,
    k_start_groups = c("anc", "idelv", "vacc", "opd", "ipd"),
    # the values the Data Adjustment page offers for each k
    k_options = c(0, 0.25, 0.5, 0.75, 1),
    # a district-month reporting rate below this (or missing) is replaced before adjusting ...
    reporting_rate_cutoff = 75,
    # ... by the district's median of the rates within this range
    reporting_rate_window = c(75, 100)
  ),
  denominators = list(
    # default rates of calculate_indicator_coverage() and get_national_rates() (proportions);
    # twin and preg_loss are also the app's starting national estimates (CacheConnection)
    sbr = 0.02,
    nmr = 0.025,
    pnmr = 0.024,
    twin = 0.015,
    preg_loss = 0.03,
    anc1survey = 0.98,
    dpt1survey = 0.97,
    survey_year = 2019
  ),
  coverage = list(
    # calculate_threshold() and CacheConnection$get_high_performers(): coverage targets (%)
    target_vaccine_national = 90,
    target_vaccine_subnational = 80,
    target_anc4 = 70,
    target_instlivebirths = 80,
    # dropout: the share of units BELOW this counts
    target_dropout = 10,
    # get_high_performers() for any other indicator
    target_other = 80
  ),
  mortality = list(
    # institutional MMR (per 100,000 live births) and SBR (per 1,000 births) flagged as very low
    mmr_low = 25,
    sbr_low = 6,
    # the completeness ratios summarise_completeness_ratio() shows
    completeness_ratios = c(0.5, 1, 1.5, 2)
  )
)

# A named vector with the same `value` for every group, e.g. the k factors.
.cd_method_by_group <- function(value, groups) {
  set_names(rep(value, length(groups)), groups)
}

# The entries cd_methodology_defaults() returns. Every value is read from `.cd_method`.
.cd_method_entries <- function() {
  m <- .cd_method
  dq <- m$data_quality
  adj <- m$adjustment
  den <- m$denominators
  cov <- m$coverage
  mort <- m$mortality

  pct <- function(x) paste0(format(x * 100, trim = TRUE), "%")
  pair_label <- function(pairs) unname(vapply(pairs, paste, character(1), collapse = "/"))

  entry <- function(id, step, group, value, unit, label, note, source) {
    list(id = id, step = step, group = group, value = value, unit = unit, label = label, note = note, source = source)
  }

  coverage_entries <- lapply(names(dq$ratio_expected_coverage), function(ind) {
    entry(
      paste0("dq_ratio_expected_coverage_", ind), "data_quality",
      if (ind %in% c("anc1", "penta1", "penta3")) "both" else "vaccine",
      unname(dq$ratio_expected_coverage[[ind]]), "proportion",
      paste0("Assumed ", ind, " coverage for expected ratios"),
      paste0("When no survey coverage is supplied, calculate_ratios_summary() builds the expected ratios from an assumed ",
             ind, " coverage of ", pct(dq$ratio_expected_coverage[[ind]]), " (the app passes the country's survey estimates instead)."),
      "R/1a_checks_ratios.R"
    )
  })

  denominator_entry <- function(key, label, what) {
    entry(
      paste0("den_", key), "denominators", "both", den[[key]], "proportion", label,
      paste0("Default ", what, " (", pct(den[[key]]), ") of calculate_indicator_coverage() when no rate is supplied; the rate it is given also fills in regions the survey has no value for."),
      "R/2_denominators_calculate_indicator_coverage.R"
    )
  }

  c(
    list(
      entry("dq_reporting_threshold", "data_quality", "both", dq$reporting_threshold, "%",
            "District reporting completeness threshold (1b)",
            paste0("Score item 1b is the percentage of districts whose facility reporting rate is at least this value; the app starts at ",
                   dq$reporting_threshold, "% and the Reporting Rate page can change it."),
            "R/1a_checks_reporting_rate.R"),
      entry("dq_reporting_threshold_picks", "data_quality", "both", dq$reporting_threshold_picks, "%",
            "Reporting threshold quick picks",
            "The values the Reporting Rate page offers as quick picks for the district reporting threshold.",
            "R/ui-page-1a_checks_reporting_rate.R"),
      entry("dq_outlier_mad_multiplier", "data_quality", "both", dq$outlier_mad_multiplier, "x MAD",
            "Extreme outlier bound",
            paste0("A monthly value is an extreme outlier when it lies more than ", dq$outlier_mad_multiplier,
                   " median absolute deviations from its district's median (Hampel X84)."),
            "R/utils-quality_checks.R"),
      entry("dq_outlier_baseline", "data_quality", "both", dq$outlier_baseline, "",
            "Outlier baseline years",
            "The district median and MAD used for the outlier bounds are computed from all years except the latest, so the latest year cannot hide its own outliers.",
            "R/utils-quality_checks.R"),
      entry("dq_ratio_adequate_range", "data_quality", "both", dq$ratio_adequate_range, "ratio",
            "Adequate range for consistency ratios",
            paste0("A district's consistency ratio (the ratio of its annual totals) is adequate when it is between ",
                   dq$ratio_adequate_range[1], " and ", dq$ratio_adequate_range[2], " inclusive."),
            "R/1a_checks_ratios.R"),
      entry("dq_ratio_pairs", "data_quality", "both", pair_label(dq$ratio_pairs), "",
            "Consistency ratios checked",
            "The internal consistency ratios checked for every indicator group (numerator/denominator).",
            "R/utils-quality_checks.R"),
      entry("dq_ratio_pairs_vaccine", "data_quality", "vaccine", pair_label(dq$ratio_pairs_vaccine), "",
            "Consistency ratios added for immunization",
            "The consistency ratios added to the common ones when the indicator group is vaccine.",
            "R/utils-quality_checks.R"),
      entry("dq_ratio_anc1_penta1_mortality", "data_quality", "both", dq$ratio_anc1_penta1_mortality, "ratio",
            "ANC1/Penta1 expected ratio multiplier",
            "The expected anc1/penta1 ratio is multiplied by this factor to allow for mortality between the first antenatal visit and the first Penta dose.",
            "R/1a_checks_ratios.R")
    ),
    coverage_entries,
    list(
      entry("dq_score_components_rmncah", "data_quality", "rmncah", dq$score_components$rmncah, "",
            "Overall score components (RMNCAH)",
            "The annual data quality score is the mean of these rows of the overall score table: reporting, completeness, outliers and the share of districts with adequate ratios.",
            "R/1a_checks_overall_score.R"),
      entry("dq_score_components_vaccine", "data_quality", "vaccine", dq$score_components$vaccine, "",
            "Overall score components (immunization)",
            "The annual data quality score is the mean of these rows of the overall score table: reporting, completeness, outliers and the share of districts with adequate ratios.",
            "R/1a_checks_overall_score.R"),

      entry("adj_k_default", "adjustment", "both", adj$k, "",
            "Completeness adjustment factor k (default adjustment)",
            paste0("adjust_service_data(adjustment = \"default\") uses k = ", adj$k, " for every indicator group (",
                   paste(adj$k_groups, collapse = ", "), ")."),
            "R/1c_adjust_service_data.R"),
      entry("adj_k_start", "adjustment", "both", adj$k_start, "",
            "Starting k in the app",
            paste0("A new dataset starts with k = ", adj$k_start, " for every indicator group, so the app adjusts nothing until the user picks a k on the Data Adjustment page."),
            "R/CacheConnection-class.R"),
      entry("adj_k_options", "adjustment", "both", adj$k_options, "",
            "k values offered",
            "The k values the Data Adjustment page offers for each indicator group.",
            "R/ui-page-1c_data_adjustment.R"),
      entry("adj_reporting_rate_cutoff", "adjustment", "both", adj$reporting_rate_cutoff, "%",
            "Reporting rate cutoff",
            paste0("Before adjusting, a reporting rate below ", adj$reporting_rate_cutoff,
                   "% (or missing) is replaced by the district's median reporting rate."),
            "R/1c_adjust_service_data.R"),
      entry("adj_reporting_rate_window", "adjustment", "both", adj$reporting_rate_window, "%",
            "Reporting rates used for the replacement median",
            paste0("The replacement median is taken over the district's reporting rates between ", adj$reporting_rate_window[1],
                   "% and ", adj$reporting_rate_window[2], "% inclusive."),
            "R/1c_adjust_service_data.R"),
      entry("adj_outlier_mad_multiplier", "adjustment", "both", dq$outlier_mad_multiplier, "x MAD",
            "Outliers replaced after adjustment",
            paste0("After the k adjustment, values more than ", dq$outlier_mad_multiplier,
                   " MAD from the district's median monthly value (baseline: all years except the latest) are replaced by the median of the district's other (non-outlier) months in the same year; missing months get the district's median for that year."),
            "R/1c_adjust_service_data.R"),

      denominator_entry("nmr", "Neonatal mortality rate", "neonatal mortality rate"),
      denominator_entry("pnmr", "Post-neonatal mortality rate", "post-neonatal mortality rate"),
      denominator_entry("sbr", "Stillbirth rate", "stillbirth rate"),
      denominator_entry("twin", "Twin rate", "twin rate"),
      denominator_entry("preg_loss", "Pregnancy loss rate", "pregnancy loss rate"),
      denominator_entry("anc1survey", "ANC1 survey coverage", "ANC1 survey coverage"),
      denominator_entry("dpt1survey", "Penta1 (DTP1) survey coverage", "Penta1 (DTP1) survey coverage"),
      entry("den_survey_year", "denominators", "both", den$survey_year, "year",
            "Survey year",
            "Default survey year in calculate_indicator_coverage(); the app uses the year of the country's latest survey.",
            "R/2_denominators_calculate_indicator_coverage.R"),
      entry("den_app_twin_preg_loss", "denominators", "both", c(den$twin, den$preg_loss), "proportion",
            "Starting twin and pregnancy loss rates in the app",
            paste0("A new dataset starts with a twin rate of ", pct(den$twin), " and a pregnancy loss rate of ", pct(den$preg_loss),
                   "; neonatal, post-neonatal and stillbirth rates come from the survey."),
            "R/CacheConnection-class.R"),

      entry("cov_target_vaccine_national", "coverage", "both", cov$target_vaccine_national, "%",
            "Vaccine coverage target (national)",
            "At national level a vaccine (BCG, Penta3, measles1) reaches the target when its coverage is at least this value.",
            "R/3_calculate_threshold.R"),
      entry("cov_target_anc4", "coverage", "rmncah", cov$target_anc4, "%",
            "ANC4 coverage target",
            "Units reach the ANC4 target when their coverage is at least this value.",
            "R/3_calculate_threshold.R"),
      entry("cov_target_instlivebirths", "coverage", "rmncah", cov$target_instlivebirths, "%",
            "Institutional live births coverage target",
            "Units reach the institutional live births target when their coverage is at least this value.",
            "R/3_calculate_threshold.R"),
      entry("cov_target_dropout", "coverage", "vaccine", cov$target_dropout, "%",
            "Dropout rate target",
            "Units meet the dropout target (Penta1-Penta3, Penta3-measles1) when their dropout rate is below this value.",
            "R/3_calculate_threshold.R"),
      entry("cov_target_other", "coverage", "both", cov$target_other, "%",
            "High performer threshold (other indicators)",
            "CacheConnection$get_high_performers() lists the units at or above this coverage for indicators without a specific target.",
            "R/CacheConnection-class.R"),
      entry("sub_target_vaccine", "subnational", "both", cov$target_vaccine_subnational, "%",
            "Vaccine coverage target (regions and districts)",
            "Below national level a vaccine (BCG, Penta3, measles1) reaches the target when its coverage is at least this value.",
            "R/3_calculate_threshold.R"),

      entry("mort_mmr_low", "mortality", "rmncah", mort$mmr_low, "per 100,000 live births",
            "Very low institutional MMR",
            "A unit whose institutional maternal mortality ratio is below this value is flagged as very low, a sign of under-reported deaths.",
            "R/5_mortality.R"),
      entry("mort_sbr_low", "mortality", "rmncah", mort$sbr_low, "per 1,000 births",
            "Very low institutional stillbirth rate",
            "A unit whose institutional stillbirth rate is below this value is flagged as very low, a sign of under-reported stillbirths.",
            "R/5_mortality.R"),
      entry("mort_completeness_ratios", "mortality", "rmncah", mort$completeness_ratios, "ratio",
            "Completeness ratios compared",
            "The completeness ratios at which the institutional mortality is compared with the UN estimates.",
            "R/5_mortality.R")
    )
  )
}

#' The Constants of the Countdown Methodology
#'
#' Lists the constants the package's methodology uses (cutoffs, thresholds,
#' default rates and targets) with the values the code runs with, so the
#' documentation can be generated from them.
#'
#' @param group Which entries to return: `"all"` (the default), or those that
#'   apply to the `"rmncah"` or the `"vaccine"` indicator group (entries for
#'   `"both"` are included in each).
#'
#' @return A tibble with one row per constant and the columns:
#'   - `id`: a stable snake_case identifier.
#'   - `step`: one of `"data_quality"`, `"adjustment"`, `"denominators"`,
#'     `"coverage"`, `"subnational"`, `"mortality"`.
#'   - `group`: `"both"`, `"rmncah"` or `"vaccine"`.
#'   - `value`: a list column; each element is a number, a string or a vector.
#'   - `unit`: for example `"%"`, `"x MAD"`, `"ratio"`, `"proportion"`, or `""`.
#'   - `label`: a short English label.
#'   - `note`: one English sentence on how the app uses it.
#'   - `source`: the file of the package (within `R/`) that uses it.
#'
#' @examples
#' cd_methodology_defaults()
#' cd_methodology_defaults("vaccine")
#'
#' @export
cd_methodology_defaults <- function(group = c("all", "rmncah", "vaccine")) {
  group <- arg_match(group)
  entries <- .cd_method_entries()

  if (group != "all") {
    entries <- Filter(function(e) e$group %in% c("both", group), entries)
  }

  new_tibble(list(
    id = vapply(entries, `[[`, character(1), "id"),
    step = vapply(entries, `[[`, character(1), "step"),
    group = vapply(entries, `[[`, character(1), "group"),
    value = lapply(entries, `[[`, "value"),
    unit = vapply(entries, `[[`, character(1), "unit"),
    label = vapply(entries, `[[`, character(1), "label"),
    note = vapply(entries, `[[`, character(1), "note"),
    source = vapply(entries, `[[`, character(1), "source")
  ))
}
