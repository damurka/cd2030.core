# More chart kinds for the report builder: the charts of the analysis pages that no standard report uses, so every chart
# the app draws can be put in a report. Each kind is drawn by .rb_draw_<kind>() from the loaded data, with the defaults
# the analysis pages start from (the latest year, the report's region or the whole country). See the top of
# R/report-builder.R for how kinds are listed and drawn.

.rb_kinds_extra <- function() {
  k <- .rb_kind
  # the indicators of the data quality checks: those of the dataset's indicator group
  dq_indicators <- tryCatch(unname(get_all_indicators()), error = function(e) character())
  if (!length(dq_indicators)) dq_indicators <- c("anc1", "anc4", "ideliv", "instlivebirths", "penta1", "penta3", "measles1", "bcg")
  units <- c("adminlevel_1", "district")
  vaccine <- identical(tryCatch(get_selected_group(), error = function(e) NULL), "vaccine")
  list(
    # data quality
    dq_reporting_units = k("chart", "quality", "Reporting rate by region or district", c("anc", "idelv", "vacc", "opd"), units,
                           variants = c(heat_map = "Heat map", bar = "Bar chart"), regional = TRUE, tall = TRUE),
    dq_completeness_units = k("chart", "quality", "Completeness of reporting by region or district", dq_indicators, units,
                              variants = c(heat_map = "Heat map", all_indicators = "All indicators", trend = "Trend"),
                              regional = TRUE, tall = TRUE),
    dq_completeness_districts = k("chart", "quality", "Districts with complete data", dq_indicators, regional = TRUE),
    dq_outliers_units = k("chart", "quality", "Values that are not extreme outliers", dq_indicators, units,
                          variants = c(heat_map = "Heat map", all_indicators = "All indicators", by_unit = "By region or district",
                                       by_indicator = "By indicator"),
                          regional = TRUE, tall = TRUE),
    dq_outlier_trend = k("chart", "quality", "Monthly values and outliers in a district", dq_indicators, year = TRUE, regional = TRUE),
    # national and sub-national coverage
    # zero-dose, under-immunized and dropout coverage are worked out for vaccine datasets only
    indicator_coverage = k("chart", "national", "Coverage indicators by year (DHIS2)",
                           variants = c(anc = "ANC and delivery", immunization = "Immunization",
                                        if (vaccine) c(delivery = "Zero-dose and dropout"))),
    continuum_gap = k("chart", "national", "Continuum of care: facility and survey compared",
                      variants = c(maternal = "Maternal", child = "Child"), groups = "rmncah"),
    continuum_units = k("chart", "subnational", "Continuum of care: latest coverage by region",
                        variants = c(maternal = "Maternal", child = "Child"), groups = "rmncah", tall = TRUE),
    # national only: the sub-national model cannot be fitted yet (generate_bayes_model() selects a `source` column that
    # the regional coverage has as source.x and source.y)
    bayes_coverage = k("chart", "national", "Bayesian coverage model estimates", c("anc4", "anc_1trimester", "ideliv", "measles1", "penta3"),
                       groups = "rmncah"),
    # denominators
    derived_coverage_trend = k("chart", "denominators", "Coverage over time by denominator", "analysis", regional = TRUE),
    # service utilization
    su_region = k("chart", "utilization", "Service use by region", variants = c(opd = "Outpatient (OPD)", ipd = "Inpatient (IPD)"),
                  groups = "rmncah", tall = TRUE),
    # health system
    hs_comparison = k("chart", "health_system", "Service use by health system inputs, by region",
                      variants = c(ratio_opd_u5_hstaff = "OPD under 5 and health workers", ratio_ipd_u5_hos = "IPD under 5 and hospitals",
                                   ratio_ipd_u5_bed = "IPD under 5 and beds"), groups = "rmncah"),
    hs_national = k("chart", "health_system", "Health system scores and densities (national)",
                    variants = c(performance = "Performance scores", density = "Densities"), groups = "rmncah")
  )
}

# ---- helpers ----

# `text` with each {name} replaced by the value given
.rbx_fill <- function(text, ...) {
  values <- list(...)
  for (name in names(values)) text <- gsub(paste0("{", name, "}"), values[[name]], text, fixed = TRUE)
  text
}

