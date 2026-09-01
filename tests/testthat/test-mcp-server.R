test_that("mcp_tool_list builds one ellmer tool per pipeline-layer read plus load_cache/report/plot", {
  skip_if_not_installed("mcptools")
  skip_if_not_installed("ellmer")

  tools <- mcp_tool_list(max_sessions = 3L)
  names <- vapply(tools, function(t) t@name, character(1))

  expect_identical(
    names,
    c(
      "load_cache",
      "get_data_overview",
      "get_overall_score",
      "get_indicator_coverage",
      "get_inequality",
      "get_mortality_summary",
      "get_service_utilization",
      "get_health_system_metrics",
      "get_private_sector_data",
      "get_mapping_data",
      "generate_report",
      "get_coverage_plot"
    )
  )
})

test_that("cd2030_mcp_server errors clearly when mcptools/ellmer aren't installed", {
  skip_if(requireNamespace("mcptools", quietly = TRUE) && requireNamespace("ellmer", quietly = TRUE),
    "mcptools and ellmer are installed; can't exercise the missing-dependency path"
  )
  expect_error(cd2030_mcp_server(), class = "rlib_error_package_not_found")
})
