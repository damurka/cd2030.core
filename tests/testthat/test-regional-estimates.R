# get_regional_estimates(): a region's own rates from the survey files; the national rates only when the region is
# not in them.

regional_cache <- function() {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cd <- suppressMessages(load_data(path, indicator_group = "rmncah"))
  cache <- suppressMessages(init_CacheConnection(countdown_data = cd))
  survey <- cache$regional_survey
  skip_if(is.null(survey) || !nrow(survey), "no regional survey for the fixture's country")
  # the survey's first region stands for the data's first region
  private <- cache$.__enclos_env__$private
  private$.in_memory_data$survey_mapping <- data.frame(
    adminlevel_1 = as.character(survey$adminlevel_1[1]),
    admin_level_1 = cache$subnational_regions$adminlevel_1[1]
  )
  cache
}

test_that("with no region, or one the survey files do not have, the national rates are given", {
  cache <- regional_cache()
  national <- cache$national_estimates
  none <- cache$get_regional_estimates(region = NULL)
  expect_identical(attr(none, "source"), "national")
  expect_equal(none[names(national)], national, ignore_attr = TRUE)

  unknown <- cache$get_regional_estimates("adminlevel_1", "Not a region")
  expect_identical(attr(unknown, "source"), "national")
  expect_equal(unknown[names(national)], national, ignore_attr = TRUE)
})

test_that("a region in the survey files gets its own latest survey values, as proportions", {
  cache <- regional_cache()
  region <- cache$subnational_regions$adminlevel_1[1]
  survey_name <- cache$survey_mapping$adminlevel_1[1]
  rows <- cache$regional_survey[cache$regional_survey$adminlevel_1 == survey_name & cache$regional_survey$iso3 == cache$country_iso, ]
  latest <- function(col) { ok <- rows[!is.na(rows[[col]]), ]; ok[[col]][which.max(ok$year)] }

  rates <- cache$get_regional_estimates("adminlevel_1", region)
  expect_identical(attr(rates, "source"), "regional")
  expect_equal(rates$anc1, round(latest("r_anc1"), 1) / 100)
  expect_equal(rates$penta1, round(latest("r_penta1"), 1) / 100)
  expect_true(all(unlist(rates[c("anc1", "penta1")]) <= 1))
  # what the region's surveys do not give stays as it is nationally
  expect_equal(rates$twin_rate, cache$national_estimates$twin_rate)
})

test_that("a district gets its region's rates", {
  cache <- regional_cache()
  region <- cache$subnational_regions$adminlevel_1[1]
  district <- cache$subnational_regions$district[cache$subnational_regions$adminlevel_1 == region][1]
  expect_equal(cache$get_regional_estimates("district", district), cache$get_regional_estimates("adminlevel_1", region))
  expect_identical(attr(cache$get_regional_estimates("district", "Not a district"), "source"), "national")
})
