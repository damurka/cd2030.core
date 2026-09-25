# Countdown's side of the report builder (datasuite.ui): the kinds of chart and table, how each is drawn from a dataset
# (.rb_draw()), the standard reports, the Countdown theme and fields, and the report context of a CacheConnection.
#
# The standard report files (R/report-preset-*.R) and R/report-kinds-extra.R are written with the builder's block
# helpers under their short names below.

.rb_kind <- function(type, group, label, indicators = NULL, levels = NULL, variants = NULL, year = FALSE, regional = FALSE,
                     groups = c("rmncah", "vaccine"), tall = FALSE) {
  datasuite.ui::report_kind(type, group, label, indicators, levels, variants, year, regional, groups, tall)
}
.rb_t <- function(i18n, key, fallback = key) datasuite.ui::report_translate(i18n, key, fallback)
.rb_tx <- function(en, fr = en, pt = en) datasuite.ui::report_tx(en, fr, pt)
.rb_in <- function(x, lang = "en") datasuite.ui::report_in(x, lang)
.rb_heading <- function(text, level = 1) datasuite.ui::report_heading(text, level)
.rb_text <- function(text) datasuite.ui::report_paragraph(text)
.rb_note <- function(text) datasuite.ui::report_note(text)
.rb_break <- function() datasuite.ui::report_page_break()
.rb_chart <- function(...) datasuite.ui::report_chart(...)
.rb_table <- function(kind, ...) datasuite.ui::report_table(kind, ...)
.rb_questions <- function(...) datasuite.ui::report_questions(...)
.rb_merge <- function(a, b) datasuite.ui::report_merge(a, b)

# ---- the kinds of chart and table ----------------------------------------------------------------------------------

#' The charts and tables a report can contain
#'
#' What each kind draws and which settings it takes. The builder offers these; [render_report_block()] draws them.
#'
#' The kinds are listed in the order of the analysis (their `group`: data quality, adjustment, denominators, national,
#' sub-national, region, mortality, service utilization, health system). The standard report files add their own kinds
#' (see the top of the standard reports section).
#'
#' @param group The indicator group; kinds that only make sense for one group (`groups`) are left out of the other.
#' @return A named list; each entry has `type` (`"chart"` or `"table"`), `group`, `label`, `indicators` (`"analysis"`,
#'   a character vector, or `NULL` when the kind has no indicator), `levels`, `variants` (named character vector or
#'   `NULL`), `year` (whether a year is chosen), `regional` (whether it is drawn for one region) and `groups` (the
#'   indicator groups it is for).
#' @export
report_block_kinds <- function(group = get_selected_group()) {
  kinds <- .rb_all_kinds()
  group <- if (identical(group, "vaccine")) "vaccine" else "rmncah"
  kinds <- Filter(function(x) group %in% (x$groups %||% c("rmncah", "vaccine")), kinds)
  rank <- match(vapply(kinds, function(x) x$group, character(1)), .rb_group_order)
  kinds[order(ifelse(is.na(rank), length(.rb_group_order) + 1, rank), seq_along(kinds))]
}

# Every kind: the core ones and those the standard report files add (.rb_kinds_<name>())
.rb_all_kinds <- function() {
  kinds <- .rb_core_kinds()
  ns <- environment(.rb_all_kinds)
  for (f in sort(ls(ns, pattern = "^\\.rb_kinds_", all.names = TRUE))) kinds <- c(kinds, get(f, envir = ns)())
  kinds
}

# The groups of kinds, in the order of the analysis (the palette shows them in this order)
.rb_group_order <- c("quality", "adjustment", "denominators", "national", "subnational", "region", "mortality", "utilization",
                     "health_system", "private_sector")

