# Phase 2 data-quality checks for the Load Data wizard (countdown-analytics/apps/rmncah).
#
# Every check_*() function below returns NULL on pass, or a named character vector of
# cli-bullet-formatted problem lines ("x"/"!"/...) on failure -- it never calls cd_abort()
# itself. This keeps each check a small, pure, independently-testable function (same spirit as
# check_required_columns_exist()/check_file_path() in utils.R, just not abort-on-call), and lets
# run_quality_checks() below collect several of them together into ONE combined abort instead of
# stopping at the first problem found -- see 0_import_load_data.R's own Tier A/Tier B call sites
# for where each one is actually wired in.

#' Format a cli-markup problem line into a plain string, right now, in the caller's own scope
#'
#' Each `check_*()` function below builds its own message from LOCAL variables (the offending
#' district names, the bad month strings, etc.) and must interpolate them immediately: if it
#' returned the raw `"{.field {x}}"` template text instead, `run_quality_checks()`'s later
#' `cd_abort()` call would try to glue-interpolate it in `cd_abort()`'s OWN calling
#' environment, where `x` no longer exists (the check function that defined it has already
#' returned) -- confirmed live, this is exactly the failure mode a first pass of this file hit.
#' @noRd
cd_fmt <- function(text, .envir = parent.frame()) {
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
#'   character vector of already-formatted problems (fail) -- see `cd_fmt()`.
#' @param call The calling environment, forwarded to `cd_abort()`.
#' @noRd
run_quality_checks <- function(checks, call = caller_env()) {
  problems <- unlist(purrr::compact(purrr::map(checks, ~ .x())), use.names = TRUE)
  if (length(problems) > 0) {
    cd_abort(problems, call = call)
  }
  invisible(NULL)
}

# --- Tier A: raw Admin_data sheet, before merge/standardize --------------------------------

#' Check the Admin_data sheet has the columns every later step assumes exist
#'
#' `first_admin_level`/`country` are only ever consumed via `any_of()` downstream (see
#' `read_and_clean_sheet()`'s own `required_columns`, used only for `drop_na()`, and
#' `standardize_data()`'s `rename(adminlevel_1 = any_of("first_admin_level"))`), so a sheet
#' missing either column silently proceeds today with `adminlevel_1`/`country` never created,
#' surfacing later as a confusing, unrelated error far from the actual cause. `district` isn't
#' checked here -- it's already covered by `read_and_clean_sheet()`'s own key-column check.
#'
#' @param admin_data The raw, cleaned Admin_data sheet (one `read_and_clean_sheet()` call's
#'   output, before `merge_data()`).
#' @export
check_admin_columns <- function(admin_data) {
  missing <- setdiff(c("country", "first_admin_level"), colnames(admin_data))
  if (length(missing) == 0) {
    return(NULL)
  }
  c("x" = cd_fmt("The Admin_data sheet is missing column(s): {.field {paste(missing, collapse = ', ')}}."))
}

#' Check the Admin_data sheet names exactly one country
#'
#' `new_countdown()` later does `distinct(country) %>% pull(country)` and passes the result
#' straight to `match_country()`, which itself only handles a length-1 input gracefully (a longer
#' vector aborts with a generic "contains multiple names" message, no detail on what the mixed
#' values actually are). Catching it here, on the raw sheet, gives a specific, actionable message
#' before any of the rest of the pipeline runs.
#'
#' @param admin_data The raw, cleaned Admin_data sheet.
#' @export
check_single_country <- function(admin_data) {
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

#' Check a district's admin-1 pairing and spelling are stable across years
#'
#' Flags a district that maps to more than one `adminlevel_1` value (case/whitespace-insensitive
#' first, so a genuine typo isn't hidden by two spellings happening to normalize the same way),
#' and separately flags a district that isn't present in every year the dataset otherwise covers
#' (service-data districts are expected to be stable across years; a district appearing in some
#' years but not others is much more often a rename/typo than a legitimate gap).
#'
#' @param .data The merged, standardized dataset (`countdown_data`-shaped: `district`,
#'   `adminlevel_1`, `year` columns).
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

#' Check every district-year has all 12 calendar months present
#'
#' @param .data The merged, standardized dataset (`district`, `year`, `month` columns).
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

#' Check every row's month string parsed to a real calendar month
#'
#' `standardize_data()` turns any month string that doesn't match one of its 12 recognized
#' patterns into `NA` silently (no warning, the row stays in the data) -- this surfaces that
#' silently-dropped information instead of letting it pass unnoticed. Relies on `raw_month`
#' (the pre-cleaning value `standardize_data()` now preserves specifically for this check); if
#' `.data` doesn't have that column (e.g. a `.dta` master dataset, which skips
#' `standardize_data()` entirely), this falls back to just checking for `NA` months with no
#' detail on the original unparseable text.
#'
#' @param .data The merged, standardized dataset.
#' @export
check_month_validity <- function(.data) {
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

#' Flag district-years where a service indicator looks like it was mixed up with population data
#'
#' `instlivebirths` (institutional live births, a monthly service indicator) is expected to vary
#' month to month; `live_births` (the Population_data sheet's own live-births figure) is joined
#' in by `district`+`year` only, so it's constant across all 12 months of a given district-year.
#' A district-year where `instlivebirths` is identical to `live_births` in every month is the
#' signature of the two having been pasted into the wrong sheet.
#'
#' @param .data The dataset (`countdown_data`-shaped).
#' @return A tibble of flagged `district`/`year` rows, or a zero-row tibble if none found.
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

#' Flag indicators that are entirely empty across the whole dataset
#'
#' Same detector `standardize_data()` already uses for its own "empty columns" log line
#' (`colSums(is.na(data)) == nrow(data)`, `0_import_load_data.R`), scoped to just the indicator
#' columns for the currently-selected indicator group (`get_indicator_groups()`) rather than
#' every column -- an admin/year/month/population column being "empty" isn't a data-quality
#' signal the same way an indicator column being empty is.
#'
#' @param .data The dataset (`countdown_data`-shaped).
#' @return A character vector of indicator names that are 100% empty.
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

  # replace_special_chars() (0_import_load_data.R) strips accents (é/è/ê/à/ñ/etc.) the same way it
  # already does for month names -- without it, a genuinely identical region name that only
  # differs by accent/case (confirmed live: a real dataset's "Oueme" vs its survey's "OUÉMÉ",
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

#' Flag dataset admin-1 names that have no matching survey region
#'
#' Checked in this direction (not the other way around) because it's the dataset's own regions
#' that need coverage: a region present in `countdown_data` but missing from the survey can't get
#' a regional/equity estimate at all. A survey region with no dataset match is just unused data,
#' not something that blocks anything.
#'
#' @param regional_survey The `regional_survey` data (has its own `adminlevel_1` column).
#' @param countdown_data The dataset (`countdown_data`-shaped).
#' @return A tibble of dataset admin-1 names with no survey match, each with its closest
#'   suggestion (see `match_admin_names()`).
#' @export
check_survey_admin_names <- function(regional_survey, countdown_data) {
  if (is.null(regional_survey) || !"adminlevel_1" %in% colnames(regional_survey)) {
    return(dplyr::tibble(name = character(0), suggestion = character(0), distance = double(0)))
  }
  match_admin_names(countdown_data$adminlevel_1, regional_survey$adminlevel_1)
}

#' Flag dataset admin-1 names that have no matching shapefile region
#'
#' Same direction as `check_survey_admin_names()` and for the same reason: a dataset region with
#' no shapefile match can't be shown on a map at all, which is the actual problem worth flagging --
#' not a shapefile region with no dataset match, which is just an unused polygon.
#'
#' @param shapefile The country's shapefile (`sf` object -- either the package-bundled one, with its
#'   own `NAME_1` column, see `get_country_shapefile()`, or a user-uploaded one via
#'   `read_shapefile_folder()`, whose admin-1 name column is whatever `name_field` says).
#' @param countdown_data The dataset (`countdown_data`-shaped).
#' @param name_field Name of the column in `shapefile` holding admin-1 names. Default `"NAME_1"`,
#'   matching the bundled shapefile -- a real uploaded one won't necessarily use that name, hence the
#'   parameter (`CacheConnection$shapefile_name_field`, set when the user picks it at upload).
#' @return A tibble of dataset admin-1 names with no shapefile match, each with its closest
#'   suggestion (see `match_admin_names()`).
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

#' Check districts match between the Admin sheet and every other sheet, both directions
#'
#' The direct fix for the root problem this redesign exists for: `merge_data()` left-joins
#' everything onto the Admin sheet, so a district that exists in Population_data/Service_data but
#' not in Admin_data was silently dropped before any check ever ran against the merged result. This
#' runs on unmerged `parts`, so nothing has been dropped yet.
#'
#' @param parts Named list of cleaned per-sheet tibbles (`load_excel_parts()$parts`).
#' @param admin_sheet_name Name of the admin sheet within `parts`.
#' @export
check_district_cross_sheet <- function(parts, admin_sheet_name) {
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

#' Check a district's admin-1 pairing is stable within the Admin sheet itself
#'
#' Pre-merge half of the old (still-existing, still used post-merge by `new_countdown()`'s Tier B)
#' `check_district_consistency()` -- this half only ever needed the Admin sheet: a district's
#' `adminlevel_1` pairing can only vary across the merged data if the Admin sheet itself lists that
#' district more than once with different values, so checking the raw sheet directly loses no
#' signal.
#'
#' @param admin_data The raw Admin sheet (`parts[[admin_sheet_name]]`, pre-rename -- still has
#'   `first_admin_level`, not `adminlevel_1`).
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

#' Check every district appears in every year present in the Population sheet
#'
#' Pre-merge half of the old `check_district_consistency()` -- district+year is the Population
#' sheet's own natural grain, no merge needed.
#'
#' @param population_data The raw Population sheet (`parts[[population_sheet_name]]`).
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

#' Check the Admin sheet's single country value is actually a recognized country name, pre-merge
#'
#' `check_single_country()` (Tier A, above) only catches more than one distinct value -- the
#' genuinely-one-value-but-unrecognized case is `match_country()`'s job, which normally only runs
#' at Finish (`merge_and_standardize()`'s `new_countdown()` call) under the deferred-merge design.
#' Left uncaught pre-merge, a user could walk the entire wizard only to hit a hard abort on the very
#' last step -- this surfaces the same problem at Data Quality instead, non-abortingly, same as
#' every other check here.
#'
#' A deliberately NOT-yet-replicated counterpart: "every indicator the selected group needs is
#' present" (`check_required_columns_exist()`, `utils.R`) still only runs at Finish. Its check is
#' against columns `standardize_data()` computes/renames during the merge itself (reporting-rate
#' `_rr` columns, `instdeliveries` -> `ideliv`) -- checking for those names against the RAW,
#' pre-standardize sheets produces false positives (confirmed live: a real, known-good file flagged
#' as "missing" columns it actually has, just not yet under their final names) that would incorrectly
#' block a user with no real problem. A correct pre-merge version would need to replicate
#' `standardize_data()`'s own rename/compute logic just to know what to look for -- a real gap
#' (Finish can still abort on this), left for follow-up work rather than shipped half-right.
#'
#' @param parts Named list of cleaned per-sheet tibbles.
#' @param admin_sheet_name Name of the admin sheet within `parts`.
#' @export
check_country_recognized <- function(parts, admin_sheet_name) {
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

#' Bind every service sheet together -- the union `check_month_presence()`/`check_indicator_emptiness()`
#' need, without joining to anything else. A row-bind across same-shaped service sheets carries none
#' of `merge_data()`'s row-dropping risk (it's a concat, not a join).
#' @noRd
.bind_service_sheets <- function(parts, service_sheet_names) {
  dplyr::bind_rows(parts[intersect(service_sheet_names, names(parts))])
}

#' Check every district-year has all 12 calendar months present, pre-merge
#'
#' Service sheets already carry `district`/`year`/`month` natively -- reuses `check_month_presence()`
#' unchanged, just called against the row-bound service sheets instead of merged `countdown_data`.
#'
#' @param parts Named list of cleaned per-sheet tibbles.
#' @param service_sheet_names Names of the service-data sheets within `parts`.
#' @export
check_month_presence_presheet <- function(parts, service_sheet_names) {
  check_month_presence(.bind_service_sheets(parts, service_sheet_names))
}

#' Check every row's month string parses to a real calendar month, pre-merge
#'
#' `month` here is already normalized (`load_excel_parts()` does this on every sheet, before
#' `merge_data()` ever runs -- see its own comment for why) -- `NA` means it genuinely didn't parse,
#' no need to re-run `parse_month_name()` here. `raw_month` (preserved by that same normalization
#' step) is what this reports, so a typo or different-language value shows up as the actual original
#' text, not just `NA`.
#'
#' @inheritParams check_month_presence_presheet
#' @export
check_month_validity_presheet <- function(parts, service_sheet_names) {
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

#' Flag indicators entirely empty across every service sheet, pre-merge
#'
#' Reuses `check_indicator_emptiness()` unchanged against the row-bound service sheets.
#' @inheritParams check_month_presence_presheet
#' @export
check_indicator_emptiness_presheet <- function(parts, service_sheet_names) {
  check_indicator_emptiness(.bind_service_sheets(parts, service_sheet_names))
}

#' Flag calendar months that different rows/sheets label with different raw text
#'
#' `load_excel_parts()` already normalizes every sheet's `month` column independently, before
#' `merge_data()` ever runs -- so the merge itself no longer silently drops data over a raw-text
#' join-key mismatch (a real, confirmed bug this fixes: one sheet labeling a year in French while
#' its sibling sheets labeled the same year in English left every one of those sibling sheets'
#' columns `NA` for that whole period). That fix is silent by design -- it makes the DATA correct,
#' it doesn't tell the user anything was off. This check surfaces the underlying anomaly itself: more
#' than one distinct `raw_month` string mapping to the same canonical calendar month is a real signal
#' about how the file was put together (e.g. a historical import already translated to English,
#' stitched together with a current year still in its original language) -- informational, not
#' blocking, since the data is already handled correctly either way, but worth knowing.
#'
#' @param parts Named list of cleaned per-sheet tibbles.
#' @param service_sheet_names Names of the service-data sheets within `parts`.
#' @return A tibble, one row per canonical month with more than one distinct raw text seen for it:
#'   `month`, `variants` (the distinct `raw_month` strings observed, comma-separated).
#' @export
check_month_language_consistency <- function(parts, service_sheet_names) {
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

#' Flag district-years where a service indicator looks mixed up with population data, pre-merge
#'
#' `check_population_service_collision()` needs `instlivebirths` (service) and `live_births`
#' (population) on the same rows -- pre-merge these live on different sheets, so this does a narrow,
#' purpose-built `district`+`year` left join (service data is the left side -- every service row is
#' kept regardless of whether a matching population row exists, unlike `merge_data()`'s
#' admin-anchored join, so nothing is silently dropped here either) just to bring the two columns
#' together for this one comparison, then delegates to the existing check.
#'
#' @param parts Named list of cleaned per-sheet tibbles.
#' @param population_sheet_name Name of the population sheet within `parts`.
#' @param service_sheet_names Names of the service-data sheets within `parts`.
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

#' Check that estimated population live births aren't lower than reported institutional counts
#'
#' Per district-year, `Population_data$live_births` (an annual estimate) should be at least as large
#' as the sum of the service sheets' own institutional counts (`instlivebirths`, or `instdeliveries`
#' if that's what the sheet has instead -- the spec names both interchangeably) across that
#' district-year's months -- not every birth happens in a facility, so the population estimate being
#' *lower* than what facilities alone reported is a real, actionable data problem, not just an
#' interesting pattern. `margin` allows the population figure to fall a little short before flagging,
#' since these are independent estimates, not the same count twice.
#'
#' @param parts Named list of cleaned per-sheet tibbles.
#' @param population_sheet_name Name of the population sheet within `parts`.
#' @param service_sheet_names Names of the service-data sheets within `parts`.
#' @param margin Fraction (0-1) of headroom allowed before flagging. Default `0.10` (10%).
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
  c("x" = cd_fmt("District-year(s) where estimated population live births is lower than reported institutional counts, beyond a {margin_pct}% margin: {.field {paste(shown, collapse = '; ')}}{more}."))
}

# --- Non-aborting aggregator: run everything against an already-loaded cache -----------------

#' Run every non-structural quality check against an already-loaded cache, without aborting
#'
#' Counterpart to `run_quality_checks()` above (which collects several checks and aborts once if
#' any fail -- the shape `new_countdown()`'s Tier B and `merge_and_standardize()`'s Tier A both need
#' at load time). This one never aborts: it runs every non-structural check and returns a full
#' report, for a caller that wants to show every result -- pass or fail -- rather than stop at the
#' first problem. Built for the Load Data wizard's Data Quality step (apps/rmncah).
#'
#' Branches on whether `cache` still holds unmerged wizard parts (`cache$wizard_parts`, set by
#' `load_excel_parts()` + `CacheConnection$set_wizard_parts()` -- the normal case for a fresh
#' Excel/Stata upload going through the wizard, Phase 3 of the Load Data wizard redesign) or already
#' has merged `countdown_data` (a resumed `.rds`, edit mode, or any non-wizard caller) -- the
#' pre-merge branch runs the sheet-scoped checks above, attributing problems to the specific sheet
#' they came from; the post-merge branch is the original, unchanged set of checks against the fully
#' merged data.
#'
#' @param cache A `CacheConnection` (or anything exposing `$wizard_parts`, `$countdown_data`,
#'   `$check_survey_admin_names()`, `$check_shapefile_admin_names()` the same way).
#' @return A named list, one entry per check: `list(ok, severity, detail)`. `severity` is one of
#'   `"blocking"` (these gate progression past the Data Quality step), `"informational"` (shown,
#'   never block), or `"mapping"` (survey/shapefile admin-name matches -- shown, never block, point
#'   instead at the relevant mapping step).
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
