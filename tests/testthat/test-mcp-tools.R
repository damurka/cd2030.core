test_that("mcp_shape_table returns all rows untruncated when under the cap", {
  df <- tibble::tibble(x = 1:5)
  out <- mcp_shape_table(df, cap = 200L)

  expect_identical(nrow(out$data), 5L)
  expect_identical(out$meta$returned_rows, 5L)
  expect_identical(out$meta$total_rows, 5L)
  expect_false(out$meta$truncated)
  expect_null(out$meta$notice)
})

test_that("mcp_shape_table truncates and adds a notice when over the cap", {
  df <- tibble::tibble(x = 1:250)
  out <- mcp_shape_table(df, cap = 200L)

  expect_identical(nrow(out$data), 200L)
  expect_identical(out$meta$returned_rows, 200L)
  expect_identical(out$meta$total_rows, 250L)
  expect_true(out$meta$truncated)
  expect_match(out$meta$notice, "Showing 200 of 250 rows")
})

test_that("mcp_shape_table handles NULL and empty data frames", {
  out_null <- mcp_shape_table(NULL)
  expect_identical(out_null$meta$total_rows, 0L)
  expect_false(out_null$meta$truncated)

  out_empty <- mcp_shape_table(tibble::tibble(x = integer()))
  expect_identical(out_empty$meta$total_rows, 0L)
  expect_false(out_empty$meta$truncated)
})

test_that("mcp_get_cache errors clearly when nothing is loaded for the path", {
  mcp_session_reset()
  on.exit(mcp_session_reset())

  target <- tempfile(fileext = ".rds")
  saveRDS(list(), target)
  on.exit(unlink(target), add = TRUE)

  expect_error(mcp_get_cache(target), "load_cache", class = "cd2030_error")
})

# --- Integration tests against a real, fully-configured cache -------------
#
# These exercise the full read surface end-to-end, but need a real .rds
# CacheConnection cache with denominators/survey estimates/etc. already set
# (this package ships no such fixture). Point CD2030_MCP_TEST_RDS at one to
# run them; they're skipped otherwise.

mcp_test_rds <- Sys.getenv("CD2030_MCP_TEST_RDS", unset = NA)
skip_mcp_integration <- is.na(mcp_test_rds) || !file.exists(mcp_test_rds)

test_that("mcp_load_cache + mcp_get_data_overview work against a real cache", {
  skip_if(skip_mcp_integration, "CD2030_MCP_TEST_RDS not set to an existing cache")
  mcp_session_reset()
  on.exit(mcp_session_reset())

  summary <- mcp_load_cache(mcp_test_rds)
  expect_type(summary, "list")
  expect_true(nzchar(summary$country))
  expect_true(length(summary$data_years) > 0)

  overview <- mcp_get_data_overview(mcp_test_rds)
  expect_identical(overview$summary$country, summary$country)
  expect_true(overview$subnational_regions$meta$total_rows > 0)
})

test_that("read tools across every pipeline layer succeed against a real cache", {
  skip_if(skip_mcp_integration, "CD2030_MCP_TEST_RDS not set to an existing cache")
  mcp_session_reset()
  on.exit(mcp_session_reset())

  mcp_load_cache(mcp_test_rds)

  expect_true(mcp_get_overall_score(mcp_test_rds, admin_level = "national")$meta$total_rows > 0)
  expect_true(mcp_get_indicator_coverage(mcp_test_rds, admin_level = "national")$meta$total_rows > 0)
  expect_true(mcp_get_inequality(mcp_test_rds, admin_level = "adminlevel_1")$meta$total_rows > 0)
  expect_true(mcp_get_mortality_summary(mcp_test_rds, indicator = "mmr")$meta$total_rows > 0)
  expect_true(mcp_get_service_utilization(mcp_test_rds, admin_level = "national", indicator = "opd")$meta$total_rows > 0)
  expect_true(mcp_get_health_system_metrics(mcp_test_rds, admin_level = "national")$meta$total_rows > 0)
  expect_true(mcp_get_private_sector_data(mcp_test_rds)$meta$total_rows > 0)

  mapping <- mcp_get_mapping_data(mcp_test_rds, admin_level = "adminlevel_1", indicator = "penta1", palette = "Blues")
  expect_true(mapping$meta$total_rows > 0)
  expect_false("geometry" %in% names(mapping$data))
})

test_that("mcp_render_coverage_plot renders a real PNG", {
  skip_if(skip_mcp_integration, "CD2030_MCP_TEST_RDS not set to an existing cache")
  mcp_session_reset()
  on.exit(mcp_session_reset())

  mcp_load_cache(mcp_test_rds)
  path <- mcp_render_coverage_plot(mcp_test_rds, indicator = "penta1", admin_level = "national")
  on.exit(unlink(path), add = TRUE)

  expect_true(file.exists(path))
  expect_true(file.info(path)$size > 0)
})

test_that("multiple sessions can be open at once, keyed by path", {
  skip_if(skip_mcp_integration, "CD2030_MCP_TEST_RDS not set to an existing cache")
  mcp_session_reset()
  on.exit(mcp_session_reset())

  # Loading the same cache under its own path twice should not evict itself.
  mcp_load_cache(mcp_test_rds)
  mcp_load_cache(mcp_test_rds)
  expect_identical(mcp_session_count(), 1L)
})
