# A computation uses the indicator group of the dataset it is given, not the one the session last selected.

test_that("a dataset is computed with its own group, whatever the session selected", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  old <- get_selected_group()
  on.exit(set_selected_group(old), add = TRUE)

  cd <- suppressMessages(load_data(path, indicator_group = "rmncah"))
  expect_identical(cd_data_group(cd), "rmncah")

  set_selected_group("rmncah")
  expected <- suppressWarnings(suppressMessages(calculate_district_outlier_summary(cd)))
  set_selected_group("vaccine")
  got <- suppressWarnings(suppressMessages(calculate_district_outlier_summary(cd)))
  expect_identical(got, expected)
  # and the session's group is as it was left
  expect_identical(get_selected_group(), "vaccine")
})

test_that("data that does not say its group is computed with the session's", {
  expect_null(cd_data_group(data.frame(x = 1)))
  expect_null(cd_data_group(structure(data.frame(x = 1), indicator_group = "no such group")))
  old <- get_selected_group()
  on.exit(set_selected_group(old), add = TRUE)
  set_selected_group("vaccine")
  f <- function(d) { local_data_group(d); get_selected_group() }
  expect_identical(f(data.frame(x = 1)), "vaccine")
  expect_identical(f(structure(data.frame(x = 1), indicator_group = "rmncah")), "rmncah")
  expect_identical(get_selected_group(), "vaccine")
})

test_that("each coverage is defined once and computed on every denominator", {
  for (group in c("rmncah", "vaccine")) {
    for (source in c("un", "dhis2", "anc1", "penta1")) {
      exprs <- .cd_coverage_exprs(source, group)
      expect_true(all(startsWith(names(exprs), "cov_")) && all(endsWith(names(exprs), paste0("_", source))))
      expect_false(anyDuplicated(names(exprs)) > 0)
    }
  }
  # the UN's and DHIS2's populations are in thousands; the live births are the source's own there
  expect_identical(deparse(.cd_coverage_exprs("un", "rmncah")$cov_bcg_un), "100 * bcg/(un_births * 1000)")
  expect_identical(deparse(.cd_coverage_exprs("dhis2", "rmncah")$cov_sba_dhis2), "100 * sba/(totlivebirths_dhis2 * 1000)")
  expect_identical(deparse(.cd_coverage_exprs("anc1", "rmncah")$cov_csection_anc1), "100 * csection/totdeliv_anc1")
  # as in Stata: the live births in facilities over the deliveries
  expect_identical(deparse(.cd_coverage_exprs("penta1", "rmncah")$cov_instdeliveries_penta1), "100 * instlivebirths/totdeliv_penta1")
  expect_true("cov_zerodose_un" %in% names(.cd_coverage_exprs("un", "vaccine")))
  expect_false("cov_zerodose_un" %in% names(.cd_coverage_exprs("un", "rmncah")))
})

test_that("new data clears the adjusted data made from the data before", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cd <- suppressMessages(load_data(path, indicator_group = "rmncah"))
  cache <- suppressMessages(init_CacheConnection(countdown_data = cd))
  private <- cache$.__enclos_env__$private
  suppressWarnings(suppressMessages(cache$adjust_data()))
  expect_false(is.null(private$.in_memory_data$adjusted_data))

  fewer <- cd[cd$year != max(cd$year), ]
  suppressWarnings(suppressMessages(cache$set_countdown_data(fewer)))
  expect_null(private$.in_memory_data$adjusted_data)
  # still asked for, so made again from the new data
  expect_true(isTRUE(cache$adjusted_flag))
  expect_false(max(cd$year) %in% suppressWarnings(suppressMessages(cache$adjusted_data))$year)
})

test_that("the population table prints its header", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cd <- suppressMessages(load_data(path, indicator_group = "rmncah"))
  metrics <- suppressWarnings(suppressMessages(prepare_population_metrics(cd, admin_level = "adminlevel_1")))
  expect_s3_class(metrics, "cd_population_metrics")
  expect_true("Table 2a" %in% names(pillar::tbl_sum(metrics)))
})

test_that("the adjustment's yearly numbers are kept, and cleared by what they are made from", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cd <- suppressMessages(load_data(path, indicator_group = "rmncah"))
  cache <- suppressMessages(init_CacheConnection(countdown_data = cd))
  private <- cache$.__enclos_env__$private
  values <- suppressWarnings(suppressMessages(cache$adjustment_values))
  expect_s3_class(values, "cd_adjustment_values")
  expect_equal(values, suppressWarnings(suppressMessages(
    generate_adjustment_values(cache$data_with_excluded_years, settings = cache$adjustment_settings))))
  expect_false(is.null(private$.in_memory_data$adjustment_values))
  expect_true("adjustment_values" %in% .cd_kept_dependents("adjusted_data"))
  suppressWarnings(suppressMessages(cache$set_excluded_years(max(cd$year))))
  expect_null(private$.in_memory_data$adjustment_values)
  expect_false(max(cd$year) %in% suppressWarnings(suppressMessages(cache$adjustment_values))$year)
})
