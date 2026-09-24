# Fixture-based happy path -------------------------------------------------------------------

test_that("kenya.xlsx fixture loads clean (all Tier A/B checks pass)", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  skip_if(identical(path, ""), "kenya.xlsx fixture not found")

  expect_no_error(cd <- load_data(path, indicator_group = "rmncah"))
  expect_s3_class(cd, "cd_data")
  # raw_month is Tier B-only scaffolding -- must never leak into the returned data.
  expect_false("raw_month" %in% colnames(cd))
})

# Tier A: raw Admin_data sheet -----------------------------------------------------------------

test_that("check_admin_columns passes when country/first_admin_level are present", {
  admin_data <- tibble::tibble(country = "Kenya", first_admin_level = "Central", district = "Nairobi")
  expect_null(check_admin_columns(admin_data))
})

test_that("check_admin_columns fails when a required column is missing", {
  admin_data <- tibble::tibble(country = "Kenya", district = "Nairobi")
  problems <- check_admin_columns(admin_data)
  expect_true(length(problems) > 0)
  expect_match(problems, "first_admin_level", all = FALSE)
})

test_that("check_single_country passes with exactly one distinct country", {
  admin_data <- tibble::tibble(country = c("Kenya", "Kenya", "Kenya"))
  expect_null(check_single_country(admin_data))
})

test_that("check_single_country fails with more than one distinct country", {
  admin_data <- tibble::tibble(country = c("Kenya", "Uganda"))
  problems <- check_single_country(admin_data)
  expect_true(length(problems) > 0)
  expect_match(problems, "Kenya", all = FALSE)
  expect_match(problems, "Uganda", all = FALSE)
})

# Tier B: merged/standardized data --------------------------------------------------------------

test_that("check_district_consistency passes when districts are stable", {
  .data <- tibble::tibble(
    district = rep(c("Nairobi", "Kisumu"), each = 2),
    adminlevel_1 = rep(c("Central", "Nyanza"), each = 2),
    year = rep(c(2022, 2023), times = 2)
  )
  expect_null(check_district_consistency(.data))
})

test_that("check_district_consistency flags an inconsistent admin-1 spelling", {
  .data <- tibble::tibble(
    district = c("Nairobi", "Nairobi"),
    adminlevel_1 = c("Central", "Cetral"), # typo
    year = c(2022, 2023)
  )
  problems <- check_district_consistency(.data)
  expect_true(length(problems) > 0)
  expect_match(problems, "Nairobi", all = FALSE)
})

test_that("check_district_consistency flags a district missing from a year", {
  .data <- tibble::tibble(
    district = c("Nairobi", "Nairobi", "Kisumu"),
    adminlevel_1 = c("Central", "Central", "Nyanza"),
    year = c(2022, 2023, 2022)
  )
  problems <- check_district_consistency(.data)
  expect_true(length(problems) > 0)
  expect_match(problems, "Kisumu", all = FALSE)
})

test_that("check_month_presence passes when all 12 months are present", {
  .data <- tidyr::expand_grid(
    district = "Nairobi", year = 2022,
    month = factor(month.name, levels = month.name, ordered = TRUE)
  )
  expect_null(check_month_presence(.data))
})

test_that("check_month_presence flags a missing month", {
  .data <- tidyr::expand_grid(
    district = "Nairobi", year = 2022,
    month = factor(month.name[-3], levels = month.name, ordered = TRUE) # no March
  )
  problems <- check_month_presence(.data)
  expect_true(length(problems) > 0)
  expect_match(problems, "March", all = FALSE)
})

test_that("check_month_validity passes when no month is NA", {
  .data <- tibble::tibble(month = factor("January", levels = month.name, ordered = TRUE))
  expect_null(check_month_validity(.data))
})

test_that("check_month_validity reports the original unparseable text via raw_month", {
  .data <- tibble::tibble(
    month = factor(NA_character_, levels = month.name, ordered = TRUE),
    raw_month = "janvier-typo"
  )
  problems <- check_month_validity(.data)
  expect_true(length(problems) > 0)
  expect_match(problems, "janvier-typo", all = FALSE)
})

test_that("check_month_validity falls back gracefully with no raw_month column", {
  .data <- tibble::tibble(month = factor(NA_character_, levels = month.name, ordered = TRUE))
  problems <- check_month_validity(.data)
  expect_true(length(problems) > 0)
})

