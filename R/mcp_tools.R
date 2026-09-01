#' MCP Tool Implementations
#'
#' @description
#' Plain R functions backing the cd2030.core MCP server's tools. These are
#' deliberately kept free of any `ellmer`/`mcptools` dependency so they can be
#' called and tested directly; [mcp_tool_list()] wraps each one as an
#' `ellmer::tool()` for the server.
#'
#' Every tool (other than [mcp_load_cache()]) takes the path of a cache
#' already opened with [mcp_load_cache()] and is read-only: none of them
#' mutate the underlying `CacheConnection`.
#'
#' @keywords internal
#' @name mcp_tools
NULL

#' @describeIn mcp_tools Open an existing `.rds` `CacheConnection` cache for
#'   use by every other MCP tool, and return a short summary of it.
#' @noRd
mcp_load_cache <- function(path, max_sessions = 3L) {
  key <- mcp_session_key(path)
  cache <- init_CacheConnection(rds_path = key)
  mcp_session_store(key, cache, max_sessions = max_sessions)
  mcp_cache_summary(cache)
}

#' @describeIn mcp_tools Fetch a previously loaded cache by path, aborting
#'   with a clear message if it hasn't been loaded. Also re-synchronizes the
#'   package's global indicator-group state to this cache, since several
#'   caches (potentially from different indicator groups) may be open at once.
#' @noRd
mcp_get_cache <- function(path) {
  key <- mcp_session_key(path)
  cache <- mcp_session_get(key)
  if (is.null(cache)) {
    cd_abort(c(
      "x" = "No cache is currently loaded for {.path {path}}.",
      "i" = "Call {.fun load_cache} with this path first."
    ))
  }

  set_selected_group(mcp_cache_indicator_group(cache))

  cache
}

#' @describeIn mcp_tools Resolve the indicator group a cache was built with,
#'   falling back to whatever's currently selected globally if the attribute
#'   is somehow absent (mirrors the resolution `init_CacheConnection()` does
#'   once at load time).
#' @noRd
mcp_cache_indicator_group <- function(cache) {
  attr_or_null(cache$countdown_data, "indicator_group") %||% get_selected_group()
}

#' @describeIn mcp_tools Build the small metadata summary returned by
#'   [mcp_load_cache()] and included in [mcp_get_data_overview()].
#' @noRd
mcp_cache_summary <- function(cache) {
  list(
    cache_path = cache$cache_path,
    country = cache$country,
    country_iso = cache$country_iso,
    indicator_group = mcp_cache_indicator_group(cache),
    data_years = cache$data_years,
    denominator = cache$denominator,
    maternal_denominator = cache$maternal_denominator,
    adjusted = cache$adjusted_flag,
    language = cache$language
  )
}

#' @describeIn mcp_tools Cap a data frame at `cap` rows for return to an LLM,
#'   noting when it was truncated so the caller knows to narrow its request.
#'   Defaults to the `max_rows` [cd2030_mcp_server()] was started with.
#' @noRd
mcp_shape_table <- function(data, cap = getOption("cd2030.mcp_max_rows", 200L)) {
  if (is.null(data) || (is.data.frame(data) && nrow(data) == 0)) {
    return(list(data = list(), meta = list(returned_rows = 0L, total_rows = 0L, truncated = FALSE)))
  }

  data <- tibble::as_tibble(data)
  total <- nrow(data)
  truncated <- total > cap
  out <- if (truncated) utils::head(data, cap) else data

  meta <- list(returned_rows = nrow(out), total_rows = total, truncated = truncated)
  if (truncated) {
    meta$notice <- sprintf(
      "Showing %d of %d rows. Narrow the result using this tool's filter arguments (e.g. region/admin_level/year) to see more.",
      nrow(out), total
    )
  }

  list(data = out, meta = meta)
}

#' @describeIn mcp_tools Shape any `CacheConnection` method result for return
#'   over MCP: tabular results go through [mcp_shape_table()] (row-capped,
#'   with a truncation notice); scalars and lists pass through untouched,
#'   since they're already small and directly JSON-serializable.
#' @noRd
mcp_shape_result <- function(x) {
  if (is.data.frame(x)) mcp_shape_table(x) else x
}

