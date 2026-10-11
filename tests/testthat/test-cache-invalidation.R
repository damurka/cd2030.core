# A setting clears the kept tables it enters, and only those: a table cleared for nothing is rebuilt for nothing (a
# new performance threshold used to rebuild 16 tables, 11 of which came out the same), and a table not cleared that
# the setting does enter is shown as it was for the old value.

dqa_tables <- c("reporting_rate_national", "reporting_rate_admin1", "reporting_rate_district", "district_reporting_rate",
                "completeness_national", "completeness_admin1", "completeness_district", "district_completeness",
                "outliers_national", "outliers_admin1", "outliers_district", "district_outliers_summary",
                "list_outlier_units", "adequacy_ratios", "overall_score")
threshold_tables <- c("district_reporting_rate", "completeness_national", "completeness_admin1", "completeness_district",
                      "overall_score")

invalidation_cache <- function() {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cd <- suppressMessages(load_data(path, indicator_group = "rmncah"))
  suppressMessages(init_CacheConnection(countdown_data = cd))
}
kept_tables <- function(cache, tables) {
  held <- cache$.__enclos_env__$private$.in_memory_data
  tables[!vapply(tables, function(x) is.null(held[[x]]), logical(1))]
}
compute <- function(cache, tables) {
  suppressMessages(suppressWarnings(lapply(stats::setNames(tables, tables), function(x) cache[[x]])))
}

test_that("a new performance threshold clears the tables computed with it and no other", {
  cache <- invalidation_cache()
  compute(cache, dqa_tables)
  expect_setequal(kept_tables(cache, dqa_tables), dqa_tables)

  cache$set_performance_threshold(if (isTRUE(cache$performance_threshold == 60L)) 70L else 60L)
  expect_setequal(setdiff(dqa_tables, kept_tables(cache, dqa_tables)), threshold_tables)
})

test_that("the tables a new threshold leaves are the ones a fresh computation gives", {
  cache <- invalidation_cache()
  compute(cache, dqa_tables)
  cache$set_performance_threshold(if (isTRUE(cache$performance_threshold == 60L)) 70L else 60L)
  left <- setdiff(dqa_tables, threshold_tables)
  kept <- compute(cache, left)

  cache$.__enclos_env__$private$invalidate_cached_data()   # everything again, with the new threshold
  fresh <- compute(cache, left)
  for (x in left) expect_equal(kept[[x]], fresh[[x]], info = x)
})

test_that("the threshold's own tables are computed with it", {
  cache <- invalidation_cache()
  low <- { cache$set_performance_threshold(1L); compute(cache, threshold_tables) }
  high <- { cache$set_performance_threshold(100L); compute(cache, threshold_tables) }
  changed <- !vapply(threshold_tables, function(x) isTRUE(all.equal(low[[x]], high[[x]])), logical(1))
  expect_true(any(changed))
})

test_that("choosing a denominator clears nothing: it is applied when a table is read", {
  cache <- invalidation_cache()
  compute(cache, dqa_tables)
  private <- cache$.__enclos_env__$private
  # kept tables stand in for the coverage ones, which this fixture has no surveys to compute
  private$.in_memory_data$indicator_coverage_national <- data.frame(year = 2020L)
  private$.in_memory_data$inequality_admin1 <- data.frame(year = 2020L)
  private$.in_memory_data$bayesian_models <- list(national_penta3_penta1 = "kept")

  cache$set_denominator(if (identical(cache$denominator, "penta1")) "anc1" else "penta1")
  cache$set_maternal_denominator(if (identical(cache$maternal_denominator, "anc1")) "dhis2" else "anc1")
  held <- private$.in_memory_data
  expect_false(is.null(held$indicator_coverage_national))
  expect_false(is.null(held$inequality_admin1))
  expect_identical(held$bayesian_models, list(national_penta3_penta1 = "kept"))
  expect_setequal(kept_tables(cache, dqa_tables), dqa_tables)
})

