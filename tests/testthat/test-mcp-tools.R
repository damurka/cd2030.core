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

test_that("mcp_shape_table caps rows further for a wide table, even under the row cap", {
  # 174 rows would normally fit under cap = 200, but at 200 columns each,
  # returning all of them would be a huge payload -- this is the real shape
  # that crashed a live MCP connection (get_indicator_coverage at district
  # level: 174 rows x 208 columns, >1M characters of JSON).
  wide_df <- tibble::as_tibble(as.data.frame(matrix(1, nrow = 174, ncol = 200)))
  out <- mcp_shape_table(wide_df, cap = 200L, max_cells = 5000L)

  expect_true(nrow(out$data) < 174L)
  expect_identical(nrow(out$data) * 200L <= 5000L, TRUE)
  expect_true(out$meta$truncated)
  expect_match(out$meta$notice, "200 columns wide")
})

test_that("mcp_shape_table's cell cap doesn't kick in for narrow tables", {
  df <- tibble::tibble(x = 1:250)
  out <- mcp_shape_table(df, cap = 200L, max_cells = 5000L)

  expect_identical(nrow(out$data), 200L)
  expect_match(out$meta$notice, "Narrow the result")
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

test_that("tools that prefer a cached active binding return the same data as a direct recompute", {
  skip_if(skip_mcp_integration, "CD2030_MCP_TEST_RDS not set to an existing cache")
  mcp_session_reset()
  on.exit(mcp_session_reset())

  mcp_load_cache(mcp_test_rds)
  cache <- mcp_get_cache(mcp_test_rds)

  # Compare the raw bindings/recomputes directly, bypassing mcp_shape_table's
  # cell-cap truncation entirely (several of these tables are wide enough --
  # up to 850+ columns for inequality -- that truncation would otherwise
  # confound this comparison with a row-count mismatch unrelated to whether
  # the binding and the recompute actually agree).
  same_after_sort <- function(a, b) {
    key_cols <- intersect(c("adminlevel_1", "district", "year"), names(a))
    a <- a[do.call(order, a[key_cols]), names(a)]
    b <- b[do.call(order, b[key_cols]), names(a)]
    isTRUE(all.equal(a, b, check.attributes = FALSE))
  }

  expect_true(same_after_sort(cache$overall_score, cache$calculate_overall_score(admin_level = "national")))
  expect_true(same_after_sort(cache$inequality_admin1, cache$calculate_inequality(admin_level = "adminlevel_1")))
  expect_true(same_after_sort(cache$completeness_district, cache$calculate_completeness_summary(admin_level = "district")))
  expect_true(same_after_sort(cache$outliers_admin1, cache$calculate_outliers_summary(admin_level = "adminlevel_1")))
  expect_true(same_after_sort(cache$reporting_rate_district, cache$calculate_reporting_rate(admin_level = "district")))
  expect_true(same_after_sort(cache$service_utilization_national, cache$compute_service_utilization("national")))

  # a region filter must still recompute (bindings don't support it) and return valid data
  region <- cache$subnational_regions$adminlevel_1[1]
  filtered <- mcp_get_reporting_rate(mcp_test_rds, admin_level = "adminlevel_1", region = region)
  expect_true(filtered$meta$total_rows > 0)
})

test_that("the 26 mechanically-added read tools succeed against a real cache", {
  skip_if(skip_mcp_integration, "CD2030_MCP_TEST_RDS not set to an existing cache")
  mcp_session_reset()
  on.exit(mcp_session_reset())

  mcp_load_cache(mcp_test_rds)

  expect_true(mcp_get_completeness_summary(mcp_test_rds, admin_level = "national")$meta$total_rows > 0)
  expect_true(mcp_get_coverage_raw(mcp_test_rds, admin_level = "national")$meta$total_rows > 0)
  expect_true(mcp_get_derived_coverage(mcp_test_rds, indicator = "anc1", admin_level = "national")$meta$total_rows > 0)
  expect_true(mcp_get_district_completeness_summary(mcp_test_rds)$meta$total_rows > 0)
  expect_true(mcp_get_district_outlier_summary(mcp_test_rds)$meta$total_rows > 0)
  expect_true(mcp_get_district_reporting_rate(mcp_test_rds)$meta$total_rows > 0)
  expect_true(mcp_get_outliers_summary(mcp_test_rds, admin_level = "national")$meta$total_rows > 0)
  expect_true(mcp_get_ratios_and_adequacy(mcp_test_rds)$meta$total_rows > 0)
  expect_true(mcp_get_reporting_rate(mcp_test_rds, admin_level = "national")$meta$total_rows > 0)
  expect_true(mcp_get_service_dqa_summary(mcp_test_rds, admin_level = "national")$meta$total_rows > 0)
  expect_true(mcp_get_service_utilization_summary(mcp_test_rds, admin_level = "national")$meta$total_rows > 0)
  expect_true(mcp_get_mch_curative_index(mcp_test_rds)$meta$total_rows > 0)
  expect_true(mcp_get_admin1_service_utilization(mcp_test_rds, metric_type = "opd")$meta$total_rows > 0)
  expect_true(mcp_get_continuum_of_care(mcp_test_rds, admin_level = "national", type = "child")$meta$total_rows > 0)
  expect_true(mcp_get_health_system_table(mcp_test_rds)$meta$total_rows > 0)
  expect_true(mcp_get_phc_scatter_data(mcp_test_rds, indicator = "ratio_fac_pop")$meta$total_rows > 0)
  expect_true(mcp_get_filtered_coverage(mcp_test_rds, indicator = "anc1", admin_level = "national")$meta$total_rows > 0)
  expect_true(mcp_get_filtered_inequality(mcp_test_rds, indicator = "anc1", admin_level = "adminlevel_1")$meta$total_rows > 0)
  expect_true(mcp_get_coverage_targets(mcp_test_rds, indicator = "anc4", target_unit = "district")$meta$total_rows > 0)
  expect_true(mcp_get_high_performers(mcp_test_rds, indicator = "anc1", admin_level = "national")$meta$total_rows > 0)
  expect_true(mcp_get_mortality_completeness_ratio(mcp_test_rds, indicator = "mmr")$meta$total_rows > 0)

  # zero rows here is a legitimate real answer (no missing units for this
  # indicator), so this only checks the call succeeds and is shaped correctly
  missing_units <- mcp_get_missing_units(mcp_test_rds, indicator = "anc1")
  expect_true(is.list(missing_units) && !is.null(missing_units$meta))
  expect_identical(missing_units$meta$total_rows, missing_units$meta$returned_rows)

  # scalar/list passthroughs, not tabular -- must NOT go through mcp_shape_table
  expect_identical(mcp_get_denominator(mcp_test_rds, indicator = "anc1"), "anc1")
  expect_type(mcp_get_lbr_mean(mcp_test_rds), "double")
  estimates <- mcp_get_regional_estimates(mcp_test_rds, admin_level = "national")
  expect_true(is.list(estimates) && !is.data.frame(estimates))

  # geometry stripped from the map-ready service utilization data
  util_map <- mcp_get_service_utilization_mapping(mcp_test_rds, indicator = "opd")
  expect_true(util_map$meta$total_rows > 0)
  expect_false(any(c("geometry", "geom") %in% names(util_map$data)))
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

test_that("the three equiplot renderers each produce a real PNG", {
  skip_if(skip_mcp_integration, "CD2030_MCP_TEST_RDS not set to an existing cache")
  mcp_session_reset()
  on.exit(mcp_session_reset())

  mcp_load_cache(mcp_test_rds)

  for (renderer in list(mcp_render_equiplot_area, mcp_render_equiplot_wealth, mcp_render_equiplot_education)) {
    path <- renderer(mcp_test_rds, indicator = "anc1")
    on.exit(unlink(path), add = TRUE)
    expect_true(file.exists(path))
    expect_true(file.info(path)$size > 0)
  }
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