.rb_core_kinds <- function() {
  k <- .rb_kind
  rmncah <- c("rmncah")
  list(
    coverage = k("chart", "national", "Coverage trend: DHIS2 and survey", "analysis", c("national", "adminlevel_1")),
    continuum = k("chart", "national", "Continuum of care", levels = "national", variants = c(maternal = "Maternal", child = "Child"), groups = rmncah),
    threshold = k("chart", "national", "Districts reaching the target", c("anc4", "instlivebirths", "vaccine", "dropout"), tall = TRUE),
    coverage_table = k("table", "national", "Coverage table (DHIS2)"),
    inequality = k("chart", "subnational", "Coverage by region over time", "analysis", c("adminlevel_1", "district")),
    map = k("chart", "subnational", "Coverage map", "analysis", variants = c(Blues = "Blue", Greens = "Green", Purples = "Purple"), year = TRUE,
            tall = TRUE),
    equity = k("chart", "subnational", "Equity (from surveys)", c("instlivebirths", "penta3", "anc4", "measles1", "bcg", "ideliv"),
               variants = c(area = "Rural / urban", wealth = "Wealth", education = "Education")),
    region_coverage = k("chart", "region", "Coverage in a region, by denominator", "analysis", year = TRUE, regional = TRUE),
    district_table = k("table", "region", "Coverage by district in a region", year = TRUE, regional = TRUE),
    derived_coverage = k("chart", "denominators", "Coverage by denominator", "analysis", c("national", "adminlevel_1")),
    denominator_trend = k("chart", "denominators", "Population projections: DHIS2 and UN",
                          variants = c(population = "Total population", births = "Live births", under1 = "Under 1")),
    reporting_rate = k("chart", "quality", "Reporting rate by district", regional = TRUE, tall = TRUE),
    overall_score = k("table", "quality", "Data quality score table", regional = TRUE),
    consistency = k("chart", "quality", "Consistency between two indicators, by district",
                    variants = c(anc1_penta1 = "ANC1 and Penta1", penta1_penta3 = "Penta1 and Penta3", opv1_opv3 = "OPV1 and OPV3")),
    service_utilization = k("chart", "utilization", "Service utilization", variants = c(opd = "Outpatient (OPD)", ipd = "Inpatient (IPD)"), groups = rmncah),
    mch_index = k("chart", "utilization", "Preventive and curative care index", groups = rmncah),
    mortality_trend = k("chart", "mortality", "Institutional mortality trend", variants = c(mmr_inst = "Maternal (iMMR)", sbr_inst = "Stillbirths (iSBR)"), groups = rmncah),
    mortality_region = k("chart", "mortality", "Institutional mortality by region", variants = c(mmr = "Maternal (iMMR)", sbr = "Stillbirths (iSBR)"), groups = rmncah,
                         tall = TRUE),
    mortality_plausibility = k("chart", "mortality", "Stillbirths per maternal death", groups = rmncah),
    mortality_ratio = k("chart", "mortality", "Completeness of death reporting", variants = c(mmr = "Maternal (iMMR)", sbr = "Stillbirths (iSBR)"), groups = rmncah),
    health_system_table = k("table", "health_system", "Health system inputs table", groups = rmncah),
    health_system_region = k("chart", "health_system", "Health system inputs by region",
                             variants = c(ratio_fac_pop = "Facilities", ratio_hos_pop = "Hospitals", ratio_hstaff_pop = "Health workers",
                                          ratio_bed_pop = "Beds"), groups = rmncah, tall = TRUE),
    phc_scatter = k("chart", "health_system", "Service outputs by inputs",
                    variants = c(ratio_fac_pop = "Facilities", ratio_hos_pop = "Hospitals", ratio_hstaff_pop = "Health workers",
                                 ratio_bed_pop = "Beds"), groups = rmncah),
    private_share = k("chart", "private_sector", "Private sector share", variants = c(national = "National", area = "Rural / urban"), groups = rmncah)
  )
}

.rb_ind_name <- function(i18n, indicator) .rb_t(i18n, paste0("opt_", indicator), indicator)


