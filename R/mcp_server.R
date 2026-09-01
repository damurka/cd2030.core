#' Run the cd2030.core MCP Server
#'
#' @description
#' Starts a [Model Context Protocol](https://modelcontextprotocol.io) server,
#' over stdio, that lets an LLM client (e.g. Claude Desktop or Claude Code)
#' query already-processed Countdown 2030 datasets: data quality scores,
#' coverage, inequality, mortality, service utilization, health system
#' metrics, private-sector splits, mapping data, generated reports, and
#' coverage charts.
#'
#' The server is read-only: no tool can create or modify a `.rds` cache, or
#' change any analysis parameter (denominators, k-factors, survey estimates,
#' ...) on one. A cache must already be fully processed -- e.g. via the
#' Countdown 2030 Shiny app -- before pointing this server at it; tools that
#' need parameters which aren't set on the cache will surface
#' `CacheConnection`'s own error explaining what's missing.
#'
#' Several caches can be open at once, addressed by their file path (see
#' the `load_cache` tool); the oldest is evicted once `max_sessions` are open.
#'
#' @param max_sessions Maximum number of `.rds` caches to keep open at once.
#'   Loading beyond this evicts the least-recently-used cache. Default `3`.
#' @param max_rows Maximum number of rows any single tool call returns before
#'   truncating (with a notice telling the caller how to narrow the request).
#'   Default `200`.
#'
#' @details
#' This requires the `mcptools` and `ellmer` packages, which are optional
#' (`Suggests`) dependencies of cd2030.core -- install them with
#' `install.packages(c("mcptools", "ellmer"))` before calling this function.
#'
#' To use with an MCP client such as Claude Desktop or Claude Code, point its
#' configuration at:
#' ```
#' Rscript -e "cd2030.core::cd2030_mcp_server()"
#' ```
#'
#' @return Does not return; blocks the R process serving the MCP protocol
#'   over stdio until the client disconnects.
#'
#' @export
cd2030_mcp_server <- function(max_sessions = 3L, max_rows = 200L) {
  check_installed(c("mcptools", "ellmer"), reason = "to run the cd2030.core MCP server")
  withr::local_options(cd2030.mcp_max_rows = max_rows)
  tools <- mcp_tool_list(max_sessions = max_sessions)
  mcptools::mcp_server(tools = tools, type = "stdio")
}