# Informational checks ---------------------------------------------------------------------------

test_that("check_population_service_collision flags a suspicious exact match across months", {
  .data <- tibble::tibble(
    district = "Nairobi",
    year = 2022,
    instlivebirths = rep(1200, 12),
    live_births = rep(1200, 12)
  )
  flagged <- check_population_service_collision(.data)
  expect_equal(nrow(flagged), 1)
  expect_equal(flagged$district, "Nairobi")
})

test_that("check_population_service_collision doesn't flag normal varying service data", {
  .data <- tibble::tibble(
    district = "Nairobi",
    year = 2022,
    instlivebirths = 1000:1011,
    live_births = rep(1200, 12)
  )
  flagged <- check_population_service_collision(.data)
  expect_equal(nrow(flagged), 0)
})

# Mapping checks -----------------------------------------------------------------------------

test_that("match_admin_names matches exact names with zero distance", {
  result <- match_admin_names(c("Central"), known_names = c("Central", "Nyanza"))
  expect_equal(nrow(result), 0) # exact match -- distance 0, under threshold
})

test_that("match_admin_names flags a name with no close match", {
  result <- match_admin_names(c("Xyzabc"), known_names = c("Central", "Nyanza"))
  expect_equal(nrow(result), 1)
  expect_equal(result$name, "Xyzabc")
})

test_that("check_survey_admin_names returns empty when regional_survey is NULL", {
  result <- check_survey_admin_names(NULL, tibble::tibble(adminlevel_1 = "Central"))
  expect_equal(nrow(result), 0)
})

# Pre-merge checks (Phase 3 of the Load Data wizard redesign) -------------------------------

test_that("check_district_cross_sheet passes when districts match across sheets", {
  parts <- list(
    Admin_data = tibble::tibble(district = c("Nairobi", "Kisumu")),
    Population_data = tibble::tibble(district = c("Nairobi", "Kisumu"))
  )
  expect_null(check_district_cross_sheet(parts, "Admin_data"))
})

test_that("check_district_cross_sheet flags a district in another sheet but not Admin_data", {
  parts <- list(
    Admin_data = tibble::tibble(district = c("Nairobi", "Kisumu")),
    Population_data = tibble::tibble(district = c("Nairobi", "Kisumu", "Mombasa"))
  )
  problems <- check_district_cross_sheet(parts, "Admin_data")
  expect_true(length(problems) > 0)
  expect_match(problems, "Mombasa", all = FALSE)
  expect_match(problems, "Population_data", all = FALSE)
})

test_that("check_district_cross_sheet flags a district in Admin_data missing everywhere else", {
  parts <- list(
    Admin_data = tibble::tibble(district = c("Nairobi", "Kisumu", "Garissa")),
    Population_data = tibble::tibble(district = c("Nairobi", "Kisumu"))
  )
  problems <- check_district_cross_sheet(parts, "Admin_data")
  expect_true(length(problems) > 0)
  expect_match(problems, "Garissa", all = FALSE)
})

test_that("check_admin_pairing_consistency flags a district with two admin-1 rows in Admin_data", {
  admin_data <- tibble::tibble(
    district = c("Nairobi", "Nairobi"),
    first_admin_level = c("Central", "Cetral")
  )
  problems <- check_admin_pairing_consistency(admin_data)
  expect_true(length(problems) > 0)
  expect_match(problems, "Nairobi", all = FALSE)
})

test_that("check_district_year_completeness flags a district missing from a year", {
  population_data <- tibble::tibble(
    district = c("Nairobi", "Nairobi", "Kisumu"),
    year = c(2022, 2023, 2022)
  )
  problems <- check_district_year_completeness(population_data)
  expect_true(length(problems) > 0)
  expect_match(problems, "Kisumu", all = FALSE)
})

test_that("check_month_presence_presheet reuses check_month_presence against row-bound service sheets", {
  parts <- list(
    Service_data_1 = tibble::tibble(district = "Nairobi", year = 2022, month = month.name[1:11])
  )
  problems <- check_month_presence_presheet(parts, "Service_data_1")
  expect_true(length(problems) > 0)
  expect_match(problems, "December", all = FALSE)
})