# The denominators' names when there is no translation
.rbx_denominator_names <- c(dhis2 = "DHIS2", un = "UN", anc1 = "ANC1", penta1 = "Penta1", anc1derived = "ANC1 population growth",
                            penta1derived = "Penta1 population growth")

# The block's region (an admin level 1 name), NULL for the whole country
.rbx_region <- function(b) {
  region <- b$region
  if (is.null(region) || identical(region, "@report") || !is.character(region) || !nzchar(region[1])) NULL else region[1]
}

# The level a data quality chart is drawn for: its districts when a region is chosen, else regions or districts
.rbx_units_level <- function(b) if (identical(b$admin_level, "district")) "district" else "adminlevel_1"

# The name of the units a chart is drawn by (translated): regions, or districts when a region is chosen
.rbx_units_name <- function(i18n, level, region) {
  if (!is.null(region) || identical(level, "district")) .rb_t(i18n, "opt_district", "District") else .rb_t(i18n, "opt_adminlevel_1", "Region")
}

# The block's indicator when it is one of `choices`, else the first of them (or `default` when it is one)
.rbx_pick <- function(value, choices, default = choices[[1]]) {
  if (is.character(value) && length(value) == 1 && value %in% choices) value else if (default %in% choices) default else choices[[1]]
}

.rbx_dq_indicator <- function(b) {
  all <- tryCatch(unname(get_all_indicators()), error = function(e) character())
  if (!length(all)) cd_abort(c("x" = "No indicators for this dataset."))
  .rbx_pick(b$indicator, all, if ("anc4" %in% all) "anc4" else "penta3")
}

# ---- data quality ----

# Average reporting rate of one service, by region (or district) and year: a heat map or bars
.rb_draw_dq_reporting_units <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  region <- .rbx_region(b)
  level <- .rbx_units_level(b)
  service <- .rbx_pick(b$indicator, c("anc", "idelv", "vacc", "opd"), if (identical(get_selected_group(), "vaccine")) "vacc" else "anc")
  type <- if (identical(b$variant, "bar")) "bar" else "heat_map"
  d <- if (is.null(region)) cache$calculate_reporting_rate(level) else cache$calculate_reporting_rate("adminlevel_1", region)
  column <- paste0(service, "_rr")
  if (!column %in% names(d)) cd_abort(c("x" = "This dataset has no reporting rate for {service}."))
  indicator <- t(paste0("opt_", service), c(anc = "ANC", idelv = "Institutional delivery", vacc = "Vaccination", opd = "OPD")[[service]])
  admin_level <- .rbx_units_name(i18n, level, region)
  title <- if (is.null(region)) {
    t("plt_title_rr_heatmap", "{admin_level} reporting rate for {indicator} by year")
  } else {
    t("plt_title_rr_heatmap_region", "{admin_level} reporting rate for {indicator} by year in {region_name}")
  }
  plot(d, plot_type = type, indicator = column, threshold = cache$performance_threshold %||% 90,
       title = .rbx_fill(title, admin_level = admin_level, indicator = indicator, region_name = region %||% ""),
       x_axis = if (type == "bar") t("title_global_year", "Year") else admin_level,
       y_axis = if (type == "bar") t("title_rr_main", "Reporting rate") else t("title_global_year", "Year"),
       legend = .rbx_fill(t("lbl_leg_rr_heatmap", "{indicator} reporting rate"), indicator = indicator))
}