.rb_draw <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  kind <- b$kind %||% "coverage"
  ind <- b$indicator %||% "anc4"
  name <- .rb_ind_name(i18n, ind)
  level <- b$admin_level %||% "national"
  region <- b$region
  if (identical(region, "@report") || identical(region, "")) region <- NULL
  years <- cache$data_years
  latest <- if (length(years)) max(years)
  coverage_labels <- list(dhis2 = t("lbl_coverage_dhis2_est", "DHIS2 estimate"), wuenic = t("lbl_coverage_wuenic_est", "WUENIC estimate"),
                          survey = t("lbl_coverage_survey_est", "Survey estimate"), ci = t("lbl_coverage_95ci", "95% CI"))
  benchmark_labels <- list("FALSE" = t("lbl_below_benchmark", "Below benchmark"), "TRUE" = t("lbl_meets_benchmark", "Meets benchmark"),
                           threshold_line = t("lbl_target_benchmark", "Benchmark"), national_line = t("lbl_national_average", "National average"))

  switch(
    kind,
    coverage = {
      if (identical(level, "national")) region <- NULL
      where <- if (is.null(region)) t("opt_national", "National") else region
      denom <- .rb_ind_name(i18n, cache$get_denominator(ind))
      plot(
        cache$get_filtered_coverage(ind, level, region = region),
        title = paste(where, name, t("lbl_rb_coverage_estimates", "coverage estimates")),
        x_axis = t("title_global_year", "Year"),
        y_axis = paste0(name, " (%)"),
        caption = paste0(t("lbl_rb_denominators_from", "Denominators derived from"), " ", denom),
        labels = coverage_labels
      )
    },
    continuum = plot(
      (d <- cache$generate_coverage_data("national", b$variant %||% "maternal")),
      type = "profile",
      indicator_labels = {
        inds <- unique(as.character(d$indicator))
        stats::setNames(lapply(inds, function(i) .rb_ind_name(i18n, i)), inds)
      },
      title = t("title_cov_profile", "Coverage profile"),
      subtitle = t("subtitle_cov_profile", ""),
      y_axis = t("opt_coverage", "Coverage (%)"),
      source_labels = list(facility = t("lbl_src_facility", "Facility (DHIS2)"), survey = t("lbl_src_survey", "Survey"),
                           wuenic = t("lbl_src_wuenic", "WUENIC"))
    ),
    threshold = {
      ind <- if (ind %in% c("anc4", "instlivebirths", "vaccine", "dropout")) ind else "anc4"
      plot(cache$get_filtered_threshold(ind, "district"),
           title = paste(.rb_ind_name(i18n, ind), t("lbl_rb_districts_target", "- districts reaching the target")),
           y_axis = t("lbl_axis_y_pct_subnat", "Districts (%)"), legend_title = t("title_global_year", "Year"))
    },
    coverage_table = .rb_coverage_table(cache, i18n),
    inequality = .rb_draw_ni_inequality(cache, b, i18n),
    map = .rb_draw_ni_map(cache, b, i18n),
    equity = {
      if (identical(b$variant %||% "area", "area")) {
        axis <- gsub("{indicator}", name, t("lbl_axis_y_coverage", "{indicator} Coverage (%)"), fixed = TRUE)
        equiplot_area(cache$area_survey, ind, title = gsub("{indicator}", name, t("plt_title_equity_area", "Inequalities in {indicator} coverage by residence"), fixed = TRUE),
                      x_title = axis, legend_title = t("lbl_leg_equity_area", "Residence"),
                      legend_labels = list(Rural = t("lbl_equity_area_rural", "Rural"), Urban = t("lbl_equity_area_urban", "Urban")))
      } else {
        .rb_draw_ni_equity(cache, b, i18n)
      }
    },
    region_coverage = {
      if (is.null(region)) cd_abort(c("x" = "Choose a region."))
      year <- b$year %||% latest
      title <- t("plt_title_region_coverage", "{indicator} coverage by region, {year} (HMIS)")
      title <- gsub("{year}", year, gsub("{indicator}", name, title, fixed = TRUE), fixed = TRUE)
      plot(cache$calculate_coverage("adminlevel_1"), ind, denominator = cache$get_denominator(ind), year = year,
           region = region, title = title,
           labels = list(lower = t("plt_regcov_lower", "Lower than average"), average = t("plt_regcov_average", "Average"),
                         higher = t("plt_regcov_higher", "Higher than average")))
    },
    district_table = .rb_district_table(cache, region, b$year %||% latest, i18n),
    derived_coverage = .rb_draw_ds_survey_comparison(cache, b, i18n),
    denominator_trend = {
      # no population chosen: the one the denominators are derived from
      if (is.null(b$variant)) {
        pop <- cache$derivation_population %||% ""
        b$variant <- if (grepl("birth", pop)) "births" else if (grepl("under1", pop)) "under1" else "population"
      }
      .rb_draw_ds_projection(cache, b, i18n)
    },
    reporting_rate = .rb_draw_dq_reporting_rate(cache, b, i18n),
    overall_score = .rb_draw_dq_score(cache, b, i18n),
    consistency = .rb_draw_dq_consistency(cache, b, i18n),
    service_utilization = {
      v <- b$variant %||% "opd"
      su_labels <- switch(
        v,
        opd = list(title = t("plt_su_title_opd", "OPD per person per year"), y_axis = t("plt_su_ylab_opd", "OPD Utilization Trends"),
                   y1 = t("plt_su_under5", "Under-5"), y2 = t("plt_su_all_ages", "All ages")),
        ipd = list(title = t("plt_su_title_ipd", "IPD admissions"),
                   y_axis = t("plt_su_ylab_ipd", "Mean # of IPD admissions per 100 persons"),
                   y1 = t("plt_su_under5", "Under-5"), y2 = t("plt_su_all_ages", "All ages")),
        list()
      )
      su_labels$x_axis <- t("title_global_year", "Year")
      plot(cache$filter_service_utilization("national", v), labels = su_labels)
    },
    mch_index = plot(cache$generate_admin1_mch_curative_index(), labels = list(
      title = t("lbl_mch_curative_title", "Preventive and curative care"),
      x_axis = t("lbl_mch_prev_index_x", "Preventive index"), y_axis = t("lbl_curative_index_y", "Curative index"),
      q_top_left = t("lbl_quad_low_prev_high_cur", "Low preventive, high curative"),
      q_top_right = t("lbl_quad_high_prev_high_cur", "High preventive, high curative"),
      q_bottom_left = t("lbl_quad_low_prev_low_cur", "Low preventive, low curative"),
      q_bottom_right = t("lbl_quad_high_prev_low_cur", "High preventive, low curative")
    )),
    mortality_trend = .rb_draw_mortality_trend(cache, b, i18n),
    mortality_region = {
      d <- cache$filter_mortality_summary(b$variant %||% "mmr", unique(c(min(years), latest)))
      v <- attr(d, "indicator")
      map_labels <- switch(
        v,
        mmr_inst = list(title = t("plt_mort_map_title_mmr_inst", "Institutional MMR by Region"),
                        legend = t("plt_mort_map_legend_mmr_inst", "Institutional MMR per 100,000 livebirths")),
        sbr_inst = list(title = t("plt_mort_map_title_sbr_inst", "Institutional SBR by Region"),
                        legend = t("plt_mort_map_legend_sbr_inst", "Institutional SBR per 1000")),
        NULL
      )
      plot(d, labels = map_labels)
    },
    mortality_plausibility = plot_mortality_plausibility(
      cache$mortality_summary, indicator = "ratio_md_sb",
      title = t("title_ratio_md_sb", "Stillbirths per maternal death"),
      y_axis = t("ylab_ratio_md_sb", "Stillbirths per maternal death"), x_axis = t("title_global_year", "Year"),
      note = t("note_ratio_md_sb", ""),
      legend_labels = list(median = t("lbl_median", "Median"), plausible = t("lbl_plausible", "Plausible range"))
    ),
    mortality_ratio = {
      v <- if (identical(b$variant, "sbr")) "sbr" else "mmr"
      type <- if (v == "sbr") t("plt_mort_type_sbr", "SBR") else t("plt_mort_type_mmr", "MMR")
      un <- function(key, fallback) gsub("{type}", type, t(key, fallback), fixed = TRUE)
      ratio_labels <- if (v == "sbr") {
        list(title = t("plt_mort_compl_title_sbr", "Completeness of facility stillbirth reporting (%), based on UN stillbirth estimates and community to institutional ratio"),
             x_axis = t("plt_mort_compl_x_sbr", "Ratio Community SBR to Institutional SBR"),
             y_axis = t("plt_mort_compl_y_sbr", "Completeness stillbirth reporting by facilities (%)"))
      } else {
        list(title = t("plt_mort_compl_title_mmr", "Completeness of facility maternal death reporting (%), based on UN MMR estimates and community to institutional ratio"),
             x_axis = t("plt_mort_compl_x_mmr", "Ratio Community MMR to Institutional MMR"),
             y_axis = t("plt_mort_compl_y_mmr", "Completeness maternal deaths reporting by facilities (%)"))
      }
      ratio_labels$lower <- un("plt_mort_un_lower", "UN {type} lower bound")
      ratio_labels$best <- un("plt_mort_un_best", "UN {type} best estimate")
      ratio_labels$upper <- un("plt_mort_un_upper", "UN {type} upper bound")
      plot(cache$summarise_completeness_ratio(v), labels = ratio_labels)
    },
    health_system_table = .rb_health_system_table(cache, latest, i18n),
    health_system_region = {
      v <- b$variant %||% "ratio_fac_pop"
      plot(cache$health_system_metrics_admin1, indicator = v, national_value = cache$health_system_metrics_national[[v]],
           title = t(paste0("title_metric_", v), v), x_axis = t(paste0("xlab_metric_", v), v), legend_labels = benchmark_labels)
    },
    phc_scatter = {
      v <- b$variant %||% "ratio_fac_pop"
      plot(cache$generate_phc_scatter_data(indicator = v),
           title = t(paste0("title_scatter_", v), v), x_axis = t(paste0("xlab_", v), v), y_axis = t("ylab_phc_scatter", "Service outputs"),
           quad_labels = list(high_high = t(paste0("lbl_hh_", v), ""), low_high = t(paste0("lbl_lh_", v), ""),
                              high_low = t(paste0("lbl_hl_", v), ""), low_low = t(paste0("lbl_ll_", v), "")))
    },
    private_share = plot(
      if (identical(b$variant, "area")) cache$area_private_share else cache$national_private_share,
      labels = list(public = t("lbl_public", "Public"), private = t("lbl_private", "Private"), share = t("plt_ps_share", "Priv. share = "),
                    careany = t("plt_ps_careany", "Careseeking for child illness"), csection = t("plt_ps_csection", "C-section"),
                    ideliv = t("plt_ps_ideliv", "Institutional delivery"),
                    rural = t("lbl_equity_area_rural", "Rural"), urban = t("lbl_equity_area_urban", "Urban"))
    ),
    {
      # kinds added by the standard report files draw with .rb_draw_<kind>()
      draw <- get0(paste0(".rb_draw_", kind), envir = environment(.rb_draw), inherits = FALSE)
      if (is.null(draw)) cd_abort(c("x" = "Unknown report block kind {.val {kind}}."))
      draw(cache, b, i18n)
    }
  )
}

