#' Load Countdown 2030 data (Excel or Stata)
#'
#' Loads a cleaned dataset from an Excel (.xlsx/.xls) or Stata (.dta) file,
#' optionally **registers** a profile override, and returns a tibble of class
#' `cd_data`. Group selection is resolved from the data inside [new_countdown()]:
#' - `"auto"` detects the best-matching group (built-ins + any overrides)
#' - `"vaccine"` or `"rmncah"` select built-ins (overrides still apply)
#' - `"custom"` uses `profile` (must exist after any inline registration)
#'
#' @param path Path to `.xlsx`, `.xls`, or `.dta`.
#' @param indicator_group One of `"auto"`, `"vaccine"`, `"rmncah"`, `"custom"`.
#'   Default `"auto"`.
#' @param profile Optional. Either a **name** (string) of an existing group, or a
#'   **definition** to register inline before loading:
#'
#'   - explicit form: `list(name = "rmncah", value = list(hiv = c("hiv_test","pmtct1")))`
#'   - compact form:  `list(hiv_profile = list(testing = c("hiv_test"), care = c("art_new")))`
#'
#'   For `"custom"`, the profile must resolve to **one** concrete name.
#'
#' @param on_conflict Conflict policy when `profile` is a definition:
#'   one of `"replace"`, `"merge"`, or `"error"`. Default `"replace"`.
#'   `"merge"` unions indicators per category.
#' @param start_year Optional integer filter for minimum year.
#' @param admin_sheet_name Excel sheet with admin data. Default `"Admin_data"`.
#' @param population_sheet_name Excel sheet with population data. Default `"Population_data"`.
#' @param reporting_sheet_name Excel sheet with reporting completeness. Default `"Reporting_completeness"`.
#' @param service_sheet_names Character vector of service-data sheets.
#'   Default: all sheets matching `"Service_data"` if not supplied.
#'
#' @return A tibble of class `cd_data`.
#'
#' @details
#' The actual **group resolution** occurs in [new_countdown()], using indicators
#' **from the loaded data**. If `profile` is a definition, it is registered via
#' [register_indicator_group()] **before** loading, so auto-detection considers it.
#'
#' @examples
#' \dontrun{
#' # Built-in group (explicit)
#' cd <- load_data("data/country.dta", indicator_group = "rmncah")
#' attr(cd, "indicator_group")  # "rmncah"
#'
#' # Auto-detect among built-ins
#' cd <- load_data("data/country.xlsx", indicator_group = "auto")
#'
#' # Inline extend rmncah, then auto-detect (merge by category)
#' cd <- load_data(
#'   "data/country.xlsx",
#'   indicator_group = "auto",
#'   profile = list(name = "rmncah", value = list(hiv = c("hiv_test","pmtct1"))),
#'   on_conflict = "merge"
#' )
#'
#' # Define a brand-new custom profile and select it
#' cd <- load_data(
#'   "data/country.xlsx",
#'   indicator_group = "custom",
#'   profile = list(my_profile = list(anc = c("anc1","anc4")))
#' )
#' }
#'
#' @param validate Logical. Whether to stop with an error when the merged data
#'   fails a data quality check: [check_district_consistency()],
#'   [check_month_presence()] or [check_month_validity()]. Default is `TRUE`.
#'   With `FALSE` a file that has such problems still loads, so the caller can
#'   run the checks later with [run_all_quality_checks()]. Structural checks,
#'   such as a missing Admin sheet column, always run.
#' @export
load_data <- function(path,
                      indicator_group = c('auto', 'vaccine', 'rmncah', 'custom'),
                      profile = NULL,
                      on_conflict = c('replace', 'merge', 'error'),
                      start_year = NULL,
                      admin_sheet_name = NULL,
                      population_sheet_name = NULL,
                      reporting_sheet_name = NULL,
                      service_sheet_names = NULL,
                      validate = TRUE) {
  check_file_path(path)
  indicator_group <- arg_match(indicator_group)
  on_conflict <- arg_match(on_conflict)

  # 1) Optionally register a dingle override before loading
  ps <- .parse_profile(profile)
  if (isTRUE(ps$needs_registration)) {
    register_indicator_group(ps$name, ps$value, on_conflict = on_conflict)
  }

  profile_name <- ps$name %||% if (is_string(profile)) profile else NULL

  # 2) Load raw data
  ext <- str_to_lower(tools::file_ext(path))
  final_data <- if (ext %in% c('xlsx', 'xls')) {
    .load_excel_data(path, indicator_group, profile, profile_name, start_year,
                     admin_sheet_name, population_sheet_name,
                     reporting_sheet_name, service_sheet_names, validate)
  } else if (ext == 'dta') {
    .load_master_dataset(path, indicator_group, profile, profile_name, validate)
  } else {
    cd_abort(c("x" = "Unsupported file for load_data(). Use Excel or Stata"))
  }

  return(final_data)
}


#' Initialize or load a cached Countdown 2030 connection
#'
#' Loads data via [load_data()] for Excel/Stata inputs, or initializes a cache
#' from an `.rds`. Returns a cache/connection object.
#'
#' @inheritParams load_data
#' @param path Path to `.xlsx`, `.xls`, `.dta`, or `.rds`.
#' @param create_cache Logical. For Excel/Stata inputs, whether to pass `path`
#'   to the connection as its data path so a cache file is created or loaded
#'   next to it. Default is `FALSE` (no cache file). Ignored for `.rds` inputs.
#'
#' @return A cache/connection object as returned by `init_CacheConnection()`.
#'
#' @examples
#' \dontrun{
#' # From Excel
#' con <- load_cache_data("data/country.xlsx", indicator_group = "auto")
#'
#' # From Stata
#' con <- load_cache_data("data/country.dta", indicator_group = "rmncah")
#'
#' # From pre-saved RDS
#' con <- load_cache_data("data/cd_data.rds", indicator_group = "rmncah")
#' }
#'
#' @export
load_cache_data <- function(path,
                            indicator_group = c('auto', 'vaccine', 'rmncah', 'custom'),
                            profile = NULL,
                            on_conflict = c('replace', 'merge', 'error'),
                            create_cache = FALSE,
                            start_year = NULL,
                            admin_sheet_name = NULL,
                            population_sheet_name = NULL,
                            reporting_sheet_name = NULL,
                            service_sheet_names = NULL,
                            validate = TRUE) {
  check_file_path(path)
  indicator_group <- arg_match(indicator_group)

  # Determine file extension and load accordingly
  ext <- str_to_lower(tools::file_ext(path))
  final_data <- if (ext %in% c('xlsx', 'xls', 'dta')) {
    on_conflict <- arg_match(on_conflict)
    # Was passing service_sheet_names twice (positionally landing in reporting_sheet_name's own slot) and
    # never actually forwarding reporting_sheet_name at all -- a pre-existing bug, fixed in passing since it's
    # immediately adjacent to the validate param being threaded through here.
    data <- load_data(path, indicator_group, profile, on_conflict, start_year,
                      admin_sheet_name, population_sheet_name, reporting_sheet_name,
                      service_sheet_names, validate)
    # data_path is the original source file -- CacheConnection derives the
    # cache's location from it and decides load-vs-create itself, so the
    # same behavior applies uniformly regardless of caller.
    data_path <- if (create_cache) path else NULL
    indicator_group <- get_selected_group()
    return(init_CacheConnection(countdown_data = data, data_path = data_path))
  } else if (ext == 'rds') {
    return(init_CacheConnection(rds_path = path, indicator_group = indicator_group))
  } else {
    cd_abort(c("x" = "Unsupported file for load_data(). Use Excel, Cahe or Stata"))
  }

  return(final_data)
}

