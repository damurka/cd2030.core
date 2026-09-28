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

test_that("the Countdown actions: setFilters (view), saveReport, addGraph, generateReport (add), listReports, readReport (read), updateBlocks (replace)", {
  actions <- .cd_ai_actions()
  expect_identical(vapply(actions, `[[`, "", "name"),
                   c("setFilters", "saveReport", "addGraph", "generateReport", "listReports", "readReport", "updateBlocks"))
  expect_identical(vapply(actions, `[[`, "", "kind"), c("view", "add", "add", "add", "read", "read", "replace"))
  expect_true(all(vapply(actions[2:4], function(a) is.function(a$classify), NA)))
  expect_true(is.function(actions[[7]]$summary))
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

# ---- reading and changing a saved report -----------------------------------------------------------------------------

ai_report_ds <- function() {
  env <- new.env()
  env$saved <- list()
  env$report_projects <- list(
    r1 = list(name = "Benin National Coverage", lang = "fr", design = list(theme = "countdown"), cover = list(title = "Cover"),
              blocks = list(list(id = "h1", type = "heading", level = 1, text = "Introduction"),
                            list(id = "c1", type = "chart", kind = "coverage", indicator = "anc4", admin_level = "national"),
                            list(id = "p1", type = "paragraph", text = ""),
                            list(id = "c2", type = "chart", kind = "coverage", indicator = "penta3", admin_level = "national"),
                            list(id = "p2", type = "paragraph", text = ""))))
  env$cache_path <- "C:/data/benin.rds"
  env$language <- "fr"
  env$set_report_project <- function(id, project) {
    env$saved[[id]] <- project
    env$report_projects[[id]] <- project
  }
  env
}

test_that("listReports lists the saved reports", {
  ds <- ai_report_ds()
  local_mocked_bindings(.cd_ai_cache = function(session) ds)
  listed <- .cd_ai_list_reports()$fn(list(), NULL)
  expect_identical(listed[[1]][c("id", "name", "kind", "lang", "blocks")],
                   list(id = "r1", name = "Benin National Coverage", kind = "report", lang = "fr", blocks = 5L))
})

test_that("readReport reads a saved report (without its data here) and names the reports when the id is wrong", {
  ds <- ai_report_ds()
  local_mocked_bindings(.cd_ai_cache = function(session) ds)
  read <- .cd_ai_read_report()
  r <- read$fn(list(reportId = "r1", data = FALSE), NULL)
  expect_identical(r$id, "r1")
  expect_identical(r$lang, "fr")
  expect_identical(vapply(r$blocks, `[[`, "", "id"), c("h1", "c1", "p1", "c2", "p2"))
  expect_error(read$fn(list(reportId = "nope"), NULL), "There is no saved report \"nope\". The saved reports: r1.")
  expect_error(read$fn(list(), NULL), "Say which report")
})

test_that("updateBlocks changes only the blocks named, keeps the report's id, and asks the user with a summary", {
  ds <- ai_report_ds()
  before <- ds$report_projects$r1
  local_mocked_bindings(.cd_ai_cache = function(session) ds)
  update <- .cd_ai_update_blocks()
  changes <- list(list(blockId = "p1", text = "ANC4 rose."), list(blockId = "p2", text = "Penta3 stayed."),
                  list(afterBlockId = "p2", insert = list(type = "paragraph", text = "In short.")),
                  list(afterBlockId = "@start", insert = list(type = "heading", text = "Summary")))
  expect_identical(update$summary(list(reportId = "r1", changes = changes), NULL),
                   "Write 3 paragraphs and 1 heading in the report \"Benin National Coverage\" (benin.rds)")
  # the summary changes nothing
  expect_length(ds$saved, 0)
  out <- update$fn(list(reportId = "r1", changes = changes), NULL)
  saved <- ds$saved$r1
  expect_identical(saved$id, "r1")
  expect_match(saved$updated, "^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$")
  expect_identical(saved[c("name", "lang", "design", "cover")], before[c("name", "lang", "design", "cover")])
  ids <- vapply(saved$blocks, `[[`, "", "id")
  expect_identical(ids[c(2, 3, 5)], c("h1", "c1", "c2"))
  expect_identical(saved$blocks[[3]], before$blocks[[2]])
  expect_identical(saved$blocks[[5]], before$blocks[[4]])
  expect_identical(vapply(saved$blocks, function(b) b$text %||% "", "")[c(1, 4, 6, 7)], c("Summary", "ANC4 rose.", "Penta3 stayed.", "In short."))
  expect_length(out$changes, 4)
  # other changes are listed
  expect_match(update$summary(list(reportId = "r1", changes = list(list(blockId = "c1", kind = "coverage", admin_level = "adminlevel_1"))), NULL),
               "^Change the report \"Benin National Coverage\" [(]benin.rds[)]: Chart ")
  # a wrong change is refused and nothing is saved
  ds$saved <- list()
  expect_error(update$fn(list(reportId = "r1", changes = list(list(blockId = "nope", text = "x"))), NULL), "there is no block nope")
  expect_length(ds$saved, 0)
})

test_that("a report the AI saves carries its own id (the Reports page saves edits by it)", {
  ds <- ai_report_ds()
  local_mocked_bindings(.cd_ai_cache = function(session) ds)
  save <- .cd_ai_save_report()
  out <- save$fn(list(project = list(name = "New", blocks = list(list(type = "paragraph", text = "Hello")))), NULL)
  expect_identical(out$reportId, "ai-report-2")
  expect_identical(ds$saved[["ai-report-2"]]$id, "ai-report-2")
  save$fn(list(project = list(name = "Again", blocks = list(list(type = "paragraph", text = "Hi"))), reportId = "r1"), NULL)
  expect_identical(ds$saved$r1$id, "r1")
})
