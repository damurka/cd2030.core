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

test_that("institutional deliveries have a coverage of their own, beside the live births per delivery", {
  defs <- .cd_coverage_exprs("penta1", "rmncah")
  expect_identical(deparse(defs$cov_ideliv_penta1), "100 * ideliv/totdeliv_penta1")
  expect_identical(deparse(defs$cov_instdeliveries_penta1), "100 * instlivebirths/totdeliv_penta1")
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cache <- suppressMessages(load_cache_data(path))
  cache$set_national_estimates(list(sbr = 0.02))
  suppressMessages(cache$adjust_data())
  coverage <- cache$indicator_coverage_national
  expect_true(all(c("cov_ideliv_dhis2", "cov_ideliv_penta1", "cov_instdeliveries_penta1") %in% names(coverage)))
  expect_false(anyNA(coverage$cov_ideliv_penta1))
  # what asks for the coverage of `ideliv` gets it (it was an empty row, with a warning)
  shown <- cache$get_filtered_coverage("ideliv", "national")
  expect_false(all(is.na(unlist(shown[1, -1]))))
})

test_that("charts name indicators by their labels, not their codes", {
  expect_identical(unname(cd_indicator_labels(indicators = c("anc1", "penta3", "nothing_known"))), c("ANC 1", "Pentavalent 3", "nothing_known"))
  french <- list(t = function(key) if (key == "opt_anc1") "CPN 1" else key)
  expect_identical(cd_indicator_labels(french, c("anc1", "penta3")), c(anc1 = "CPN 1", penta3 = "Pentavalent 3"))

  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  data <- suppressMessages(load_data(path))
  axis_text <- function(p) {
    built <- ggplot2::ggplot_build(p)
    unlist(lapply(built$layout$panel_params[[1]][c("x", "y")], function(a) a$get_labels()))
  }
  shown <- axis_text(plot(calculate_completeness_summary(data, "adminlevel_1")))
  expect_true(all(c("ANC 1", "Pentavalent 3", "Institutional Deliveries") %in% shown))
  expect_false(any(c("anc1", "penta3", "ideliv") %in% shown))
  shown <- axis_text(plot(calculate_outliers_summary(data, "adminlevel_1"), "heat_map"))
  expect_true("ANC 1" %in% shown)
  # the labels a page gives (translated) are used
  shown <- axis_text(plot(calculate_completeness_summary(data, "adminlevel_1"), indicator_labels = c(anc1 = "CPN 1")))
  expect_true("CPN 1" %in% shown)

  cache <- suppressMessages(load_cache_data(path))
  cache$set_national_estimates(list(sbr = 0.02))
  suppressMessages(cache$adjust_data())
  continuum <- cache$generate_coverage_data("adminlevel_1", "maternal")
  shown <- axis_text(plot(continuum, type = "heatmap", indicator_labels = list(anc4 = "Four visits")))
  expect_true(all(c("ANC 1", "Four visits") %in% gsub("\n", " ", shown)))
  expect_false("anc1" %in% shown)
})

test_that("the two charts with quadrants draw them the same way", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  skip_if_not_installed("ggrepel")
  cache <- suppressMessages(load_cache_data(path))
  suppressMessages(cache$adjust_data())
  geoms <- function(p) unname(vapply(p$layers, function(l) class(l$geom)[[1]], character(1)))
  quadrants <- c("GeomRect", "GeomRect", "GeomVline", "GeomHline", "GeomText", "GeomText", "GeomText", "GeomText")
  phc <- plot(cache$generate_phc_scatter_data(indicator = "ratio_hstaff_pop"), quad_labels = list(high_high = "Both high"))
  mch <- plot(cache$generate_admin1_mch_curative_index())
  expect_identical(geoms(phc)[1:8], quadrants)
  expect_identical(geoms(mch)[1:8], quadrants)
  # the high-high text is in the top right corner
  expect_identical(phc$layers[[6]]$aes_params$label, "Both high")
})

test_that("a sector's share of the C-sections is within its own country and year", {
  estimates <- tibble::tibble(
    iso = rep(c("AAA", "BBB"), each = 2), country = rep(c("A", "B"), each = 2), year = 2020L, source = "DHS",
    indic = rep(c("csectionpub", "csectionpriv"), 2), r_raw = c(0.10, 0.05, 0.02, 0.02), N = c(1000, 1000, 5000, 5000)
  )
  shares <- load_private_sector_data(.data = estimates, level = "national")
  by_country <- tapply(shares$share_csection, shares$iso, sum)
  expect_equal(as.vector(by_country), c(1, 1))
  expect_equal(shares$share_csection[shares$iso == "AAA"], c(2 / 3, 1 / 3))

  # the built-in shares: a country's two bars add up to its survey rate
  built_in <- private_share$national
  kenya <- built_in[built_in$iso == "KEN" & built_in$indic == "csection", ]
  survey <- survey_data$all
  rate <- survey$r_csection[survey$iso3 == "KEN" & survey$year == kenya$year]
  expect_equal(kenya$totalPrevalence * 100, rate, tolerance = 1e-6)
  every <- built_in[built_in$indic == "csection", ]
  expect_true(all(every$totalPrevalence > 0.005 & every$totalPrevalence < 0.5))
})