# Completeness of reporting (percent of values not missing), by region (or district): for one indicator by year, the
# average for every indicator, or the trend of one indicator
.rb_draw_dq_completeness_units <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  region <- .rbx_region(b)
  level <- .rbx_units_level(b)
  variant <- .rbx_pick(b$variant, c("heat_map", "all_indicators", "trend"))
  ind <- .rbx_dq_indicator(b)
  indicator <- .rb_ind_name(i18n, ind)
  admin_level <- .rbx_units_name(i18n, level, region)
  d <- if (is.null(region)) cache$calculate_completeness_summary(level) else cache$calculate_completeness_summary("adminlevel_1", region)
  fill <- function(text) .rbx_fill(text, admin_level = admin_level, indicator = indicator, region = region %||% "")
  suffix <- if (is.null(region)) "" else "_reg"
  if (variant == "trend") {
    # the trend shows the units with missing values only
    if (!any(d[[paste0("mis_", ind)]] < 100, na.rm = TRUE)) cd_abort(c("i" = "{indicator} has no missing values: there is no trend to show."))
    plot(d, plot_type = "trend", indicator = ind,
         title = fill(t("plt_title_complete_trend", "Trend in reporting completeness (%) for {indicator} by {admin_level}")),
         x_axis = t("title_global_year", "Year"), y_axis = t("lbl_axis_y_complete_trend", "Completeness (%)"))
  } else if (variant == "all_indicators") {
    title <- if (is.null(region)) t("plt_title_complete_heatmap_all", "Average reporting missingness (%) by {admin_level}")
             else t("plt_title_complete_heatmap_all_reg", "Average reporting missingness (%) by {admin_level} in {region}")
    plot(d, plot_type = "heat_map", indicator = NULL, title = fill(title), x_axis = admin_level,
         y_axis = t("title_global_indicator", "Indicator"), legend = t("lbl_leg_complete_heatmap", "Missingness (%)"))
  } else {
    title <- if (is.null(region)) t("plt_title_complete_heatmap_one", "Proportion of missing reports (%) for {indicator} by year and {admin_level}")
             else t("plt_title_complete_heatmap_one_reg", "Proportion of missing reports (%) for {indicator} by year and {admin_level} in {region}")
    plot(d, plot_type = "heat_map", indicator = ind, title = fill(title), x_axis = admin_level,
         y_axis = t("title_global_year", "Year"), legend = t("lbl_leg_complete_heatmap", "Missingness (%)"))
  }
}

# Percent of districts with no missing values for one indicator, by year
.rb_draw_dq_completeness_districts <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  region <- .rbx_region(b)
  ind <- .rbx_dq_indicator(b)
  d <- if (is.null(region)) cache$district_completeness else cache$calculate_district_completeness_summary(region)
  if (!paste0("mis_", ind) %in% names(d)) cd_abort(c("x" = "No completeness figures for {ind}."))
  title <- .rbx_fill(t("plt_title_complete_district_plot", "Percent of districts with complete data for {indicator}"),
                     indicator = .rb_ind_name(i18n, ind))
  plot(d, indicator = ind, title = paste0(title, if (!is.null(region)) paste0(": ", region) else ""),
       x_axis = t("title_global_year", "Year"), y_axis = t("lbl_axis_y_complete_trend", "Completeness (%)"))
}

# Percent of monthly values that are not extreme outliers, by region (or district): for one indicator by year, the
# average for every indicator, bars by year for each unit, or bars by year for each indicator
.rb_draw_dq_outliers_units <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  region <- .rbx_region(b)
  level <- .rbx_units_level(b)
  variant <- .rbx_pick(b$variant, c("heat_map", "all_indicators", "by_unit", "by_indicator"))
  ind <- .rbx_dq_indicator(b)
  indicator <- .rb_ind_name(i18n, ind)
  admin_level <- .rbx_units_name(i18n, level, region)
  d <- if (is.null(region)) cache$calculate_outliers_summary(level) else cache$calculate_outliers_summary("adminlevel_1", region)
  fill <- function(text) .rbx_fill(text, admin_level = admin_level, indicator = indicator)
  where <- if (!is.null(region)) paste0(": ", region) else ""
  legend <- t("lbl_leg_outlier", "Percent non-outliers (%)")
  threshold <- cache$performance_threshold %||% 90
  switch(
    variant,
    heat_map = plot(d, selection_type = "heat_map", indicator = ind, threshold = threshold,
                    title = paste0(fill(t("plt_title_outlier_heatmap_one", "Percent non-outliers for {indicator} by year and {admin_level}")), where),
                    x_axis = admin_level, y_axis = t("title_global_year", "Year"), legend = legend),
    all_indicators = plot(d, selection_type = "heat_map", indicator = NULL, threshold = threshold,
                          title = paste0(fill(t("plt_title_outlier_heatmap_all", "Average percent non-outliers by {admin_level}")), where),
                          x_axis = admin_level, y_axis = t("title_global_indicator", "Indicator"), legend = legend),
    by_unit = plot(d, selection_type = "region", indicator = ind, threshold = threshold,
                   title = paste0(fill(t("plt_title_outlier_region", "Percent non-outliers by year and {admin_level}")), " - ", indicator, where),
                   x_axis = t("title_global_year", "Year"), y_axis = legend, legend = legend),
    by_indicator = plot(d, selection_type = "indicator", threshold = threshold,
                        title = paste0(t("plt_title_outlier_indicator", "Percent non-outliers by year and indicator"), where),
                        x_axis = t("title_global_year", "Year"), y_axis = legend, legend = legend)
  )
}

