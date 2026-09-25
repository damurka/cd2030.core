test_that("the extra chart kinds are listed with complete specs", {
  extra <- .rb_kinds_extra()
  expect_gt(length(extra), 0)
  core <- names(.rb_core_kinds())
  expect_length(intersect(names(extra), core), 0)
  fields <- c("type", "group", "label", "indicators", "levels", "variants", "year", "regional", "groups", "tall")
  for (name in names(extra)) {
    spec <- extra[[name]]
    expect_true(all(fields %in% names(spec)), info = name)
    expect_identical(spec$type, "chart", info = name)
    expect_true(spec$group %in% .rb_group_order, info = name)
    expect_true(is.character(spec$label) && nzchar(spec$label), info = name)
    expect_true(all(spec$groups %in% c("rmncah", "vaccine")), info = name)
    expect_true(all(spec$levels %in% c("national", "adminlevel_1", "district")), info = name)
    if (!is.null(spec$variants)) expect_true(!is.null(names(spec$variants)) && all(nzchar(names(spec$variants))), info = name)
    expect_true(is.null(spec$indicators) || identical(spec$indicators, "analysis") || is.character(spec$indicators), info = name)
    expect_true(is.logical(spec$year) && is.logical(spec$regional) && is.logical(spec$tall), info = name)
    # each kind is drawn by its own function
    expect_true(is.function(get0(paste0(".rb_draw_", name), envir = asNamespace("cd2030.core"), inherits = FALSE)), info = name)
  }
})

test_that("the extra kinds are offered to the groups they are for", {
  rmncah <- names(report_block_kinds("rmncah"))
  vaccine <- names(report_block_kinds("vaccine"))
  extra <- .rb_kinds_extra()
  for (name in names(extra)) {
    expect_identical(name %in% rmncah, "rmncah" %in% extra[[name]]$groups, info = name)
    expect_identical(name %in% vaccine, "vaccine" %in% extra[[name]]$groups, info = name)
  }
  expect_true(all(c("dq_reporting_units", "dq_outliers_units", "derived_coverage_trend", "hs_national", "bayes_coverage") %in% rmncah))
  expect_false("hs_national" %in% vaccine)
})

test_that("an extra kind that cannot be drawn says so instead of failing", {
  cache <- list(countdown_data = NULL, data_years = NULL, performance_threshold = 90,
                calculate_reporting_rate = function(...) stop("no data loaded"))
  out <- render_report_block(cache, list(type = "chart", kind = "dq_reporting_units"), NULL, NULL)
  expect_identical(out$type, "error")
  expect_match(out$message, "no data loaded")
})

test_that("the helpers pick the block's settings or their defaults", {
  expect_null(.rbx_region(list(region = "@report")))
  expect_null(.rbx_region(list(region = "")))
  expect_identical(.rbx_region(list(region = "North")), "North")
  expect_identical(.rbx_units_level(list(admin_level = "district")), "district")
  expect_identical(.rbx_units_level(list()), "adminlevel_1")
  expect_identical(.rbx_pick("b", c("a", "b")), "b")
  expect_identical(.rbx_pick("z", c("a", "b")), "a")
  expect_identical(.rbx_pick(NULL, c("a", "b"), "b"), "b")
  expect_identical(.rbx_fill("{a} and {b}", a = "x", b = 2), "x and 2")
})