# Coverage of the main indicators in each district of one region, for one year
.rb_district_table <- function(cache, region, year, i18n) {
  if (is.null(region)) cd_abort(c("x" = "Choose a region."))
  wanted <- c("anc4", "anc_1trimester", "instlivebirths", "csection", "pnc48h", "penta3", "measles1", "opd_under5")
  cols <- vapply(wanted, function(ind) paste0("cov_", ind, "_", cache$get_denominator(ind) %||% ""), character(1))
  d <- cache$indicator_coverage_district
  d <- d[d$adminlevel_1 == region & d$year == year, , drop = FALSE]
  if (!nrow(d)) cd_abort(c("x" = "No district coverage for {region} in {year}."))
  keep <- cols[cols %in% names(d)]
  if (!length(keep)) cd_abort(c("x" = "No coverage columns for these indicators."))
  out <- as.data.frame(d[, c("district", keep), drop = FALSE])
  out <- out[order(out$district), , drop = FALSE]
  for (col in keep) out[[col]] <- round(as.numeric(out[[col]]), 1)
  names(out) <- c(.rb_t(i18n, "lbl_rb_district", "District"), vapply(names(keep), function(ind) .rb_ind_name(i18n, ind), character(1)))
  ft <- flextable::flextable(out)
  ft <- flextable::theme_booktabs(ft)
  ft <- flextable::bold(ft, part = "header")
  ft <- flextable::fontsize(ft, size = 9, part = "all")
  flextable::autofit(ft)
}

