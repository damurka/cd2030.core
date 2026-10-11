# Phase 2 data-quality checks for the Load Data wizard (countdown-analytics/apps/rmncah).
#
# Every check_*() function below returns NULL on pass, or a named character vector of
# cli-bullet-formatted problem lines ("x"/"!"/...) on failure -- it never calls cd_abort()
# itself. This keeps each check a small, pure, independently-testable function (same spirit as
# check_required_columns_exist()/check_file_path() in utils.R, just not abort-on-call), and lets
# run_quality_checks() below collect several of them together into ONE combined abort instead of
# stopping at the first problem found -- see 0_import_load_data.R's own Tier A/Tier B call sites
# for where each one is actually wired in.

#' Format a cli message as plain text in the caller's scope
#'
#' Interpolates `text` with the caller's variables and returns a plain string with no ANSI codes.
#'
#' @param text A string with cli inline markup.
#' @param .envir The environment the markup is evaluated in.
#' @return A character string.
#' @noRd
cd_fmt <- function(text, .envir = parent.frame()) {
  # Each check formats its message here, while its local variables still exist. A raw template
  # handed to run_quality_checks() would be interpolated by cd_abort() in an environment where
  # those variables are gone.
  cli::cli_div(theme = cd_theme())
  # ansi_strip() -- confirmed live: cli::format_inline() can emit raw ANSI color escape codes (the
  # theme's own span.field/span.val colors, cd_theme() above) depending on the R session's own
  # ANSI-color detection state, which is NOT something this app's caller (the Load Data wizard,
  # apps/rmncah) controls or wants -- this text is rendered straight into HTML, where an unstripped
  # escape sequence shows up as garbled control characters (e.g. a literal "[34m"/"[39m") instead of
  # any color at all. Stripping guarantees clean plain text regardless of that detection state.
  cli::ansi_strip(cli::format_inline(text, .envir = .envir))
}

#' Run several quality checks and abort once with every problem found
#'
#' @param checks A named list of zero-argument functions, each returning `NULL` (pass) or a
#'   character vector of problems already formatted with `cd_fmt()` (fail).
#' @param call The calling environment, forwarded to `cd_abort()`.
#' @return `NULL`, invisibly, when every check passes. Otherwise it aborts.
#' @noRd
run_quality_checks <- function(checks, call = caller_env()) {
  problems <- unlist(purrr::compact(purrr::map(checks, ~ .x())), use.names = TRUE)
  if (length(problems) > 0) {
    cd_abort(problems, call = call)
  }
  invisible(NULL)
}

# --- Tier A: raw Admin_data sheet, before merge/standardize --------------------------------

#' Check that the Admin sheet has its required columns
#'
#' Checks that the Admin sheet has the `country` and `first_admin_level` columns. Run it on
#' the sheet before the sheets are merged, so that a missing column is reported by name.
#'
#' @param admin_data A data frame. The cleaned Admin sheet, before the sheets are merged (the
#'   admin element of `load_excel_parts()$parts`).
#' @return `NULL` if both columns are present. Otherwise a character vector of length one,
#'   named `"x"`, with a message that lists the missing columns.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' admin <- sheets$parts[[sheets$admin_sheet_name]]
#' check_admin_columns(admin)
#'
#' # A sheet without its country column
#' check_admin_columns(admin[setdiff(names(admin), "country")])
#' @export
check_admin_columns <- function(admin_data) {
  # Later steps pick these two columns up with any_of(), so a sheet without them loads and then
  # fails far from the cause. `district` is checked by read_and_clean_sheet().
  missing <- setdiff(c("country", "first_admin_level"), colnames(admin_data))
  if (length(missing) == 0) {
    return(NULL)
  }
  c("x" = cd_fmt("The Admin_data sheet is missing column(s): {.field {paste(missing, collapse = ', ')}}."))
}

#' Check that the sheets have the columns an indicator group needs
#'
#' Checks the unmerged sheets for every column the indicator group requires: the group's
#' indicators, a reporting rate for each of its categories, and the population columns. It
#' reports the same missing columns that [new_countdown()] stops on, before the sheets are merged.
#'
#' @details
#' Only the column names are read. They are compared as they will be once the sheets are merged
#' and standardized, so a column that standardization renames or computes is not reported as
#' missing. The messages use the names the workbook uses.
#'
#' @param parts A named list of cleaned per-sheet tibbles (`load_excel_parts()$parts`).
#' @param group A string. The indicator group to check against. Default is the selected group.
#' @return `NULL` if no required column is missing, or if the sheets have no columns. Otherwise
#'   a character vector with up to three messages, each named `"x"`: one for the population
#'   columns, one for the reporting rate columns and one for the indicator columns.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' check_required_columns_presheet(sheets$parts, group = "rmncah")
#'
#' # A Population sheet without its growth rate column
#' parts <- sheets$parts
#' parts[[sheets$population_sheet_name]]$pop_growth_rate <- NULL
#' check_required_columns_presheet(parts, group = "rmncah")
#' @export
check_required_columns_presheet <- function(parts, group = get_selected_group()) {
  # A workbook whose Population sheet had no Pop_growth_rate passed every other check and then
  # failed inside standardize_data(). This check names the column instead.
  column_names <- unique(unlist(lapply(parts, colnames), use.names = FALSE))
  if (length(column_names) == 0) {
    return(NULL)
  }
  missing <- required_columns_missing(.standardized_column_names(column_names), group)
  if (length(unlist(missing)) == 0) {
    return(NULL)
  }
  describe_missing_columns(missing, group)
}

#' Check that the Admin sheet names one country
#'
#' Checks that the `country` column of the Admin sheet holds no more than one distinct value.
#' A dataset must belong to one country, so run this before the sheets are merged to get a
#' message that lists the values found.
#'
#' @details
#' Missing values are ignored. A sheet with no country value at all passes this check.
#'
#' @param admin_data A data frame. The cleaned Admin sheet, with a `country` column.
#' @return `NULL` if the sheet has at most one country value. Otherwise a character vector of
#'   length one, named `"x"`, with a message that lists the values.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' admin <- sheets$parts[[sheets$admin_sheet_name]]
#' check_single_country(admin)
#'
#' # A row that belongs to another country
#' admin$country[1] <- "Uganda"
#' check_single_country(admin)
#' @export
check_single_country <- function(admin_data) {
  # new_countdown() passes the distinct country values to match_country(), which aborts on more
  # than one value without saying what the values are.
  values <- admin_data %>%
    dplyr::distinct(.data$country) %>%
    dplyr::pull(.data$country)
  values <- values[!is.na(values)]
  if (length(values) <= 1) {
    return(NULL)
  }
  c("x" = cd_fmt("The Admin_data sheet's {.field country} column has more than one value: {.val {paste(values, collapse = ', ')}}."))
}

# --- Tier B: merged + standardized data, inside new_countdown() ----------------------------