#' Load processed master dataset (Stata .dta)
#'
#' Reads a Stata file, converts labelled columns to factors, then delegates to
#' [new_countdown()] for validation and group resolution.
#'
#' @inheritParams load_data
#' @param profile_name Internal. Normalized name extracted from `profile`.
#'
#' @return A tibble of class `cd_data`.
#' @noRd
.load_master_dataset <- function(
    path,
    indicator_group = c('auto', 'vaccine', 'rmncah', 'custom'),
    profile = NULL,
    profile_name = NULL,
    validate = TRUE
) {
  check_file_path(path)
  indicator_group <- arg_match(indicator_group)

  # Determine file extension and load accordingly
  ext <- tools::file_ext(path)
  if (str_to_lower(ext) != 'dta') {
    cd_abort(c("x" = "Unsupported file format: please provide a DTA file."))
  }

  out <- read_dta(path) %>%
    mutate(across(where(is.labelled), ~ as_factor(.x)))

  # Months as the rest of the package has them (an ordered factor of the English names), as a workbook's are.
  # A Stata file gives them as a labelled value, text or a number; left as that, the check that every month is
  # there could not compare them (a file written by save_data() could not be read back).
  if ("month" %in% names(out)) {
    month <- out$month
    parsed <- if (is.numeric(month)) {
      factor(month.name[ifelse(month %in% 1:12, month, NA)], levels = month.name, ordered = TRUE)
    } else {
      parse_month_name(as.character(month))
    }
    # only when every month was understood: otherwise the values are kept for the checks to report
    if (!any(is.na(parsed) & !is.na(month))) out$month <- parsed
  }

  new_countdown(out, indicator_group = indicator_group, profile = profile, profile_name = profile_name, validate = validate)
}

#' Read and clean the sheets of a Countdown 2030 workbook
#'
#' Reads and cleans each sheet of a Countdown 2030 Excel workbook and returns the sheets
#' separately, without merging them. Use it to run data quality checks on each sheet before
#' the merge, then pass the result to [merge_and_standardize()] to finish loading.
#'
#' @details
#' Month names are standardized to English on every sheet that has a `month` column, and the
#' original text is kept in a `raw_month` column. The sheets can then be joined on `month` even
#' if they name the months in different languages.
#'
#' The function stops with an error if a named sheet is not in the workbook, if a sheet is
#' empty, or if a sheet lacks its key columns (`district` for the Admin sheet, `district` and
#' `year` for the Population sheet, and `district`, `year` and `month` for the others). Other
#' problems with the data are left to the data quality checks.
#'
#' @param path Path to an `.xlsx` or `.xls` file.
#' @inheritParams load_data
#' @return A list with these elements:
#'   - `parts`: a named list of cleaned tibbles, one per sheet, named by sheet.
#'   - `sheet_names`: a character vector of the sheet names, in the order the sheets are merged.
#'   - `sheet_ids`: a named list of the key columns of the Admin sheet, the Population sheet
#'     and (as `service_data`) every other sheet.
#'   - `admin_sheet_name`, `population_sheet_name`, `reporting_sheet_name`,
#'     `service_sheet_names`: the sheet names used, with defaults filled in.
#'   - `path`, `start_year`: the arguments as given.
#' @seealso [merge_and_standardize()], [run_all_quality_checks()]
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' names(sheets$parts)
#' sheets$service_sheet_names
#' sheets$parts[[sheets$population_sheet_name]]
#'
#' # Month names are in English, the workbook's own text is kept beside them
#' unique(sheets$parts[[sheets$service_sheet_names[1]]][c("month", "raw_month")])
#' @export
load_excel_parts <- function(path,
                             start_year = NULL,
                             admin_sheet_name = NULL,
                             population_sheet_name = NULL,
                             reporting_sheet_name = NULL,
                             service_sheet_names = NULL) {
  check_file_path(path)

  admin_sheet_name <-  admin_sheet_name %||% 'Admin_data'
  population_sheet_name <- population_sheet_name %||% 'Population_data'
  reporting_sheet_name <- reporting_sheet_name %||% 'Reporting_completeness'
  ex_sheets <- excel_sheets(path)
  service_sheet_names <- service_sheet_names %||% ex_sheets[grepl('Service_data', ex_sheets)]

  # Combine all sheet names
  sheet_names <- c(service_sheet_names, reporting_sheet_name, population_sheet_name, admin_sheet_name)

  # Validate if sheet names are provided
  if (length(sheet_names) == 0) {
    cd_abort(
      c("x" = "The {.arg sheet_names} cannot be empty. Provide at least one sheet name.")
    )
  }

  # Check if specified sheets are present in the file
  available_sheets <- excel_sheets(path)
  missing_sheets <- setdiff(sheet_names, available_sheets)
  if (length(missing_sheets) > 0) {
    cd_abort(
      c(
        "x" = "missing sheet(s)",
        "!" = paste(missing_sheets, collapse = ", ")
      )
    )
  }

  sheet_ids <- list2(
    !!admin_sheet_name := "district",
    !!population_sheet_name := c("district", "year"),
    service_data = c("district", "year", "month")
  )

  excel_name <- basename(path)

  # Log and load each sheet with basic cleaning steps
  cd_info(c("i" = "Loading Excel {.val {excel_name}} for parts"))
  parts <- map(sheet_names, ~ suppressMessages(
    read_and_clean_sheet(path, .x, sheet_ids, start_year)
  ))
  names(parts) <- sheet_names

  # Normalize month text on every sheet that has one, BEFORE merge_data() ever runs
  # (merge_and_standardize()) -- its own join key includes "month" as raw, un-normalized text
  # (sheet_ids$service_data above), and different sheets can legitimately use different
  # languages/case for the same conceptual month: confirmed live against a real file, one
  # Service_data sheet labeled a whole year in French while its sibling Service_data sheets labeled
  # the SAME year in English. Joining on raw text before this normalization silently fails to match
  # those rows across sheets -- whichever sheet ISN'T the merge's own anchor ends up with every one
  # of its own columns NA for the entire mismatched period, with no error or warning anywhere. Every
  # sheet is normalized independently and identically here (parse_month_name(), same function
  # standardize_data() itself uses), so the join key is consistent regardless of which sheet used
  # which language. raw_month preserves the true original text -- same field standardize_data()
  # itself derives this from post-merge, for the OTHER pipelines (e.g. save_dhis2_master_data(),
  # save_data.R) that still merge before normalizing.
  parts <- map(parts, function(d) {
    if ("month" %in% colnames(d)) {
      d$raw_month <- d$month
      d$month <- as.character(parse_month_name(d$month))
    }
    d
  })

  list(
    parts = parts,
    sheet_names = sheet_names,
    sheet_ids = sheet_ids,
    admin_sheet_name = admin_sheet_name,
    population_sheet_name = population_sheet_name,
    reporting_sheet_name = reporting_sheet_name,
    service_sheet_names = service_sheet_names,
    path = path,
    start_year = start_year
  )
}