test_that("the Bayesian fits run in another R process, not in the app's", {
  skip_on_cran()
  old <- future::plan()
  on.exit(future::plan(old), add = TRUE)
  future::plan(future::sequential)
  cd_start_bayes_workers()
  expect_false(inherits(future::plan(), "sequential"))
  worker <- future::value(future::future(Sys.getpid()))
  expect_false(identical(worker, Sys.getpid()))
})

# a sub-national model as generate_bayes_model() returns it, without the fit: what its charts read
fake_bayes_model <- function() {
  regions <- c("North", "South", "East")
  temporal <- expand.grid(admin1 = regions, year = 2019:2025, stringsAsFactors = FALSE)
  centre <- c(North = 0.9, South = 0.7, East = 0.8)[temporal$admin1]
  temporal <- tibble::tibble(variable = "eta", iso = "KEN", admin1 = temporal$admin1, year = temporal$year,
                             `2.5%` = centre - 0.1, `50%` = centre, `97.5%` = centre + 0.05)
  routine <- tibble::tibble(admin1 = rep(regions, each = 3), year = rep(2021:2023, 3), routine_value = rep(c(0.85, 0.75, 0.95), each = 3))
  structure(list(posteriors = list(temporal = temporal), dat_routine = routine),
            class = c("cd_bayes_model", "list"), indicator = "penta3", is_national = FALSE)
}

test_that("a sub-national model's regions are compared in the year asked, with their facility data and the country's", {
  model <- fake_bayes_model()
  country <- tibble::tibble(year = 2021:2023, value = c(0.8, 0.82, 0.84))
  p <- plot(model, national = country)
  built <- ggplot2::ggplot_build(p)
  # the latest year the facility data has, not a year the model only projects
  expect_match(ggplot2::get_labs(p)$title, "2023", fixed = TRUE)
  geoms <- unname(vapply(p$layers, function(l) class(l$geom)[[1]], character(1)))
  expect_identical(geoms, c("GeomLinerange", "GeomPoint", "GeomPoint", "GeomVline"))
  expect_equal(built$data[[4]]$xintercept, 0.84)
  expect_equal(sort(built$data[[3]]$x), c(0.75, 0.85, 0.95))
  # the regions are ordered by their estimate
  expect_identical(levels(p$data$region), c("South", "East", "North"))

  p <- plot(model, year = 2025, national = country)
  expect_match(ggplot2::get_labs(p)$title, "2025", fixed = TRUE)
  # a year the facility data does not have: the estimates alone
  expect_identical(unname(vapply(p$layers, function(l) class(l$geom)[[1]], character(1))), c("GeomLinerange", "GeomPoint"))
  expect_error(plot(model, year = 1990), "no estimate for 1990")
  expect_error(plot(model, national = data.frame(a = 1)), "year")
  labelled <- plot(model, national = country, legend_labels = list(model = "Estimation", national = "National"))
  expect_true("Estimation" %in% ggplot2::ggplot_build(labelled)$plot$scales$get_scales("colour")$get_labels())
})

test_that("a region's inequality chart has the region's own coverage and the national one, each under its name", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cache <- suppressMessages(load_cache_data(path))
  cache$set_national_estimates(list(sbr = 0.02))
  suppressMessages(cache$adjust_data())
  districts <- cache$get_filtered_inequality("instlivebirths", "adminlevel_1", region = "Nairobi")
  expect_true("region_value" %in% names(districts))
  expect_identical(attr(districts, "region"), "Nairobi")
  # the region's own coverage, not the country's
  admin1 <- cache$indicator_coverage_admin1
  denominator <- cache$get_denominator("instlivebirths")
  own <- admin1[admin1$adminlevel_1 == "Nairobi", ][[paste0("cov_instlivebirths_", denominator)]]
  expect_equal(sort(unique(districts$region_value)), sort(unique(own)))
  p <- plot(districts)
  entries <- ggplot2::ggplot_build(p)$plot$scales$get_scales("colour")$get_labels()
  expect_identical(entries, c("Coverage at subnational unit", "Nairobi coverage", "National coverage"))
  # every region compared with the country: no region of its own
  all_regions <- cache$get_filtered_inequality("instlivebirths", "adminlevel_1")
  expect_false("region_value" %in% names(all_regions))
  expect_identical(ggplot2::ggplot_build(plot(all_regions))$plot$scales$get_scales("colour")$get_labels(),
                   c("Coverage at subnational unit", "National coverage"))
})

