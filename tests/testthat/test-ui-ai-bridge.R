test_that("the current page's filter chips are found by their input ids", {
  ids <- c("coverage-admin-admin", "coverage-admin-region", "coverage-years", "coverage-ind-indicator",
           "coverage-denom-denominator", "equity-years", "tabs", "coverage-page-notes")
  expect_identical(.cd_ai_filter_ids(ids, "coverage", "years"), "coverage-years")
  expect_identical(.cd_ai_filter_ids(ids, "coverage", "admin"), "coverage-admin-admin")
  expect_identical(.cd_ai_filter_ids(ids, "equity", "admin"), character(0))
  expect_identical(.cd_ai_filter_ids(ids, NULL, "years"), character(0))
})

test_that("the filters in effect are one value per kind, years as integers", {
  values <- list("coverage-admin-admin" = "district", "coverage-admin-region" = "Nairobi", "coverage-years" = "2020,2021",
                 "coverage-ind-indicator" = "penta3", "coverage-denom-denominator" = "", tabs = "coverage")
  f <- .cd_ai_filters(values, "coverage")
  expect_identical(f, list(admin_level = "district", region = "Nairobi", years = c(2020L, 2021L), indicator = "penta3"))
  values[["coverage-years"]] <- ""
  expect_null(.cd_ai_filters(values, "coverage")$years)
  expect_null(.cd_ai_filters(values, "introduction"))
})

test_that("setFilters is a change action describing its filters", {
  a <- .cd_ai_actions()[[1]]
  expect_identical(a$name, "setFilters")
  expect_identical(a$kind, "change")
  expect_setequal(names(a$args), names(.cd_ai_filter_names))
})

test_that("the Countdown actions are setFilters, saveReport, addGraph and generateReport, all change", {
  actions <- .cd_ai_actions()
  expect_identical(vapply(actions, `[[`, "", "name"), c("setFilters", "saveReport", "addGraph", "generateReport"))
  expect_true(all(vapply(actions, `[[`, "", "kind") == "change"))
})

test_that("about gives the report kind and the options that are ready, without computing", {
  ready <- function() "anc4"
  broken <- function() stop("not ready")
  about <- .cd_about("coverage", indicator = ready, region = broken, admin_level = "", level = NULL, variant = "trend")()
  expect_identical(about$kind, "coverage")
  expect_identical(about$options, list(indicator = "anc4", variant = "trend"))
  none <- .cd_about(NULL)()
  expect_null(none$kind)
  expect_identical(length(none$options), 0L)
})

test_that("new ids and file names for what the AI adds", {
  expect_identical(.cd_ai_new_id("graph-", character()), "graph-1")
  expect_identical(.cd_ai_new_id("graph-", c("graph-1", "graph-2")), "graph-3")
  expect_identical(.cd_ai_new_id("graph-", c("graph-2", "x")), "graph-3")
  expect_identical(.cd_ai_file_stem("National coverage / 2023!"), "National_coverage_2023")
  expect_identical(.cd_ai_file_stem(NULL), "report")
})