#' @describeIn mcp_tools Same as [mcp_shape_result()], but strips any spatial
#'   geometry column first -- raw polygon coordinates aren't useful as
#'   returned "data" to an LLM.
#' @noRd
mcp_shape_result_no_geom <- function(x) {
  if (is.data.frame(x)) {
    x <- dplyr::select(x, -dplyr::any_of(c("geometry", "geom")))
  }
  mcp_shape_result(x)
}

#' @describeIn mcp_tools Call a single, hardcoded read-only `CacheConnection`
#'   method by name and shape its result for MCP. `method` is always a
#'   literal string baked into the caller below -- never a value coming from
#'   an MCP tool argument -- so this cannot be used to reach an arbitrary
#'   (e.g. mutating) method; it only removes the repetition of writing
#'   `cache <- mcp_get_cache(path); shape(cache$foo(...))` for every one of
#'   the ~30 read methods this file wraps.
#' @noRd
mcp_call_cache_method <- function(path, method, args = list(), shape = mcp_shape_result) {
  cache <- mcp_get_cache(path)
  shape(do.call(cache[[method]], args))
}

#' @describeIn mcp_tools Country/years/regions metadata for a loaded cache.
#' @noRd
mcp_get_data_overview <- function(path) {
  cache <- mcp_get_cache(path)
  list(
    summary = mcp_cache_summary(cache),
    subnational_regions = mcp_shape_table(cache$subnational_regions)
  )
}

#' @describeIn mcp_tools DQA overall score (Layer 1).
#' @noRd
mcp_get_overall_score <- function(path, admin_level = c("national", "adminlevel_1"), region = NULL) {
  admin_level <- arg_match(admin_level)
  cache <- mcp_get_cache(path)
  mcp_shape_table(cache$calculate_overall_score(admin_level = admin_level, region = region))
}

#' @describeIn mcp_tools Indicator coverage (Layer 2).
#' @noRd
mcp_get_indicator_coverage <- function(path, admin_level = c("national", "adminlevel_1", "district"), region = NULL) {
  admin_level <- arg_match(admin_level)
  cache <- mcp_get_cache(path)
  mcp_shape_table(cache$get_base_indicator_coverage(admin_level = admin_level, region = region))
}

#' @describeIn mcp_tools Subnational inequality (Layer 3).
#' @noRd
mcp_get_inequality <- function(path, admin_level = c("adminlevel_1", "district"), region = NULL) {
  admin_level <- arg_match(admin_level)
  cache <- mcp_get_cache(path)
  mcp_shape_table(cache$calculate_inequality(admin_level = admin_level, region = region))
}

#' @describeIn mcp_tools Mortality ratio summary (Layer 3).
#' @noRd
mcp_get_mortality_summary <- function(path, indicator = c("mmr", "sbr", "nn"), map_years = NULL) {
  indicator <- arg_match(indicator)
  cache <- mcp_get_cache(path)
  mcp_shape_table(cache$filter_mortality_summary(indicator = indicator, map_years = map_years))
}

#' @describeIn mcp_tools OPD/IPD service utilization (Layer 3).
#' @noRd
mcp_get_service_utilization <- function(path,
                                        admin_level = c("national", "adminlevel_1"),
                                        indicator = c("opd", "ipd", "under5", "cfr", "deaths"),
                                        region = NULL) {
  admin_level <- arg_match(admin_level)
  indicator <- arg_match(indicator)
  cache <- mcp_get_cache(path)
  mcp_shape_table(cache$filter_service_utilization(admin_level = admin_level, indicator = indicator, region = region))
}

#' @describeIn mcp_tools Health system metrics (Layer 3).
#' @noRd
mcp_get_health_system_metrics <- function(path, admin_level = c("national", "adminlevel_1")) {
  admin_level <- arg_match(admin_level)
  cache <- mcp_get_cache(path)
  data <- if (admin_level == "national") {
    cache$health_system_metrics_national
  } else {
    cache$health_system_metrics_admin1
  }
  mcp_shape_table(data)
}