#' Check that districts are consistent across the dataset
#'
#' Checks two things in the merged data: that each district belongs to one admin level 1 unit,
#' and that each district appears in every year of the data. A district that fails either test
#' has usually been renamed or misspelled in part of the workbook.
#'
#' @details
#' Admin level 1 names are compared without regard to case or extra spaces, so `"North  East"`
#' and `"north east"` count as the same unit. The years a district must appear in are all the
#' distinct years in `.data`.
#'
#' @param .data A data frame. The merged and standardized dataset, with `district`,
#'   `adminlevel_1` and `year` columns.
#' @return `NULL` if no problem is found. Otherwise a character vector with one or two messages,
#'   each named `"x"`: one that lists the districts with more than one admin level 1 name, and
#'   one that lists the districts missing from at least one year.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' data <- load_data(path)
#' check_district_consistency(data)
#'
#' # A district spelled differently in one year
#' renamed <- data
#' renamed$district[renamed$district == "Baringo" & renamed$year == 2023] <- "Baringo County"
#' check_district_consistency(renamed)
#' @export
check_district_consistency <- function(.data) {
  pairs <- .data %>%
    dplyr::distinct(.data$district, .data$adminlevel_1) %>%
    dplyr::mutate(admin_key = stringr::str_squish(stringr::str_to_lower(.data$adminlevel_1)))

  inconsistent <- pairs %>%
    dplyr::summarise(n = dplyr::n_distinct(.data$admin_key), .by = "district") %>%
    dplyr::filter(.data$n > 1) %>%
    dplyr::pull(.data$district)

  all_years <- .data %>% dplyr::distinct(.data$year) %>% dplyr::pull(.data$year)
  district_years <- .data %>% dplyr::distinct(.data$district, .data$year)
  incomplete <- district_years %>%
    dplyr::summarise(n = dplyr::n_distinct(.data$year), .by = "district") %>%
    dplyr::filter(.data$n < length(all_years)) %>%
    dplyr::pull(.data$district)

  problems <- character(0)
  if (length(inconsistent) > 0) {
    problems <- c(problems, "x" = cd_fmt("District(s) with an inconsistent admin-1 name across years/sheets: {.field {paste(inconsistent, collapse = ', ')}}."))
  }
  if (length(incomplete) > 0) {
    problems <- c(problems, "x" = cd_fmt("District(s) missing from at least one year present elsewhere in the data: {.field {paste(incomplete, collapse = ', ')}}."))
  }
  if (length(problems) == 0) NULL else problems
}

#' Check that every district-year has all 12 months
#'
#' Checks that each district has a row for every calendar month of every year it appears in.
#' A missing month leaves a gap in the monthly series the analysis relies on.
#'
#' @param .data A data frame with `district`, `year` and `month` columns, where `month` holds
#'   English month names. This is usually the merged and standardized dataset.
#' @return `NULL` if no month is missing. Otherwise a character vector of length one, named
#'   `"x"`, with a message that lists the missing months as `district year/month`. The message
#'   lists the first 10 and gives a count of the rest.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' data <- load_data(path)
#' check_month_presence(data)
#'
#' # One month of one district-year dropped
#' gap <- data$district == "Baringo" & data$year == 2023 & data$month == "March"
#' check_month_presence(data[!gap, ])
#' @export
check_month_presence <- function(.data) {
  district_years <- .data %>% dplyr::distinct(.data$district, .data$year)
  expected <- tidyr::expand_grid(district_years, month = factor(month.name, levels = month.name, ordered = TRUE))
  present <- .data %>% dplyr::distinct(.data$district, .data$year, .data$month)

  missing <- dplyr::anti_join(expected, present, by = c("district", "year", "month"))
  if (nrow(missing) == 0) {
    return(NULL)
  }
  detail <- missing %>%
    dplyr::mutate(label = paste0(.data$district, " ", .data$year, "/", .data$month)) %>%
    dplyr::pull(.data$label)
  shown <- utils::head(detail, 10)
  more <- if (length(detail) > length(shown)) paste0(" (+", length(detail) - length(shown), " more)") else ""
  c("x" = cd_fmt("Missing month(s): {.field {paste(shown, collapse = ', ')}}{more}."))
}

#' Check that every month value is a recognized month
#'
#' Checks the merged data for rows whose month could not be read as a calendar month, for
#' example because of a typo or a month name in a language that is not supported. Such rows
#' have a missing `month` and would otherwise stay in the data unnoticed.
#'
#' @details
#' A row is a problem when its `month` is `NA`. If `.data` has a `raw_month` column (the month
#' text as it was in the workbook), the message lists the distinct unrecognized values. If it
#' does not, as with a Stata master dataset, or if those values are all missing, the message
#' gives the number of affected rows instead.
#'
#' @param .data A data frame. The merged and standardized dataset, with a `month` column and
#'   optionally a `raw_month` column.
#' @return `NULL` if every month is recognized, or if `.data` has no `month` column. Otherwise
#'   a character vector of length one, named `"x"`, with the message.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' data <- load_data(path)
#' check_month_validity(data)
#'
#' # Months that could not be read are missing after loading
#' data$month[1:3] <- NA
#' check_month_validity(data)
#' @export
check_month_validity <- function(.data) {
  # standardize_data() turns an unrecognized month into NA without a warning and keeps the row.
  if (!"month" %in% colnames(.data)) {
    return(NULL)
  }
  bad <- .data[is.na(.data$month), , drop = FALSE]
  if (nrow(bad) == 0) {
    return(NULL)
  }
  if ("raw_month" %in% colnames(bad)) {
    values <- unique(stats::na.omit(bad$raw_month))
    if (length(values) > 0) {
      return(c("x" = cd_fmt("Unrecognized month value(s) (typo, different language, etc.): {.val {paste(values, collapse = ', ')}}.")))
    }
  }
  n <- nrow(bad)
  c("x" = cd_fmt("{n} row(s) have a missing or unrecognized month value."))
}

# --- Informational checks: CacheConnection methods, called on demand -----------------------

#' Flag district-years where service births equal population births
#'
#' Finds district-years where the monthly institutional live births (`instlivebirths`) equal the
#' annual population live births (`live_births`) in every month. Monthly counts normally vary,
#' so this pattern suggests that population figures were entered in a service data sheet.
#'
#' @details
#' Only months where both values are present are compared. A district-year is flagged when it
#' has at least three such months and the two values are equal in all of them.
#'
#' @param .data A data frame. The merged dataset, with `district`, `year`, `instlivebirths` and
#'   `live_births` columns.
#' @return A tibble with columns `district` and `year`, one row per flagged district-year. It
#'   has no rows if nothing is flagged or if `.data` lacks `instlivebirths` or `live_births`.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' data <- load_data(path)
#' check_population_service_collision(data)
#'
#' # Annual population births entered as the monthly service figure
#' copied <- data$district == "Baringo" & data$year == 2023
#' data$instlivebirths[copied] <- data$live_births[copied]
#' check_population_service_collision(data)
#' @export
check_population_service_collision <- function(.data) {
  if (!all(c("instlivebirths", "live_births") %in% colnames(.data))) {
    return(dplyr::tibble(district = character(0), year = integer(0)))
  }
  .data %>%
    dplyr::filter(!is.na(.data$instlivebirths), !is.na(.data$live_births)) %>%
    dplyr::summarise(
      months = dplyr::n(),
      matching = sum(.data$instlivebirths == .data$live_births),
      .by = c("district", "year")
    ) %>%
    dplyr::filter(.data$months >= 3, .data$matching == .data$months) %>%
    dplyr::select("district", "year")
}