.rb_health_system_table <- function(cache, year, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  labels <- list(
    section = list(infrastructure = t("sec_infrastructure", "Infrastructure"), workforce = t("sec_workforce", "Workforce"),
                   private_sector = t("sec_private_sector", "Private sector")),
    indicator = list(fac_density = t("ind_fac_density", "Health facility density"), hosp_share = t("ind_hosp_share", "Hospitals (%)"),
                     hosp_density = t("ind_hosp_density", "Hospital density"), bed_density = t("ind_bed_density", "Bed density"),
                     hwf_density = t("ind_hwf_density", "Health workforce density"), skill_mix = t("ind_skill_mix", "Skill mix"),
                     private_share = t("ind_private_share", "Private facilities (%)"), ngo_share = t("ind_ngo_share", "NGO facilities (%)")),
    unit = list(per_10k = t("unit_per_10k", "per 10,000"), per_100k = t("unit_per_100k", "per 100,000"), pct = "%")
  )
  ft <- plot(cache$generate_health_system_table(labels = labels), year = year,
             indicator_label = t("title_global_indicator", "Indicator"), value_label = t("lbl_value", "Value"), unit_label = t("lbl_unit", "Unit"))
  flextable::padding(ft, padding = 1.5, part = "all")
}

# DHIS2 coverage by indicator and year, for the main indicators the dataset has
.rb_coverage_table <- function(cache, i18n) {
  wanted <- intersect(c("anc4", "anc_1trimester", "instlivebirths", "ideliv", "pnc48h", "penta3", "measles1", "bcg"), get_analysis_indicators())
  rows <- lapply(wanted, function(ind) {
    d <- tryCatch(cache$get_filtered_coverage(ind, "national"), error = function(e) NULL)
    if (is.null(d)) return(NULL)
    row <- d[d$estimates == "DHIS2 estimate", , drop = FALSE]
    if (!nrow(row)) return(NULL)
    values <- unlist(row[1, setdiff(names(row), "estimates")])
    tibble::tibble(indicator = .rb_ind_name(i18n, ind), year = names(values), value = round(as.numeric(values), 1))
  })
  long <- do.call(rbind, Filter(Negate(is.null), rows))
  if (is.null(long) || !nrow(long)) cd_abort(c("x" = "No DHIS2 coverage estimates to show."))
  long <- long[!is.na(long$value), ]
  years <- sort(unique(long$year))
  years <- utils::tail(years, 6)
  wide <- tidyr::pivot_wider(long[long$year %in% years, ], names_from = "year", values_from = "value")
  names(wide)[1] <- .rb_t(i18n, "lbl_rb_indicator", "Indicator")
  ft <- flextable::flextable(wide)
  ft <- flextable::theme_booktabs(ft)
  ft <- flextable::fontsize(ft, size = 9, part = "all")
  flextable::autofit(ft)
}