#' Merge and standardize sheets read by `load_excel_parts()`
#'
#' Merges the separate sheets returned by [load_excel_parts()] into one dataset, standardizes
#' its columns and returns it as a `cd_data` tibble. This is the second half of loading an
#' Excel workbook.
#'
#' @details
#' Before merging, the function stops with an error if the Admin sheet fails
#' [check_admin_columns()] or [check_single_country()]. The merged data then goes to
#' [new_countdown()], which resolves the indicator group and, when `validate` is `TRUE`, stops
#' on a data quality problem.
#'
#' @param parts_result A list. What [load_excel_parts()] returns.
#' @inheritParams load_data
#' @param profile_name Optional. The resolved profile (indicator group) name,
#'   used when resolving the indicator group (for example with
#'   `indicator_group = "custom"`). Default is `NULL`.
#' @return A tibble of class `cd_data`.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' data <- merge_and_standardize(sheets)
#' data
#'
#' # Load even if a data quality check fails, to run the checks afterwards
#' data <- merge_and_standardize(sheets, validate = FALSE)
#' @export
merge_and_standardize <- function(parts_result,
                                  indicator_group = c('auto', 'vaccine', 'rmncah', 'custom'),
                                  profile = NULL,
                                  profile_name = NULL,
                                  validate = TRUE) {
  # The two Admin sheet checks below run here even when the caller (the Load Data wizard) has
  # already run them without aborting, as a backstop.
  indicator_group <- arg_match(indicator_group)

  parts <- parts_result$parts
  sheet_names <- parts_result$sheet_names
  sheet_ids <- parts_result$sheet_ids
  admin_sheet_name <- parts_result$admin_sheet_name

  # Tier A quality checks: structural problems with the raw Admin_data sheet, caught here
  # (before merge_data()/standardize_data()) rather than surfacing later as a confusing, unrelated
  # error far from the actual cause -- see 0_data_quality_checks.R's own header comment for why
  # these return problems instead of aborting individually, and are collected together instead.
  run_quality_checks(list(
    admin_columns = function() check_admin_columns(parts[[admin_sheet_name]]),
    single_country = function() check_single_country(parts[[admin_sheet_name]])
  ))

  # Standardize merged data
  out <- parts %>%
    merge_data(sheet_names, sheet_ids) %>%
    standardize_data()

  cd_info(c("i" = "Successfully loaded and cleaned data"), )

  new_countdown(out, indicator_group = indicator_group, profile = profile, profile_name = profile_name, validate = validate)
}

#' Read & clean Countdown 2030 Excel sheets
#'
#' Reads the specified sheets, applies standard cleaning, merges, and returns a
#' tibble. Group selection is not performed here; see [new_countdown()].
#'
#' @inheritParams load_data
#' @return A cleaned tibble.
#' @noRd
.load_excel_data <- function(path,
                            indicator_group = c('auto', 'vaccine', 'rmncah', 'custom'),
                            profile = NULL,
                            profile_name = NULL,
                            start_year = NULL,
                            admin_sheet_name = NULL,
                            population_sheet_name = NULL,
                            reporting_sheet_name = NULL,
                            service_sheet_names = NULL,
                            validate = TRUE) {
  check_file_path(path)
  indicator_group <- arg_match(indicator_group)

  parts_result <- load_excel_parts(path, start_year, admin_sheet_name, population_sheet_name,
                                   reporting_sheet_name, service_sheet_names)
  merge_and_standardize(parts_result, indicator_group, profile, profile_name, validate)
}

#' Create a `cd_data` object from cleaned data and resolve the indicator group
#'
#' Validates required columns, resolves the concrete indicator group name from
#' the **data** (`"auto"` detection supported), ensures the selected group's
#' indicators are fully present, sets the global selection, and returns a `cd_data`.
#'
#' @param .data Tibble after cleaning/merge.
#' @param class Optional character vector of extra classes to add in front of
#'   `"cd_data"`. Default is `NULL`.
#' @param indicator_group One of `"auto"`, `"vaccine"`, `"rmncah"`, `"custom"`.
#' @param profile_name Optional. The resolved profile (indicator group) name,
#'   used when resolving the indicator group (for example with
#'   `indicator_group = "custom"`). Default is `NULL`.
#' @param profile For `"custom"`, the group name to select (must exist). Ignored otherwise.
#'   Stored as the `profile` attribute of the result.
#' @param validate Logical. Whether to run the Tier B quality checks (district
#'   consistency, month presence and month validity). Default is `TRUE`.
#'
#' @return A tibble with class `cd_data` and `attr(, "indicator_group")` set to
#'   the resolved name. Also sets `options(cd2030.selected_group)` via [set_selected_group()].
#'
#' @examples
#' \dontrun{
#' x <- .load_excel_data("data/country.xlsx", indicator_group = "auto")
#' cd <- new_countdown(x, indicator_group = "auto")
#' attr(cd, "indicator_group")
#' }
#'
#' @export
new_countdown <- function(
    .data,
    class = NULL,
    indicator_group = c("auto","vaccine","rmncah","custom"),
    profile_name = NULL,
    profile = NULL,
    validate = TRUE
) {
  check_required(.data)

  .data <- .data %>%
     rename(ideliv = any_of('instdeliveries'))

  column_names <- colnames(.data)

  resolved_group <- resolve_indicator_group(column_names, indicator_group, profile_name)
  check_required_columns_exist(.data, resolved_group)

  # Tier B quality checks: need the fully merged/standardized data (district/adminlevel_1/year/
  # month all present as real columns), unlike Tier A's raw-sheet checks in .load_excel_data().
  # Collected together the same way -- see 0_data_quality_checks.R's header comment. Deliberately
  # run before match_country() below rather than folded into this same run_quality_checks() call:
  # match_country() both aborts AND returns a match result this function uses immediately
  # afterward, so it keeps its existing single-check, fail-fast behavior unchanged.
  #
  # validate = FALSE skips this tier only -- a caller (the Load Data wizard, apps/rmncah) that wants
  # to let a data-QUALITY problem (as opposed to a structural one -- required columns/country match
  # just above and below still always run) load anyway, so it can run these same checks itself,
  # later, progressively, against the already-loaded data (run_all_quality_checks(),
  # 0_data_quality_checks.R) instead of as an upfront hard stop.
  if (validate) {
    run_quality_checks(list(
      district_consistency = function() check_district_consistency(.data),
      month_presence = function() check_month_presence(.data),
      month_validity = function() check_month_validity(.data)
    ))
  }
  .data <- .data %>% select(-starts_with("raw_month"))

  set_selected_group(resolved_group)

  country_name <- .data %>%
    distinct(country) %>%
    pull(country)

  country <- match_country(country_name)

  # Add attributes for indicator groups and tracers and create the cd_data class
  new_tibble(
    .data,
    country = country$alternate,
    iso3 = as.character(country$iso3),
    indicator_group = resolved_group,
    profile = profile,
    class = c(class, "cd_data")
  )
}


