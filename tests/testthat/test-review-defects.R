# Defects found reading the package against its own documentation (NEWS, 1.4.0): each stays fixed.

test_that("an error's bullets reach the user", {
  # cd_abort("x" = "...") puts the text in `...` and leaves `message` empty: "argument "message" is missing"
  expect_error(cd_abort(c("x" = "The title must be one string.")), "The title must be one string", class = "cd2030_error")

  r_dir <- test_path("..", "..", "R")
  skip_if_not(dir.exists(r_dir), "the package's sources are not here")
  bare <- unlist(lapply(list.files(r_dir, "\\.R$", full.names = TRUE), function(f) {
    lines <- readLines(f, warn = FALSE)
    hit <- grep("cd_abort\\(\\s*[\"'][xi!][\"']\\s*=", lines)
    if (length(hit)) paste0(basename(f), ":", hit)
  }))
  expect_identical(bare, NULL)
})

test_that("an error names the value it is about, not the variable holding it", {
  expect_error(check_ratio_pairs(list(a = "anc1")), "ratio pair", class = "cd2030_error")
  msg <- tryCatch(check_ratio_pairs(list(a = "anc1"), arg = "my_pairs"), error = function(e) conditionMessage(e))
  expect_match(msg, "my_pairs", fixed = TRUE)
})

test_that("the survey estimates leave OPV out by name outside the vaccine group", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cd <- suppressMessages(load_data(path, indicator_group = "rmncah"))
  cache <- suppressMessages(init_CacheConnection(countdown_data = cd))
  private <- cache$.__enclos_env__$private
  private$.in_memory_data$survey_estimates <- c(anc1 = 98, penta1 = 97, opv1 = 96, opv3 = 90)

  old <- get_selected_group()
  on.exit(set_selected_group(old), add = TRUE)
  set_selected_group("rmncah")
  expect_named(cache$survey_estimates, c("anc1", "penta1"))
  # the group is the dataset's own, not the session's
  attr(private$.in_memory_data$countdown_data, "indicator_group") <- "vaccine"
  expect_true(all(c("opv1", "opv3") %in% names(cache$survey_estimates)))
})

test_that("new survey estimates clear the ratios summary made from them", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cd <- suppressMessages(load_data(path, indicator_group = "rmncah"))
  cache <- suppressMessages(init_CacheConnection(countdown_data = cd))
  private <- cache$.__enclos_env__$private
  private$.in_memory_data$ratios_summary <- data.frame(year = "2020")

  current <- private$.in_memory_data$survey_estimates
  change <- current[1]
  change[] <- if (isTRUE(current[[1]] == 50)) 51 else 50
  suppressWarnings(suppressMessages(cache$set_survey_estimates(change)))
  expect_null(private$.in_memory_data$ratios_summary)
})

test_that("the education survey's levels are ordered in `level`, with no stray column", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cd <- suppressMessages(load_data(path, indicator_group = "rmncah"))
  cache <- suppressMessages(init_CacheConnection(countdown_data = cd))
  survey <- suppressMessages(cache$education_survey)
  expect_false("levels" %in% names(survey))
  expect_identical(levels(survey$level), c("none", "primary", "secondary+"))
})

test_that("the OPV comparison is labelled as OPV", {
  texts <- paste(deparse(body(plot_comparison_opv1_opv3)), collapse = " ")
  expect_match(texts, "OPV1 and OPV3", fixed = TRUE)
  expect_match(texts, 'x_title = "OPV1"', fixed = TRUE)
  expect_match(texts, 'y_title = "OPV3"', fixed = TRUE)
})

test_that("a class's check is named after the class, and nothing checks such a class another way", {
  ns <- asNamespace("cd2030.core")
  helpers <- grep("^check_cd_", ls(ns), value = TRUE)
  helpers <- setdiff(helpers, "check_cd_class")
  expect_true(length(helpers) >= 12)
  for (helper in helpers) {
    class <- sub("^check_", "", helper)
    check <- get(helper, envir = ns)
    expect_true(check(structure(list(), class = class)), info = helper)
    expect_error(check(structure(list(), class = "something_else")), class, class = "cd2030_error", info = helper)
  }

  r_dir <- test_path("..", "..", "R")
  skip_if_not(dir.exists(r_dir), "the package's sources are not here")
  classes <- sub("^check_", "", helpers)
  direct <- unlist(lapply(setdiff(list.files(r_dir, "[.]R$", full.names = TRUE), file.path(r_dir, "utils.R")), function(f) {
    lines <- readLines(f, warn = FALSE)
    hit <- grep(paste0("check_cd_class[(][^)]*[\"'](", paste(classes, collapse = "|"), ")[\"']"), lines)
    if (length(hit)) paste0(basename(f), ":", hit)
  }))
  expect_identical(direct, NULL)
})

test_that("the former filter_*() names still work, and say what to call instead", {
  former <- c("adjustment_value", "coverage", "inequality", "mapping_data", "mortality_summary", "service_utilization")
  ns <- asNamespace("cd2030.core")
  for (name in former) {
    expect_true(is.function(get(paste0("select_", name), envir = ns)), info = name)
    expect_true(paste0("filter_", name) %in% getNamespaceExports(ns), info = name)
  }
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cd <- suppressMessages(load_data(path, indicator_group = "rmncah"))
  values <- suppressWarnings(suppressMessages(generate_adjustment_values(cd)))
  rlang::reset_warning_verbosity("cd2030.core-filter_adjustment_value")
  expect_warning(old <- filter_adjustment_value(values, "anc1"), "select_adjustment_value", class = "cd2030_deprecated")
  expect_identical(old, select_adjustment_value(values, "anc1"))
  # once per session
  expect_no_warning(filter_adjustment_value(values, "anc1"))
})

test_that("a Stata file written by save_data() is read back, months and all", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  data <- suppressMessages(load_data(path))
  expect_false(any(startsWith(names(data), "raw_month")))
  file <- withr::local_tempfile(fileext = ".dta")
  save_data(data, file)
  back <- suppressMessages(load_data(file))
  expect_s3_class(back, "cd_data")
  expect_identical(nrow(back), nrow(data))
  expect_true(is.ordered(back$month))
  expect_identical(levels(back$month), month.name)
  expect_identical(as.character(back$month), as.character(data$month))
})

test_that("a table card with a year control downloads the year it shows", {
  i18n <- list(t = function(key, ...) key)
  rows <- data.frame(year = c(2021L, 2021L, 2022L), district = c("a", "b", "c"), value = 1:3)
  shiny::testServer(
    cd_table_server,
    args = list(id = "t", cache = shiny::reactive(NULL), i18n = i18n, data = shiny::reactive(rows),
                data_transform = function(d) d[d$value > 1, ]),
    {
      session$setInputs(control_input = "2021")
      expect_identical(download_data()$district, "b")
      session$setInputs(control_input = "2022")
      expect_identical(download_data()$district, "c")
    }
  )
  # a writer of the caller's own gets the year too, not transformed
  shiny::testServer(
    cd_table_server,
    args = list(id = "t", cache = shiny::reactive(NULL), i18n = i18n, data = shiny::reactive(rows),
                excel_write_fun = function(wb, d) NULL),
    {
      session$setInputs(control_input = "2021")
      expect_identical(download_data()$district, c("a", "b"))
    }
  )
})
