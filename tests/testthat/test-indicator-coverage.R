# Coverage formulas, checked against the Countdown 2030 Stata code (2_denominators.do)

coverage_fixture <- function() {
  set_selected_group("vaccine")
  doses <- c("anc1", "penta1", "penta2", "penta3", "measles1", "measles2", "bcg", "opv1", "opv2", "opv3",
             "pcv1", "pcv2", "pcv3", "rota1", "rota2", "ipv1", "ipv2", "instlivebirths", "ideliv", "sba")
  d <- expand.grid(adminlevel_1 = "A", district = c("d1", "d2"), year = 2023L, month = 1:12, stringsAsFactors = FALSE)
  for (dose in doses) d[[dose]] <- 100
  d$penta3 <- 80
  d$total_pop <- 500000; d$under5_pop <- 80000; d$under1_pop <- 20000; d$live_births <- 22500
  d$total_births <- 23000; d$women15_49 <- 120000; d$pop_rate <- 0.02
  x <- tibble::as_tibble(d)
  class(x) <- c("cd_data", class(x))
  attr(x, "iso3") <- "KEN"
  attr(x, "country") <- "Kenya"
  un <- structure(
    tibble::tibble(year = 2023L, un_population = 1000, un_births = 45, un_under1y = 40, un_popgrowth = 0.02),
    class = c("cd_un_estimates", "tbl_df", "tbl", "data.frame")
  )
  calculate_indicator_coverage(x, "national", survey_year = 2022L, un_estimates = un, nmr = 0.025, pnmr = 0.02, dpt1survey = 0.9, anc1survey = 0.95)
}

test_that("zero-dose and under-vaccinated are the share of surviving infants without penta1 / penta3", {
  cov <- coverage_fixture()
  for (den in c("dhis2", "un")) {
    infants <- cov[[paste0("totinftpenta_", den)]] * 1000 # populations are in thousands
    expect_equal(cov[[paste0("cov_zerodose_", den)]], 100 * (infants - cov$penta1) / infants)
    expect_equal(cov[[paste0("cov_undervax_", den)]], 100 * (infants - cov$penta3) / infants)
    expect_equal(cov[[paste0("cov_zerodose_", den)]] + cov[[paste0("cov_penta1_", den)]], 100)
  }
  for (den in c("anc1", "penta1")) {
    infants <- cov[[paste0("totinftpenta_", den)]] # counts
    expect_equal(cov[[paste0("cov_zerodose_", den)]], 100 * (infants - cov$penta1) / infants)
    expect_equal(cov[[paste0("cov_undervax_", den)]], 100 * (infants - cov$penta3) / infants)
  }
  # penta1-based infants are penta1 / dpt1survey, so zero-dose is 1 - dpt1survey
  expect_equal(cov$cov_zerodose_penta1, 100 * (1 - 0.9))
})

test_that("measles2 coverage uses the infants surviving to the second dose (totmeasles2), as the Stata code does", {
  cov <- coverage_fixture()
  expect_equal(cov$cov_measles2_dhis2, 100 * cov$measles2 / (cov$totmeasles2_dhis2 * 1000))
  expect_equal(cov$cov_measles2_un, 100 * cov$measles2 / (cov$totmeasles2_un * 1000))
  expect_equal(cov$cov_measles2_penta1, 100 * cov$measles2 / cov$totmeasles2_penta1)
  expect_gt(cov$cov_measles2_dhis2, cov$cov_measles1_dhis2)
})
