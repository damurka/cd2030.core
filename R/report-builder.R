# The report builder: a report is a list of blocks (headings, text, notes, page breaks, charts and tables) plus a design.
# Charts and tables are described by what to draw (kind, indicator, level, region, year), never stored as pictures, so a
# report is drawn from the loaded data every time it is exported. The app's builder edits the block list; export_report()
# writes it as Word or PDF. Reports are kept in the dataset (CacheConnection$set_report_project()).
#
# Block fields:
#   id, type = "heading" | "paragraph" | "note" | "pagebreak" | "chart" | "table" | "image"
#   heading: text, level (1 or 2)
#   paragraph / note: text (formatted, see R/report-text.R), align = "left" | "center" | "right" | "justify",
#                     list = "bullet" | "number" (one item per line)
#   chart / table: kind (see report_block_kinds()), indicator, admin_level, region, year, variant,
#                  size = "full" | "half" | "third", title (overrides the drawn title), caption (FALSE hides the caption),
#                  options (chart options for this chart only, as the chart customize panel gives them)
#   image: src (a data URL), ratio (height / width), size = "full" | "half" | "third", width (percent of its column),
#          align, shape = "rect" | "rounded" | "circle", border (TRUE / FALSE), caption, alt
#   canvas: a free-layout page (see R/report-canvas.R): h (height of its area, inches), items placed like a slide's
#
# Consecutive half-width (or third-width) charts and images share a row. The design (fonts, colours, page) is R/report-theme.R; writing
# the files is R/report-export.R.

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

# One kind. `groups`: the indicator groups it is for. `tall`: drawn taller than wide charts (maps, charts faceted by
# district), see report_block_size().
.rb_kind <- function(type, group, label, indicators = NULL, levels = NULL, variants = NULL, year = FALSE, regional = FALSE,
                     groups = c("rmncah", "vaccine"), tall = FALSE) {
  list(type = type, group = group, label = label, indicators = indicators, levels = levels, variants = variants, year = year,
       regional = regional, groups = groups, tall = tall)
}

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

# A translated string, or the English fallback when there is no translation (or no i18n)
.rb_t <- function(i18n, key, fallback = key) {
  if (is.null(i18n)) return(fallback)
  value <- tryCatch(i18n$t(key), error = function(e) key)
  if (is.null(value) || identical(value, key) || !nzchar(value)) fallback else value
}

.rb_ind_name <- function(i18n, indicator) .rb_t(i18n, paste0("opt_", indicator), indicator)

# ---- drawing one block ---------------------------------------------------------------------------------------------

#' Draw one chart or table of a report
#'
#' @param cache A [CacheConnection] with data loaded.
#' @param block A chart or table block (see the top of this file for its fields). A `region` of `"@report"` is the
#'   report's region: the caller puts it in first ([report_resolve_block()]).
#' @param i18n An object with a `t(key)` method for translated labels, or `NULL` for English.
#' @param design The report's design: its palette colours the chart's series (see [report_themes()]). `NULL` keeps the
#'   chart's own colours.
#'
#' @return `list(type = "plot", value = <ggplot>)`, `list(type = "table", value = <flextable>)`, or
#'   `list(type = "error", message = <text>)` when it cannot be drawn with this dataset.
#' @export
render_report_block <- function(cache, block, i18n = NULL, design = NULL) {
  tryCatch(
    {
      value <- .rb_draw(cache, block, i18n)
      if (inherits(value, "ggplot")) {
        value <- value + cd_report_theme()
        # a title typed for this chart ({chart_indicator} and {chart_year} are this chart's)
        if (!is.null(block$title) && nzchar(block$title)) value <- value + ggplot2::labs(title = report_chart_fields(list(block), cache, i18n)[[1]]$title)
        if (isFALSE(block$caption)) value <- value + ggplot2::labs(caption = NULL)
        # the theme's palette, then what was set for this chart in the builder
        palette <- if (!is.null(design)) .rb_palette_options(value, .rb_design(design))
        own <- .rb_block_options(block$options)
        # a chart on a slide: its text at a size read on a slide (.rb_slide_text_options()), under what was set for it
        box <- .rb_box(block)
        slide <- if (!is.null(box)) .rb_slide_text_options(value, box)
        if (length(palette) || length(slide) || length(own)) value <- apply_chart_options(value, merge_chart_options(palette, slide, own))
        # a ggplot is built only when it is printed: build it now, so a chart that cannot be drawn says so here
        ggplot2::ggplot_build(value)
        list(type = "plot", value = value)
      } else if (inherits(value, "flextable")) {
        list(type = "table", value = value)
      } else {
        list(type = "error", message = "This block did not produce a chart or table.")
      }
    },
    error = function(e) list(type = "error", message = conditionMessage(e))
  )
}

