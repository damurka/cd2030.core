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