test_that("check_month_validity_presheet flags an unparseable raw month string", {
  # month/raw_month here mirror what load_excel_parts() itself now produces (normalizes every sheet's
  # month column BEFORE this check ever runs -- see its own comment) -- NA for whatever didn't parse,
  # raw_month preserving the true original text for this check's own error detail.
  parts <- list(
    Service_data_1 = tibble::tibble(
      district = "Nairobi", year = 2022,
      raw_month = c("January", "Zzztember"),
      month = c("January", NA)
    )
  )
  problems <- check_month_validity_presheet(parts, "Service_data_1")
  expect_true(length(problems) > 0)
  expect_match(problems, "Zzztember", all = FALSE)
})

test_that("check_population_service_collision_presheet flags a district-year mixed up across sheets", {
  parts <- list(
    Population_data = tibble::tibble(district = "Nairobi", year = 2022, live_births = 1200),
    Service_data_1 = tibble::tibble(district = "Nairobi", year = 2022, month = month.name, instlivebirths = 1200)
  )
  flagged <- check_population_service_collision_presheet(parts, "Population_data", "Service_data_1")
  expect_equal(nrow(flagged), 1)
})

test_that("check_population_vs_births passes when population comfortably covers reported deliveries", {
  parts <- list(
    Population_data = tibble::tibble(district = "Nairobi", year = 2022, live_births = 30000),
    Service_data_1 = tibble::tibble(district = "Nairobi", year = 2022, month = month.name, instlivebirths = 1000)
  )
  expect_null(check_population_vs_births(parts, "Population_data", "Service_data_1"))
})

test_that("check_population_vs_births flags population estimates lower than reported institutional counts", {
  parts <- list(
    Population_data = tibble::tibble(district = "Nairobi", year = 2022, live_births = 2000),
    Service_data_1 = tibble::tibble(district = "Nairobi", year = 2022, month = month.name, instlivebirths = 2500)
  )
  problems <- check_population_vs_births(parts, "Population_data", "Service_data_1")
  expect_true(length(problems) > 0)
  expect_match(problems, "Nairobi", all = FALSE)
})

test_that("check_population_vs_births respects the margin parameter", {
  parts <- list(
    Population_data = tibble::tibble(district = "Nairobi", year = 2022, live_births = 950),
    Service_data_1 = tibble::tibble(district = "Nairobi", year = 2022, month = "January", instlivebirths = 1000)
  )
  # 950 is within a 10% margin of the (single-month) reported total of 1000 (>= 900) -- should pass
  expect_null(check_population_vs_births(parts, "Population_data", "Service_data_1", margin = 0.10))
  # ...but not within a 2% margin (>= 980)
  problems <- check_population_vs_births(parts, "Population_data", "Service_data_1", margin = 0.02)
  expect_true(length(problems) > 0)
})

# generate_admin1_keys() (Finish step, Phase 4) ----------------------------------------------

test_that("check_month_language_consistency passes when every sheet agrees on raw month text", {
  parts <- list(
    Service_data_1 = tibble::tibble(district = "Nairobi", year = 2022, raw_month = "January", month = "January"),
    Service_data_2 = tibble::tibble(district = "Nairobi", year = 2022, raw_month = "January", month = "January")
  )
  result <- check_month_language_consistency(parts, c("Service_data_1", "Service_data_2"))
  expect_equal(nrow(result), 0)
})

test_that("check_month_language_consistency flags a canonical month with more than one raw variant", {
  # Mirrors the real, confirmed case: one sheet labels a period in French, its sibling sheet labels
  # the SAME canonical month in English -- both now normalize to the same `month`, but the
  # underlying raw_month text still disagrees, which is exactly what this check surfaces.
  parts <- list(
    Service_data_1 = tibble::tibble(district = "Nairobi", year = 2022, raw_month = "Janvier", month = "January"),
    Service_data_2 = tibble::tibble(district = "Nairobi", year = 2022, raw_month = "January", month = "January")
  )
  result <- check_month_language_consistency(parts, c("Service_data_1", "Service_data_2"))
  expect_equal(nrow(result), 1)
  expect_equal(result$month, "January")
  expect_match(result$variants, "Janvier")
  expect_match(result$variants, "January")
})

test_that("generate_admin1_keys assigns one stable key per distinct name, alphabetically", {
  keys <- generate_admin1_keys(c("Nyanza", "Central", "Central", NA, "Nyanza"))
  expect_equal(nrow(keys), 2)
  expect_equal(keys$adminlevel_1, c("Central", "Nyanza"))
  expect_equal(keys$admin1_key, c("A1-001", "A1-002"))
})
