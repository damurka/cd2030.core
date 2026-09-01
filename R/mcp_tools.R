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
