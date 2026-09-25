#' Analyze Subnational Health Coverage Data with Inequality Metrics
#'
#' `calculate_inequality` computes subnational health coverage metrics and evaluates
#' disparities compared to reference averages (either national or regional).
#'
#' @param subnational_data A data frame containing pre-calculated subnational health coverage data.
#' @param reference_data A data frame containing pre-calculated reference health coverage data
#'   (e.g., national data if analyzing `adminlevel_1`, or `adminlevel_1` data if analyzing `district`).
#'
#' @return A tibble (`cd_inequality` object) containing:
#'   - Subnational health coverage metrics.
#'   - Population shares.
#'   - MADM, MRDM, and related disparity metrics.
#'
#' @export
calculate_inequality <- function(subnational_data,
                                 reference_data) {
  year = NULL

  # Validation
  check_cd_indicator_coverage(subnational_data)
  check_cd_indicator_coverage(reference_data)

  sub_admin_level <- attr_or_abort(subnational_data, 'admin_level')
  sub_region <- attr_or_null(subnational_data, 'region')

  ref_admin_level <- attr_or_abort(reference_data, 'admin_level')

  if (!ref_admin_level %in% c('national', 'adminlevel_1')) {
    cd_abort(c('x' = 'Subnational data must be {.val adminlevel_1} or {.val district}.'))
  }

  if (!sub_admin_level %in% c('district', 'adminlevel_1')) {
    cd_abort(c('x' = 'Subnational data must be {.val adminlevel_1} or {.val district}.'))
  }

  if (sub_admin_level %in% c('adminlevel_1', 'district')  && is.null(sub_region) && ref_admin_level != 'national') {
    cd_abort(c('x' = 'Reference data must be {.val national} when subnational data is {.val adminlevel_1} or {.val district} and {.val region} is null.'))
  }

  if (sub_admin_level == 'adminlevel_1' && !is.null(sub_region) && ref_admin_level != 'adminlevel_1') {
    cd_abort(c('x' = 'Reference data must be {.val adminlevel_1} when subnational data is {.val adminlevel_1} and {.val region} is not null.'))
  }

  if (!is.null(sub_region)) {
    if (!sub_region %in% unique(subnational_data$adminlevel_1)) {
      cd_warn(c('!' = 'Region {.val sub_region} not found in subnational data.'))
      return(NULL)
    }
  }

  admin_level_col <- get_admin_columns(sub_admin_level, sub_region)
  admin_level_col <- c(admin_level_col, 'year')

  level <- if ((sub_admin_level == 'adminlevel_1' && !is.null(sub_region))) {
    'adminlevel_1'
  } else {
    'national'
  }

  indicators <- get_analysis_indicators()
  cov_indicator_pattern <- paste0("cov_(", paste(indicators, collapse = "|"), ")")

  national_data <- reference_data %>%
    select(any_of(admin_level_col), matches("^tot_|"), matches(cov_indicator_pattern), -ends_with("_un")) %>%
    rename_with(~ paste0("nat_", .x), matches("^cov_|^tot"))

  sub_data <- subnational_data %>%
    select(any_of(admin_level_col), matches("^tot"), matches(cov_indicator_pattern))

  join_keys <- switch (
    level,
    national = 'year',
    adminlevel_1 = c('adminlevel_1', 'year')
  )

  combined_data <- sub_data %>%
    left_join(national_data, by = join_keys) %>%
    mutate(
      across(starts_with("cov_"), ~ abs(.x - get(paste0("nat_", cur_column()))), .names = "diff_{.col}"),
      across(starts_with("tot"), ~ .x / get(paste0("nat_", cur_column())), .names = "popshare_{.col}")
    ) %>%
    mutate(
      across(starts_with("diff_"), ~ mean(.x, na.rm = TRUE), .names = "{ gsub('^diff', 'madm', .col) }"),
      across(starts_with("diff_"), ~ {
        indicator <- str_extract(cur_column(), "(?<=_cov_).+(?=_[^_]+$)")
        denominator <- str_extract(cur_column(), "[^_]+$")
        population <- get_population_column(indicator, denominator)
        if (is.na(population)) {
          return(NA)
        }

        stats::weighted.mean(.x, get(paste("popshare", population, sep = "_")), na.rm = TRUE)
      },
      .names = "{ gsub('^diff', 'madmpop', .col) }"
      ),
      across(starts_with("madm_"), ~ {
        indicator <- str_replace(cur_column(), "^madm", "nat")

        (.x / mean(get(indicator))) * 100
      },
      .names = "{ gsub('^madm', 'mrdm', .col) }"
      ),
      across(starts_with("madmpop_"), ~ {
        indicator <- str_replace(cur_column(), "^madmpop", "nat")

        (.x / mean(get(indicator))) * 100
      },
      .names = "{ gsub('^madmpop', 'mrdmpop', .col) }"
      ),
      .by = year
    ) %>%
    mutate(
      across(starts_with("cov_"), ~ {
        rd_max <- round(robust_max(.x, fallback = 100), -1)
        rd_max <- if_else(rd_max < robust_max(.x, fallback = 100), rd_max + 10, rd_max)
        rd_max <- rd_max * 1.05

        if_else(rd_max %% 20 != 0, rd_max + 10, rd_max)
      },
      .names = "rd_max_{.col}"
      )
    )

  new_tibble(
    combined_data,
    class = "cd_inequality",
    admin_level = sub_admin_level,
    region = sub_region
  )
}

#' Filter Subnational Inequality Metrics
#'
#' `filter_inequality` refines the output of `calculate_inequality` by selecting
#' specific indicators and denominators for analysis. It extracts and renames relevant
#' columns to streamline further analyses.
#'
#' @param .data A `cd_inequality` tibble created by `calculate_inequality`.
#' @param indicator A character vector of health indicators to include (e.g., `"penta3"`, `"measles1"`).
#' @param denominator A character vector of denominators to filter by (e.g., `"dhis2"`, `"anc1"`).
#'
#' @return A tibble containing filtered subnational inequality metrics for
#'   the specified indicators and denominators.
#'
#' @examples
#' \dontrun{
#' # Filter for Penta-3 coverage using DHIS-2 denominator
#' filtered_data <- inequality_metrics %>%
#'   filter_inequality(indicator = "penta3", denominator = "dhis2")
#' }
#'
#' @export
filter_inequality <- function(.data,
                              indicator,
                              denominator = c("dhis2", "anc1", "penta1", "penta1derived", "anc1derived")) {

  admin_level <- attr_or_abort(.data, "admin_level")
  region <- attr_or_null(.data, 'region')

  indicator <- arg_match(indicator, get_analysis_indicators())
  denominator <- arg_match(denominator)

  pop_col <- get_population_column(indicator, denominator)
  dhis_col <- paste("cov", indicator, denominator, sep = "_")
  admin_col <- get_admin_columns(admin_level)

  data <- .data %>%
    select(year, any_of(c(pop_col, admin_col)), ends_with(dhis_col), ends_with(pop_col)) %>%
    rename_with(~ str_remove(.x, paste0("_", dhis_col)), ends_with(dhis_col)) %>%
    select(-any_of(paste0("nat_", pop_col))) %>%
    rename_with(~ str_remove(.x, paste0("_", pop_col)), ends_with(pop_col))

  new_tibble(
    data,
    class = 'cd_inequality_filtered',
    admin_level = admin_level,
    region = region,
    indicator = indicator,
    denominator = denominator
  )
}