# ---- standard reports ----------------------------------------------------------------------------------------------
#
# A standard report is the Countdown report of one analysis section (and the synthesis chartbook and the sub-national
# one-pager), rebuilt as blocks. Each is in its own file, R/report-preset-<id>.R, as a function .rb_preset_<id>(group)
# returning list(name, description, blocks, design_patch, cover_patch); `group` is the indicator group ("rmncah",
# "vaccine"). A slide deck returns kind = "deck" and `slides` instead of `blocks` (see R/report-deck.R). Its texts are written in the app's three languages with .rb_tx(en, fr, pt), and report_presets(lang) makes
# them in one. A file can also add chart kinds: a function .rb_kinds_<name>() returning more entries of
# report_block_kinds(), and for each kind a function .rb_draw_<kind>(cache, block, i18n) that draws it.

# The standard reports of an indicator group, in the order of the analysis
.rb_standard_ids <- function(group) {
  if (identical(group, "vaccine")) {
    c("data_quality", "adjustment", "denominator_selection", "national_inequality", "synthesis", "one_pager")
  } else {
    c("data_quality", "adjustment", "denominator_selection", "national_coverage", "national_inequality", "mortality",
      "service_utilization", "health_system", "private_sector", "synthesis", "one_pager")
  }
}

#' The standard reports
#'
#' One per analysis section (data quality, adjustment, denominators, national coverage, inequality, mortality,
#' service utilization, health system, private sector), then the synthesis chartbook and the sub-national one-pager: the
#' Countdown report templates rebuilt as blocks, which the builder opens as editable copies. The one-pager is about one
#' region: its blocks use the report's region (`region = "@report"`). It is a slide deck of one dense slide.
#'
#' @param lang The language of the report's text: `"en"`, `"fr"` or `"pt"`.
#' @param group The indicator group (`"rmncah"` or `"vaccine"`); each has its own list.
#' @return A named list of reports in the order of the analysis, each `list(name, description, kind, design, cover,
#'   blocks)` for a document (`kind = "document"`), or `list(name, description, kind = "deck", design, cover, slides)`
#'   for a slide deck (see [export_deck()]). [report_project_blocks()] gives the blocks of either.
#' @export
report_presets <- function(lang = "en", group = get_selected_group()) {
  lang <- if (lang %in% c("en", "fr", "pt")) lang else "en"
  group <- if (identical(group, "vaccine")) "vaccine" else "rmncah"
  design <- report_default_design()
  ns <- environment(report_presets)
  out <- list()
  for (id in .rb_standard_ids(group)) {
    make <- get0(paste0(".rb_preset_", id), envir = ns, inherits = FALSE)
    if (is.null(make)) next
    def <- make(group)
    kind <- if (identical(def$kind, "deck")) "deck" else "document"
    p <- list(
      name = .rb_in(def$name, lang),
      description = .rb_in(def$description, lang),
      kind = kind,
      design = .rb_merge(design, .rb_in(def$design_patch %||% list(), lang)),
      cover = .rb_merge(report_default_cover(), .rb_in(def$cover_patch %||% list(), lang))
    )
    if (kind == "deck") {
      p$slides <- .rb_in(def$slides, lang)
    } else {
      blocks <- .rb_in(def$blocks, lang)
      p$blocks <- lapply(seq_along(blocks), function(i) c(list(id = paste0("b", i)), blocks[[i]]))
    }
    out[[id]] <- p
  }
  out
}