# The text of a chart on a slide, as PowerPoint sizes a chart's text: 12 pt on a wide chart (8 in and wider), down to 9 pt
# on a narrow one (3 in) and never smaller (a chart is drawn at its box's size on a slide, so these are the sizes on the slide); the title
# 4 pt larger, a source note 1 pt smaller (at least 9 pt), text drawn on the chart 2 pt smaller (at least 8 pt). So that
# it fits the box: the title, subtitle and source note wrap at the box's width, a legend too wide for it is laid out in
# columns (rows of entries), and category labels that do not fit side by side are turned upright. What the user set
# for the chart replaces these (merged after them).
.rb_slide_text_options <- function(p, box) {
  s <- round(min(12, max(9, 9 + (box[1] - 3) * 3 / 5)), 1)
  opts <- list(title_size = s + 4, subtitle_size = s, caption_size = max(9, s - 1), x_title_size = s, y_title_size = s,
               x_text_size = s, y_text_size = s, legend_title_size = s, legend_text_size = s, strip_text_size = s,
               label_size = max(8, s - 2), title_wrap = max(15, floor(box[1] * 72 / ((s + 4) * 0.52))),
               legend_key_size = round(s * 0.45, 1))
  built <- tryCatch(ggplot2::ggplot_build(p), error = function(e) NULL)
  if (is.null(built)) return(do.call(cd_chart_options, opts))
  # text of `n` characters at this size, in inches
  inches <- function(n) n * s * 0.55 / 72
  # the legend: its entries in one row, else in as many columns as fit
  entries <- unlist(lapply(c("fill", "colour", "shape", "linetype"), function(a) {
    sc <- built$plot$scales$get_scales(a)
    if (is.null(sc) || identical(sc$guide, "none")) return(NULL)
    tryCatch(as.character(unlist(sc$get_labels())), error = function(e) NULL)
  }))
  entries <- unique(entries[!is.na(entries) & nzchar(entries)])
  if (length(entries) > 1) {
    each <- inches(nchar(entries)) + 0.35
    if (sum(each) > 0.95 * box[1]) opts$legend_ncol <- max(1, floor(0.95 * box[1] / max(each)))
  }
  # the horizontal axis's labels: their width at this size against the chart's
  labels <- tryCatch(if (inherits(p$coordinates, "CoordFlip")) NULL else built$layout$panel_params[[1]]$x$get_labels(),
                     error = function(e) NULL)
  labels <- as.character(unlist(labels))
  labels <- labels[!is.na(labels)]
  panels <- tryCatch(max(1, length(unique(built$layout$layout$COL))), error = function(e) 1)
  if (length(labels) > 1) {
    wide <- inches(sum(nchar(labels))) + length(labels) * s * 0.5 / 72
    if (wide > 0.85 * box[1] / panels) opts$x_text_angle <- 90
  }
  do.call(cd_chart_options, opts)
}

#' A block as it is drawn in a report
#'
#' Puts the report's region in a block that asks for it (`region = "@report"`). A report without a region is a
#' national report: such a block is then drawn for the whole country (or asks for a region when it needs one).
#' @param block A block.
#' @param project The report (its `region`; `NULL` or `""`: national).
#' @param regions Not used; kept for older callers.
#' @return The block.
#' @export
report_resolve_block <- function(block, project, regions = NULL) {
  if (identical(block$region, "@report")) {
    region <- project$region
    block$region <- if (is.character(region) && length(region) == 1 && nzchar(region)) region else NULL
  }
  block
}

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