#' Helper function to read and clean a single Excel sheet
#'
#' `read_and_clean_sheet` reads a specified Excel sheet, applies several cleaning
#' steps to standardize the data, and checks for duplicate entries based on
#' specified columns.
#'
#' @param path A string. Path to the Excel file.
#' @param sheet_name A string. Name of the sheet to read and clean.
#' @param sheet_ids A named list specifying the columns for duplicate checks
#'   for each sheet.
#' @param start_year An integer. The minimum year to keep. Default is `NULL`
#'   (keep every year).
#' @param call The call environment for error handling (default is the caller's
#'   environment).
#'
#' @return A cleaned tibble for the specified sheet.
#' @details
#' **Internal Steps**:
#' 1. **Path and Parameter Validation**: Checks if the file path is valid and
#'    that `sheet_name` and `sheet_ids` are provided. Throws an error if any
#'    are missing.
#' 2. **Data Loading and Column Cleaning**:
#'    - Reads the specified Excel sheet into a tibble.
#'    - Converts column names to lowercase and removes spaces.
#'    - Removes the first two rows, which may contain headers or empty rows.
#'    - Drops any columns starting with "..", which are usually unwanted
#'      blank columns.
#' 3. **Column Standardization**:
#'    - Renames the `district_name` column to `district` if it exists.
#'    - Converts all columns except `country`, `first_admin_level`,
#'      `district`, and `month` to numeric, suppressing warnings for any
#'      non-numeric values.
#'    - Filters out rows that are entirely missing in key columns, as defined
#'      by `required_columns`.
#' 4. **Duplicate Check**: Identifies columns used for duplicate checks based on
#'    `sheet_ids`. If duplicates are found, it throws an error with details.
#'
#' @examples
#' \dontrun{
#' # Load and clean a single sheet from an Excel file
#' cleaned_data <- read_and_clean_sheet("data.xlsx",
#'   sheet_name = "Sheet1",
#'   sheet_ids = list(Sheet1 = "id")
#' )
#' }
#'
#' @noRd
read_and_clean_sheet <- function(path, sheet_name, sheet_ids, start_year = NULL, call = caller_env()) {
  check_file_path(path, call = call)
  check_required(sheet_name, call = call)
  check_required(sheet_ids, call = call)

  # Columns that are required to have data
  required_columns <- c("country", "first_admin_level", "district", "year", "month")

  data <- tryCatch(
    read_excel(path, sheet = sheet_name, .name_repair = "unique") %>% # Read sheet
      rename_with(~ tolower(gsub(" ", "", .))) %>% # Convert column names to lower case and remove spaces
      slice(-c(1, 2)) %>% # Remove the first two rows (header rows)
      select(-starts_with("..")) %>% # Remove columns with names starting with ".." (usually blank or junk columns)
      rename_with(~ gsub("\\.\\.\\.\\d+$", "", .)) %>%
      rename(district = any_of("district_name")) %>% # Rename 'district_name' to 'district' if exists
      drop_na(any_of(required_columns)) %>% # Remove rows with key columns missing
      mutate(
        across(any_of("year"), ~ as.integer(.)), # Convert year column to integer
        across(-any_of(required_columns), ~ suppressWarnings(as.numeric(.))) # Convert other columns to numeric
      ),
    error = function(e) {
      clean_message <- clean_error_message(e)
      cd_abort(c("x" = paste0(clean_message), " in ", sheet_name), call = call)
    }
  )

  # A row whose year didn't survive as.integer() just above (a stray header/label row bleeding
  # into the data -- confirmed against a real file: a leftover French sub-header's "Mois" value
  # sitting in what should have been the year column) becomes NA here, and the filter() below
  # would otherwise drop it with zero signal -- exactly what let that row go unnoticed by every
  # later check. Surfaced as a log line at minimum; a full in-app surfacing of "N rows dropped for
  # an invalid year" is a reasonable smaller follow-up, not this function's own concern.
  if ("year" %in% colnames(data)) {
    invalid_year_n <- sum(is.na(data$year))
    if (invalid_year_n > 0) {
      cd_info(c("!" = "{invalid_year_n} row(s) in {.field {sheet_name}} have an invalid year value and were dropped."), call = call)
    }
  }

  # (`||` was given the whole year column here, so any start_year stopped the load)
  if (!is.null(start_year)) data <- data %>% filter(if_all(matches("year"), ~ .x >= start_year))

  if (nrow(data) == 0 || ncol(data) == 0) {
    cd_abort(c("x" = "Sheet {.arg {sheet_name}} is empty."), call = call)
  }

  # Determine columns for duplicate checking
  ids <- sheet_ids[[sheet_name]] %||% sheet_ids[["service_data"]]

  if (!all(ids %in% colnames(data))) {
    missing <- setdiff(ids, colnames(data))
    cd_abort(
      c("x" = 'Key Columns {.val {paste(missing, collapse = ", ")}} missing in {.field {sheet_name}}.'),
      call = call
    )
  }

  return(data)
}