#' Flag indicators that have no data
#'
#' Finds the indicators of the selected indicator group whose column is missing in every row
#' of the dataset. An indicator with no data cannot be analysed.
#'
#' @details
#' Only indicator columns that are present in `.data` are examined. An indicator whose column
#' is absent is not reported here.
#'
#' @param .data A data frame. The merged dataset, with one column per indicator.
#' @return A character vector of the names of the empty indicators. It has length zero if
#'   there are none.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' data <- load_data(path)
#' check_indicator_emptiness(data)
#'
#' # An indicator that was never reported
#' data$penta3 <- NA_real_
#' check_indicator_emptiness(data)
#' @export
check_indicator_emptiness <- function(.data) {
  indicators <- unique(purrr::list_c(get_indicator_groups()))
  present <- intersect(indicators, colnames(.data))
  if (length(present) == 0) {
    return(character(0))
  }
  empty <- present[colSums(is.na(.data[present])) == nrow(.data)]
  empty
}

# --- Mapping checks: CacheConnection methods, informational --------------------------------

#' Check that every one of `names_to_check` has a close match somewhere in `known_names`
#'
#' Shared by `check_survey_admin_names()`/`check_shapefile_admin_names()` -- same
#' Jaro-Winkler `stringdist` + closest-match-under-threshold idiom `match_country()`
#' (`0_import_load_data.R`) already uses for country names, applied to district/region names
#' instead. Direction matters: `names_to_check` is always the dataset's OWN `adminlevel_1`
#' values -- what actually needs coverage (a dataset region with no matching survey/shapefile
#' entry can't get a regional estimate or be shown on a map) -- checked against `known_names`,
#' the survey's or shapefile's own names. Not the other way around: a survey/shapefile row with
#' no dataset match is just unused, not a coverage gap in the dataset itself.
#'
#' @param names_to_check Character vector of names whose coverage is being verified -- the
#'   dataset's own `adminlevel_1` values.
#' @param known_names Character vector of names to match against -- the survey's or shapefile's
#'   own region names.
#' @param threshold Jaro-Winkler distance above which a name is considered unmatched.
#' @return A tibble with one row per unmatched name: `name`, `suggestion`, `distance`.
#' @noRd
match_admin_names <- function(names_to_check, known_names, threshold = 0.25) {
  names_to_check <- unique(stats::na.omit(names_to_check))
  known_names <- unique(stats::na.omit(known_names))
  if (length(names_to_check) == 0 || length(known_names) == 0) {
    return(dplyr::tibble(name = character(0), suggestion = character(0), distance = double(0)))
  }

  # replace_special_chars() (0_import_load_data.R) strips accents (e-acute, e-grave, n-tilde, etc.) the same way it
  # already does for month names -- without it, a genuinely identical region name that only
  # differs by accent/case (confirmed live: a real dataset's "Oueme" vs its survey's "OUEME" written with accents,
  # Jaro-Winkler distance 0.267 -- just over the default threshold -- collapses to an exact 0 once
  # both are normalized the same way) reads as a false mismatch.
  normalize <- function(x) stringr::str_to_lower(replace_special_chars(x))
  purrr::map_dfr(names_to_check, function(nm) {
    dists <- stringdist::stringdist(normalize(nm), normalize(known_names), method = "jw")
    best <- which.min(dists)
    dplyr::tibble(name = nm, suggestion = known_names[best], distance = dists[best])
  }) %>%
    dplyr::filter(.data$distance >= threshold)
}

#' Flag admin level 1 names with no matching survey region
#'
#' Finds the admin level 1 names in the dataset that have no close match among the regions of
#' the regional survey. A dataset region without a survey match cannot get a regional or equity
#' estimate.
#'
#' @details
#' Names are compared without regard to case or accents, using the Jaro-Winkler distance. A
#' name is unmatched when its distance to the closest survey name is 0.25 or more. Survey
#' regions that match no dataset name are not reported.
#'
#' @param regional_survey A data frame of regional survey data with an `adminlevel_1` column,
#'   or `NULL`.
#' @param countdown_data A data frame. The dataset, with an `adminlevel_1` column.
#' @return A tibble with one row per unmatched dataset name and columns `name` (the dataset
#'   name), `suggestion` (the closest survey name) and `distance` (the distance between them).
#'   It has no rows if every name matches, or if `regional_survey` is `NULL` or has no
#'   `adminlevel_1` column.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' cache <- load_cache_data(path)
#' data <- cache$countdown_data
#' check_survey_admin_names(cache$regional_survey, data)
#'
#' # A region the survey calls something else
#' data$adminlevel_1[data$adminlevel_1 == "Coast"] <- "Pwani"
#' check_survey_admin_names(cache$regional_survey, data)
#' @export
check_survey_admin_names <- function(regional_survey, countdown_data) {
  if (is.null(regional_survey) || !"adminlevel_1" %in% colnames(regional_survey)) {
    return(dplyr::tibble(name = character(0), suggestion = character(0), distance = double(0)))
  }
  match_admin_names(countdown_data$adminlevel_1, regional_survey$adminlevel_1)
}

#' Flag admin level 1 names with no matching shapefile region
#'
#' Finds the admin level 1 names in the dataset that have no close match among the regions of
#' the shapefile. A dataset region without a shapefile match cannot be shown on a map.
#'
#' @details
#' Names are compared without regard to case or accents, using the Jaro-Winkler distance. A
#' name is unmatched when its distance to the closest shapefile name is 0.25 or more. Shapefile
#' regions that match no dataset name are not reported.
#'
#' @param shapefile An `sf` object, or `NULL`. The country's shapefile: the one bundled with
#'   the package or one the user uploaded.
#' @param countdown_data A data frame. The dataset, with an `adminlevel_1` column.
#' @param name_field A string. The column of `shapefile` that holds the admin level 1 names.
#'   Default is `"NAME_1"`, the column the bundled shapefiles use.
#' @return A tibble with one row per unmatched dataset name and columns `name` (the dataset
#'   name), `suggestion` (the closest shapefile name) and `distance` (the distance between
#'   them). It has no rows if every name matches, or if `shapefile` is `NULL` or has no
#'   `name_field` column.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' cache <- load_cache_data(path)
#'
#' # The bundled shapefile has the counties, the dataset's regions are the former provinces
#' check_shapefile_admin_names(cache$shapefile, cache$countdown_data)
#'
#' # With no shapefile there is nothing to compare
#' check_shapefile_admin_names(NULL, cache$countdown_data)
#' @export
check_shapefile_admin_names <- function(shapefile, countdown_data, name_field = "NAME_1") {
  if (is.null(shapefile) || !name_field %in% colnames(shapefile)) {
    return(dplyr::tibble(name = character(0), suggestion = character(0), distance = double(0)))
  }
  match_admin_names(countdown_data$adminlevel_1, shapefile[[name_field]])
}