# One indicator's monthly values in one district, with the median, the outlier bounds and the outliers. The district is
# the one with the most outliers for the indicator in the year (in the report's region, when it has one).
.rb_draw_dq_outlier_trend <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  region <- .rbx_region(b)
  ind <- .rbx_dq_indicator(b)
  years <- cache$data_years
  year <- suppressWarnings(as.integer(b$year %||% if (length(years)) max(years) else NA))
  d <- cache$list_outlier_units
  flag <- paste0(ind, "_outlier5std")
  if (!flag %in% names(d)) cd_abort(c("x" = "No outlier checks for {ind}."))
  pool <- d[d$year == year, , drop = FALSE]
  if (!is.null(region)) pool <- pool[pool$adminlevel_1 == region, , drop = FALSE]
  if (!nrow(pool)) cd_abort(c("x" = "No monthly values for {year}."))
  counts <- tapply(as.numeric(pool[[flag]]), pool$district, function(x) sum(x, na.rm = TRUE))
  district <- names(counts)[which.max(counts)]
  indicator <- .rb_ind_name(i18n, ind)
  plot(d, indicator = ind, region = district, year = year,
       title = .rbx_fill(t("plt_title_outlier_trend_year", "{indicator_name} trend for {region_name} in {year_val}"),
                         indicator_name = indicator, region_name = district, year_val = year),
       x_axis = t("lbl_axis_x_outlier_trend", "Months"), y_axis = indicator, legend = t("lbl_leg_outlier_trend", "Series"),
       label = c(reported = t("lbl_outlier_series_reported", "Reported value"), median = t("lbl_outlier_series_median", "Median"),
                 bounds = t("lbl_outlier_series_bounds", "Median \u00b1 5 MAD"), outliers = t("lbl_outlier_series_outliers", "Outliers")))
}

# ---- coverage ----

# National coverage of a set of indicators by year, with the denominator chosen for them (the indicator coverage chart)
.rb_draw_indicator_coverage <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  set <- .rbx_pick(b$variant, c("anc", "immunization", "delivery"))
  inds <- switch(set,
                 anc = c("anc1", "instlivebirths"),
                 delivery = c("zerodose", "undervax", "dropout_penta13", "dropout_measles12"),
                 immunization = c("penta1", "penta3", "opv3", "ipv1", "bcg", "measles1", "measles2"))
  fallbacks <- c(anc1 = "ANC1", instlivebirths = "Institutional live births", zerodose = "Zero-dose children (Penta1)",
                 undervax = "Under-immunized children", dropout_penta13 = "Penta1 to Penta3 dropout", dropout_measles12 = "Measles1 to Measles2 dropout",
                 penta1 = "Penta1", penta3 = "Penta3", opv3 = "OPV3", ipv1 = "IPV1", bcg = "BCG", measles1 = "Measles1", measles2 = "Measles2")
  denom <- if (set == "anc") cache$maternal_denominator else cache$denominator
  if (is.null(denom)) cd_abort(c("x" = "Choose the denominators first."))
  d <- cache$indicator_coverage_national
  if (is.null(d)) cd_abort(c("x" = "No coverage for this dataset."))
  cols <- paste0("cov_", inds, "_", denom)
  keep <- vapply(cols, function(col) col %in% names(d) && any(!is.na(d[[col]])), logical(1))
  if (!any(keep)) cd_abort(c("x" = "This dataset has no coverage for these indicators."))
  labels <- vapply(inds[keep], function(i) t(paste0("opt_", i), fallbacks[[i]]), character(1))
  set_name <- switch(set, anc = t("lbl_rb_var_anc", "ANC and delivery"), immunization = t("lbl_rb_var_immunization", "Immunization"),
                     delivery = t("lbl_rb_var_delivery", "Zero-dose and dropout"))
  title <- .rbx_fill(t("plt_rbx_indicator_coverage", "{set} coverage indicators, based on the {denominator} denominator"),
                     set = set_name, denominator = t(paste0("opt_", denom), unname(.rbx_denominator_names[denom] %|% denom)))
  plot_line_graph(d, x = "year", y_vars = cols[keep], legend_labels = unname(labels), title = title,
                  y_axis = t("opt_coverage", "Coverage"), x_axis = t("title_global_year", "Year")) +
    ggplot2::labs(colour = NULL)
}