#' Merge data frames
#'
#' `merge_data` merges a list of cleaned data frames by performing a series of
#' left joins using specified key columns. It ensures a consistent data structure
#' for further processing.
#'
#' @param .data A list of cleaned data frames to be merged.
#' @param sheet_names A vector of sheet names specifying the order of joins.
#' @param sheet_ids A named list containing column names to be used as join keys
#' for each sheet.
#' @param call The environment for error handling (default is the caller's
#' environment).
#'
#' @return A single merged data frame containing all specified sheets.
#' @details
#' **Internal Steps**:
#' 1. **Parameter Validation**: Checks that `.data`, `sheet_names`, and
#'    `sheet_ids` are provided. Throws an error if any of these are missing.
#' 2. **Iterative Left Joins**: Starts with the first data frame in `.data`
#'    (corresponding to the first element in `sheet_names`) as the base. Then, for
#'    each subsequent sheet name, performs a left join with the respective data
#'    frame in `.data` using key columns from `sheet_ids`. If key columns are
#'    missing for a sheet, defaults to keys from `sheet_ids[['service_data']]`.
#' 3. **Reordering and Sorting**: After merging, reorders columns to ensure
#'    `district`, `year`, and `month` appear first, and arranges the rows by
#'    `district`, `year`, and `month` for consistency.
#'
#' @examples
#' \dontrun{
#'   # Assuming `sheets` is a list of cleaned data frames
#'   merged_df <- merge_data(sheets,
#'     sheet_names = c("Sheet1", "Sheet2"),
#'     sheet_ids = list(Sheet1 = "id")
#'   )
#' }
#'
#' @noRd
merge_data <- function(.data, sheet_names, sheet_ids, call = caller_env()) {
  district <- year <- month <- NULL

  check_required(.data, call = call)
  check_required(sheet_names, call = call)
  check_required(sheet_ids, call = call)

  # Merge datasets iteratively using left join and the specified key columns
  merged_data <- reduce(
    .x = sheet_names[-1],
    .f = ~ left_join(.x, .data[[.y]], by = sheet_ids[[.y]] %||% sheet_ids[["service_data"]]),
    .init = .data[[sheet_names[1]]]
  )

  merged_data %>%
    relocate(district, year, month) %>%
    arrange(district, year, month)
}

#' Parse free-text month values into a standardized, ordered month factor
#'
#' Recognizes English, French and Portuguese month names and their abbreviations. Used by
#' `load_excel_parts()` and `standardize_data()`, so both read months the same way.
#'
#' @param month Character vector of raw month values.
#' @return An ordered `factor(levels = month.name)`; `NA` for anything unrecognized.
#' @noRd
parse_month_name <- function(month) {
  month <- str_to_lower(replace_special_chars(month))
  case_when(
    str_detect(month, "^jan|^jav") ~ "January",
    str_detect(month, "^fev|^feb") ~ "February",
    str_detect(month, "^mar") ~ "March",
    str_detect(month, "^avr|^abr|^apr") ~ "April",
    str_detect(month, "^mai|^may") ~ "May",
    str_detect(month, "^juin|^jun") ~ "June",
    str_detect(month, "^juil|^jul") ~ "July",
    str_detect(month, "^aou|^ago|^aug") ~ "August",
    str_detect(month, "^set|^sep") ~ "September",
    str_detect(month, "^out|^oct") ~ "October",
    str_detect(month, "^nov") ~ "November",
    str_detect(month, "^dec|^dez") ~ "December",
    .ptype = factor(levels = month.name, ordered = TRUE)
  )
}

#' Data preparation
#'
#' `standardize_data` standardizes and cleans a merged data frame by performing
#' multiple transformations such as column standardization, reporting rate
#' calculations, rounding, and renaming.
#'
#' @param .data A merged data frame to clean and standardize.
#' @param call The call environment for error handling (default is the caller's
#' environment).
#'
#' @return A final cleaned and standardized data frame.
#' @details
#' **Internal Steps**:
#' 1. **Month Column Standardization**: The `month` column is cleaned by replacing
#'    special characters and standardizing month names (e.g., abbreviations or
#'    language-specific variants).
#' 2. **Stillbirth Total Calculation**: Calculates `stillbirth_total` as the sum
#'    of `stillbirth_fresh` and `stillbirth_macerated`, handling missing values.
#' 3. **Missing Reporting Rate Calculation**: For columns ending with
#'    `_reporting_rate`, computes the reporting rate as `(received / expected) * 100`
#'    if missing and if `expected` is not zero.
#' 4. **Rounding Numeric Columns**: Rounds selected numeric columns, including
#'    those ending in `_rate`, to whole numbers.
#' 5. **Population Growth Rate**: Calculates annual population growth rate per
#'    district, storing the mean growth rate in `pop_growth_rate`.
#' 6. **Dropping Columns**: Drops intermediary columns such as `_reporting_received`
#'    and `_reporting_expected` after calculations.
#' 7. **Renaming Columns**: Renames columns for consistency, such as converting
#'    `first_admin_level` to `adminlevel_1`, and any `_reporting_rate` suffix to `_rr`.
#' 8. **Empty Column Check**: Identifies columns that are entirely missing
#'    (all values `NA`) and logs a message listing them.
#'
#' @examples
#' \dontrun{
#' # Standardize a merged data frame
#' standardized_df <- standardize_data(merged_data)
#' }
#'
#' @noRd
# What standardize_data() renames: the name the analysis uses = the name the workbook's sheets use. Kept as
# data, apart from the function, so the Data Quality step can ask "which required columns will be missing?" of
# the sheets' names alone, before anything is merged (.standardized_column_names()).
.standardize_renames <- c(
  adminlevel_1 = "first_admin_level",
  ideliv = "instdelivery",
  pnc48h = "pnc_48h",
  pop_rate = "pop_growth_rate",
  total_pop = "total_population",
  under5_pop = "population_under_5years",
  under1_pop = "population_under_1year",
  live_births = "live_births",
  total_births = "total_births",
  women15_49 = "women_15_49_years",
  total_hospitals = "number_hospitals",
  total_hcenters = "number_hcenters",
  total_facilities = "total_number_health_facilities",
  total_profit = "number_pfacilities_profit",
  total_nonprofit = "number_pfacilities_nonprofit",
  total_physicians = "total_physicians",
  total_nurses = "total_nurses_midwives",
  total_nonclinique_phys = "total_nonclinique_physicians",
  total_beds = "number_hospital_beds",
  total_stillbirth = "stillbirth_total",
  stillbirth_f = "stillbirth_fresh",
  stillbirth_m = "stillbirth_macerated",
  idelv_rr = "instdelivey_reporting_rate"
)

#' The column names a set of sheets will have once merged and standardized
#'
#' What `standardize_data()` and `new_countdown()` do to the names, done to the names alone: the renames above,
#' `_reporting_rate` -> `_rr`, `instdeliveries` -> `ideliv`, and `stillbirth_total`, which is computed.
#' @param column_names The sheets' column names (lower case, no spaces, as `read_and_clean_sheet()` leaves them).
#' @noRd
.standardized_column_names <- function(column_names) {
  x <- unique(column_names)
  if (all(c("stillbirth_fresh", "stillbirth_macerated") %in% x)) {
    x <- union(x, "stillbirth_total")
  }
  hit <- match(x, .standardize_renames)
  x[!is.na(hit)] <- names(.standardize_renames)[hit[!is.na(hit)]]
  x <- gsub("_reporting_rate", "_rr", x)
  x[x == "instdeliveries"] <- "ideliv"
  unique(x)
}

