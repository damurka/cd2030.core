test_that("the dictionary has the six denominators with their canonical labels", {
  d <- cd_dictionary()
  expect_named(d, c("denominators", "indicators", "populations", "reporting_rates", "columns", "grammar"))
  expect_identical(d$denominators$id, c("un", "dhis2", "anc1", "penta1", "anc1derived", "penta1derived"))
  expect_identical(unname(cd_denominator_labels()[c("anc1", "penta1", "anc1derived", "penta1derived")]),
                   c("ANC1-derived", "Penta1-derived", "ANC1 population growth", "Penta1 population growth"))
  # every indicator the package analyses has a label
  expect_true(all(get_analysis_indicators() %in% d$indicators$id))
})

test_that("the denominator labels use a translator when there is one, and fall back to English", {
  i18n <- list(t = function(key) if (key == "lbl_denom_anc1_growth") "Croissance (CPN1)" else key)
  labels <- cd_denominator_labels(i18n, ids = c("anc1derived", "penta1"))
  expect_identical(unname(labels), c("Croissance (CPN1)", "Penta1-derived"))
  expect_named(labels, c("anc1derived", "penta1"))
})

test_that("every coverage column the package builds is read, with its indicator and denominator", {
  denominators <- c("un", "dhis2", "anc1", "penta1", "anc1derived", "penta1derived")
  names <- as.vector(outer(get_analysis_indicators(), denominators, function(i, d) paste0("cov_", i, "_", d)))
  d <- cd_describe_columns(names)
  expect_true(all(d$type == "coverage"))
  expect_identical(d$denominator, rep(denominators, each = length(get_analysis_indicators())))
  expect_identical(d$indicator, rep(get_analysis_indicators(), times = length(denominators)))
})

test_that("anc1derived is read as the population-growth option, never as ANC1-derived", {
  d <- cd_describe_columns(c("cov_penta3_penta1derived", "cov_penta3_penta1", "cov_instlivebirths_anc1derived",
                             "cov_instlivebirths_anc1"))
  expect_identical(d$denominator, c("penta1derived", "penta1", "anc1derived", "anc1"))
  expect_match(d$description[1], "Penta1 population growth")
  expect_match(d$description[2], "Penta1-derived")
  expect_match(d$description[3], "ANC1 population growth")
  expect_match(d$description[4], "ANC1-derived")
})

test_that("the target-population columns the package builds are read", {
  names <- c()
  for (ind in get_analysis_indicators()) for (den in c("dhis2", "anc1", "penta1")) {
    col <- get_population_column(ind, den)
    if (!is.na(col)) names <- c(names, col)
  }
  names <- unique(c(names, paste0(unique(names[grepl("_(anc1|penta1)$", names)]), "derived")))
  d <- cd_describe_columns(names)
  expect_false(any(d$type == "unknown"), info = paste(names[d$type == "unknown"], collapse = ", "))
  expect_true(all(d$type[grepl("derived$", names)] == "population_growth"))
})

test_that("survey, reporting-rate, count and fixed columns are read; unknown names are not guessed", {
  d <- cd_describe_columns(c("r_penta1", "ul_penta1", "ll_anc1", "vacc_rr", "mean_rr", "penta1", "zerodose", "year",
                             "adminlevel_1", "denominator", "nat_totpreg_anc1", "penta1_survey", "cov_penta1_derived",
                             "something_else", NA, ""))
  expect_identical(d$type, c("survey", "survey_upper", "survey_lower", "reporting_rate", "reporting_rate", "count",
                             "count", "fixed", "fixed", "fixed", "population", "count", "unknown", "unknown",
                             "unknown", "unknown"))
  expect_true(all(is.na(d$description[d$type == "unknown"])))
  expect_match(d$description[which(d$column == "denominator")], "anc1derived = ANC1 population growth", fixed = TRUE)
})
