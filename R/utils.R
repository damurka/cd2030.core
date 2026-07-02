check_file_path <- function(path, call = caller_env()) {
  check_required(.data, call = call)
  # Validate if the file exists
  if (!file.exists(path)) {
    cd_abort(
      c("x" = "The specified file {.val {path}} does not exist. Please provide a valid file path."),
      call = call
    )
  }

  invisible(TRUE)
}

check_required_columns_exist <- function(.data, resolved_group, call = caller_env()) {
  # Indicator groups required for analysis within Countdown 2030
  indicator_groups <- get_indicator_groups(resolved_group)

  # Check for any missing columns within the indicator groups
  missing_cols <- list_c(imap(indicator_groups, ~ setdiff(c(.x, paste0(.y, "_rr")), colnames(.data))))

  # Abort with a detailed error message if required columns are missing
  if (length(missing_cols) > 0) {
    cd_abort(
      c(
        "x" = "Data does not contain all indicators for group '{resolved_group}'.",
        "!" = '{.field {paste(missing_cols, collapse = ", ")}}'
      ),
      call = call
    )
  }
}

check_cd_class <- function(.data,
                           expected_class,
                           arg = caller_arg(.data),
                           call = caller_env()) {
  check_required(.data, arg = arg, call = call)

  if (!inherits(.data, expected_class)) {
    cd_abort(
      c("x" = "The data object must be of class {.cls {expected_class}}."),
      call = call
    )
  }

  invisible(TRUE)
}


check_cd_population_metrics <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_population_metrics", arg = arg, call = call)
}

check_cd_indicator_coverage <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_indicator_coverage", arg = arg, call = call)
}

check_cd_population <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_population", arg = arg, call = call)
}

check_cd_reporting_rate <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_average_reporting_rate", arg = arg, call = call)
}

check_cd_data <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_data", arg = arg, call = call)
}

check_cd_fpet <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_fpet_data", arg = arg, call = call)
}

check_cd_mapping <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_mapping", arg = arg, call = call)
}

check_cd_coverage <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_coverage", arg = arg, call = call)
}

#' Validate UN Estimates Data for Population Metrics
#'
#' Ensures the provided UN estimates data is valid and appropriate for the selected
#' administrative level.
#'
#' @param .data A tibble containing UN estimates data or `NULL`.
#' @param admin_level Character. Specifies the administrative level for aggregation.
#'   Must be one of `"national"`, `"adminlevel_1"`, or `"district"`.
#' @param call The calling environment for error messages.
#'
#' @return Invisible `NULL`. Throws an error if the validation fails.
#' @noRd
check_un_estimates_data <- function(.data = NULL,
                                    admin_level = c("national", "adminlevel_1", "district"),
                                    arg = caller_arg(.data),
                                    call = caller_env()) {
  admin_level <- arg_match(admin_level)
  if (admin_level == "national") {
    if (is.null(.data)) {
      cd_abort(c("x" = "{.arg un_estimate} must be provided for {.val national} metrics."), call = call)
    }
    check_cd_class(.data, "cd_un_estimates", arg = arg, call = call)
  }

  invisible(TRUE)
}

check_un_mortality_data <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_un_mortality", arg = arg, call = call)
}

check_fpet_data <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_fpet_data", arg = arg, call = call)
}

check_wuenic_data <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_wuenic_data", arg = arg, call = call)

  if (!all(c("iso3", "year") %in% colnames(.data))) {
    cd_abort(c("x" = "WUENIC data must contain {.field iso3} and {.field year} columns."), call = call)
  }

  invisible(TRUE)
}

