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

test_that("setFilters changes the view, describing its filters", {
  a <- .cd_ai_actions()[[1]]
  expect_identical(a$name, "setFilters")
  expect_identical(a$kind, "view")
  expect_setequal(names(a$args), names(.cd_ai_filter_names))
  expect_identical(a$summary(list(years = c(2020, 2023), indicator = "anc4"), NULL),
                   "Set the filters on this page: years = 2020, 2023; indicator = anc4")
})

test_that("the Countdown actions are setFilters (view), then saveReport, addGraph and generateReport (add)", {
  actions <- .cd_ai_actions()
  expect_identical(vapply(actions, `[[`, "", "name"), c("setFilters", "saveReport", "addGraph", "generateReport"))
  expect_identical(vapply(actions, `[[`, "", "kind"), c("view", "add", "add", "add"))
  expect_true(all(vapply(actions[-1], function(a) is.function(a$classify), NA)))
})

test_that("saving over a saved report or graph replaces it, and the user sees what", {
  ds <- list(report_projects = list(`ai-report-1` = list(name = "Old")), graphs = list(`graph-1` = list(title = "Old chart")),
             cache_path = "C:/data/kenya.rds")
  session <- list(userData = list(cd_cache = function() ds))
  local_mocked_bindings(.cd_ai_cache = function(session) ds)
  save <- .cd_ai_actions()[[2]]
  project <- list(name = "New", blocks = list(list(type = "heading"), list(type = "chart"), list(type = "chart"), list(type = "image")))
  expect_identical(save$classify(list(project = project), session), "add")
  expect_identical(save$classify(list(project = project, reportId = "ai-report-9"), session), "add")
  expect_identical(save$classify(list(project = project, reportId = "ai-report-1"), session), "replace")
  expect_identical(save$summary(list(project = project), session),
                   "Save the report \"New\" (4 blocks: 2 charts, 1 picture) in kenya.rds")
  expect_identical(save$summary(list(project = project, reportId = "ai-report-1"), session),
                   "Replace the saved report \"Old\" with \"New\" (4 blocks: 2 charts, 1 picture) in kenya.rds")
  graph <- .cd_ai_actions()[[3]]
  expect_identical(graph$classify(list(spec = list(title = "T")), session), "add")
  expect_identical(graph$classify(list(spec = list(title = "T"), graphId = "graph-1"), session), "replace")
  expect_identical(graph$summary(list(spec = list(title = "T"), graphId = "graph-1"), session),
                   "Replace the saved chart \"Old chart\" with \"T\" in kenya.rds")
})

test_that("writing a report over an existing file replaces it", {
  dir <- withr::local_tempdir()
  withr::local_envvar(CDSUITE_SHINY_WORKSPACE_DIR = dir)
  ds <- list(report_projects = list(r1 = list(name = "My report")))
  local_mocked_bindings(.cd_ai_cache = function(session) ds)
  session <- list(input = list(selected_language = "en"))
  gen <- .cd_ai_actions()[[4]]
  args <- list(reportId = "r1", format = "pdf")
  expect_identical(gen$classify(args, session), "add")
  expect_match(gen$summary(args, session), "^Write \"My_report.pdf\" in .+[^g]$")
  expect_match(gen$summary(args, session), "reports")
  dir.create(file.path(dir, "reports"))
  writeLines("x", file.path(dir, "reports", "My_report.pdf"))
  expect_identical(gen$classify(args, session), "replace")
  expect_match(gen$summary(args, session), ", replacing the existing file$")
  expect_error(gen$classify(list(format = "pdf"), session), "Say which report")
})

test_that("block counts for what the user confirms", {
  expect_identical(.cd_ai_block_counts(list()), "")
  expect_identical(.cd_ai_block_counts(list(list(type = "paragraph"))), " (1 block)")
  expect_identical(.cd_ai_block_counts(list(list(type = "table"), list(type = "chart"))), " (2 blocks: 1 chart, 1 table)")
  expect_identical(.cd_ai_dataset_name(list(cache_path = NULL)), "the dataset")
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