# ---- sizes ---------------------------------------------------------------------------------------------------------

#' The size a chart or image block is shown at, in inches
#'
#' Worked out from the page (see [report_page()]): a full-width block spans the text, a half-width one half of it.
#' Shared by the builder's previews and by the exported files, so the page on screen and the file agree. A block on a
#' slide carries its box, `box = c(width, height)` in inches (see [report_project_blocks()]): it is drawn at that size.
#'
#' @param block A chart or image block.
#' @param design The report's design (`NULL`: the default page).
#' @return `c(width, height)` in inches.
#' @export
report_block_size <- function(block, design = NULL) {
  box <- .rb_box(block)
  if (!is.null(box)) return(box)
  page <- report_page(design %||% report_default_design())
  full <- page$text_width - 0.27
  size <- block$size %||% "full"
  w <- switch(size, half = (full - 0.2) / 2, third = (full - 0.4) / 3, full)
  if (identical(block$type, "image")) {
    w <- w * min(100, max(5, as.numeric(block$width %||% 100))) / 100
    h <- w * .rb_image_ratio(block)
    cap <- page$text_height * 0.8
    if (h > cap) { w <- w * cap / h; h <- cap }
    return(round(c(w, h), 3))
  }
  tall <- isTRUE(.rb_all_kinds()[[block$kind %||% ""]]$tall)
  ratio <- switch(size, half = if (tall) 1.143 else 0.825, third = if (tall) 1 else 0.7, if (tall) 0.8 else 0.569)
  # wide pages (chartbook, poster) would make very tall charts: the height stops at what an A4 page gives
  h <- min(w * ratio, if (tall) 5.2 else 3.7, page$text_height * 0.8)
  round(c(w, h), 3)
}

# A slide item's box, c(width, height) in inches, or NULL when the block is not on a slide
.rb_box <- function(block) {
  box <- suppressWarnings(as.numeric(unlist(block$box)))
  if (length(box) == 2 && all(is.finite(box)) && all(box > 0)) box else NULL
}

# The size a chart or image is shown at on the page (inches). A picture's is report_block_size(); a chart is drawn at
# report_block_size() and then treated as a picture of that shape: its width (percent of its column), crop and turn
# change the size it is shown at, as in the editor. Unformatted, the two are the same.
.rb_shown_size <- function(block, design = NULL) {
  size <- report_block_size(block, design)
  if (!identical(block$type, "chart")) return(size)
  block$type <- "image"
  block$ratio <- size[2] / size[1]
  report_block_size(block, design)
}

# Whether a chart is formatted as a picture (its drawing is then made into one and changed as pictures are)
.rb_chart_pictured <- function(block) {
  identical(block$type, "chart") && (
    any(.rb_image_crop(block) > 0) || as.integer(block$rotate %||% 0) %% 360 != 0 || isTRUE(block$flip_h) || isTRUE(block$flip_v) ||
      !(block$shape %||% "rect") %in% "rect" || isTRUE(block$border) || isTRUE(block$greyscale) ||
      !(as.numeric(block$brightness %||% 0) %in% 0) || !(as.numeric(block$contrast %||% 0) %in% 0) || nzchar(.rb_pic_style_of(block)))
}

# An image block's picture once turned, cropped and stretched: its height over its width (a circle is square before
# it is stretched)
.rb_image_ratio <- function(block) {
  if (identical(block$shape, "circle")) return(.rb_image_stretch(block))
  ratio <- suppressWarnings(as.numeric(block$ratio %||% 0.6))
  if (length(ratio) != 1 || !is.finite(ratio) || ratio <= 0) ratio <- 0.6
  if (as.integer(block$rotate %||% 0) %% 180 == 90) ratio <- 1 / ratio
  crop <- .rb_image_crop(block)
  ratio * (1 - crop[1] - crop[3]) / (1 - crop[2] - crop[4]) * .rb_image_stretch(block)
}

