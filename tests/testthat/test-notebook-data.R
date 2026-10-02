# notebook_data(): a folder's datasets for DataSuite's notebooks -- listed from the file names, prepared as Stata
# files for Python and Stata, attached by name in R -- and the .rds never written.

nb_folder <- function(env = parent.frame()) {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  folder <- withr::local_tempdir(.local_envir = env)
  cd <- suppressMessages(load_data(path, indicator_group = "rmncah"))
  cc <- suppressMessages(init_CacheConnection(countdown_data = cd))
  suppressMessages(cc$set_cache_path(file.path(folder, "CAM_2026_KENYA_TEST_rmncah.rds")))
  file.copy(file.path(folder, "CAM_2026_KENYA_TEST_rmncah.rds"), file.path(folder, "OTHER - COUNTRY_rmncah.rds"))
  writeLines("x", file.path(folder, "CAM_2026_KENYA_TEST.xlsx"))
  writeLines("x", file.path(folder, "Somalia - CAM2026.xlsx"))
  dir.create(file.path(folder, "CAM_2026_KENYA_TEST_rmncah.shiny-workspace", "notebooks"), recursive = TRUE)
  dir.create(file.path(folder, "OLD_PROJECT.shiny-workspace"))
  folder
}

nb_md5 <- function(folder) unname(tools::md5sum(list.files(folder, pattern = "\\.rds$", full.names = TRUE)))

test_that("the list comes from the file names: the notebook's own dataset, the others, what is not loaded yet", {
  folder <- nb_folder()
  ws <- file.path(folder, "CAM_2026_KENYA_TEST_rmncah.shiny-workspace")
  writeLines("not an rds", file.path(folder, "broken_rmncah.rds"))   # listed without being opened
  l <- notebook_data("list", folder, ws)
  status <- vapply(l$datasets, function(d) d$status, "")
  names(status) <- vapply(l$datasets, function(d) d$name, "")
  expect_equal(status[["CAM_2026_KENYA_TEST_rmncah"]], "ok")
  expect_equal(status[["broken_rmncah"]], "ok")
  expect_equal(status[["Somalia - CAM2026"]], "not-loaded")
  expect_equal(status[["OLD_PROJECT"]], "workspace-only")
  own <- Filter(function(d) isTRUE(d$own), l$datasets)
  expect_length(own, 1)
  expect_equal(own[[1]]$name, "CAM_2026_KENYA_TEST_rmncah")
  expect_true("ref_wuenic" %in% vapply(l$ref$tables, function(t) t$name, ""))
})

test_that("prepare writes the tables as Stata files once, and again when the .rds has changed", {
  folder <- nb_folder()
  ws <- file.path(folder, "CAM_2026_KENYA_TEST_rmncah.shiny-workspace")
  before <- nb_md5(folder)

  p <- notebook_data("prepare", folder, ws, datasets = list("OTHER - COUNTRY_rmncah", "ref"))
  expect_setequal(vapply(p$refreshed, function(r) r$dataset, ""), c("CAM_2026_KENYA_TEST_rmncah", "OTHER - COUNTRY_rmncah", "ref"))
  expect_true(all(c("countdown_data", "kept_data", "settings") %in% unlist(p$own_tables)))
  x <- haven::read_dta(file.path(ws, "data", "countdown_data.dta"))
  expect_gt(nrow(x), 0)
  expect_match(attr(x, "label"), "^CAM_2026_KENYA_TEST_rmncah countdown_data, revision")
  expect_false(is.null(attr(x$year, "label")))                  # the data dictionary's description
  expect_true(file.exists(file.path(ws, "data", "_others", "OTHER___COUNTRY_rmncah__countdown_data.dta")))
  expect_true(file.exists(file.path(ws, "data", "_others", "ref_wuenic.dta")))

  # within the period: nothing is looked at again; forced but unchanged: nothing is written
  expect_length(notebook_data("prepare", folder, ws)$refreshed, 0)
  expect_length(notebook_data("prepare", folder, ws, force = TRUE)$refreshed, 0)
  # the app saved (the file changed): read again
  rds <- file.path(folder, "CAM_2026_KENYA_TEST_rmncah.rds")
  Sys.setFileTime(rds, Sys.time() + 5)
  again <- notebook_data("prepare", folder, ws, period = 0)
  expect_equal(vapply(again$refreshed, function(r) r$dataset, ""), "CAM_2026_KENYA_TEST_rmncah")

  expect_equal(nb_md5(folder), before)
})

test_that("in R the tables are there by name, read when used and again once the .rds changed", {
  folder <- nb_folder()
  ws <- file.path(folder, "CAM_2026_KENYA_TEST_rmncah.shiny-workspace")
  before <- nb_md5(folder)
  withr::defer(while ("datasuite:data" %in% search()) detach("datasuite:data", character.only = TRUE))

  notebook_data("attach", folder, ws, period = 0)
  data_env <- as.environment("datasuite:data")
  expect_true(bindingIsActive("countdown_data", data_env))
  expect_gt(nrow(get("countdown_data", data_env)), 0)
  expect_true(get("cache", data_env)$read_only)
  expect_gt(nrow(get("ds_use", data_env)("OTHER - COUNTRY_rmncah/countdown_data")), 0)
  expect_gt(nrow(get("ref_wuenic", data_env)), 0)
  expect_true("OTHER - COUNTRY_rmncah/kept_data" %in% get("ds_list", data_env)()$use)

  rds <- file.path(folder, "CAM_2026_KENYA_TEST_rmncah.rds")
  Sys.setFileTime(rds, Sys.time() + 5)
  expect_message(get("countdown_data", data_env), "reloaded")

  suppressMessages(get("ds_save", data_env)(data.frame(district = "a", n = 1), "my check"))
  expect_true(file.exists(file.path(ws, "data", "my_check.dta")))
  expect_equal(get("ds_use", data_env)("my_check")$n, 1)
  expect_equal(get("my_check", data_env)$n, 1)

  expect_equal(nb_md5(folder), before)
})

test_that("every table of the dataset is listed with what it holds, and prepare writes only those asked for", {
  folder <- nb_folder()
  ws <- file.path(folder, "CAM_2026_KENYA_TEST_rmncah.shiny-workspace")
  own <- Filter(function(d) isTRUE(d$own), notebook_data("list", folder, ws)$datasets)[[1]]
  names <- vapply(own$tables, function(t) t$name, "")
  expect_true(all(c("countdown_data", "adjusted_data", "indicator_coverage_national", "overall_score") %in% names))
  expect_false("shapefile" %in% names)
  expect_false(any(duplicated(names)))
  what <- vapply(own$tables, function(t) t$what %||% NA_character_, "")
  expect_match(what[names == "countdown_data"], "HMIS data")
  expect_false(any(vapply(own$tables, function(t) isTRUE(t$ready), NA)))   # nothing written yet

  p <- notebook_data("prepare", folder, ws, tables = "reporting_rate_national")
  expect_equal(unlist(p$own_tables), "reporting_rate_national")
  expect_equal(list.files(file.path(ws, "data"), pattern = "\\.dta$"), "reporting_rate_national.dta")
  # another table asked for within the period is written at once; the first is kept
  p <- notebook_data("prepare", folder, ws, tables = "countdown_data")
  expect_setequal(unlist(p$own_tables), c("reporting_rate_national", "countdown_data"))
  own <- Filter(function(d) isTRUE(d$own), notebook_data("list", folder, ws)$datasets)[[1]]
  ready <- Filter(function(t) isTRUE(t$ready), own$tables)
  expect_setequal(vapply(ready, function(t) t$name, ""), c("reporting_rate_national", "countdown_data"))
})