.rbx_continuum_labels <- function(i18n, d) {
  inds <- levels(d$indicator) %||% unique(as.character(d$indicator))
  stats::setNames(lapply(inds, function(i) .rb_ind_name(i18n, i)), inds)
}

# The latest facility coverage minus the latest survey coverage, for the maternal or child continuum of care
.rb_draw_continuum_gap <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  type <- if (identical(b$variant, "child")) "child" else "maternal"
  d <- cache$generate_coverage_data("national", type)
  if (!all(c("facility", "survey") %in% as.character(d$source))) cd_abort(c("x" = "Facility and survey coverage are both needed."))
  plot(d, type = "gap",
       title = t("plt_rbx_cov_gap_title", "Source comparison"),
       subtitle = t("plt_rbx_cov_gap_subtitle", "Latest facility estimate minus latest survey estimate"),
       x_axis = t("plt_rbx_cov_gap_x", "Percentage-point difference"), y_axis = NULL,
       indicator_labels = .rbx_continuum_labels(i18n, d))
}

# The latest coverage of each indicator of the maternal or child continuum of care, by region
.rb_draw_continuum_units <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  type <- if (identical(b$variant, "child")) "child" else "maternal"
  d <- cache$generate_coverage_data("adminlevel_1", type)
  if (!nrow(d)) cd_abort(c("x" = "No coverage by region."))
  year <- max(d$year, na.rm = TRUE)
  plot(d, type = "dot",
       title = .rbx_fill(t("plt_rbx_cov_dot_title", "Latest coverage by region ({year})"), year = year),
       x_axis = t("opt_coverage", "Coverage"), y_axis = NULL,
       indicator_labels = .rbx_continuum_labels(i18n, d))
}

# National coverage estimates of the Bayesian model (surveys and facility data). The model is fitted the first time it is
# asked for (some seconds) and kept with the data.
.rb_draw_bayes_coverage <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  ind <- .rbx_pick(b$indicator, c("anc4", "anc_1trimester", "ideliv", "measles1", "penta3"), "penta3")
  model <- cache$get_bayes_model("national", ind)
  plot(model,
       title = paste(t("plot_title_bayes_coverage", "Bayesian Coverage Model Estimates"), "-", .rb_ind_name(i18n, ind)),
       x_axis = t("title_global_year", "Year"),
       y_axis = t("opt_coverage", "Coverage"),
       caption = t("plot_legend_source", "Source: Survey Data & DHIS2 Routine Data"))
}

# ---- denominators ----

# One indicator's coverage over time with each denominator, and the survey estimates, nationally or in the report's region
.rb_draw_derived_coverage_trend <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  ind <- .rbx_pick(b$indicator, get_analysis_indicators(), "penta3")
  region <- .rbx_region(b)
  data <- if (is.null(region)) {
    cache$calculate_derived_coverage(ind, "national")
  } else {
    calculate_derived_coverage(cache$calculate_coverage("adminlevel_1", region), ind)
  }
  indicator <- .rb_ind_name(i18n, ind)
  title <- if (is.null(region)) t("plt_title_denom_nat_trend", "National Coverage Over Time by Denominator")
           else t("plt_title_denom_subnat_trend", "{region_name} Coverage Over Time by Denominator")
  plot(data, type = "trend",
       title = paste0(.rbx_fill(title, region_name = region %||% ""), " - ", indicator),
       x_label = t("title_global_year", "Year"),
       y_label = .rbx_fill(t("lbl_axis_y_coverage", "{indicator} Coverage (%)"), indicator = indicator),
       legend_labels = list(
         un = t("opt_un", "UN"), dhis2 = t("opt_dhis2", "DHIS2"), anc1 = t("opt_anc1", "ANC1"), penta1 = t("opt_penta1", "Penta1"),
         penta1derived = t("opt_penta1derived", "Penta1 Population Growth"), anc1derived = t("opt_anc1derived", "ANC1 Population Growth"),
         survey = t("lbl_coverage_survey_est", "Survey estimate")
       )) +
    # the denominators' legend and the survey year's, one above the other: side by side they are wider than the page
    ggplot2::theme(legend.box = "vertical")
}

