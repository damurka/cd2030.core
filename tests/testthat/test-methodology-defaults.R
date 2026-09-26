entry_value <- function(id) {
  d <- cd_methodology_defaults()
  d$value[[match(id, d$id)]]
}

test_that("every entry has all the fields, with the allowed values", {
  d <- cd_methodology_defaults()
  expect_named(d, c("id", "step", "group", "value", "unit", "label", "note", "source"))
  expect_gt(nrow(d), 0)
  expect_false(anyDuplicated(d$id) > 0)
  expect_true(all(grepl("^[a-z][a-z0-9_]*$", d$id)))
  expect_true(all(d$step %in% c("data_quality", "adjustment", "denominators", "coverage", "subnational", "mortality")))
  expect_true(all(d$group %in% c("both", "rmncah", "vaccine")))
  for (col in c("unit", "label", "note", "source")) {
    expect_type(d[[col]], "character")
    expect_false(anyNA(d[[col]]))
  }
  expect_true(all(nzchar(d$label)))
  expect_true(all(nzchar(d$note)))
  expect_true(all(vapply(d$value, function(v) (is.numeric(v) || is.character(v)) && length(v) > 0 && !anyNA(v), logical(1))))
  expect_true(all(grepl("^R/.+\\.R$", d$source)))
  expect_true(all(file.exists(test_path("..", "..", d$source))) || !dir.exists(test_path("..", "..", "R")))
})

test_that("group filters keep the shared entries", {
  all <- cd_methodology_defaults()
  rmncah <- cd_methodology_defaults("rmncah")
  vaccine <- cd_methodology_defaults("vaccine")
  expect_setequal(rmncah$id, all$id[all$group %in% c("both", "rmncah")])
  expect_setequal(vaccine$id, all$id[all$group %in% c("both", "vaccine")])
  expect_error(cd_methodology_defaults("other"))
})

test_that("the entries report the values the code uses", {
  expect_equal(entry_value("adj_k_default"), 0.25)
  expect_equal(entry_value("adj_reporting_rate_cutoff"), 75)
  expect_equal(entry_value("adj_reporting_rate_window"), c(75, 100))
  expect_equal(entry_value("dq_outlier_mad_multiplier"), 5)
  expect_equal(entry_value("dq_reporting_threshold"), 90)
  expect_equal(entry_value("dq_ratio_adequate_range"), c(1, 1.5))
  expect_equal(entry_value("den_nmr"), 0.025)
  expect_equal(entry_value("den_preg_loss"), 0.03)
  expect_equal(entry_value("den_twin"), 0.015)
  expect_equal(entry_value("cov_target_vaccine_national"), 90)
  expect_equal(entry_value("sub_target_vaccine"), 80)
})

test_that("function defaults are the exported constants", {
  expect_equal(eval(formals(calculate_district_reporting_rate)$threshold), entry_value("dq_reporting_threshold"))
  expect_equal(eval(formals(calculate_completeness_summary)$threshold), entry_value("dq_reporting_threshold"))
  expect_equal(eval(formals(calculate_overall_score1)$threshold), entry_value("dq_reporting_threshold"))
  expect_equal(eval(formals(calculate_ratios_and_adequacy)$adequate_range), entry_value("dq_ratio_adequate_range"))
  expect_equal(eval(formals(calculate_ratios_summary)$anc1_penta1_mortality), entry_value("dq_ratio_anc1_penta1_mortality"))
  expect_equal(
    unname(eval(formals(calculate_ratios_summary)$survey_coverage)["opv3"]),
    entry_value("dq_ratio_expected_coverage_opv3")
  )

  f <- formals(calculate_indicator_coverage)
  for (key in c("nmr", "pnmr", "sbr", "twin", "preg_loss", "anc1survey", "dpt1survey")) {
    expect_equal(eval(f[[key]]), entry_value(paste0("den_", key)), info = key)
  }
  expect_equal(eval(f$survey_year), entry_value("den_survey_year"))
})

test_that("a new CacheConnection starts from the exported constants", {
  cache <- CacheConnection$new(wizard_parts = list(parts = list()), read_only = TRUE)
  expect_equal(cache$performance_threshold, entry_value("dq_reporting_threshold"))
  expect_equal(unname(cache$k_factors), rep(entry_value("adj_k_start"), 5))
  expect_named(cache$k_factors, c("anc", "idelv", "vacc", "opd", "ipd"))
  expect_equal(cache$national_estimates$twin_rate, entry_value("den_twin"))
  expect_equal(cache$national_estimates$preg_loss, entry_value("den_preg_loss"))
})

test_that("outlier flags on a synthetic series match median +/- 5 x MAD of the earlier years", {
  k <- entry_value("dq_outlier_mad_multiplier")
  base <- c(100, 104, 98, 101, 97, 103, 99, 102, 100, 96, 105, 101)
  d <- tibble::tibble(
    district = "A",
    year = rep(c(2021, 2022, 2023), each = 12),
    month = rep(1:12, 3),
    x = c(base, base + 1, c(100, 250, 20, 114, 87, 100, 130, 70, 100, 100, 100, 100))
  )

  flagged <- add_outlier5std_column(d, "x")

  baseline <- d$x[d$year < 2023]
  med <- round(stats::median(baseline), 1)
  mad <- round(stats::mad(baseline), 1)
  expected <- as.numeric(d$x < round(med - k * mad, 1) | d$x > round(med + k * mad, 1))

  expect_equal(flagged$x_outlier5std, expected)
  expect_true(sum(expected) > 0)
  # 114 and 87 lie between 4 and 5 MAD from the median: a 4 x MAD rule would flag them, 5 x MAD does not
  expect_true(sum(abs(d$x - med) > 4 * mad) > sum(expected))
})

test_that("adjust_service_data()'s default adjustment is k from cd_methodology_defaults()", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")
  cd <- suppressMessages(load_data(path, indicator_group = "rmncah"))
  k <- entry_value("adj_k_default")
  groups <- c("anc", "idelv", "pnc", "vacc", "opd", "ipd")

  default <- suppressMessages(adjust_service_data(cd, adjustment = "default"))
  same_k <- suppressMessages(adjust_service_data(cd, adjustment = "custom", k_factors = set_names(rep(k, 6), groups)))
  other_k <- suppressMessages(adjust_service_data(cd, adjustment = "custom", k_factors = set_names(rep(0.9, 6), groups)))

  expect_equal(default, same_k)
  expect_false(isTRUE(all.equal(default, other_k)))
})
