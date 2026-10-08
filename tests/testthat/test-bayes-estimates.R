# bayes_model_estimates(): a fitted Bayesian model's estimates as a table. The model here is made by hand, with the
# one part the function reads (the posterior summary by year that bayescoveragedeploy::fit_local_model() returns), so
# the test needs neither Stan nor the model's packages.

fake_bayes_model <- function(indicator = "penta3", regions = NULL) {
  years <- 2010:2012
  areas <- if (is.null(regions)) NA_character_ else regions
  temporal <- tidyr::expand_grid(admin1 = areas, year = years)
  temporal$`2.5%` <- 0.50; temporal$`10%` <- 0.55; temporal$`25%` <- 0.58
  temporal$`50%` <- 0.60 + (temporal$year - 2010) / 100
  temporal$`75%` <- 0.66; temporal$`90%` <- 0.70; temporal$`97.5%` <- 0.75
  temporal$iso <- "BEN"
  if (is.null(regions)) temporal$admin1 <- NULL
  structure(
    list(posteriors = list(temporal = temporal)),
    class = c("cd_bayes_model", "list"), indicator = indicator, is_national = is.null(regions)
  )
}

test_that("bayes_model_estimates gives a national model's coverage by year, in percent", {
  estimates <- bayes_model_estimates(fake_bayes_model())
  expect_named(estimates, c("indicator", "year", "estimate", "lower", "upper", "lower_80", "upper_80"))
  expect_equal(estimates$year, 2010:2012)
  expect_equal(estimates$indicator, rep("penta3", 3))
  expect_equal(estimates$estimate, c(60, 61, 62))
  expect_equal(estimates$lower, rep(50, 3))
  expect_equal(estimates$upper, rep(75, 3))
  expect_equal(estimates$lower_80, rep(55, 3))
  expect_equal(estimates$upper_80, rep(70, 3))
})

test_that("bayes_model_estimates gives a sub-national model a row per region and year", {
  estimates <- bayes_model_estimates(fake_bayes_model("measles1", regions = c("Zou", "Alibori")))
  expect_named(estimates, c("indicator", "adminlevel_1", "year", "estimate", "lower", "upper", "lower_80", "upper_80"))
  expect_equal(nrow(estimates), 6)
  expect_equal(estimates$adminlevel_1, rep(c("Alibori", "Zou"), each = 3))
  expect_equal(estimates$year, rep(2010:2012, 2))
})

test_that("bayes_model_estimates refuses what is not a fitted model", {
  expect_error(bayes_model_estimates(list()))
  empty <- structure(list(posteriors = list()), class = c("cd_bayes_model", "list"), indicator = "penta3")
  expect_error(bayes_model_estimates(empty), "no estimates")
})

test_that("slim_bayes_model drops the draws and the compiled model, and nothing a chart or table reads", {
  model <- fake_bayes_model(regions = c("Zou", "Alibori"))
  model$samples <- raw(1e6)
  model$stan_model <- raw(1e5)
  model$data <- data.frame(year = 2010)
  attr(model, "iso") <- "BEN"

  slim <- slim_bayes_model(model)
  expect_named(slim, c("posteriors", "data"))
  expect_s3_class(slim, "cd_bayes_model")
  expect_equal(attr(slim, "indicator"), "penta3")
  expect_equal(attr(slim, "iso"), "BEN")
  expect_false(attr(slim, "is_national"))
  expect_identical(bayes_model_estimates(slim), bayes_model_estimates(model))
  expect_lt(length(serialize(slim, NULL)), length(serialize(model, NULL)) / 100)

  # a model that has neither is left as it is
  expect_identical(slim_bayes_model(slim), slim)
})
