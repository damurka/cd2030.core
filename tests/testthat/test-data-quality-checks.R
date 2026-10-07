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

# Required columns: one definition, asked of merged data (new_countdown) and of unmerged sheets (Data Quality) ----

# Sheets as read_and_clean_sheet() leaves them, with every column the vaccine group needs
required_parts <- function(drop = character(0)) {
  groups <- get_indicator_groups("vaccine")
  indicators <- unname(unlist(groups))
  key <- tibble::tibble(district = "Baringo County", year = 2024)
  service <- dplyr::bind_cols(key, month = "January", tibble::as_tibble(stats::setNames(as.list(rep(1, length(indicators))), indicators)))
  reporting <- dplyr::bind_cols(key, month = "January", tibble::as_tibble(stats::setNames(as.list(rep(90, length(groups))), paste0(names(groups), "_reporting_rate"))))
  population <- dplyr::bind_cols(key, tibble::tibble(
    total_population = 1, population_under_5years = 1, population_under_1year = 1,
    live_births = 1, total_births = 1, women_15_49_years = 1, pop_growth_rate = 2.1
  ))
  admin <- tibble::tibble(country = "Kenya", first_admin_level = "Rift Valley", district = "Baringo County")
  parts <- list(Service_data = service, Reporting_completeness = reporting, Population_data = population, Admin_data = admin)
  lapply(parts, function(sheet) sheet[, setdiff(colnames(sheet), drop), drop = FALSE])
}

# Empty data with the columns those sheets will have once merged and standardized
merged_like <- function(parts) {
  columns <- .standardized_column_names(unique(unlist(lapply(parts, colnames))))
  tibble::as_tibble(stats::setNames(rep(list(numeric(0)), length(columns)), columns))
}

test_that("check_required_columns_presheet passes sheets that have every column, under the workbook's names", {
  # the names are the sheets' own (total_population, *_reporting_rate): what the merge renames is not "missing"
  expect_null(check_required_columns_presheet(required_parts(), group = "vaccine"))
})

test_that("check_required_columns_presheet names a missing population column as the workbook calls it", {
  # as the Data Extractor's workbook was: everything but the growth rate
  problems <- check_required_columns_presheet(required_parts(drop = "pop_growth_rate"), group = "vaccine")
  expect_length(problems, 1)
  expect_match(problems, "Population_data")
  expect_match(problems, "pop_growth_rate")
  expect_no_match(problems, "total_population")
})

test_that("check_required_columns_presheet reports indicators and reporting rates by their sheet", {
  groups <- get_indicator_groups("vaccine")
  indicator <- unname(unlist(groups))[1]
  rate <- paste0(names(groups)[1], "_reporting_rate")
  problems <- check_required_columns_presheet(required_parts(drop = c(indicator, rate, "women_15_49_years")), group = "vaccine")
  expect_length(problems, 3)
  expect_match(problems, "women_15_49_years", all = FALSE)
  expect_match(problems, rate, all = FALSE, fixed = TRUE)
  expect_match(problems, indicator, all = FALSE, fixed = TRUE)
})

test_that("the sheets and the merged data are asked the same question", {
  # what the Data Quality step reports is what new_countdown() would stop on at Finish
  for (drop in list(character(0), "pop_growth_rate", c("total_births", "live_births"))) {
    parts <- required_parts(drop = drop)
    before <- check_required_columns_presheet(parts, group = "vaccine")
    after <- describe_missing_columns(required_columns_missing(colnames(merged_like(parts)), "vaccine"), "vaccine")
    expect_identical(unname(before), if (length(after)) unname(after) else NULL)
  }
})

test_that("check_required_columns_exist stops on a missing population column, naming it", {
  expect_error(check_required_columns_exist(merged_like(required_parts(drop = "pop_growth_rate")), "vaccine"), "pop_growth_rate")
  expect_no_error(check_required_columns_exist(merged_like(required_parts()), "vaccine"))
})

test_that("standardize_data does not fail on data without pop_growth_rate, and does not make the column up", {
  merged <- tibble::tibble(
    country = "Kenya", first_admin_level = "Rift Valley", district = "Baringo County",
    year = c(2023, 2023, 2024, 2024), month = c("January", "February", "January", "February"),
    total_population = c(1000, 1000, 1030, 1030), stillbirth_fresh = 1, stillbirth_macerated = 1
  )
  out <- standardize_data(merged)
  expect_false("pop_rate" %in% colnames(out))
  expect_true("total_pop" %in% colnames(out))

  with_rate <- standardize_data(dplyr::mutate(merged, pop_growth_rate = 2.5))
  expect_type(with_rate$pop_rate, "double")
})

# Every issue as a table and a workbook ------------------------------------------------------------

test_that("quality_issues_table has a row per check and a row per issue, nothing shortened", {
  flagged <- tibble::tibble(district = paste("District", 1:14), year = 2024, live_births = 10, total_delivered = 20)
  sentence <- c("x" = "District-year(s) where ...: District 1 2024; ... (+4 more).")
  attr(sentence, "rows") <- flagged
  results <- list(
    admin_columns = list(ok = TRUE, severity = "blocking", detail = NULL),
    required_columns = list(ok = FALSE, severity = "blocking", detail = c("x" = "The Population_data sheet is missing column(s): pop_growth_rate.")),
    population_vs_births = list(ok = FALSE, severity = "informational", detail = sentence),
    indicator_emptiness = list(ok = FALSE, severity = "informational", detail = c("hiv_test", "bcg")),
    population_service_collision = list(ok = TRUE, severity = "informational", detail = tibble::tibble(district = character(0), year = integer(0)))
  )
  tables <- quality_issues_table(results, labels = c(required_columns = "Colonnes requises"))

  expect_equal(nrow(tables$summary), 5)
  expect_equal(tables$summary$status, c("passed", "issue", "issue", "issue", "passed"))
  expect_equal(tables$summary$issues, c(0L, 1L, 14L, 2L, 0L))
  expect_equal(tables$summary$check[2], "Colonnes requises")
  expect_equal(tables$summary$check[1], "Admin sheet columns")

  expect_equal(nrow(tables$issues), 17)
  expect_match(tables$issues$issue[1], "pop_growth_rate")
  expect_equal(sum(tables$issues$check == "Population live births against reported births"), 14)
  expect_match(tables$issues$issue[15], "District 14")
  expect_equal(tail(tables$issues$issue, 2), c("hiv_test", "bcg"))
})

test_that("write_quality_issues writes the two sheets", {
  results <- list(
    required_columns = list(ok = FALSE, severity = "blocking", detail = c("x" = "The Population_data sheet is missing column(s): pop_growth_rate.")),
    month_presence = list(ok = TRUE, severity = "blocking", detail = NULL)
  )
  path <- withr::local_tempfile(fileext = ".xlsx")
  write_quality_issues(results, path)
  expect_equal(openxlsx::getSheetNames(path), c("Summary", "Issues"))
  expect_equal(openxlsx::read.xlsx(path, "Summary")$status, c("issue", "passed"))
  expect_match(openxlsx::read.xlsx(path, "Issues")$issue, "pop_growth_rate")

  # nothing found: the workbook is still written, every check passed
  results$required_columns <- list(ok = TRUE, severity = "blocking", detail = NULL)
  write_quality_issues(results, path)
  expect_equal(openxlsx::read.xlsx(path, "Summary")$status, c("passed", "passed"))
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