#' The workbook's name for a standardized column: what a user looks for in the sheet
#' @noRd
.raw_column_names <- function(column_names) {
  hit <- match(column_names, names(.standardize_renames))
  column_names[!is.na(hit)] <- unname(.standardize_renames[hit[!is.na(hit)]])
  sub("_rr$", "_reporting_rate", column_names)
}

standardize_data <- function(.data, call = caller_env()) {
  country <- month <- district <- . <- year <- total_population <- pop_growth_rate <- popgrowthrate <-
    meanpopgrowthrate <- adminlevel_1 <- first_admin_level <- stillbirth_fresh <-
    stillbirth_macerated <- NULL

  check_required(.data, call = call)

  # month/raw_month may already be normalized, plain-character text -- load_excel_parts() (Phase 3
  # of the Load Data wizard redesign) now does this BEFORE merge_data() ever runs, so its own
  # month-inclusive join key matches consistently across sheets regardless of source language (see
  # that function's own comment for the real, confirmed bug this fixes: a raw-text join silently
  # dropping one sheet's columns to NA for a whole mismatched-language period). Only re-derive
  # raw_month/month from scratch here if that hasn't already happened -- keeps this function
  # correct, unchanged, for every OTHER caller that still merges before normalizing (e.g.
  # save_dhis2_master_data(), save_data.R).
  already_normalized <- "raw_month" %in% colnames(.data)

  # A workbook without pop_growth_rate: the name fell through to the NULL above, which if_else() below refused
  # ("`false` must be a vector, not `NULL`") in the first district. The column is not made up here: it stays
  # absent, for new_countdown()'s required-columns check to name (check_required_columns_exist()).
  has_growth_rate <- "pop_growth_rate" %in% colnames(.data)

  data <- .data %>%
    mutate(
      # Preserved verbatim, before any cleaning, purely so new_countdown()'s Tier B
      # check_month_validity() can report exactly what unparseable text looked like (a typo,
      # different-language month name, etc.) instead of just "this row's month is NA". Dropped
      # again by new_countdown() once that check has run -- never part of the final countdown_data.
      raw_month = if (already_normalized) raw_month else month,
      # Clean and standardize the 'Month' column -- see parse_month_name()'s own comment for why
      # this is a shared helper, not inline here. Already-normalized text just needs re-typing to
      # the ordered factor every downstream consumer expects, not re-parsing.
      month = factor(if (already_normalized) month else parse_month_name(month), levels = month.name, ordered = TRUE),

      # Calculate stillbirth_total as the row-wise sum of stillbirth_fresh and stillbirth_macerated
      stillbirth_total = rowSums(select(., stillbirth_fresh, stillbirth_macerated), na.rm = TRUE),

      # Calculate missing reporting rates based on received/expected values
      across(
        ends_with("_reporting_rate"),
        ~ {
          var_prefix <- str_replace(cur_column(), "_reporting_rate", "")
          received_col <- paste0(var_prefix, "_reporting_received")
          expected_col <- paste0(var_prefix, "_reporting_expected")

          # Calculate the reporting rate only where values are missing
          if_else(
            is.na(.),
            if_else(
              get(expected_col) == 0,
              NA_real_,
              get(received_col) / get(expected_col) * 100
            ),
            .
          )
        }
      ),

      # Round selected columns and all columns ending with "_rate" to whole numbers
      across(
        any_of(c(
          ends_with("_rate"), "total_population", "population_under_5years",
          "population_under_1year", "live_births", "total_births"
        )),
        ~ round(.x, 0)
      )
    ) %>%
    mutate(
      # Calculate yearly population growth rate within each district
      popgrowthrate = ((total_population / lag(total_population))^(1 / (year - lag(year))) - 1) * 100,
      meanpopgrowthrate = mean(popgrowthrate, na.rm = TRUE),

      # Update pop_growth_rate with rounded mean if applicable
      pop_growth_rate = if (has_growth_rate) round(if_else(!is.na(meanpopgrowthrate), meanpopgrowthrate, pop_growth_rate), 1),

      # Apply the calculations by district
      .by = district
    ) %>%
    # Drop the specified columns and intermediate variables
    select(-matches("_reporting_received$|_reporting_expected$")) %>%
    rename(any_of(.standardize_renames)) %>%
    rename_with(~ gsub("_reporting_rate", "_rr", .x)) %>% # Rename columns ending with '_reporting_rate' to '_rr'
    # rename(idelv_rr = any_of('instdelivey_rr')) %>%
    relocate(country, adminlevel_1, district, year, month) %>%
    arrange(district, year, month)

  # Notify about empty columns
  empty_columns <- names(data)[colSums(is.na(data)) == nrow(data)]
  if (length(empty_columns) > 0) {
    cd_info(
      c("!" = 'The following columns are empty: {.field {paste(empty_columns, collapse = ", ")}}'),
      call = call
    )
  }

  return(data)
}

#' Replace special characters in text
#'
#' `replace_special_chars` replaces special characters in a text string with
#' their standard ASCII equivalents, helping to normalize text containing
#' diacritics or symbols for easier processing or comparison.
#'
#' @param text A character string or vector of character strings containing
#'   special characters.
#'
#' @details
#' This function specifically targets and replaces diacritic characters commonly
#'   found in various languages, along with some other symbols, converting them
#'   to their simpler ASCII equivalents:
#' - **Characters replaced with 'a'**: `?`, `?`, `?`, `?`, `?`, `?`, `?`, `?`
#' - **Characters replaced with 'e'**: `?`, `?`, `?`, `?`, `?`, `?`, `&`
#' - **Characters replaced with 'i'**: `?`, `?`, `?`, `?`, `?`, `?`
#' - **Characters replaced with 'o'**: `?`, `?`, `?`, `?`, `?`, `?`, `?`, `?`, `?`, `?`, `?`
#' - **Characters replaced with 'u'**: `?`, `?`, `?`, `?`, `?`, `?`, `?`, `?`
#' - **Character replaced with 'n'**: `?`
#'
#' @return A character string or vector of character strings with the special
#' characters replaced by their ASCII equivalents.
#'
#' @examples
#' replace_special_chars("????????????") # Returns "aeiounAEIOUN"
#' replace_special_chars("H?ll? W?rld") # Returns "Hello World"
#'
#' @noRd
replace_special_chars <- function(text) {
  str_replace_all(text, c(
    "[\u00E1\u00E3\u00E0\u00C1\u00C0\u00C3\u00E2\u00C2]" = "a", # ????????
    "[\u00E9\u00C9\u00EA\u00E8\u00C8\u00CA&]" = "e", # ??????
    "[\u00ED\u00CD\u00EF\u00EC\u00CF\u00CC]" = "i", # ??????
    "[\u00F3\u00F6\u00F5\u00F2\u00D3\u00D5\u00D2\u00F4\u00D4\u00D6\u00A2]" = "o", # ???????????
    "[\u00FA\u00F9\u00FB\u00FC\u00D9\u00DA\u00DC\u00DB]" = "u", # ????????
    "\u00F1" = "n" # ?
  ))
}