#' @describeIn cd2030_mcp_server Build the `ellmer::tool()` list served by
#'   [cd2030_mcp_server()]. Split out so it can be constructed (and its
#'   underlying `mcp_*` functions exercised) without actually starting a
#'   blocking stdio server.
#' @noRd
mcp_tool_list <- function(max_sessions = 3L) {
  path_arg <- ellmer::type_string("Path to a cd2030.core .rds cache file previously opened with the load_cache tool.")
  region_arg <- function(desc) ellmer::type_string(desc, required = FALSE)

  list(
    ellmer::tool(
      function(path) mcp_load_cache(path, max_sessions = max_sessions),
      name = "load_cache",
      description = paste(
        "Open a cd2030.core CacheConnection .rds cache file so every other cd2030",
        "tool can query it by this same file path. Loading a new cache does not close",
        "previously loaded ones -- up to", max_sessions, "may be open at once; the",
        "least-recently-used one is evicted automatically beyond that. Returns a",
        "summary of the loaded dataset (country, years covered, denominators, etc.)."
      ),
      arguments = list(
        path = ellmer::type_string("Absolute path to an existing cd2030.core .rds cache file.")
      )
    ),
    ellmer::tool(
      mcp_get_data_overview,
      name = "get_data_overview",
      description = "Get metadata about a loaded cache: country, years covered, and the admin1/district regions present in the data.",
      arguments = list(path = path_arg)
    ),
    ellmer::tool(
      function(path, admin_level = "national", region = NULL) {
        mcp_get_overall_score(path, admin_level = admin_level, region = region)
      },
      name = "get_overall_score",
      description = "Get the data-quality-assessment overall score (reporting rate, completeness, outliers, ratios rolled into one grade) for a loaded cache.",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("national", "adminlevel_1"), "Level to compute the score at."),
        region = region_arg("Region name; required when admin_level is adminlevel_1, must be omitted for national.")
      )
    ),
    ellmer::tool(
      function(path, admin_level = "national", region = NULL) {
        mcp_get_indicator_coverage(path, admin_level = admin_level, region = region)
      },
      name = "get_indicator_coverage",
      description = "Get indicator coverage estimates (e.g. penta1, anc1, measles1) at national, admin1, or district level for a loaded cache.",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("national", "adminlevel_1", "district"), "Level to compute coverage at."),
        region = region_arg("Optional region (adminlevel_1 or district) to filter to; omit for all regions.")
      )
    ),
    ellmer::tool(
      function(path, admin_level = "adminlevel_1", region = NULL) {
        mcp_get_inequality(path, admin_level = admin_level, region = region)
      },
      name = "get_inequality",
      description = "Get subnational inequality data (coverage relative to the national reference) at admin1 or district level for a loaded cache.",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("adminlevel_1", "district"), "Level to compute inequality at."),
        region = region_arg("Optional adminlevel_1 region to filter district-level results to.")
      )
    ),
    ellmer::tool(
      function(path, indicator, map_years = NULL) {
        mcp_get_mortality_summary(path, indicator = indicator, map_years = map_years)
      },
      name = "get_mortality_summary",
      description = "Get mortality ratio summaries (maternal, stillbirth, or neonatal) comparing internal data with UN estimates for a loaded cache.",
      arguments = list(
        path = path_arg,
        indicator = ellmer::type_enum(c("mmr", "sbr", "nn"), "Mortality indicator: mmr (maternal), sbr (stillbirth), or nn (neonatal)."),
        map_years = ellmer::type_array(ellmer::type_integer(), "Years to include; omit to use the cache's default mapping years.", required = FALSE)
      )
    ),
    ellmer::tool(
      function(path, admin_level = "national", indicator, region = NULL) {
        mcp_get_service_utilization(path, admin_level = admin_level, indicator = indicator, region = region)
      },
      name = "get_service_utilization",
      description = "Get OPD/IPD service utilization data (visits, under-5 share, case-fatality rate, deaths) for a loaded cache.",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("national", "adminlevel_1"), "Level to aggregate utilization at."),
        indicator = ellmer::type_enum(c("opd", "ipd", "under5", "cfr", "deaths"), "Utilization indicator to return."),
        region = region_arg("Optional adminlevel_1 region to filter to.")
      )
    ),
    ellmer::tool(
      function(path, admin_level = "national") {
        mcp_get_health_system_metrics(path, admin_level = admin_level)
      },
      name = "get_health_system_metrics",
      description = "Get core health system metrics (facility/health-worker density, bed ratios, etc.) at national or admin1 level for a loaded cache.",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("national", "adminlevel_1"), "Level to compute metrics at.")
      )
    ),
    ellmer::tool(
      function(path) mcp_get_private_sector_data(path),
      name = "get_private_sector_data",
      description = "Get the private vs NGO vs public sector ownership distribution for a loaded cache.",
      arguments = list(path = path_arg)
    ),
    ellmer::tool(
      function(path, admin_level = "adminlevel_1", indicator, palette = "Blues", plot_year = NULL) {
        mcp_get_mapping_data(path, admin_level = admin_level, indicator = indicator, palette = palette, plot_year = plot_year)
      },
      name = "get_mapping_data",
      description = "Get subnational coverage data prepared for map visualization (region, year, and indicator coverage columns -- no spatial geometry, use get_coverage_plot for a chart).",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("adminlevel_1", "district"), "Level to compute mapping data at."),
        indicator = ellmer::type_string("Coverage indicator to map, e.g. penta1, anc4, measles1."),
        palette = ellmer::type_enum(c("Reds", "Blues", "Greens", "Purples", "YlGnBu"), "Color palette name (informational; no geometry/colors are returned)."),
        plot_year = ellmer::type_array(ellmer::type_integer(), "Years to include; omit to use the cache's default mapping years.", required = FALSE)
      )
    ),
    # -----------------------------------------------------------------------
    # Remaining read methods, added mechanically: each worker is a hardcoded
    # one-liner (see mcp_call_cache_method()), but the tool name/description/
    # argument schema below is still hand-written per tool, since that's what
    # actually determines whether an LLM calls it correctly.
    # -----------------------------------------------------------------------
    ellmer::tool(
      function(path, admin_level = "national", region = NULL) {
        mcp_get_completeness_summary(path, admin_level = admin_level, region = region)
      },
      name = "get_completeness_summary",
      description = "Get the DQA completeness summary (% non-missing values) at national, admin1, or district level for a loaded cache.",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("national", "adminlevel_1", "district"), "Level to compute completeness at."),
        region = region_arg("Optional region to filter to.")
      )
    ),
    ellmer::tool(
      function(path, admin_level = "national", region = NULL) {
        mcp_get_coverage_raw(path, admin_level = admin_level, region = region)
      },
      name = "get_coverage_raw",
      description = "Get the full, multi-indicator raw coverage merge (every indicator x denominator combination in one wide table) for a loaded cache. Use get_filtered_coverage instead if you only need one indicator.",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("national", "adminlevel_1", "district"), "Level to compute coverage at."),
        region = region_arg("Optional region to filter to.")
      )
    ),
    ellmer::tool(
      function(path, indicator, admin_level = "national", region = NULL) {
        mcp_get_derived_coverage(path, indicator = indicator, admin_level = admin_level, region = region)
      },
      name = "get_derived_coverage",
      description = "Get a derived coverage indicator computed from survey-based ratios, at national, admin1, or district level.",
      arguments = list(
        path = path_arg,
        indicator = ellmer::type_string("Coverage indicator, e.g. penta1, anc4, measles1."),
        admin_level = ellmer::type_enum(c("national", "adminlevel_1", "district"), "Level to compute at."),
        region = region_arg("Optional region to filter to.")
      )
    ),
    ellmer::tool(
      function(path, region = NULL) mcp_get_district_completeness_summary(path, region = region),
      name = "get_district_completeness_summary",
      description = "Get the % of districts meeting completeness thresholds, per indicator and year.",
      arguments = list(path = path_arg, region = region_arg("Optional adminlevel_1 region to filter to."))
    ),
    ellmer::tool(
      function(path, region = NULL) mcp_get_district_outlier_summary(path, region = region),
      name = "get_district_outlier_summary",
      description = "Get the % of districts with acceptable outlier variance, per indicator and year.",
      arguments = list(path = path_arg, region = region_arg("Optional adminlevel_1 region to filter to."))
    ),
    ellmer::tool(
      function(path, region = NULL) mcp_get_district_reporting_rate(path, region = region),
      name = "get_district_reporting_rate",
      description = "Get the % of districts meeting reporting-rate thresholds, per indicator group and year.",
      arguments = list(path = path_arg, region = region_arg("Optional adminlevel_1 region to filter to."))
    ),
    ellmer::tool(
      function(path, admin_level = "national", region = NULL) {
        mcp_get_outliers_summary(path, admin_level = admin_level, region = region)
      },
      name = "get_outliers_summary",
      description = "Get the % of values that are not severe outliers (Hampel method), at national, admin1, or district level.",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("national", "adminlevel_1", "district"), "Level to compute at."),
        region = region_arg("Optional region to filter to.")
      )
    ),
    ellmer::tool(
      function(path, region = NULL) mcp_get_ratios_and_adequacy(path, region = region),
      name = "get_ratios_and_adequacy",
      description = "Get chronological indicator-ratio adequacy (e.g. ANC1-to-Penta1, Penta1-to-Penta3) by year.",
      arguments = list(path = path_arg, region = region_arg("Optional adminlevel_1 region to filter to."))
    ),
    ellmer::tool(
      function(path, admin_level = "national", region = NULL) {
        mcp_get_reporting_rate(path, admin_level = admin_level, region = region)
      },
      name = "get_reporting_rate",
      description = "Get the average facility reporting rate, at national, admin1, or district level.",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("national", "adminlevel_1", "district"), "Level to compute at."),
        region = region_arg("Optional region to filter to.")
      )
    ),
    ellmer::tool(
      function(path, admin_level = "national", region = NULL) {
        mcp_get_service_dqa_summary(path, admin_level = admin_level, region = region)
      },
      name = "get_service_dqa_summary",
      description = "Get the service-DQA summary comparing general reporting/completeness/outliers against service-utilization metrics.",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("national", "adminlevel_1"), "Level to compute at."),
        region = region_arg("Region name; required when admin_level is adminlevel_1, must be omitted for national.")
      )
    ),
    ellmer::tool(
      function(path, admin_level = "national") mcp_get_service_utilization_summary(path, admin_level = admin_level),
      name = "get_service_utilization_summary",
      description = "Get the full OPD/IPD service utilization table (visits, deaths, ratios, all metrics at once) at national, admin1, or district level. Use get_service_utilization instead if you only need one metric.",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("national", "adminlevel_1", "district"), "Level to aggregate at.")
      )
    ),
    ellmer::tool(
      function(path) mcp_get_mch_curative_index(path),
      name = "get_mch_curative_index",
      description = "Get the maternal/child-health vs curative-services index, by admin1 region and year.",
      arguments = list(path = path_arg)
    ),
    ellmer::tool(
      function(path, metric_type = "opd") mcp_get_admin1_service_utilization(path, metric_type = metric_type),
      name = "get_admin1_service_utilization",
      description = "Get the under-5 service-utilization ratio for one metric, by admin1 region and year.",
      arguments = list(
        path = path_arg,
        metric_type = ellmer::type_enum(c("opd", "ipd"), "Utilization metric to return.")
      )
    ),
    ellmer::tool(
      function(path, admin_level = "national", type = "child", region = NULL) {
        mcp_get_coverage_data_selected(path, admin_level = admin_level, type = type, region = region)
      },
      name = "get_coverage_data_selected",
      description = "Get a continuum-of-care coverage summary (a curated set of indicators) for maternal or child health, at national or admin1 level.",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("national", "adminlevel_1"), "Level to compute at."),
        type = ellmer::type_enum(c("maternal", "child"), "Which continuum-of-care set to return."),
        region = region_arg("Optional adminlevel_1 region to filter to.")
      )
    ),
    ellmer::tool(
      function(path) mcp_get_health_system_table(path),
      name = "get_health_system_table",
      description = "Get a formatted table of core national health-system metrics (facility/health-worker density, bed ratios, etc.).",
      arguments = list(path = path_arg)
    ),
    ellmer::tool(
      function(path, indicator = "ratio_fac_pop") mcp_get_phc_scatter_data(path, indicator = indicator),
      name = "get_phc_scatter_data",
      description = "Get primary-health-care scatter data (facility or health-worker density vs. service coverage), by admin1 region.",
      arguments = list(
        path = path_arg,
        indicator = ellmer::type_enum(c("ratio_fac_pop", "ratio_hstaff_pop"), "Which density ratio to pair with coverage.")
      )
    ),
    ellmer::tool(
      function(path, indicator) mcp_get_denominator(path, indicator = indicator),
      name = "get_denominator",
      description = "Resolve which denominator (the cache's standard or maternal denominator) applies to a given indicator.",
      arguments = list(path = path_arg, indicator = ellmer::type_string("Indicator name, e.g. penta1, anc4, instlivebirths."))
    ),
    ellmer::tool(
      function(path, indicator, admin_level = "national", region = NULL) {
        mcp_get_filtered_coverage(path, indicator = indicator, admin_level = admin_level, region = region)
      },
      name = "get_filtered_coverage",
      description = "Get coverage for a single indicator across years, with DHIS2/WUENIC/survey estimates -- the underlying data for get_coverage_plot.",
      arguments = list(
        path = path_arg,
        indicator = ellmer::type_string("Coverage indicator, e.g. penta1, anc4, measles1."),
        admin_level = ellmer::type_enum(c("national", "adminlevel_1", "district"), "Level to compute at."),
        region = region_arg("Optional region to filter to.")
      )
    ),
    ellmer::tool(
      function(path, indicator, admin_level = "adminlevel_1", region = NULL) {
        mcp_get_filtered_inequality(path, indicator = indicator, admin_level = admin_level, region = region)
      },
      name = "get_filtered_inequality",
      description = "Get subnational inequality data for a single indicator. Use get_inequality instead for the raw multi-indicator matrix.",
      arguments = list(
        path = path_arg,
        indicator = ellmer::type_string("Coverage indicator, e.g. penta1, anc4, measles1."),
        admin_level = ellmer::type_enum(c("adminlevel_1", "district"), "Level to compute at."),
        region = region_arg("Optional adminlevel_1 region to filter district-level results to.")
      )
    ),
    ellmer::tool(
      function(path, indicator = "anc4", target_unit = "district", region = NULL) {
        mcp_get_filtered_threshold(path, indicator = indicator, target_unit = target_unit, region = region)
      },
      name = "get_filtered_threshold",
      description = "Evaluate an indicator against its benchmark coverage threshold (e.g. 80%), returning the % of districts or admin1 regions meeting it.",
      arguments = list(
        path = path_arg,
        indicator = ellmer::type_enum(c("anc4", "instlivebirths", "vaccine", "dropout"), "Indicator group to evaluate."),
        target_unit = ellmer::type_enum(c("district", "adminlevel_1"), "Unit whose pass rate is reported."),
        region = region_arg("Optional adminlevel_1 region to filter to; only valid when target_unit is district.")
      )
    ),
    ellmer::tool(
      function(path, indicator, admin_level = "national", region = NULL) {
        mcp_get_high_performers(path, indicator = indicator, admin_level = admin_level, region = region)
      },
      name = "get_high_performers",
      description = "Identify regions/districts exceeding the benchmark coverage threshold for an indicator.",
      arguments = list(
        path = path_arg,
        indicator = ellmer::type_string("Coverage indicator, e.g. penta1, anc4, measles1."),
        admin_level = ellmer::type_enum(c("national", "adminlevel_1", "district"), "Level to evaluate at."),
        region = region_arg("Optional region to filter to.")
      )
    ),
    ellmer::tool(
      function(path, admin_level = "national", region = NULL) {
        mcp_get_regional_estimates(path, admin_level = admin_level, region = region)
      },
      name = "get_regional_estimates",
      description = "Get the national (or region-substituted) mortality/survey rate estimates (sbr, nmr, pnmr, anc1, penta1, etc.) used elsewhere in the pipeline.",
      arguments = list(
        path = path_arg,
        admin_level = ellmer::type_enum(c("national", "adminlevel_1", "district"), "Level to resolve estimates at."),
        region = region_arg("Optional region name; national estimates are returned if omitted.")
      )
    ),
    ellmer::tool(
      function(path) mcp_get_lbr_mean(path),
      name = "get_lbr_mean",
      description = "Get the mean institutional-livebirths coverage rate, used as the baseline for mortality-completeness-ratio calculations.",
      arguments = list(path = path_arg)
    ),
    ellmer::tool(
      function(path, indicator, region = NULL) mcp_get_missing_units(path, indicator = indicator, region = region),
      name = "get_missing_units",
      description = "List facility/period units with missing values for a given indicator.",
      arguments = list(
        path = path_arg,
        indicator = ellmer::type_string("Indicator to check, e.g. penta1, anc1."),
        region = region_arg("Optional adminlevel_1 region to filter to.")
      )
    ),
    ellmer::tool(
      function(path, indicator = "opd", map_years = NULL) {
        mcp_get_service_utilization_mapping(path, indicator = indicator, map_years = map_years)
      },
      name = "get_service_utilization_mapping",
      description = "Get service-utilization data prepared for map visualization (region, year, and ratio columns -- no spatial geometry).",
      arguments = list(
        path = path_arg,
        indicator = ellmer::type_enum(c("ipd", "opd"), "Utilization metric to map."),
        map_years = ellmer::type_array(ellmer::type_integer(), "Years to include; omit to use the cache's default mapping years.", required = FALSE)
      )
    ),
    ellmer::tool(
      function(path, indicator = "mmr") mcp_get_mortality_completeness_ratio(path, indicator = indicator),
      name = "get_mortality_completeness_ratio",
      description = "Get the completeness-adjusted mortality ratio compared against UN estimate bounds, for one mortality indicator.",
      arguments = list(
        path = path_arg,
        indicator = ellmer::type_enum(c("mmr", "sbr", "nn"), "Mortality indicator: mmr (maternal), sbr (stillbirth), or nn (neonatal).")
      )
    ),
    ellmer::tool(
      function(path, report_name, output_format = "word_document", adminlevel_1 = NULL) {
        mcp_generate_report(path, report_name = report_name, output_format = output_format, adminlevel_1 = adminlevel_1)
      },
      name = "generate_report",
      description = paste(
        "Render one of cd2030.core's existing report templates (e.g. data_quality,",
        "national_coverage, national_inequality, mortality, health_system,",
        "private_sector, service_utilization, synthesis_report) to a file in a",
        "reports/ folder next to the cache, and return its path. Does not accept an",
        "arbitrary destination path."
      ),
      arguments = list(
        path = path_arg,
        report_name = ellmer::type_string("Report template name, e.g. data_quality, national_coverage, mortality, synthesis_report."),
        output_format = ellmer::type_enum(c("word_document", "pdf_document"), "Output file format."),
        adminlevel_1 = region_arg("Optional adminlevel_1 region to scope a subnational one-pager report to.")
      )
    ),
    ellmer::tool(
      function(path, indicator, admin_level = "national", region = NULL) {
        ellmer::content_image_file(
          mcp_render_coverage_plot(path, indicator = indicator, admin_level = admin_level, region = region),
          "image/png",
          resize = "none"
        )
      },
      name = "get_coverage_plot",
      description = "Render a coverage-over-time line chart (DHIS2/WUENIC/survey estimates) for one indicator and return it as an image.",
      arguments = list(
        path = path_arg,
        indicator = ellmer::type_string("Coverage indicator to plot, e.g. penta1, anc4, measles1."),
        admin_level = ellmer::type_enum(c("national", "adminlevel_1", "district"), "Level to plot coverage at."),
        region = region_arg("Optional region to filter to; required when admin_level is adminlevel_1 or district.")
      )
    )
  )
}