# ---- service utilization and health system ----

# Under-5 outpatient visits per child, or inpatient admissions per 100 children, by region (latest year)
.rb_draw_su_region <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  v <- if (identical(b$variant, "ipd")) "ipd" else "opd"
  plot(cache$generate_admin1_service_utilization(v),
       title = t(paste0("opt_", v, "_capita_title"), if (v == "opd") "Sub-National OPD Distribution" else "Sub-National IPD Distribution"),
       x_axis = t(paste0("opt_", v, "_capita_x_axis"),
                  if (v == "opd") "OPD per capita under 5, by adminlevel1" else "IPD per 100 children under 5, by adminlevel1"),
       legend = t(paste0("opt_", v, "_capita_legend"), if (v == "opd") "OPD Under 5" else "IPD Under 5")) +
    ggplot2::labs(y = NULL)
}

# Under-5 service use against health workers, hospitals or beds, by region, with a linear fit
.rb_draw_hs_comparison <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  v <- .rbx_pick(b$variant, c("ratio_opd_u5_hstaff", "ratio_ipd_u5_hos", "ratio_ipd_u5_bed"))
  d <- cache$health_system_comparison
  if (is.null(d) || !nrow(d)) cd_abort(c("x" = "No health system data for this dataset."))
  # one point for each region (the data has a row for each district, with its region's figures)
  d <- d[!duplicated(d$adminlevel_1), , drop = FALSE]
  plot(d, indicator = v, title = t(paste0("title_", v), NULL), x_axis = t(paste0("xlab_", v), NULL), y_axis = t(paste0("ylab_", v), NULL),
       legend_labels = list(admin = t("lbl_admin1_units", "Admin1 units"), linear = t("lbl_linear_fit", "Linear fit")))
}

# The national health system scores (infrastructure, workforce, service use) or densities (facilities, workforce, beds)
.rb_draw_hs_national <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  metric <- if (identical(b$variant, "density")) "density" else "performance"
  d <- cache$health_system_metrics_national
  if (is.null(d) || !nrow(d)) cd_abort(c("x" = "No health system data for this dataset."))
  p <- plot_national_health_metric(d, metric)
  if (metric == "performance") {
    labels <- c("Total score" = t("plt_rbx_hs_score_total", "Total score"),
                "Score infrastructure*" = paste0(t("plt_rbx_hs_score_infra", "Score infrastructure"), "*"),
                "Score workforce**" = paste0(t("plt_rbx_hs_score_workforce", "Score workforce"), "**"),
                "Score service utilization***" = paste0(t("plt_rbx_hs_score_utilization", "Score service utilization"), "***"))
    title <- t("plt_rbx_hs_performance_title", "Health system performance at national level")
    caption <- t("plt_rbx_hs_performance_caption", paste0(
      "* Score facility density & bed density\n",
      "** Score health workforce density (physicians, non-clinical physicians, nurses & midwives)\n",
      "*** Score outpatient service utilization & inpatient service utilization"))
  } else {
    labels <- c("Health Facility Density *" = paste0(t("opt_ratio_fac_pop", "Health Facility Density"), " *"),
                "Health workforce density (Core health professionals) *" = paste0(t("xlab_metric_ratio_hstaff_pop", "Health workforce density"), " *"),
                "Hospital Beds Density *" = paste0(t("plt_rbx_hs_bed_density", "Hospital Beds Density"), " *"))
    title <- t("plt_rbx_hs_density_title", "Health system density at national level")
    caption <- t("plt_rbx_hs_density_caption", "* per 10,000 population")
  }
  p + ggplot2::scale_x_discrete(labels = labels) + ggplot2::labs(title = title, caption = caption)
}