#' Find the country a name refers to
#'
#' Looks a country name up among the countries the package has reference data for (the
#' `countries` table) and returns that country. Stops with an error when the name is not one of
#' them, or could be more than one.
#'
#' @details
#' Names are compared without regard to case, accents, punctuation or words such as "Republic
#' of". A name is matched, in this order:
#'
#' 1. to a country it names exactly: one of the country's names in the table (in English,
#'    French or Portuguese), a name it is also known by (`.cd_country_aliases`), or its ISO3
#'    code;
#' 2. to the one country whose name starts with it, as whole words ("Burkina" for Burkina Faso);
#' 3. to the one country it is a misspelling of: one letter wrong, missing, added or swapped
#'    with its neighbour in a name of five letters or more, two in a name of nine or more.
#'
#' A name that is another country's (`.cd_country_others`: Sudan, Republic of the Congo) is not
#' matched, and neither is a misspelling that fits two countries equally (Nigeria and Niger).
#' The error then names the countries it is closest to.
#'
#' @param country_name A string. The country's name or ISO3 code.
#' @param call The environment of the calling function, for the error message.
#'
#' @return A one-row data frame of the `countries` table with the columns `alternate` (the
#'   country's name as the package shows it) and `iso3`.
#'
#' @noRd
match_country <- function(country_name, call = caller_call()) {
  check_required(country_name)

  if (!is_scalar_character(country_name)) {
    cd_abort(
      c("x" = "Country contains multiple names. Please clean the data")
    )
  }

  key <- .cd_country_key(country_name)
  if (is.na(key) || nchar(key) < 3) {
    cd_abort(
      c("x" = "Please provide a valid country name as a string.")
    )
  }

  names_of <- .cd_country_names()
  found <- character()
  if (!.cd_country_plain(country_name) %in% .cd_country_plain(.cd_country_others)) {
    # 1. the name itself
    found <- unique(names_of$iso3[names_of$key == key])
    # 2. the first words of one country's name
    if (length(found) != 1) {
      found <- unique(names_of$iso3[startsWith(names_of$key, paste0(key, " "))])
    }
    # 3. a misspelling: the longer the name, the more letters may be wrong
    if (length(found) != 1) {
      allowed <- if (nchar(key) >= 9) 2 else if (nchar(key) >= 5) 1 else 0
      edits <- stringdist::stringdist(key, names_of$key, method = "osa")
      closest <- tapply(edits, names_of$iso3, min)
      found <- names(closest)[closest <= allowed & closest == min(closest)]
    }
  }
  if (length(found) == 1) {
    return(countries[countries$iso3 == found, c("alternate", "iso3")])
  }

  # Not matched: the countries the name is closest to, when it is close to any
  close <- found
  if (!length(close)) {
    distance <- tapply(stringdist::stringdist(key, names_of$key, method = "jw", p = 0.1), names_of$iso3, min)
    close <- names(distance)[distance < 0.15 & distance == min(distance)]
  }
  suggestion <- countries$alternate[match(close, countries$iso3)]
  cd_abort(
    c(
      "x" = "The country {.val {country_name}} is not one of the {nrow(countries)} countries with reference data.",
      if (length(suggestion)) c("!" = "Did you mean {.or {.val {suggestion}}}?")
    )
  )
}

# Names a country is also written as, beside those in the `countries` table (by ISO3 code).
.cd_country_aliases <- list(
  CAF = c("RCA", "Centrafrique"),
  CIV = c("Ivory Coast"),
  COD = c("RDC", "RD Congo", "DR Congo", "Congo DRC", "Congo Kinshasa", "R\u00e9publique D\u00e9mocratique du Congo"),
  CPV = c("Cape Verde", "Cap Vert"),
  STP = c("Sao Tome")
)

# Names of countries without reference data that would otherwise be taken for one that has: the table gives
# "Sudan" and "Congo" as names of South Sudan and of the Democratic Republic of the Congo.
.cd_country_others <- c("Sudan", "Republic of the Sudan", "Republic of the Congo", "Republic of Congo", "Congo Republic",
                        "Congo Brazzaville", "Equatorial Guinea", "Papua New Guinea", "French Guiana")

# A name as it is compared: without case, accents or punctuation.
.cd_country_plain <- function(x) {
  x <- tolower(stringi::stri_trans_general(as.character(x), "Latin-ASCII"))
  trimws(gsub("[^a-z0-9]+", " ", x))
}

# ... and without the words that say what kind of state it is, when something is left without them.
.cd_country_key <- function(x) {
  plain <- .cd_country_plain(x)
  short <- trimws(gsub(" +", " ", gsub("\\b(republic|republique|republica|of|the|de|du|da|la|federal|kingdom|islamic|state)\\b", " ", plain)))
  ifelse(nzchar(short), short, plain)
}

# Every name of every country in the `countries` table, as compared: `iso3`, `key`.
.cd_country_names <- function() {
  rows <- lapply(seq_len(nrow(countries)), function(i) {
    iso3 <- countries$iso3[i]
    names <- c(strsplit(countries$country[i], "|", fixed = TRUE)[[1]], countries$alternate[i], iso3, .cd_country_aliases[[iso3]])
    # a name the table gives a country that is another country's own is left out ("Sudan"); "Congo" on its own
    # stays the Democratic Republic's, as the table has it
    names <- names[!.cd_country_plain(names) %in% .cd_country_plain(.cd_country_others)]
    data.frame(iso3 = iso3, key = unique(.cd_country_key(names)))
  })
  names_of <- do.call(rbind, rows)
  names_of[!is.na(names_of$key) & nzchar(names_of$key), ]
}