# --- Pre-merge checks: separate per-sheet `parts`, before merge_data()/standardize_data() --------
#
# Phase 3 of the Load Data wizard redesign (apps/rmncah): the wizard now holds each Excel sheet
# separately (CacheConnection$wizard_parts, set from load_excel_parts()) all the way through Data
# Quality, and only merges at Finish (merge_and_standardize()). Every check below is the pre-merge
# counterpart of an existing post-merge one -- same severity, same user-facing meaning -- but reads
# straight from `parts` so a problem can be attributed to the specific sheet it came from, and so a
# row that would have been silently dropped by merge_data()'s left-join-anchored-on-admin (the
# original bug this whole redesign exists to fix) is checked BEFORE that drop can ever happen.

#' Check that districts match between the Admin sheet and the others
#'
#' Compares the districts in the Admin sheet with the districts in all the other sheets, in
#' both directions. Run it on the unmerged sheets: merging keeps only the districts of one
#' sheet, so a district that is missing from that sheet would be dropped without notice.
#'
#' @param parts A named list of cleaned per-sheet tibbles (`load_excel_parts()$parts`).
#' @param admin_sheet_name A string. The name of the Admin sheet within `parts`.
#' @return `NULL` if the districts match, or if the Admin sheet has no `district` column.
#'   Otherwise a character vector with one or two messages, each named `"x"`: one that lists
#'   the districts found in another sheet but not in the Admin sheet, each with the sheets it
#'   was found in, and one that lists the Admin sheet districts found in no other sheet.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' check_district_cross_sheet(sheets$parts, sheets$admin_sheet_name)
#'
#' # A district renamed in the Admin sheet only
#' parts <- sheets$parts
#' parts[[sheets$admin_sheet_name]]$district[1] <- "Baringo County"
#' check_district_cross_sheet(parts, sheets$admin_sheet_name)
#' @export
check_district_cross_sheet <- function(parts, admin_sheet_name) {
  # merge_data() left-joins onto one sheet, so a district absent from it is lost before any
  # check on the merged data can see it.
  if (!"district" %in% colnames(parts[[admin_sheet_name]])) {
    return(NULL)
  }
  admin_districts <- unique(stats::na.omit(parts[[admin_sheet_name]]$district))
  other_sheets <- setdiff(names(parts), admin_sheet_name)
  other_by_sheet <- purrr::map(parts[other_sheets], function(d) {
    if ("district" %in% colnames(d)) unique(stats::na.omit(d$district)) else character(0)
  })
  other_districts <- unique(purrr::list_c(unname(other_by_sheet)))

  only_in_other <- setdiff(other_districts, admin_districts)
  only_in_admin <- setdiff(admin_districts, other_districts)

  problems <- character(0)
  if (length(only_in_other) > 0) {
    # Name which sheet(s) each one actually came from -- the per-sheet attribution the redesign is for.
    detail <- vapply(only_in_other, function(d) {
      found_in <- names(other_by_sheet)[vapply(other_by_sheet, function(ds) d %in% ds, logical(1))]
      paste0(d, " (", paste(found_in, collapse = ", "), ")")
    }, character(1))
    problems <- c(problems, "x" = cd_fmt("District(s) present in the data but missing from {.field {admin_sheet_name}}: {.field {paste(detail, collapse = '; ')}}."))
  }
  if (length(only_in_admin) > 0) {
    problems <- c(problems, "x" = cd_fmt("District(s) in {.field {admin_sheet_name}} not found in any other sheet: {.field {paste(only_in_admin, collapse = ', ')}}."))
  }
  if (length(problems) == 0) NULL else problems
}

#' Check that each district has one admin level 1 name in the Admin sheet
#'
#' Checks that no district is listed in the Admin sheet under more than one admin level 1 unit.
#' This is the part of [check_district_consistency()] that can run before the sheets are merged.
#'
#' @details
#' Admin level 1 names are compared without regard to case or extra spaces.
#'
#' @param admin_data A data frame. The cleaned Admin sheet, before the sheets are merged, with
#'   `district` and `first_admin_level` columns.
#' @return `NULL` if every district has one admin level 1 name, or if the sheet lacks either
#'   column. Otherwise a character vector of length one, named `"x"`, with a message that lists
#'   the districts.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' admin <- sheets$parts[[sheets$admin_sheet_name]]
#' check_admin_pairing_consistency(admin)
#'
#' # The first district listed a second time, under another region
#' again <- admin[1, ]
#' again$first_admin_level <- "Western"
#' check_admin_pairing_consistency(rbind(admin, again))
#' @export
check_admin_pairing_consistency <- function(admin_data) {
  if (!all(c("district", "first_admin_level") %in% colnames(admin_data))) {
    return(NULL)
  }
  pairs <- admin_data %>%
    dplyr::distinct(.data$district, .data$first_admin_level) %>%
    dplyr::mutate(admin_key = stringr::str_squish(stringr::str_to_lower(.data$first_admin_level)))

  inconsistent <- pairs %>%
    dplyr::summarise(n = dplyr::n_distinct(.data$admin_key), .by = "district") %>%
    dplyr::filter(.data$n > 1) %>%
    dplyr::pull(.data$district)

  if (length(inconsistent) == 0) {
    return(NULL)
  }
  c("x" = cd_fmt("District(s) with an inconsistent admin-1 name in the Admin sheet: {.field {paste(inconsistent, collapse = ', ')}}."))
}

#' Check that every district has every year in the Population sheet
#'
#' Checks that each district in the Population sheet has a row for every year the sheet
#' covers. This is the part of [check_district_consistency()] that can run before the sheets
#' are merged.
#'
#' @param population_data A data frame. The cleaned Population sheet, before the sheets are
#'   merged, with `district` and `year` columns.
#' @return `NULL` if every district appears in every year, or if the sheet lacks either column.
#'   Otherwise a character vector of length one, named `"x"`, with a message that lists the
#'   districts missing from at least one year.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' population <- sheets$parts[[sheets$population_sheet_name]]
#' check_district_year_completeness(population)
#'
#' # A district with no population row for one year
#' gap <- population$district == "Baringo" & population$year == 2023
#' check_district_year_completeness(population[!gap, ])
#' @export
check_district_year_completeness <- function(population_data) {
  if (!all(c("district", "year") %in% colnames(population_data))) {
    return(NULL)
  }
  all_years <- population_data %>% dplyr::distinct(.data$year) %>% dplyr::pull(.data$year)
  district_years <- population_data %>% dplyr::distinct(.data$district, .data$year)
  incomplete <- district_years %>%
    dplyr::summarise(n = dplyr::n_distinct(.data$year), .by = "district") %>%
    dplyr::filter(.data$n < length(all_years)) %>%
    dplyr::pull(.data$district)

  if (length(incomplete) == 0) {
    return(NULL)
  }
  c("x" = cd_fmt("District(s) missing from at least one year present elsewhere in the Population sheet: {.field {paste(incomplete, collapse = ', ')}}."))
}