test_that("the formatted tables share one look, and the data tables one way of writing numbers", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cache <- suppressMessages(load_cache_data(path))
  suppressMessages(cache$adjust_data())
  tables <- list(
    score = plot(cache$calculate_overall_score("national")),
    utilization = plot(cache$calculate_service_dqa_summary("national")),
    health = plot(cache$generate_health_system_table(), year = 2023)
  )
  for (name in names(tables)) {
    ft <- tables[[name]]
    expect_s3_class(ft, "flextable")
    # the header's fill, and a section row's, are the same on each
    expect_true(all(ft$header$styles$cells$background.color$data == .cd_table_colours$header), info = name)
    expect_true(.cd_table_colours$section %in% ft$body$styles$cells$background.color$data, info = name)
    expect_identical(unique(as.vector(ft$body$styles$text$font.family$data)), "sans", info = name)
  }
  # a cell judged against the threshold has the charts' colours
  fills <- unique(as.vector(tables$score$body$styles$cells$background.color$data))
  expect_true(all(fills %in% c("white", "transparent", .cd_table_colours$section, .cd_palette$traffic_light)))
  expect_true(.cd_palette$traffic_light[[3]] %in% fills)

  expect_identical(.cd_table_number(12345.4, "penta1"), "12,345")
  expect_identical(.cd_table_number(98.44, "anc_rr"), "98.4")
  expect_identical(.cd_table_number(87.25, "cov_penta3_penta1"), "87.2")
  expect_identical(.cd_table_number(2023, "year"), "2023")
  expect_identical(.cd_table_number(NA_real_, "penta1"), "")
  expect_identical(.cd_table_number("Nairobi", "district"), "Nairobi")
  table <- .cd_reactable(data.frame(district = letters[1:12], penta1 = 1:12))
  expect_false(isFALSE(table$x$tag$attribs$pagination))   # paged (the default is left unsaid)
  expect_identical(table$x$tag$attribs$defaultPageSize %||% 10, 10)
  expect_false(.cd_reactable(data.frame(year = 2021:2023, n = 1:3), sortable = FALSE, paginate = FALSE)$x$tag$attribs$pagination)
})

test_that("the regional continuum heat map is drawn by the app's chart server", {
  regions <- rep(c("North", "South", "East"), each = 2)
  x <- tibble::new_tibble(
    tibble::tibble(adminlevel_1 = regions, year = 2023, name = "x", value = c(15, 95, 45, 70, NA, 55),
                   source = factor("facility"), indicator = factor(rep(c("anc1", "anc4"), 3), levels = c("anc1", "anc4"))),
    class = "cd_coverage_selected", admin_level = "adminlevel_1", region = NULL
  )
  p <- plot(x, type = "heatmap")
  # the numbers are coloured to read on their tiles, without a scale: a scale that has no legend stopped the app
  # listing the chart's legend ("subscript out of bounds", 1.4.0 and 1.4.1 on datasuite.ui 0.5.0)
  expect_false(any(vapply(p$scales$scales, function(s) "colour" %in% s$aesthetics, logical(1))))
  text <- ggplot2::ggplot_build(p)$data[[2]]
  expect_true(all(text$colour %in% c("white", "grey10", "grey40")))
  expect_setequal(unique(text$colour), c("white", "grey10", "grey40"))
  entries <- datasuite.ui:::cd_chart_entries(p)
  expect_length(entries$legend, 0)
  expect_length(entries$categories, 2)
})

test_that("the inequality chart is drawn with no region chosen, as the page asks for it", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cache <- suppressMessages(load_cache_data(path))
  cache$set_national_estimates(list(sbr = 0.02))
  suppressMessages(cache$adjust_data())
  x <- cache$get_filtered_inequality("instlivebirths", "adminlevel_1")
  # the page gives the region's label only when a region is chosen: NULL otherwise
  p <- plot(x, legend_labels = list(subnational = "Districts", national = "National coverage", region = NULL))
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
  expect_no_error(ggplot2::ggplot_build(plot(x)))
})