#' Find the country of an Admin sheet without raising an error
#'
#' Looks up the country named in the Admin sheet and returns its name and ISO3 code. Unlike
#' the lookup in [new_countdown()], it does not stop with an error when the country cannot be
#' resolved. Use it to show the country before the sheets are merged.
#'
#' @details
#' The country is resolved only when the `country` column holds exactly one distinct value,
#' ignoring missing values, and that value is close to a name in the package's list of
#' countries. This function does not validate the sheet. Use [check_single_country()] and
#' [check_country_recognized()] for that.
#'
#' @param admin_data A data frame. The cleaned Admin sheet, before the sheets are merged.
#' @return A list with two elements: `country` (the country's name as the package spells it)
#'   and `country_iso` (its ISO3 code), both strings. Both are `NULL` if the sheet has no
#'   `country` column or the country cannot be resolved.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' sheets <- load_excel_parts(path)
#' admin <- sheets$parts[[sheets$admin_sheet_name]]
#' resolve_country_best_effort(admin)
#'
#' # Nothing is returned, and no error raised, for a country that is not recognized
#' admin$country <- "Atlantis"
#' resolve_country_best_effort(admin)
#' @export
resolve_country_best_effort <- function(admin_data) {
  # The Load Data wizard needs a country and ISO code to show before the merge. match_country()
  # aborts on anything ambiguous, which would leave both NULL for the whole wizard.
  if (!"country" %in% colnames(admin_data)) {
    return(list(country = NULL, country_iso = NULL))
  }
  values <- admin_data %>% distinct(country) %>% pull(country)
  values <- values[!is.na(values)]
  if (length(values) != 1) {
    return(list(country = NULL, country_iso = NULL))
  }
  result <- tryCatch(match_country(values[1]), error = function(e) NULL)
  if (is.null(result)) {
    return(list(country = NULL, country_iso = NULL))
  }
  list(country = result$alternate, country_iso = as.character(result$iso3))
}

#' Generate a key for each admin level 1 unit
#'
#' Gives each distinct admin level 1 name a short key, so that the same unit can be identified
#' in several tables (for example the dataset, the survey mapping and the map mapping). Generate
#' the keys once from the dataset's names, then join them to the other tables by name.
#'
#' @details
#' The keys are arbitrary: the distinct names are sorted and numbered in that order. They are
#' not standard codes, and they are not stable between datasets. A dataset with a different set
#' of names can give a different key to the same unit. Missing names get no key.
#'
#' @param admin1_names A character vector of admin level 1 names, usually the `adminlevel_1`
#'   column of the dataset.
#' @return A tibble with one row per distinct name, sorted by name, and columns `adminlevel_1`
#'   (the name) and `admin1_key` (the key: `"A1-001"`, `"A1-002"` and so on).
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' data <- load_data(path)
#' generate_admin1_keys(data$adminlevel_1)
#'
#' # Repeated and missing names get no key of their own
#' generate_admin1_keys(c("Western", "Coast", "Western", NA))
#' @export
generate_admin1_keys <- function(admin1_names) {
  # Sub-national units have no standard code available in general, so the key is made up here.
  # Nothing needs it to be stable across uploads. That would take a saved name-to-key table.
  distinct_names <- sort(unique(stats::na.omit(admin1_names)))
  tibble::tibble(
    adminlevel_1 = distinct_names,
    admin1_key = sprintf("A1-%03d", seq_along(distinct_names))
  )
}

#' Parse a single profile argument (name or inline definition)
#'
#' Accepts either:
#' - **String name** of an existing/target profile (no registration needed)
#' - **Explicit spec**: `list(name = "my_profile", value = <named list of character vectors>)`
#' - **Compact spec**:  `list(my_profile = <named list of character vectors>)`
#'
#' Returns a small list with:
#' - `name`: profile name (character scalar)
#' - `value`: profile definition (named list) or `NULL`
#' - `needs_registration`: `TRUE` if `value` is present and should be registered,
#'   otherwise `FALSE`.
#'
#' Reserved names `"auto"` and `"custom"` are disallowed for registration; they
#' may appear as plain names only to control selection mode upstream.
#'
#' @param profile A string (name) or a list spec (explicit/compact). See Details.
#'
#' @return A list: `list(name, value, needs_registration)`.
#'
#' @examples
#' # Name only (no registration)
#' .parse_profile("rmncah")
#'
#' # Explicit spec (register then use)
#' .parse_profile(list(
#'   name  = "rmncah",
#'   value = list(hiv = c("hiv_test","pmtct1"))
#' ))
#'
#' # Compact spec (register then use)
#' .parse_profile(list(
#'   hiv_profile = list(
#'     testing = c("hiv_test","pmtct1"),
#'     care    = c("art_new","art_current")
#'   )
#' ))
#'
#' @noRd
.parse_profile <- function(profile) {
  # nothing provided
  if (is.null(profile)) {
    return(list(name = NULL, value = NULL, needs_registration = FALSE))
  }

  # string -> name only (no registration)
  if (rlang::is_string(profile)) {
    return(list(name = profile, value = NULL, needs_registration = FALSE))
  }

  # explicit spec: list(name=..., value=<named list>)
  if (is.list(profile) && rlang::is_named(profile) && all(c("name","value") %in% names(profile))) {
    nm  <- profile$name
    val <- profile$value

    if (!rlang::is_string(nm) || !nzchar(nm)) {
      cd_abort(c("x" = "{.arg profile$name} must be a non-empty string"))
    }
    if (!is.list(val) || !rlang::is_named(val)) {
      cd_abort(c("x" = "{.arg profile$value} must be a named list of categories \u2192 character vectors"))
    }
    bad <- purrr::map_lgl(val, ~ !is.character(.x) || anyNA(.x))
    if (any(bad)) {
      cd_abort(c("x" = "Each category in {.arg profile$value} must be a character vector"))
    }

    if (nm %in% c("auto","custom")) {
      cd_abort(c("x" = "Profile name cannot be 'auto' or 'custom' when registering a definition"))
    }

    return(list(name = nm, value = val, needs_registration = TRUE))
  }

  # compact spec: list(<name> = <named categories list>)
  if (is.list(profile) && length(profile) == 1L && rlang::is_named(profile)) {
    nm  <- names(profile)[1]
    val <- profile[[1]]

    if (!nzchar(nm)) {
      cd_abort(c("x" = "Compact {.arg profile} must use a non-empty name"))
    }
    if (!is.list(val) || !rlang::is_named(val)) {
      cd_abort(c("x" = "Compact {.arg profile} must be list(<name> = <named categories list>)"))
    }
    bad <- purrr::map_lgl(val, ~ !is.character(.x) || anyNA(.x))
    if (any(bad)) {
      cd_abort(c("x" = "Each category in compact {.arg profile} must be a character vector"))
    }

    if (nm %in% c("auto","custom")) {
      cd_abort(c("x" = "Profile name cannot be 'auto' or 'custom' when registering a definition"))
    }

    return(list(name = nm, value = val, needs_registration = TRUE))
  }

  cd_abort(c("x" = "Unsupported {.arg profile} shape. Use a string, an explicit spec, or a compact spec."))
}

