test_that("an indicator's k, outlier and missing-value switches come from its district, then its region, then everywhere", {
  set_selected_group("rmncah")
  s <- adjustment_settings_default()
  s$everywhere$indicator_k <- list(anc1 = 0)
  s$everywhere$outliers <- list(csection = FALSE)
  s$areas <- list(
    list(area = "North", level = "adminlevel_1", group_k = list(vacc = 0.5), outliers = list(penta1 = FALSE)),
    list(area = "N2", level = "district", group_k = list(anc = 1), all_outliers = FALSE, all_missing = FALSE)
  )
  s <- adjustment_settings_check(s)
  districts <- data.frame(adminlevel_1 = c("North", "North", "South"), district = c("N1", "N2", "S1"))
  plan <- .adjust_plan(districts, s, c("anc1", "anc4", "penta1", "penta3", "csection"), c("anc1", "penta1", "csection"))
  row <- function(d) plan[plan$district == d, ]

  # everywhere: anc1 its own k 0, the rest the group's 0.25; csection's outliers not corrected
  expect_equal(row("S1")$k__anc1, 0)
  expect_equal(row("S1")$k__anc4, 0.25)
  expect_false(row("S1")$out__csection)
  expect_true(row("S1")$out__penta1)
  # the region: vaccination k 0.5, penta1's outliers not corrected; the rest as everywhere
  expect_equal(row("N1")$k__penta3, 0.5)
  expect_false(row("N1")$out__penta1)
  expect_equal(row("N1")$k__anc1, 0)
  # the district over its region: ANC k 1 (its group k wins over everywhere's anc1 0), nothing corrected for outliers
  # or missing values; vaccination still its region's 0.5
  expect_equal(row("N2")$k__anc1, 1)
  expect_equal(row("N2")$k__penta1, 0.5)
  expect_false(row("N2")$out__anc1)
  expect_false(row("N2")$miss__anc4)
})

test_that("the settings are checked and tidied", {
  set_selected_group("rmncah")
  expect_error(adjustment_settings_check(list(everywhere = list(group_k = list(anc = 1.25)))), "between 0 and 1")
  expect_error(adjustment_settings_check(list(everywhere = list(indicator_k = list(nothing = 0.5)))), "Unknown")
  expect_error(adjustment_settings_check(list(areas = list(list(area = "X", level = "country")))), "level")
  # a group this app does not have is left out, not refused (the method lists every app's groups)
  s <- adjustment_settings_check(list(everywhere = list(group_k = list(anc = 0.25, pnc = 0.25))))
  expect_named(s$everywhere$group_k, "anc")
  # JSON as the page sends it: numbers as strings, one-element lists
  s <- adjustment_settings_check(list(removed_years = list(2019), removals = list(list(area = "N1", level = "district", years = list())),
                                      everywhere = list(group_k = list(anc = "0.5"))))
  expect_identical(s$removed_years, 2019)
  expect_length(s$removals[[1]]$years, 0)
  expect_identical(s$everywhere$group_k$anc, 0.5)
})

test_that("the settings from the older k-factors and years, and the footnote", {
  set_selected_group("rmncah")
  s <- adjustment_settings_from_k(c(anc = 0.5, vacc = 0), c(2019, 2020))
  expect_identical(s$removed_years, c(2019, 2020))
  expect_identical(s$everywhere$group_k$anc, 0.5)
  s$removals <- list(list(area = "N1", level = "district", years = 2021))
  s$areas <- list(list(area = "S1", level = "district", group_k = list(anc = 0, idelv = 0, vacc = 0, opd = 0), all_outliers = FALSE, all_missing = FALSE, reported = TRUE))
  f <- adjustment_settings_footnote(s, indicator_labels = list(anc1 = "ANC1"))
  expect_true(any(grepl("2019, 2020 removed everywhere", f)))
  expect_true(any(grepl("N1 removed for 2021", f)))
  expect_true(any(grepl("S1: kept as reported", f)))
})