#' Check that the country in the Admin sheet is recognized
#'
#' Checks that the country named in the Admin sheet is one the package supports. Run it before
#' the sheets are merged to report an unrecognized country early. [new_countdown()] stops with
#' an error on the same problem.
#'
#' @details
#' The check applies only when the `country` column holds exactly one distinct value, ignoring
#' missing values. More than one value is reported by [check_single_country()]. The name is
#' recognized when it is close to a name in the package's list of countries.
#'
#' @param parts A named list of cleaned per-sheet tibbles (`load_excel_parts()$parts`).
#' @param admin_sheet_name A string. The name of the Admin sheet within `parts`.
#' @return `NULL` if the country is recognized, if the Admin sheet has no `country` column, or
#'   if the column does not hold exactly one value. Otherwise a character vector of length one,
#'   named `"x"`, with a message that gives the unrecognized name.
#' @seealso [check_required_columns_presheet()]
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' check_country_recognized(sheets$parts, sheets$admin_sheet_name)
#'
#' # A country the package has no reference data for
#' parts <- sheets$parts
#' parts[[sheets$admin_sheet_name]]$country <- "Atlantis"
#' check_country_recognized(parts, sheets$admin_sheet_name)
#' @export
check_country_recognized <- function(parts, admin_sheet_name) {
  # match_country() otherwise runs only in new_countdown(), after the merge. Without this check
  # an unrecognized country is reported on the last step of the Load Data wizard.
  admin_data <- parts[[admin_sheet_name]]
  if (!"country" %in% colnames(admin_data)) {
    return(NULL)
  }
  values <- unique(stats::na.omit(admin_data$country))
  if (length(values) != 1) {
    # More than one value is check_single_country()'s own problem to report, not this one's.
    return(NULL)
  }
  result <- tryCatch(match_country(values[1]), error = function(e) e)
  if (!inherits(result, "error")) {
    return(NULL)
  }
  c("x" = cd_fmt("The country name {.val {values}} in {.field {admin_sheet_name}} is not recognized."))
}

#' Bind the service sheets into one data frame
#'
#' Stacks the rows of the service sheets without joining them to any other sheet, so no row is
#' dropped.
#' @noRd
.bind_service_sheets <- function(parts, service_sheet_names) {
  dplyr::bind_rows(parts[intersect(service_sheet_names, names(parts))])
}

#' Check that every district-year has all 12 months, before merging
#'
#' Runs [check_month_presence()] on the service sheets, stacked together, before the sheets
#' are merged. A district-year passes when its 12 months are present across the service sheets
#' taken together.
#'
#' @param parts A named list of cleaned per-sheet tibbles (`load_excel_parts()$parts`).
#' @param service_sheet_names A character vector. The names of the service data sheets within
#'   `parts`.
#' @return `NULL` if no month is missing. Otherwise a character vector of length one, named
#'   `"x"`, with a message that lists the missing months as `district year/month`. The message
#'   lists the first 10 and gives a count of the rest.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' check_month_presence_presheet(sheets$parts, sheets$service_sheet_names)
#'
#' # March left out of every service sheet
#' parts <- sheets$parts
#' for (sheet in sheets$service_sheet_names) {
#'   parts[[sheet]] <- parts[[sheet]][parts[[sheet]]$month != "March", ]
#' }
#' check_month_presence_presheet(parts, sheets$service_sheet_names)
#' @export
check_month_presence_presheet <- function(parts, service_sheet_names) {
  check_month_presence(.bind_service_sheets(parts, service_sheet_names))
}

#' Check that every month value is a recognized month, before merging
#'
#' Checks the service sheets, before they are merged, for rows whose month could not be read
#' as a calendar month, for example because of a typo or a month name in a language that is
#' not supported.
#'
#' @details
#' A row is a problem when its `month` is `NA`. If the sheets have a `raw_month` column (the
#' month text as it was in the workbook, which [load_excel_parts()] keeps), the message lists
#' the distinct unrecognized values. If they do not, or if those values are all missing, the
#' message gives the number of affected rows instead.
#'
#' @inheritParams check_month_presence_presheet
#' @return `NULL` if every month is recognized, or if the service sheets have no `month`
#'   column. Otherwise a character vector of length one, named `"x"`, with the message.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' check_month_validity_presheet(sheets$parts, sheets$service_sheet_names)
#'
#' # A month the workbook misspells is read as missing
#' parts <- sheets$parts
#' sheet <- sheets$service_sheet_names[1]
#' typo <- parts[[sheet]]$month == "March"
#' parts[[sheet]]$raw_month[typo] <- "Mrch"
#' parts[[sheet]]$month[typo] <- NA
#' check_month_validity_presheet(parts, sheets$service_sheet_names)
#' @export
check_month_validity_presheet <- function(parts, service_sheet_names) {
  # load_excel_parts() has already parsed `month` on every sheet, so NA here means the value
  # did not parse. There is no need to call parse_month_name() again.
  service_data <- .bind_service_sheets(parts, service_sheet_names)
  if (!"month" %in% colnames(service_data)) {
    return(NULL)
  }
  bad <- service_data[is.na(service_data$month), , drop = FALSE]
  if (nrow(bad) == 0) {
    return(NULL)
  }
  if ("raw_month" %in% colnames(bad)) {
    values <- unique(stats::na.omit(bad$raw_month))
    if (length(values) > 0) {
      return(c("x" = cd_fmt("Unrecognized month value(s) (typo, different language, etc.): {.val {paste(values, collapse = ', ')}}.")))
    }
  }
  n <- nrow(bad)
  c("x" = cd_fmt("{n} row(s) have a missing or unrecognized month value."))
}

#' Flag indicators that have no data, before merging
#'
#' Runs [check_indicator_emptiness()] on the service sheets, stacked together, before the
#' sheets are merged. An indicator is flagged when it is missing in every row of every service
#' sheet.
#'
#' @inheritParams check_month_presence_presheet
#' @return A character vector of the names of the empty indicators. It has length zero if
#'   there are none.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' check_indicator_emptiness_presheet(sheets$parts, sheets$service_sheet_names)
#' @export
check_indicator_emptiness_presheet <- function(parts, service_sheet_names) {
  check_indicator_emptiness(.bind_service_sheets(parts, service_sheet_names))
}