#' @describeIn mcp_tools Private vs public sector ownership split (Layer 3).
#' @noRd
mcp_get_private_sector_data <- function(path) {
  cache <- mcp_get_cache(path)
  mcp_shape_table(cache$generate_private_sector_data())
}

#' @describeIn mcp_tools Subnational coverage prepared for map rendering
#'   (Layer 3), stripped of the geometry column since raw polygon coordinates
#'   aren't useful as returned data (see [mcp_render_coverage_plot()] for the
#'   corresponding chart).
#' @noRd
mcp_get_mapping_data <- function(path,
                                 admin_level = c("adminlevel_1", "district"),
                                 indicator,
                                 palette = c("Reds", "Blues", "Greens", "Purples", "YlGnBu"),
                                 plot_year = NULL) {
  admin_level <- arg_match(admin_level)
  palette <- arg_match(palette)
  check_required(indicator)

  cache <- mcp_get_cache(path)
  data <- cache$get_filtered_mapping_data(
    indicator = indicator,
    admin_level = admin_level,
    palette = palette,
    plot_year = plot_year
  )
  mcp_shape_table(dplyr::select(data, -dplyr::any_of("geometry")))
}

# =========================================================================
# Remaining read methods (Layer 0-3), added mechanically via
# mcp_call_cache_method() -- each is a thin, hardcoded dispatch to one
# CacheConnection method, argument validation and defaults deferred to that
# method itself (see mcp_call_cache_method()'s @describeIn).
# =========================================================================

#' @describeIn mcp_tools DQA completeness summary (Layer 1).
#' @noRd
mcp_get_completeness_summary <- function(path, admin_level = c("national", "adminlevel_1", "district"), region = NULL) {
  mcp_call_cache_method(path, "calculate_completeness_summary", list(admin_level = admin_level, region = region))
}

#' @describeIn mcp_tools Full, multi-indicator raw coverage merge (Layer 2) --
#'   every indicator/denominator combination in one wide table; see
#'   [mcp_get_filtered_coverage()] for a single indicator instead.
#' @noRd
mcp_get_coverage_raw <- function(path, admin_level = c("national", "adminlevel_1", "district"), region = NULL) {
  mcp_call_cache_method(path, "calculate_coverage", list(admin_level = admin_level, region = region))
}

#' @describeIn mcp_tools Derived coverage indicators from survey data (Layer 2).
#' @noRd
mcp_get_derived_coverage <- function(path, indicator, admin_level = c("national", "adminlevel_1", "district"), region = NULL) {
  mcp_call_cache_method(path, "calculate_derived_coverage", list(indicator = indicator, admin_level = admin_level, region = region))
}

#' @describeIn mcp_tools District-level completeness detail (Layer 1).
#' @noRd
mcp_get_district_completeness_summary <- function(path, region = NULL) {
  mcp_call_cache_method(path, "calculate_district_completeness_summary", list(region = region))
}

#' @describeIn mcp_tools District-level outlier detail (Layer 1).
#' @noRd
mcp_get_district_outlier_summary <- function(path, region = NULL) {
  mcp_call_cache_method(path, "calculate_district_outlier_summary", list(region = region))
}

#' @describeIn mcp_tools District-level reporting-rate detail (Layer 1).
#' @noRd
mcp_get_district_reporting_rate <- function(path, region = NULL) {
  mcp_call_cache_method(path, "calculate_district_reporting_rate", list(region = region))
}

#' @describeIn mcp_tools Outlier summary (Layer 1).
#' @noRd
mcp_get_outliers_summary <- function(path, admin_level = c("national", "adminlevel_1", "district"), region = NULL) {
  mcp_call_cache_method(path, "calculate_outliers_summary", list(admin_level = admin_level, region = region))
}

#' @describeIn mcp_tools Chronological ratio/adequacy summary, e.g.
#'   ANC1-to-Penta1 (Layer 1).
#' @noRd
mcp_get_ratios_and_adequacy <- function(path, region = NULL) {
  mcp_call_cache_method(path, "calculate_ratios_and_adequacy", list(region = region))
}

#' @describeIn mcp_tools Average reporting rate (Layer 1).
#' @noRd
mcp_get_reporting_rate <- function(path, admin_level = c("national", "adminlevel_1", "district"), region = NULL) {
  mcp_call_cache_method(path, "calculate_reporting_rate", list(admin_level = admin_level, region = region))
}