check_survey_data <- function(.data,
                              admin_level = c("national", "adminlevel_1", "district"),
                              arg = caller_arg(.data),
                              call = caller_env()) {
  check_cd_class(.data, "cd_survey_data", arg = arg, call = call)

  admin_level <- arg_match(admin_level)
  if (admin_level == "national" && "adminlevel_1" %in% colnames(.data)) {
    cd_abort(c("x" = "Regional survey data used in national level"), call = call)
  } else if (admin_level != "national" && !"adminlevel_1" %in% colnames(.data)) {
    cd_abort(c("x" = "National survey data used in subnational level"), call = call)
  }

  if (!all(c("iso3", "year") %in% colnames(.data))) {
    cd_abort(c("x" = "Survey data must contain {.field iso} and {.field year} columns."), call = call)
  }

  invisible(TRUE)
}

check_equity_data <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_equity_data", arg = arg, call = call)
}

check_service_utilization <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_service_utilization", arg = arg, call = call)
}

check_un_mortality <- function(.data, arg = caller_arg(.data), call = caller_env()) {
  check_cd_class(.data, "cd_un_mortality", arg = arg, call = call)
}

check_ratio_pairs <- function(.list, arg = call_args(.list), call = caller_env()) {
  check_required(.data, call = call)

  # Check that ratio_pairs is a named list with each element as a character vector of length 2
  is_ratio_pairs <- all(
    is.list(.list),
    all(lengths(.list) == 2),
    all(map_lgl(.list, ~ is.character(.x) && length(.x) == 2))
  )

  if (!is_ratio_pairs) {
    cd_abort(c("x" = "{.arg arg} is not a proper ratio pair."), call = call)
  }

  invisible(TRUE)
}

check_scalar_integerish <- function(vec, arg = caller_arg(vec), call = caller_env()) {
  check_required(vec, arg = arg, call = call)

  if (!is_scalar_integerish(vec)) {
    cd_abort(
      message = c(
        "x" = "{.arg {arg}} is not an integer",
        "!" = "Provide a scalar integer value"
      ),
      call = call
    )
  }
}

check_scalar_character <- function(vec, arg = caller_arg(vec), call = caller_env()) {
  check_required(vec, arg = arg, call = call)

  if (!is_scalar_character(vec)) {
    cd_abort(
      message = c(
        "x" = "{.arg {arg}} is not a scalar string",
        "!" = "Provide a scalar string value"
      ),
      call = call
    )
  }
}

# MASTER ENGINE: Parses all surveys (National & Regional) identically
parse_estimates_from_df = function(estimates, iso, region = NULL) {
  if (is.null(estimates) || nrow(estimates) == 0) return(NULL)

  group <- get_selected_group()
  common_factors <- c("anc1", "instlivebirths", "bcg", "penta1", "penta3", "measles1")
  factors <- if (group == "vaccine") c(common_factors, "opv1", "opv3") else c(common_factors, "anc4", "low_bweight", "csection")
      
  cols_to_keep <- c("year", factors, "nmr", "pnmr", "sbr")

  # if (length(cols_to_keep) <= 1) return(NULL) # Only 'year' exists

  is_region <- 'adminlevel_1' %in% names(estimates)
  if (!is_region && !is.null(region)) {
    cd_abort(c('x' = 'Cannot specify {.arg region} in national survey data'))
  }

  est_long <- estimates %>%
    filter(iso3 == iso, if (is_region && !is.null(region)) adminlevel_1 == region else TRUE) %>%
    select(year, starts_with("r_"), -ends_with("24_35")) %>%
    rename_with(~ str_remove(.x, "r_"), starts_with("r_")) %>% 
    select(any_of(cols_to_keep)) %>% 
    pivot_longer(cols = -year) %>% 
    filter(!is.na(value)) %>% 
    slice_max(order_by = year, by = name, with_ties = FALSE)
      
  if (nrow(est_long) == 0) return(NULL)

  # Standardize values: Mortality rates are per 1000. 
  # We keep coverage metrics as 0-100 percentages for the UI here.
  processed <- est_long %>%
    mutate(value = case_when(
      name %in% c("nmr", "pnmr", "sbr") ~ value / 1000,
      .default = round(value, 1) 
    ))
        
  named_vals <- set_names(processed$value, processed$name)
  return(list(year = max(est_long$year), values = named_vals))
}