#' Flag months that are written in more than one way
#'
#' Finds the calendar months that the service sheets label with more than one text, for example
#' `"January"` in one sheet and `"Janvier"` in another. The data loads correctly either way,
#' because the month names are standardized. The result shows that the workbook mixes
#' languages or spellings, which is worth knowing about how it was put together.
#'
#' @param parts A named list of cleaned per-sheet tibbles (`load_excel_parts()$parts`).
#' @param service_sheet_names A character vector. The names of the service data sheets within
#'   `parts`.
#' @return A tibble with one row per month that has more than one distinct original text, and
#'   columns `month` (the standardized month name) and `variants` (the distinct original texts,
#'   sorted and separated by commas). It has no rows if no month qualifies, or if the service
#'   sheets lack a `month` or `raw_month` column.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' check_month_language_consistency(sheets$parts, sheets$service_sheet_names)
#'
#' # One service sheet that names January in French
#' parts <- sheets$parts
#' sheet <- sheets$service_sheet_names[2]
#' parts[[sheet]]$raw_month[parts[[sheet]]$month == "January"] <- "Janvier"
#' check_month_language_consistency(parts, sheets$service_sheet_names)
#' @export
check_month_language_consistency <- function(parts, service_sheet_names) {
  # load_excel_parts() standardizes `month` on each sheet before the merge, so a sheet in French
  # beside sheets in English no longer loses data in the join. That fix is silent. This check
  # reports the mix itself.
  service_data <- .bind_service_sheets(parts, service_sheet_names)
  if (!all(c("month", "raw_month") %in% colnames(service_data))) {
    return(dplyr::tibble(month = character(0), variants = character(0)))
  }
  service_data %>%
    dplyr::filter(!is.na(.data$month)) %>%
    dplyr::distinct(.data$month, .data$raw_month) %>%
    dplyr::summarise(variants = paste(sort(unique(.data$raw_month)), collapse = ", "), n = dplyr::n(), .by = "month") %>%
    dplyr::filter(.data$n > 1) %>%
    dplyr::select("month", "variants")
}

#' Flag service births that equal population births, before merging
#'
#' Runs [check_population_service_collision()] on the unmerged sheets. It finds district-years
#' where the monthly institutional live births in the service sheets equal the annual live
#' births in the Population sheet in every month, which suggests that population figures were
#' entered in a service data sheet.
#'
#' @details
#' The service sheets are stacked and the Population sheet's `live_births` is added to each
#' service row by `district` and `year`. Every service row is kept. A district-year is flagged
#' when it has at least three months with both values present and the two values are equal in
#' all of them.
#'
#' @param parts A named list of cleaned per-sheet tibbles (`load_excel_parts()$parts`).
#' @param population_sheet_name A string. The name of the Population sheet within `parts`.
#' @param service_sheet_names A character vector. The names of the service data sheets within
#'   `parts`.
#' @return A tibble with columns `district` and `year`, one row per flagged district-year. It
#'   has no rows if nothing is flagged, if the Population sheet lacks `district`, `year` or
#'   `live_births`, or if the service sheets lack `instlivebirths`.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' check_population_service_collision_presheet(
#'   sheets$parts, sheets$population_sheet_name, sheets$service_sheet_names
#' )
#'
#' # Baringo's 2023 population births entered in every month of the service sheet
#' parts <- sheets$parts
#' population <- parts[[sheets$population_sheet_name]]
#' births <- population$live_births[population$district == "Baringo" & population$year == 2023]
#' service <- parts[[sheets$service_sheet_names[1]]]
#' service$instlivebirths[service$district == "Baringo" & service$year == 2023] <- births
#' parts[[sheets$service_sheet_names[1]]] <- service
#' check_population_service_collision_presheet(
#'   parts, sheets$population_sheet_name, sheets$service_sheet_names
#' )
#' @export
check_population_service_collision_presheet <- function(parts, population_sheet_name, service_sheet_names) {
  population_data <- parts[[population_sheet_name]]
  service_data <- .bind_service_sheets(parts, service_sheet_names)
  if (!all(c("district", "year") %in% colnames(population_data)) ||
      !"live_births" %in% colnames(population_data) ||
      !"instlivebirths" %in% colnames(service_data)) {
    return(dplyr::tibble(district = character(0), year = integer(0)))
  }
  joined <- service_data %>%
    dplyr::left_join(
      dplyr::select(population_data, "district", "year", "live_births"),
      by = c("district", "year")
    )
  check_population_service_collision(joined)
}

#' Check that population live births are not below reported births
#'
#' Compares, for each district-year, the estimated live births in the Population sheet with
#' the institutional births reported in the service sheets. Not every birth happens in a
#' facility, so an estimate that is lower than what facilities reported points to a problem in
#' one of the two figures.
#'
#' @details
#' The reported figure is the sum over the months of a district-year of `instlivebirths`, or
#' of `instdeliveries` if the service sheets have no `instlivebirths` column. A district-year
#' is flagged when `live_births` is less than `(1 - margin)` times that sum. Only district-years
#' that have both figures are compared.
#'
#' @param parts A named list of cleaned per-sheet tibbles (`load_excel_parts()$parts`).
#' @param population_sheet_name A string. The name of the Population sheet within `parts`.
#' @param service_sheet_names A character vector. The names of the service data sheets within
#'   `parts`.
#' @param margin A number between 0 and 1. The fraction by which the population figure may
#'   fall short of the reported figure before it is flagged. Default is `0.10` (10%).
#' @return `NULL` if no district-year is flagged, if the Population sheet lacks `district`,
#'   `year` or `live_births`, or if the service sheets have neither births column. Otherwise a
#'   character vector of length one, named `"x"`, with a message that lists the first 10 flagged
#'   district-years and gives a count of the rest. Its `"rows"` attribute is a tibble of all the
#'   flagged district-years, with columns `district`, `year`, `live_births` and
#'   `total_delivered` (the reported sum).
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' found <- check_population_vs_births(
#'   sheets$parts, sheets$population_sheet_name, sheets$service_sheet_names
#' )
#' found
#' attr(found, "rows")
#'
#' # Flag any shortfall, however small
#' check_population_vs_births(
#'   sheets$parts, sheets$population_sheet_name, sheets$service_sheet_names,
#'   margin = 0
#' )
#' @export
check_population_vs_births <- function(parts, population_sheet_name, service_sheet_names, margin = 0.10) {
  population_data <- parts[[population_sheet_name]]
  if (!all(c("district", "year", "live_births") %in% colnames(population_data))) {
    return(NULL)
  }
  service_data <- .bind_service_sheets(parts, service_sheet_names)
  delivery_col <- intersect(c("instlivebirths", "instdeliveries"), colnames(service_data))
  if (length(delivery_col) == 0) {
    return(NULL)
  }
  delivery_col <- delivery_col[1]

  service_totals <- service_data %>%
    dplyr::filter(!is.na(.data[[delivery_col]])) %>%
    dplyr::summarise(total_delivered = sum(.data[[delivery_col]], na.rm = TRUE), .by = c("district", "year"))

  flagged <- population_data %>%
    dplyr::filter(!is.na(.data$live_births)) %>%
    dplyr::select("district", "year", "live_births") %>%
    dplyr::inner_join(service_totals, by = c("district", "year")) %>%
    dplyr::filter(.data$live_births < (1 - margin) * .data$total_delivered)

  if (nrow(flagged) == 0) {
    return(NULL)
  }
  detail <- flagged %>%
    dplyr::mutate(label = paste0(.data$district, " ", .data$year, " (population: ", round(.data$live_births), ", reported: ", round(.data$total_delivered), ")")) %>%
    dplyr::pull(.data$label)
  shown <- utils::head(detail, 10)
  more <- if (length(detail) > length(shown)) paste0(" (+", length(detail) - length(shown), " more)") else ""
  margin_pct <- margin * 100
  problems <- c("x" = cd_fmt("District-year(s) where estimated population live births is lower than reported institutional counts, beyond a {margin_pct}% margin: {.field {paste(shown, collapse = '; ')}}{more}."))
  # the sentence names ten; every one of them, for quality_issues_table()
  attr(problems, "rows") <- dplyr::select(flagged, "district", "year", "live_births", "total_delivered")
  problems
}