#' @describeIn mcp_tools Service-DQA summary comparing reporting vs.
#'   utilization metrics (Layer 1/3).
#' @noRd
mcp_get_service_dqa_summary <- function(path, admin_level = c("national", "adminlevel_1"), region = NULL) {
  mcp_call_cache_method(path, "calculate_service_dqa_summary", list(admin_level = admin_level, region = region))
}

#' @describeIn mcp_tools Full OPD/IPD service utilization table (Layer 3) --
#'   every metric at once; see [mcp_get_service_utilization()] for a single
#'   indicator instead.
#' @noRd
mcp_get_service_utilization_summary <- function(path, admin_level = c("national", "adminlevel_1", "district")) {
  mcp_call_cache_method(path, "compute_service_utilization", list(admin_level = admin_level))
}

#' @describeIn mcp_tools Maternal/child-health vs. curative-services index,
#'   by admin1 region (Layer 3).
#' @noRd
mcp_get_mch_curative_index <- function(path) {
  mcp_call_cache_method(path, "generate_admin1_mch_curative_index")
}

#' @describeIn mcp_tools Admin1 service-utilization ratio for one metric (Layer 3).
#' @noRd
mcp_get_admin1_service_utilization <- function(path, metric_type = c("opd", "ipd")) {
  mcp_call_cache_method(path, "generate_admin1_service_utilization", list(metric_type = metric_type))
}

#' @describeIn mcp_tools Continuum-of-care coverage summary for maternal or
#'   child indicators (Layer 2).
#' @noRd
mcp_get_coverage_data_selected <- function(path, admin_level = c("national", "adminlevel_1"), type = c("maternal", "child"), region = NULL) {
  mcp_call_cache_method(path, "generate_coverage_data", list(admin_level = admin_level, type = type, region = region))
}

#' @describeIn mcp_tools Formatted core health-system metrics table (Layer 3).
#' @noRd
mcp_get_health_system_table <- function(path) {
  mcp_call_cache_method(path, "generate_health_system_table")
}

#' @describeIn mcp_tools Primary-health-care scatter data (facility/staff
#'   density vs. coverage), by admin1 region (Layer 3).
#' @noRd
mcp_get_phc_scatter_data <- function(path, indicator = c("ratio_fac_pop", "ratio_hstaff_pop")) {
  mcp_call_cache_method(path, "generate_phc_scatter_data", list(indicator = indicator))
}

#' @describeIn mcp_tools Resolve which denominator (standard or maternal)
#'   applies to a given indicator.
#' @noRd
mcp_get_denominator <- function(path, indicator) {
  mcp_call_cache_method(path, "get_denominator", list(indicator = indicator))
}

#' @describeIn mcp_tools Coverage for a single indicator, across years, with
#'   DHIS2/WUENIC/survey estimates (Layer 2) -- the data backing
#'   [mcp_render_coverage_plot()].
#' @noRd
mcp_get_filtered_coverage <- function(path, indicator, admin_level = c("national", "adminlevel_1", "district"), region = NULL) {
  mcp_call_cache_method(path, "get_filtered_coverage", list(indicator = indicator, admin_level = admin_level, region = region))
}

#' @describeIn mcp_tools Inequality data for a single indicator (Layer 3) --
#'   see [mcp_get_inequality()] for the raw multi-indicator matrix instead.
#' @noRd
mcp_get_filtered_inequality <- function(path, indicator, admin_level = c("adminlevel_1", "district"), region = NULL) {
  mcp_call_cache_method(path, "get_filtered_inequality", list(indicator = indicator, admin_level = admin_level, region = region))
}

#' @describeIn mcp_tools Evaluate an indicator against its benchmark
#'   threshold (Layer 2/3).
#' @noRd
mcp_get_filtered_threshold <- function(path, indicator = c("anc4", "instlivebirths", "vaccine", "dropout"), target_unit = c("district", "adminlevel_1"), region = NULL) {
  mcp_call_cache_method(path, "get_filtered_threshold", list(indicator = indicator, target_unit = target_unit, region = region))
}