# How much a picture is stretched by a side handle: its height over the height its shape gives (1: not stretched)
.rb_image_stretch <- function(block) {
  s <- suppressWarnings(as.numeric(block$stretch %||% 1))
  if (length(s) != 1 || !is.finite(s) || s <= 0) return(1)
  min(10, max(0.1, s))
}

# How much of each side of a picture is cut off, as fractions: top, right, bottom, left (a tenth is always left)
.rb_image_crop <- function(block) {
  crop <- suppressWarnings(as.numeric(unlist(block$crop %||% list())))
  if (length(crop) != 4 || anyNA(crop)) return(c(0, 0, 0, 0))
  crop <- pmin(pmax(crop, 0), 90) / 100
  if (crop[1] + crop[3] > 0.9) crop[c(1, 3)] <- crop[c(1, 3)] * 0.9 / (crop[1] + crop[3])
  if (crop[2] + crop[4] > 0.9) crop[c(2, 4)] <- crop[c(2, 4)] * 0.9 / (crop[2] + crop[4])
  crop
}

#' Draw a chart block to a PNG file
#'
#' Charts are written as SVG (vector: sharp at any size, on screen, printed or in the PDF Word makes) when the
#' \pkg{svglite} package is installed and `file` ends in `.svg`; otherwise as PNG at `dpi`.
#'
#' @param rendered The result of [render_report_block()] with `type = "plot"`.
#' @param block The block (for its size).
#' @param file Path of the file to write: `.svg` or `.png`.
#' @param dpi Resolution of a PNG.
#' @param design The report's design (for the page size).
#' @return `file`, invisibly.
#' @export
save_report_chart <- function(rendered, block, file, dpi = 200, design = NULL) {
  # a narrow chart is drawn somewhat larger and shown smaller, so its legend and labels fit; not by more than 40%, so its
  # text stays readable once shrunk. A chart on a slide is drawn at its box's size, as it is in the slide file.
  shown <- report_block_size(block, design)
  size <- if (!is.null(.rb_box(block))) shown else shown * min(1.4, max(1, 4.6 / shown[1]))
  if (grepl("\\.svg$", file)) {
    svglite::svglite(file, width = size[1], height = size[2])
    on.exit(grDevices::dev.off(), add = TRUE)
    print(rendered$value)
    return(invisible(file))
  }
  draw <- function(device) {
    device(file, width = size[1], height = size[2], units = "in", res = dpi)
    on.exit(grDevices::dev.off(), add = TRUE)
    print(rendered$value)
  }
  # ragg draws nothing, or only some letters, without an error, for some sizes of the fonts that carry bitmap versions of
  # their letters (Calibri, Cambria and the other ClearType fonts); the cairo device draws them
  cairo <- function(...) grDevices::png(..., type = "cairo")
  family <- tryCatch(ggplot2::calc_element("text", ggplot2::theme_grey() + rendered$value$theme)$family, error = function(e) "")
  bitmap_font <- isTRUE(family %in% c("Calibri", "Cambria", "Candara", "Consolas", "Constantia", "Corbel"))
  if (bitmap_font && isTRUE(capabilities("cairo"))) {
    draw(cairo)
  } else if (requireNamespace("ragg", quietly = TRUE)) {
    draw(ragg::agg_png)
    if (.rb_png_blank(file) && isTRUE(capabilities("cairo"))) draw(cairo)
  } else {
    draw(grDevices::png)
  }
  invisible(file)
}

# Whether a PNG is one flat colour (nothing was drawn)
.rb_png_blank <- function(file) {
  if (requireNamespace("png", quietly = TRUE)) {
    px <- tryCatch(png::readPNG(file), error = function(e) NULL)
    if (!is.null(px)) return(length(unique(as.vector(px))) <= 1)
  }
  isTRUE(file.info(file)$size < 3000)
}