# --- Every issue as a table, and as a workbook -------------------------------------------------

# A check's name in the workbook, where the wizard gives no translation of its own
.quality_check_names <- c(
  admin_columns = "Admin sheet columns",
  required_columns = "Required columns",
  single_country = "One country",
  country_recognized = "Country recognized",
  district_cross_sheet = "Districts across sheets",
  district_consistency = "District consistency",
  month_presence = "Months present",
  month_validity = "Month names",
  population_vs_births = "Population live births against reported births",
  population_service_collision = "Service data mixed up with population data",
  indicator_emptiness = "Empty indicators",
  month_language_consistency = "Month names in more than one language",
  survey_admin_names = "Survey admin names",
  shapefile_admin_names = "Shapefile admin names"
)

#' One line per thing a check found
#' @noRd
.quality_issue_items <- function(detail) {
  rows <- attr(detail, "rows", exact = TRUE)
  if (is.data.frame(rows)) {
    detail <- rows
  }
  if (is.null(detail)) {
    return(character(0))
  }
  if (is.data.frame(detail)) {
    if (nrow(detail) == 0) {
      return(character(0))
    }
    columns <- lapply(names(detail), function(name) paste0(name, ": ", format(detail[[name]], trim = TRUE)))
    return(do.call(paste, c(columns, sep = "; ")))
  }
  cli::ansi_strip(as.character(unname(detail)))
}

#' Tabulate data quality results
#'
#' Turns the results of [run_all_quality_checks()] into two tables: a summary with one row per
#' check, and a list with one row per issue found.
#'
#' @param results A named list. What [run_all_quality_checks()] returns.
#' @param labels An optional named character vector that maps a check's key (`names(results)`)
#'   to the name to show for it, for example a translated name. A check without a label gets a
#'   plain English name.
#' @return A list of two tibbles. `summary` has columns `check`, `severity`, `status`
#'   (`"passed"` or `"issue"`) and `issues` (the number of issues). `issues` has columns `check`,
#'   `severity` and `issue`, with one row for each thing a check found (each district-year,
#'   each name, each message) and nothing shortened.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' cache <- load_cache_data(path)
#' results <- run_all_quality_checks(cache)
#' tables <- quality_issues_table(results)
#' tables$summary
#' tables$issues
#'
#' # A check under a name of your own
#' quality_issues_table(results, labels = c(indicator_emptiness = "Indicators without data"))$summary
#' @export
quality_issues_table <- function(results, labels = NULL) {
  label_of <- function(key) {
    label <- if (key %in% names(labels)) labels[[key]] else .quality_check_names[key]
    if (is.null(label) || is.na(label)) key else unname(label)
  }
  keys <- names(results)
  items <- lapply(results, function(r) if (isTRUE(r$ok)) character(0) else .quality_issue_items(r$detail))
  failed <- !vapply(results, function(r) isTRUE(r$ok), logical(1))
  severity <- vapply(results, function(r) as.character(r$severity %||% NA_character_), character(1))
  check <- vapply(keys, label_of, character(1))

  list(
    summary = dplyr::tibble(
      check = unname(check),
      severity = unname(severity),
      status = ifelse(unname(failed), "issue", "passed"),
      issues = unname(lengths(items))
    ),
    issues = dplyr::tibble(
      check = rep(unname(check), lengths(items)),
      severity = rep(unname(severity), lengths(items)),
      issue = unlist(items, use.names = FALSE) %||% character(0)
    )
  )
}

#' Write every data quality result to an Excel workbook
#'
#' Two sheets: `Summary` (each check, whether it passed, how many issues) and `Issues` (one row per issue).
#'
#' @inheritParams quality_issues_table
#' @param path Where to write the `.xlsx`.
#' @return `path`, invisibly.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' cache <- load_cache_data(path)
#' results <- run_all_quality_checks(cache)
#' file <- write_quality_issues(results, tempfile(fileext = ".xlsx"))
#' openxlsx::read.xlsx(file, sheet = "Issues")
#' @export
write_quality_issues <- function(results, path, labels = NULL) {
  tables <- quality_issues_table(results, labels)
  wb <- openxlsx::createWorkbook()
  header <- openxlsx::createStyle(textDecoration = "bold")
  for (sheet in c("Summary", "Issues")) {
    table <- tables[[tolower(sheet)]]
    openxlsx::addWorksheet(wb, sheet)
    openxlsx::writeData(wb, sheet, table, headerStyle = header)
    openxlsx::freezePane(wb, sheet, firstRow = TRUE)
    openxlsx::setColWidths(wb, sheet, cols = seq_along(table), widths = if (sheet == "Issues") c(44, 14, 110) else c(44, 14, 10, 8))
  }
  openxlsx::saveWorkbook(wb, path, overwrite = TRUE)
  invisible(path)
}

# --- Non-aborting aggregator: run everything against an already-loaded cache -----------------