# ---- the Countdown theme, fields and report context ----------------------------------------------------------------

# The Countdown look: the theme new reports start from, and its cover
.cd_report_theme_countdown <- list(
  theme = "countdown", name = "Countdown",
  accent = "#7d3f40", heading_color = "#7d3f40", text_color = "#2b3138", muted_color = "#5c6670",
  note_fill = "#f7f1e3", note_border = "#e6d7b0", heading_font = "Georgia", body_font = "Calibri",
  palette = c("#1c4f9c", "#7d3f40", "#1b6b45", "#a8480f", "#6b4c9a", "#5c6670"),
  footer = "Countdown to 2030 \u00b7 {country}"
)

# The indicators whose values are fields: {<indicator>_latest} (DHIS2, latest year) and {<indicator>_survey}
.rb_field_indicators <- c("anc1", "anc4", "anc_1trimester", "instlivebirths", "ideliv", "pnc48h", "bcg", "penta1", "penta3", "measles1")

# The fields Countdown adds to the builder's own: the country and coverage values
.cd_report_field_catalog <- function() {
  values <- unlist(lapply(.rb_field_indicators, function(ind) list(
    list(key = paste0(ind, "_latest"), group = "coverage", label = paste(ind, "coverage, latest year (DHIS2)"), indicator = ind, what = "latest"),
    list(key = paste0(ind, "_survey"), group = "coverage", label = paste(ind, "coverage, latest survey"), indicator = ind, what = "survey")
  )), recursive = FALSE)
  c(list(list(key = "country", group = "report", label = "Country")), values)
}