# ---- standard reports ----------------------------------------------------------------------------------------------
#
# A standard report is the Countdown report of one analysis section (and the synthesis chartbook and the sub-national
# one-pager), rebuilt as blocks. Each is in its own file, R/report-preset-<id>.R, as a function .rb_preset_<id>(group)
# returning list(name, description, blocks, design_patch, cover_patch); `group` is the indicator group ("rmncah",
# "vaccine"). A slide deck returns kind = "deck" and `slides` instead of `blocks` (see R/report-deck.R). Its texts are written in the app's three languages with .rb_tx(en, fr, pt), and report_presets(lang) makes
# them in one. A file can also add chart kinds: a function .rb_kinds_<name>() returning more entries of
# report_block_kinds(), and for each kind a function .rb_draw_<kind>(cache, block, i18n) that draws it.

#' Text in the app's languages
#'
#' @param en,fr,pt The text in English, French and Portuguese (French and Portuguese default to the English).
#' @return An object of class `rb_tx`.
#' @noRd
.rb_tx <- function(en, fr = en, pt = en) structure(list(en = en, fr = fr, pt = pt), class = "rb_tx")

# Every .rb_tx() in `x` (a block, a list of blocks, a cover...) replaced by its text in `lang`
.rb_in <- function(x, lang = "en") {
  if (inherits(x, "rb_tx")) return(x[[lang]] %||% x$en)
  if (is.list(x)) {
    out <- lapply(x, .rb_in, lang = lang)
    attributes(out) <- attributes(x)
    return(out)
  }
  x
}

.rb_heading <- function(text, level = 1) list(type = "heading", text = text, level = level)
.rb_text <- function(text) list(type = "paragraph", text = text)
.rb_note <- function(text) list(type = "note", text = text)
.rb_break <- function() list(type = "pagebreak")
.rb_chart <- function(kind, indicator = NULL, admin_level = "national", size = "full", variant = NULL, type = "chart", region = NULL,
                      year = NULL, title = NULL) {
  Filter(Negate(is.null), list(type = type, kind = kind, indicator = indicator, admin_level = admin_level, size = size, variant = variant,
                               region = region, year = year, title = title, caption = TRUE))
}
.rb_table <- function(kind, ...) .rb_chart(kind, ..., type = "table", admin_level = NULL)

# A notes box of questions for the analyst ("Interpretations"), one per line. Each question is a string or a .rb_tx().
.rb_questions <- function(..., title = .rb_tx("Interpretations", "Interpr\u00e9tations", "Interpreta\u00e7\u00f5es")) {
  items <- list(...)
  dot <- intToUtf8(0x2022)
  text <- lapply(c(en = "en", fr = "fr", pt = "pt"), function(lang) {
    lines <- vapply(items, function(q) .rb_in(q, lang), character(1))
    paste0("<b>", .rb_in(title, lang), "</b><br>", paste0(dot, " ", lines, collapse = "<br>"))
  })
  .rb_note(do.call(.rb_tx, unname(text)))
}

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

#' Every block of a report
#'
#' A document's blocks, or every item's block of a slide deck, in order, so a caller can count, check or draw them
#' the same way for both. A slide item's block gets the item's id and its box (`box = c(width, height)`, inches), which
#' [report_block_size()] draws it at. A document's free-layout page (a block of type `"canvas"`, whose `items` are
#' placed like a slide's) is given as its items' blocks, in the same way; the canvas block itself is not in the list.
#' @param project A report (`kind = "deck"` for a slide deck; anything else is a document).
#' @return A list of blocks.
#' @export
report_project_blocks <- function(project) {
  item_block <- function(item) {
    b <- item$block %||% list()
    b$id <- item$id %||% b$id
    b$box <- c(as.numeric(item$w %||% 1), as.numeric(item$h %||% 1))
    b
  }
  if (!identical(project$kind, "deck")) {
    out <- list()
    for (b in project$blocks %||% list()) {
      if (identical(b$type, "canvas")) {
        for (item in b$items %||% list()) out[[length(out) + 1]] <- item_block(item)
      } else {
        out[[length(out) + 1]] <- b
      }
    }
    return(out)
  }
  out <- list()
  for (slide in project$slides %||% list()) {
    for (item in slide$items %||% list()) out[[length(out) + 1]] <- item_block(item)
  }
  out
}