#' Run all data quality checks and report every result
#'
#' Runs the data quality checks on the data held in a cache and returns the result of each
#' one, whether it passed or not. It does not stop on a problem, so a caller can show the
#' whole report.
#'
#' @details
#' Which checks run depends on what the cache holds:
#' - If it holds unmerged sheets (`cache$wizard_parts`), the checks run on the separate sheets,
#'   so a problem can be traced to the sheet it comes from.
#' - Otherwise, if it holds results saved when the sheets were merged
#'   (`cache$wizard_quality_results`), those saved results are returned and no check is run.
#' - Otherwise the checks run on the merged dataset (`cache$countdown_data`). This set has
#'   fewer checks than the one for unmerged sheets.
#'
#' @param cache A `CacheConnection`, or an object with the same `wizard_parts`,
#'   `wizard_quality_results` and `countdown_data` fields and `check_survey_admin_names()` and
#'   `check_shapefile_admin_names()` methods.
#' @return A named list with one element per check. Each element is a list with:
#'   - `ok`: `TRUE` if the check passed.
#'   - `severity`: `"blocking"` (the caller should not go on until the problem is fixed),
#'     `"informational"` (shown, but does not block) or `"mapping"` (an admin level 1 name with
#'     no match in the survey or the shapefile; shown, but does not block).
#'   - `detail`: what the check returned, which is `NULL`, a character vector or a tibble,
#'     depending on the check.
#' @seealso [quality_issues_table()] and [write_quality_issues()] to tabulate or save the result.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#'
#' # On a loaded dataset
#' cache <- load_cache_data(path)
#' results <- run_all_quality_checks(cache)
#' names(results)
#' results$indicator_emptiness
#'
#' # On the sheets of a workbook, before they are merged
#' sheets <- load_excel_parts(path)
#' results <- run_all_quality_checks(init_CacheConnection(wizard_parts = sheets))
#' Filter(function(result) !result$ok, results)
#' @export
run_all_quality_checks <- function(cache) {
  if (!is.null(cache$wizard_parts)) {
    .run_pre_merge_quality_checks(cache)
  } else if (!is.null(cache$wizard_quality_results)) {
    # A frozen snapshot of the pre-merge checks, taken once at Finish (CacheConnection's own
    # set_wizard_quality_results(), called right before clear_wizard_parts() wipes wizard_parts
    # itself) -- not a fresh .run_post_merge_quality_checks() call. Confirmed live: without this,
    # revisiting Data Quality after Finish (a landing-page Edit link, or edit mode generally) fell
    # through to the post-merge branch below and silently ran a DIFFERENT set of checks against the
    # merged/standardized countdown_data instead of the original unmerged sheets -- reporting
    # different numbers than what the user actually saw during the walkthrough ("data quality is not
    # giving the actual values given during the uploading"). wizard_parts itself can't just be kept
    # around instead of clearing it -- see clear_wizard_parts()'s own comment for why that would grow
    # stale the moment anything downstream changes countdown_data; this snapshot, frozen at the one
    # moment it was genuinely accurate, doesn't have that problem.
    cache$wizard_quality_results
  } else {
    .run_post_merge_quality_checks(cache)
  }
}

#' @noRd
.run_pre_merge_quality_checks <- function(cache) {
  wp <- cache$wizard_parts
  parts <- wp$parts
  admin_sheet_name <- wp$admin_sheet_name
  population_sheet_name <- wp$population_sheet_name
  service_sheet_names <- wp$service_sheet_names

  admin_columns <- check_admin_columns(parts[[admin_sheet_name]])
  required_columns <- check_required_columns_presheet(parts)
  single_country <- check_single_country(parts[[admin_sheet_name]])
  country_recognized <- check_country_recognized(parts, admin_sheet_name)
  district_cross_sheet <- check_district_cross_sheet(parts, admin_sheet_name)
  admin_pairing <- check_admin_pairing_consistency(parts[[admin_sheet_name]])
  district_year <- check_district_year_completeness(parts[[population_sheet_name]])
  months_present <- check_month_presence_presheet(parts, service_sheet_names)
  months_valid <- check_month_validity_presheet(parts, service_sheet_names)
  population_vs_births <- check_population_vs_births(parts, population_sheet_name, service_sheet_names)
  collision <- check_population_service_collision_presheet(parts, population_sheet_name, service_sheet_names)
  empty <- check_indicator_emptiness_presheet(parts, service_sheet_names)
  month_language <- check_month_language_consistency(parts, service_sheet_names)
  survey_names <- cache$check_survey_admin_names()
  shapefile_names <- cache$check_shapefile_admin_names()

  list(
    admin_columns = list(ok = is.null(admin_columns), severity = "blocking", detail = admin_columns),
    required_columns = list(ok = is.null(required_columns), severity = "blocking", detail = required_columns),
    single_country = list(ok = is.null(single_country), severity = "blocking", detail = single_country),
    country_recognized = list(ok = is.null(country_recognized), severity = "blocking", detail = country_recognized),
    district_cross_sheet = list(ok = is.null(district_cross_sheet), severity = "blocking", detail = district_cross_sheet),
    district_consistency = list(ok = is.null(admin_pairing) && is.null(district_year), severity = "blocking", detail = c(admin_pairing, district_year)),
    month_presence = list(ok = is.null(months_present), severity = "blocking", detail = months_present),
    month_validity = list(ok = is.null(months_valid), severity = "blocking", detail = months_valid),
    # informational, not blocking -- a live population-vs-reported-births gap can be a genuine data problem,
    # but it can just as easily be legitimate (in/out-migration, catchment areas that cross district lines,
    # a population estimate that's simply stale for a fast-growing area) -- the user's own call to make, not
    # something that should stop them finishing the wizard the way a structural problem (missing columns,
    # unrecognized districts) does. See data_quality.R's own dq_data_row() placement, which moved to match.
    population_vs_births = list(ok = is.null(population_vs_births), severity = "informational", detail = population_vs_births),
    population_service_collision = list(ok = nrow(collision) == 0, severity = "informational", detail = collision),
    indicator_emptiness = list(ok = length(empty) == 0, severity = "informational", detail = empty),
    month_language_consistency = list(ok = nrow(month_language) == 0, severity = "informational", detail = month_language),
    survey_admin_names = list(ok = nrow(survey_names) == 0, severity = "mapping", detail = survey_names),
    shapefile_admin_names = list(ok = nrow(shapefile_names) == 0, severity = "mapping", detail = shapefile_names)
  )
}

#' @noRd
.run_post_merge_quality_checks <- function(cache) {
  .data <- cache$countdown_data

  district <- check_district_consistency(.data)
  months_present <- check_month_presence(.data)
  months_valid <- check_month_validity(.data)
  collision <- check_population_service_collision(.data)
  empty <- check_indicator_emptiness(.data)
  survey_names <- cache$check_survey_admin_names()
  shapefile_names <- cache$check_shapefile_admin_names()

  list(
    district_consistency = list(ok = is.null(district), severity = "blocking", detail = district),
    month_presence = list(ok = is.null(months_present), severity = "blocking", detail = months_present),
    month_validity = list(ok = is.null(months_valid), severity = "blocking", detail = months_valid),
    population_service_collision = list(ok = nrow(collision) == 0, severity = "informational", detail = collision),
    indicator_emptiness = list(ok = length(empty) == 0, severity = "informational", detail = empty),
    survey_admin_names = list(ok = nrow(survey_names) == 0, severity = "mapping", detail = survey_names),
    shapefile_admin_names = list(ok = nrow(shapefile_names) == 0, severity = "mapping", detail = shapefile_names)
  )
}