# Their values for one dataset
.cd_report_field_values <- function(cache) {
  out <- list(country = tryCatch(cache$country, error = function(e) NULL) %||% "")
  for (ind in .rb_field_indicators) {
    d <- tryCatch(suppressWarnings(cache$get_filtered_coverage(ind, "national")), error = function(e) NULL)
    if (is.null(d) || !nrow(d)) next
    last_value <- function(row) {
      if (!nrow(row)) return(NULL)
      v <- unlist(row[1, setdiff(names(row), "estimates")])
      v <- v[!is.na(v)]
      if (!length(v)) NULL else list(value = v[[length(v)]], year = names(v)[[length(v)]])
    }
    latest <- last_value(d[startsWith(d$estimates, "DHIS2"), , drop = FALSE])
    survey <- last_value(d[startsWith(d$estimates, "Survey"), , drop = FALSE])
    if (!is.null(latest)) out[[paste0(ind, "_latest")]] <- paste0(format(round(latest$value, 1), nsmall = 1), "%")
    if (!is.null(survey)) out[[paste0(ind, "_survey")]] <- paste0(format(round(survey$value, 1), nsmall = 1), "% (", survey$year, ")")
  }
  out
}

#' The report context of a dataset
#'
#' What the report builder (datasuite.ui) needs from a Countdown dataset: its charts and tables drawn in the report's
#' look, the pictures and templates kept in it, its saved chart options, its fields (country, coverage values), years,
#' regions and flag. Every report function accepts the dataset itself too ([datasuite.ui::as_report_context()]).
#' @param cache A [CacheConnection].
#' @return A report context ([datasuite.ui::report_context()]).
#' @export
cd_report_context <- function(cache) {
  datasuite.ui::report_context(
    draw = function(block, i18n) {
      value <- .rb_draw(cache, block, i18n)
      if (inherits(value, "ggplot")) value <- value + cd_report_theme()
      value
    },
    asset_get = function(id) cache$report_assets[[id]],
    asset_set = function(id, value) cache$set_report_asset(id, value),
    chart_options = function() cache$chart_options %||% list(),
    fields = function(project, lang) .cd_report_field_values(cache),
    years = function() cache$data_years,
    regions = function() cache$subnational_regions$adminlevel_1,
    flag = function() datasuite.ui::report_flag_file(tryCatch(cache$country_iso, error = function(e) NULL))
  )
}

#' @exportS3Method datasuite.ui::as_report_context
as_report_context.CacheConnection <- function(x, ...) cd_report_context(x)

# What Countdown's reports offer, registered with the builder when the package loads
.cd_register_reports <- function() {
  datasuite.ui::report_register(
    themes = list(countdown = .cd_report_theme_countdown),
    default_theme = "countdown",
    cover = list(kicker = "Countdown to 2030 \u00b7 {country}"),
    # the kinds of this app's indicator group, with "analysis" (the group's analysis indicators) filled in
    kinds = function() {
      analysis <- tryCatch(get_analysis_indicators(), error = function(e) character())
      lapply(report_block_kinds(getOption("cd2030.app_group", get_selected_group())), function(k) {
        if (identical(k$indicators, "analysis")) k$indicators <- analysis
        k
      })
    },
    presets = function(lang) report_presets(lang, getOption("cd2030.app_group", get_selected_group())),
    indicator_name = function(indicator, i18n) .rb_ind_name(i18n, indicator),
    fields = .cd_report_field_catalog(),
    # a chart is known by the data it draws, so the screen and a report find its options by the same id
    chart_id = function(data, plot) cd_chart_id(data) %||% datasuite.ui::cd_chart_type(plot)
  )
}