#' @describeIn mcp_tools Regions/districts exceeding a benchmark coverage
#'   threshold for an indicator (Layer 2/3).
#' @noRd
mcp_get_high_performers <- function(path, indicator, admin_level = c("national", "adminlevel_1", "district"), region = NULL) {
  mcp_call_cache_method(path, "get_high_performers", list(indicator = indicator, admin_level = admin_level, region = region))
}

#' @describeIn mcp_tools National (or region-substituted) mortality/survey
#'   rate estimates used elsewhere in the pipeline (Layer 0).
#' @noRd
mcp_get_regional_estimates <- function(path, admin_level = c("national", "adminlevel_1", "district"), region = NULL) {
  mcp_call_cache_method(path, "get_regional_estimates", list(admin_level = admin_level, region = region))
}

#' @describeIn mcp_tools Mean institutional-livebirths rate used as the
#'   mortality-completeness-ratio baseline (Layer 3).
#' @noRd
mcp_get_lbr_mean <- function(path) {
  mcp_call_cache_method(path, "lbr_mean")
}

#' @describeIn mcp_tools Facility/period units missing an indicator (Layer 1).
#' @noRd
mcp_get_missing_units <- function(path, indicator, region = NULL) {
  mcp_call_cache_method(path, "list_missing_units", list(indicator = indicator, region = region))
}

#' @describeIn mcp_tools Service-utilization data prepared for map
#'   rendering (Layer 3), stripped of its geometry column (same rationale as
#'   [mcp_get_mapping_data()]).
#' @noRd
mcp_get_service_utilization_mapping <- function(path, indicator = c("ipd", "opd"), map_years = NULL) {
  mcp_call_cache_method(
    path, "prepare_mapping_service_utlization", list(indicator = indicator, map_years = map_years),
    shape = mcp_shape_result_no_geom
  )
}

#' @describeIn mcp_tools Completeness-adjusted mortality ratio vs. UN
#'   estimate bounds (Layer 3).
#' @noRd
mcp_get_mortality_completeness_ratio <- function(path, indicator = c("mmr", "sbr", "nn")) {
  mcp_call_cache_method(path, "summarise_completeness_ratio", list(indicator = indicator))
}

#' @describeIn mcp_tools Render one of the package's existing report
#'   templates to disk, in a `reports/` directory alongside the cache, and
#'   return its path.
#' @noRd
mcp_generate_report <- function(path,
                                report_name,
                                output_format = c("word_document", "pdf_document"),
                                adminlevel_1 = NULL) {
  output_format <- arg_match(output_format)
  check_required(report_name)

  cache <- mcp_get_cache(path)

  reports_dir <- file.path(dirname(cache$cache_path), "reports")
  if (!dir.exists(reports_dir)) {
    dir.create(reports_dir, recursive = TRUE)
  }

  ext <- switch(output_format, word_document = "docx", pdf_document = "pdf")
  output_path <- file.path(
    reports_dir,
    sprintf("%s_%s.%s", report_name, format(Sys.time(), "%Y%m%d%H%M%S"), ext)
  )

  generate_report(
    cache = cache,
    output_file = output_path,
    report_name = report_name,
    adminlevel_1 = adminlevel_1,
    output_format = output_format
  )

  list(path = output_path, report_name = report_name, output_format = output_format)
}

#' @describeIn mcp_tools Render a coverage line chart to a temporary PNG file
#'   and return its path, for the caller to wrap as inline MCP image content.
#' @noRd
mcp_render_coverage_plot <- function(path,
                                     indicator,
                                     admin_level = c("national", "adminlevel_1", "district"),
                                     region = NULL) {
  admin_level <- arg_match(admin_level)
  check_required(indicator)

  cache <- mcp_get_cache(path)
  filtered <- cache$get_filtered_coverage(indicator = indicator, admin_level = admin_level, region = region)
  p <- plot(filtered)

  out_path <- tempfile("cd2030_coverage_plot_", fileext = ".png")
  ggplot2::ggsave(out_path, plot = p, width = 768 / 96, height = 768 / 96, dpi = 96, bg = "white")
  out_path
}