test_that("a new survey year clears the coverage tables, which are computed from it", {
  cache <- invalidation_cache()
  private <- cache$.__enclos_env__$private
  private$.in_memory_data$indicator_coverage_national <- data.frame(year = 2020L)
  private$.in_memory_data$inequality_admin1 <- data.frame(year = 2020L)
  private$.in_memory_data$health_system_metrics_national <- data.frame(year = 2020L)

  cache$set_survey_year(if (isTRUE(cache$survey_year == 2015L)) 2016L else 2015L)
  held <- private$.in_memory_data
  expect_null(held$indicator_coverage_national)
  expect_null(held$inequality_admin1)
  # made from the adjusted data alone: the survey year does not enter them
  expect_false(is.null(held$health_system_metrics_national))
})

test_that("changed data clears every kept table", {
  cache <- invalidation_cache()
  compute(cache, dqa_tables)
  private <- cache$.__enclos_env__$private
  private$.in_memory_data$health_system_metrics_national <- data.frame(year = 2020L)
  private$.in_memory_data$indicator_coverage_national <- data.frame(year = 2020L)

  private$invalidate_cached_data()
  expect_length(kept_tables(cache, c(dqa_tables, "health_system_metrics_national", "indicator_coverage_national")), 0)
})

test_that("a new first survey year clears the results computed from the surveys", {
  cache <- invalidation_cache()
  private <- cache$.__enclos_env__$private
  private$.in_memory_data$indicator_coverage_admin1 <- data.frame(year = 2020L)
  private$.in_memory_data$inequality_admin1 <- data.frame(year = 2020L)
  private$.in_memory_data$bayesian_models <- list(national_penta3_penta1 = "kept")

  first <- min(cache$national_survey$year)
  cache$set_start_survey_year(as.integer(first) + 1L)
  held <- private$.in_memory_data
  expect_null(held$indicator_coverage_admin1)
  expect_null(held$inequality_admin1)
  expect_null(held$bayesian_models)
  # and every survey table is read from that year on
  expect_gte(min(cache$national_survey$year), first + 1L)
  expect_gte(min(cache$regional_survey$year), first + 1L)
})

test_that("the kept tables are described once: every input exists, and nothing is computed from itself", {
  tables <- cd2030.core:::.cd_kept_tables
  fields <- names(invalidation_cache()$.__enclos_env__$private$.data_template)
  reads <- unique(unlist(lapply(tables, `[[`, "reads")))
  expect_identical(setdiff(reads, c(fields, names(tables))), character())
  expect_identical(setdiff(names(tables), fields), character())
  for (name in names(tables)) expect_false(name %in% cd2030.core:::.cd_kept_dependents(name), info = name)
  # every table but the store filled from outside can be computed
  computed <- vapply(tables, function(t) is.function(t$compute), logical(1))
  expect_identical(names(tables)[!computed], "bayesian_models")
  # and the definitions say the same
  for (name in setdiff(names(tables), "bayesian_models")) expect_setequal(cache_definition(name)$depends_on, tables[[name]]$reads)
})

test_that("a setting clears what is computed from it through other tables too", {
  dependents <- cd2030.core:::.cd_kept_dependents
  expect_setequal(dependents("performance_threshold"),
                  c(threshold_tables, "bayesian_models"))
  expect_true(all(c("inequality_admin1", "health_system_comparison", "bayesian_models") %in% dependents("survey_year")))
  expect_false("health_system_metrics_national" %in% dependents("survey_year"))
  expect_setequal(dependents("un_mortality_estimates"), "mortality_ratios")
  expect_setequal(dependents("wuenic_estimates"), "bayesian_models")
  expect_identical(dependents("denominator"), character())
  expect_true(all(c("ratios_summary", "indicator_coverage_national") %in% dependents("survey_estimates")))
})

test_that("a kept table cannot be assigned", {
  cache <- invalidation_cache()
  expect_error(cache$overall_score <- 1, "read-only", class = "cd2030_error")
})