test_that("the reporting rate heat map writes each number in the colour that reads on its tile", {
  x <- tibble::new_tibble(
    tibble::tibble(adminlevel_1 = rep(c("North", "South", "East"), 2), year = rep(2022:2023, each = 3), anc_rr = c(50, 80, 95, 60, 85, 99)),
    class = "cd_average_reporting_rate", admin_level = "adminlevel_1", region = NULL
  )
  text <- ggplot2::ggplot_build(plot(x, plot_type = "heat_map", indicator = "anc_rr"))$data[[2]]
  fills <- ggplot2::ggplot_build(plot(x, plot_type = "heat_map", indicator = "anc_rr"))$data[[1]]$fill
  expect_identical(text$colour, unname(.cd_text_on(fills)))
  expect_gt(length(unique(text$colour)), 1)
})

test_that("k factors set on a dataset are the ones its adjustment settings hold, and come back from the file", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  file <- withr::local_tempfile(fileext = ".rds")
  cache <- suppressMessages(load_cache_data(path))
  settings <- cache$adjustment_settings
  settings$everywhere$group_k$anc <- 0.5
  cache$set_adjustment_settings(settings)   # now stored, as the Data Adjustment page stores them
  expect_identical(cache$k_factors[["anc"]], 0.5)
  k <- cache$k_factors
  k[["vacc"]] <- 0.75
  cache$set_k_factors(k)                    # the settings kept the k they had: adjust_data() did not use the new one
  expect_identical(cache$adjustment_settings$everywhere$group_k$vacc, 0.75)
  expect_identical(cache$adjustment_settings$everywhere$group_k$anc, 0.5)
})

test_that("the consistency check and its chart use nothing deprecated, and the app's own labels are translated", {
  file <- testthat::test_path("..", "..", "R", "1a_checks_internal_consistency.R")
  if (file.exists(file)) {   # the source is not there when the installed package is tested
    source <- paste(readLines(file, warn = FALSE), collapse = " ")
    expect_false(grepl("cur_data()", source, fixed = TRUE))
    expect_false(grepl("\"dashed\", size", source, fixed = TRUE))
  }
  keys <- vapply(jsonlite::fromJSON(system.file("translation", "cd2030.json", package = "cd2030.core"), simplifyVector = FALSE)$translation, function(t) t$key, character(1))
  expect_true(all(c("lbl_consist_ratio_opv1_opv3", "lbl_score_range_opv1_opv3", "opt_instdeliveries", "msg_select_indicator") %in% keys))
  expect_identical(anyDuplicated(keys), 0L)
})

test_that("the charts are written in one scale of text sizes", {
  scale <- cd_type_scale()
  expect_named(scale, c("title", "subtitle", "axis_title", "axis_text", "legend", "strip", "caption", "label", "label_small"))
  sizes <- function(theme) vapply(c("plot.title", "plot.subtitle", "axis.title", "axis.text", "legend.text", "strip.text", "plot.caption"), function(e) theme[[e]]$size, numeric(1))
  page <- sizes(Reduce(`+`, Filter(function(part) inherits(part, "theme"), cd_plot_theme()), ggplot2::theme_grey()))
  expect_equal(unname(page), unname(unlist(scale[c("title", "subtitle", "axis_title", "axis_text", "legend", "strip", "caption")])))
  # the light charts, and a report's charts from the report's own base size, in the same proportions
  expect_equal(unname(sizes(cd_minimal_theme())), unname(page))
  expect_equal(unname(sizes(cd_minimal_theme(base_size = 22))), unname(page) * 2)
  # (but the title, which is the size of the axis titles: a report's chart is narrow)
  report <- sizes(.cd_report_theme_base(base_size = 10))
  expect_equal(unname(report / report[["axis.title"]])[-1], unname(page / page[["axis.title"]])[-1])
  expect_equal(report[["plot.title"]], 10)
  expect_identical(.cd_report_theme_base()$plot.title$face, "bold")

  # no chart sets a size of its own: a number in element_text(size = ), or on a text drawn on the chart
  dir <- testthat::test_path("..", "..", "R")
  skip_if_not(dir.exists(dir), "the source is not there when the installed package is tested")
  for (file in setdiff(list.files(dir, "^(plot|chart|page|[0-9]).*[.]R$", full.names = TRUE), file.path(dir, "utils-plot-themes.R"))) {
    lines <- readLines(file, warn = FALSE)
    lines <- lines[!grepl("^\\s*#", lines)]
    expect_false(any(grepl("element_text\\([^)]*size *= *[0-9]", lines)), info = basename(file))
    text <- grep("geom_text|geom_label|annotate\\(\"text\"", lines, value = TRUE)
    expect_false(any(grepl("[^a-z_]size *= *[0-9]", text)), info = basename(file))
  }
})
