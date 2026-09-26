# A stand-in for a CacheConnection: the few members these functions read.
fake_cache <- function() {
  d <- data.frame(
    adminlevel_1 = c("North", "North", "South", "South", "North", "North", "South", "South"),
    district = c("A", "B", "C", "D", "A", "B", "C", "D"),
    year = c(2022, 2022, 2022, 2022, 2023, 2023, 2023, 2023),
    anc4 = c(500, 300, 400, 200, 400, 300, 420, 150)
  )
  den <- c(1000, 600, 800, 400, 1000, 650, 800, 400)
  d$cov_anc4_anc1 <- d$anc4 / den * 100
  rr <- data.frame(adminlevel_1 = d$adminlevel_1, district = d$district, year = d$year,
                   anc_rr = c(95, 90, 92, 96, 94, 60, 93, 80), mean_rr = 90)
  list(
    indicator_coverage_district = d,
    indicator_coverage_admin1 = NULL,
    reporting_rate_district = rr,
    reporting_rate_national = data.frame(year = c(2022, 2023), anc_rr = c(93, 82)),
    get_denominator = function(indicator) "anc1"
  )
}

test_that("decompose_change's parts add up to the change above, and flag low reporting", {
  withr::local_options(cd2030.selected_group = "rmncah")
  out <- .cd_decompose_change(fake_cache(), "anc4", 2022, 2023)
  total <- attr(out, "total")
  expect_equal(total$coverage_from, 1400 / 2800 * 100)
  expect_equal(total$coverage_to, 1270 / 2850 * 100)
  expect_equal(sum(out$contribution), total$change)
  expect_equal(sum(out$contribution_service) + sum(out$contribution_denominator), total$change)
  # the biggest pull on a fall comes first
  expect_identical(out$district[1], "A")
  expect_true(out$reporting_flag[out$district == "B"])
  expect_true(out$reporting_flag[out$district == "D"])
  expect_false(out$reporting_flag[out$district == "A"])
  expect_identical(total$reporting_column, "anc_rr")

  north <- .cd_decompose_change(fake_cache(), "anc4", 2022, 2023, region = "North")
  expect_setequal(north$district, c("A", "B"))
  expect_error(.cd_decompose_change(fake_cache(), "anc4", 2019, 2023), "2019")
  expect_error(.cd_decompose_change(fake_cache(), "penta3", 2022, 2023), "no")
})

test_that("a custom chart's data comes from a chartable member, transformed", {
  cache <- fake_cache()
  spec <- list(title = "Reporting", data = list(member = "reporting_rate_national"),
               transform = list(list(filter = list(year = 2023))),
               plot = list(geom = "col", x = "year", y = "anc_rr"))
  d <- cd_custom_chart_data(cache, spec)
  expect_identical(nrow(d), 1L)
  expect_equal(d$anc_rr, 82)
  expect_error(cd_member_data(cache, "countdown_data"), "can't be charted")
  p <- .rb_draw_custom(cache, list(spec = spec))
  expect_s3_class(p, "ggplot")
  expect_error(.rb_draw_custom(list(graphs = list()), list(graph = "missing")), "no description")
})

test_that("a read-only cache never writes, and every change moves the revision", {
  cache <- CacheConnection$new(wizard_parts = list(parts = list()))
  expect_identical(cache$revision, 0L)
  cache$set_report_project("r1", list(name = "R", blocks = list()))
  expect_identical(cache$revision, 1L)
  cache$set_graph("g1", list(data = list(member = "reporting_rate_national"), plot = list(geom = "line", x = "year", y = "anc_rr")))
  expect_identical(cache$revision, 2L)
  expect_identical(names(cache$graphs), "g1")
  expect_error(cache$set_graph("g2", list(data = list(member = "countdown_data"), plot = list(geom = "line", x = "a", y = "b"))), "charted")

  ro <- CacheConnection$new(wizard_parts = list(parts = list()), read_only = TRUE)
  expect_true(ro$read_only)
  path <- withr::local_tempfile(fileext = ".rds")
  ro$set_cache_path(path)
  expect_false(file.exists(path))
})

test_that("the manifest lists every public member with arguments and docs, and the report kinds", {
  m <- cache_manifest()
  names <- vapply(m$members, `[[`, "", "name")
  expect_true(all(c("calculate_coverage", "decompose_change", "reporting_rate_district", "revision", "graphs") %in% names))
  expect_false(any(c("clone", "initialize") %in% names))
  cov <- m$members[[which(names == "calculate_coverage")]]
  expect_identical(cov$kind, "method")
  expect_true(cov$chartable)
  admin <- Filter(function(a) a$name == "admin_level", cov$args)[[1]]
  expect_true(admin$required)
  dec <- m$members[[which(names == "decompose_change")]]
  expect_identical(Filter(function(a) a$name == "admin_level", dec$args)[[1]]$choices, c("district", "adminlevel_1"))
  expect_true(m$members[[which(names == "set_graph")]]$writes)
  expect_identical(m$members[[which(names == "reporting_rate_district")]]$kind, "binding")
  kinds <- vapply(m$reportKinds, `[[`, "", "id")
  expect_true(all(c("coverage", "custom_chart") %in% kinds))
  json <- jsonlite::toJSON(m, auto_unbox = TRUE, null = "null")
  expect_true(jsonlite::validate(json))
})

test_that("a read-only copy keeps the file's revision", {
  ro <- CacheConnection$new(wizard_parts = list(parts = list()), read_only = TRUE)
  ro$set_report_project("r1", list(name = "R", blocks = list()))
  expect_identical(ro$revision, 0L)
})
