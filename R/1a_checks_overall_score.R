#' Calculate Overall Quality Score for Data Quality Metrics
#'
#' This function calculates an overall quality score based on various data
#' quality metrics. It summarizes completeness, outlier presence, and
#' consistency of reporting in immunization health facility data.
#'
#' @param .data A data frame of type `cd_data` containing facility data
#'   including annual reporting rates, completeness, and consistency indicators.
#' @param threshold The data reporting rate threshold.
#' @param ratio_pairs description
#' @param region Optional name of an `adminlevel_1` region. If supplied, all
#'   metrics are calculated for that region only. Default is `NULL`.
#' @param labels Optional named list overriding the default row labels. May
#'   contain `header` (`h1`, `h2`, `h3`), `section` (`r1a`, `r1b`, `r1c`, `r2a`,
#'   `r2b`, `score`) and `metric` (for example `r_anc1_penta1`,
#'   `ok_anc1_penta1`) sub-lists; only the supplied entries are replaced.
#'   Default is `NULL`.
#'
#' @details
#' `calculate_overall_score` processes multiple data quality indicators:
#'  - **Completeness metrics**: Percentage of expected reports, districts with
#'    complete reporting, and districts with no missing values.
#'  - **Outlier metrics**: Percentage of monthly values and districts without
#'    extreme outliers.
#'  - **Consistency ratios**: Ratios between different immunization indicators
#'    to ensure internal consistency.
#'
#' The function calculates averages for the selected metrics and includes
#' a row summarizing the annual data quality score.
#'
#' @return A tibble with calculated scores for each metric, including
#'   a summary row for the annual quality score. The result is ordered by
#'   metric codes and ready for reporting in tabular or graphical form.
#'
#' @examples
#' \dontrun{
#' calculate_overall_score(.data = my_data)
#' }
#'
#' @export
calculate_overall_score <- function(.data,
                                    threshold,
                                    ratio_pairs = NULL,
                                    region = NULL,
                                    labels = NULL) {
  check_cd_data(.data)

  selected_group <- get_selected_group()

  avg_reporting_rate <- calculate_average_reporting_rate(.data, "adminlevel_1", region = region) %>%
    summarise(mean_rr = mean(mean_rr, na.rm = TRUE), .by = year)

  district_reporting_rate <- calculate_district_reporting_rate(.data, threshold = threshold, region = region)

  district_completeness <- calculate_district_completeness_summary(.data, region = region)

  outliers <- calculate_outliers_summary(.data, admin_level = "adminlevel_1", region = region) %>%
    summarise(mean_out_all = mean(mean_out_all, na.rm = TRUE), .by = year)

  outliersd <- calculate_district_outlier_summary(.data, region = region)

  adeqratiosd <- calculate_ratios_and_adequacy(.data, ratio_pairs = ratio_pairs, region = region)

  .generate_score_table(
    average_reporting_rate = avg_reporting_rate,
    district_reporting_rate = district_reporting_rate,
    district_completeness = district_completeness,
    outliers_summary = outliers,
    district_outliers_summary = outliersd,
    ratios_summary = adeqratiosd,
    threshold = threshold,
    labels = labels
  )
}

#' Calculate Overall Quality Score from Summaries
#'
#' Builds the same score table as [calculate_overall_score()], but from
#' summaries that have already been calculated.
#'
#' @param average_reporting_rate A `cd_average_reporting_rate` object with a
#'   `mean_rr` column by year.
#' @param district_reporting_rate A `cd_district_reporting_rate` object.
#' @param district_completeness A `cd_missing_district` object, as returned by
#'   [calculate_district_completeness_summary()].
#' @param outliers_summary A `cd_outlier` object with a `mean_out_all` column by
#'   year.
#' @param district_outliers_summary A `cd_district_outliers_summary` object.
#' @param ratios_summary A `cd_ratios_and_adequacy` object.
#' @param labels Optional named list overriding the default row labels, with
#'   `header`, `section` and `metric` sub-lists (see
#'   [calculate_overall_score()]). Default is `NULL`.
#' @param threshold Numeric. The district reporting rate threshold shown in the
#'   label of row 1b. Default is `90`.
#'
#' @return A tibble with calculated scores for each metric, including a summary
#'   row for the annual quality score.
#'
#' @export
calculate_overall_score1 <- function(average_reporting_rate,
                                     district_reporting_rate,
                                     district_completeness,
                                     outliers_summary,
                                     district_outliers_summary,
                                     ratios_summary,
                                     labels = NULL,
                                     threshold = 90) {
  check_cd_class(average_reporting_rate, "cd_average_reporting_rate")
  check_cd_class(district_reporting_rate, "cd_district_reporting_rate")
  check_cd_class(district_completeness, "cd_missing_district")
  check_cd_class(outliers_summary, "cd_outlier")
  check_cd_class(district_outliers_summary, "cd_district_outliers_summary")
  check_cd_class(ratios_summary, "cd_ratios_and_adequacy")
  is_bare_numeric(threshold)

  # threshold <- attr_or_abort(district_reporting_rate, "threshold")

  .generate_score_table(
    average_reporting_rate = average_reporting_rate,
    district_reporting_rate = district_reporting_rate,
    district_completeness = district_completeness,
    outliers_summary = outliers_summary,
    district_outliers_summary = district_outliers_summary,
    ratios_summary = ratios_summary,
    threshold = threshold,
    labels = labels
  )
}

.generate_score_table <- function(average_reporting_rate,
                                  district_reporting_rate,
                                  district_completeness,
                                  outliers_summary,
                                  district_outliers_summary,
                                  ratios_summary,
                                  threshold,
                                  labels = NULL) {
  # 2. Setup: Determine Group & Columns
  selected_group <- get_selected_group()

  col_completeness <- if (selected_group == "vaccine") "mean_mis_vacc_tracer" else "mean_mis_all"
  col_outliers_dst <- if (selected_group == "vaccine") "mean_out_vacc_only" else "mean_out_all"

  # Base IDs are always percentages
  ids_to_average <- c("1a", "1b", "1c", "2a", "2b")

  # Add group-specific percentage IDs from the Ratio section
  if (selected_group == "vaccine") {
    # Vaccine: 3a,3b,3c are Ratios. 3f,3g,3h are Percentages.
    ids_to_average <- c(ids_to_average, "3f", "3g", "3h")
  } else {
    # RMNCAH: 3a,3b are Ratios. 3c,3d are Percentages.
    ids_to_average <- c(ids_to_average, "3c", "3d")
  }

  lbl_completeness <- if (selected_group == "vaccine") {
    "% of districts with no missing values (mean for common vaccines)"
  } else {
    "% of districts with no missing values for the 4 forms"
  }

  # 3. Setup: Define Labels
  default_lbl <- list(
    header = list(
      h1 = "1. Completeness of monthly facility reporting (mean of ANC, delivery, immunization)",
      h2 = "2. Extreme outliers (mean of ANC, delivery, immunization)",
      h3 = "3. Consistency of annual reporting"
    ),
    section = list(
      r1a = "% of expected monthly facility reports (national)",
      r1b = paste0("% of districts with completeness of facility reporting >= ", threshold),
      r1c = lbl_completeness,
      r2a = "% of monthly values that are not extreme outliers (national)",
      r2b = "% of districts with no extreme outliers in the year",
      score = "Annual data quality score"
    ),
    metric = list(
      r_anc1_penta1    = "Ratio anc1/penta1",
      r_penta1_penta3  = "Ratio penta1/penta3",
      r_opv1_opv3      = "Ratio opv1/opv3",
      ok_anc1_penta1   = "% district with anc1/penta1 in expected ranged",
      ok_penta1_penta3 = "% district with penta1/penta3 in expected ranged",
      ok_opv1_opv3     = "% district with opv1/opv3 in expected ranged"
    )
  )

  if (!is.null(labels)) {
    if (!is.null(labels$header)) default_lbl$header <- modifyList(default_lbl$header, as.list(labels$header))
    if (!is.null(labels$section)) default_lbl$section <- modifyList(default_lbl$section, as.list(labels$section))
    if (!is.null(labels$metric)) default_lbl$metric <- modifyList(default_lbl$metric, as.list(labels$metric))
  }

  # 4. Process Standard Sections
  row_1a <- average_reporting_rate %>% process_metric_row("mean_rr", default_lbl$section$r1a, "1a")
  row_1b <- district_reporting_rate %>% process_metric_row("low_mean_rr", default_lbl$section$r1b, "1b")
  row_1c <- district_completeness %>% process_metric_row(col_completeness, default_lbl$section$r1c, "1c")
  row_2a <- outliers_summary %>% process_metric_row("mean_out_all", default_lbl$section$r2a, "2a")
  row_2b <- district_outliers_summary %>% process_metric_row(col_outliers_dst, default_lbl$section$r2b, "2b")

  # 5. Process Ratios

  # Map raw names -> short IDs
  raw_to_id_map <- c(
    "Ratio anc1/penta1"                                = "r_anc1_penta1",
    "Ratio penta1/penta3"                              = "r_penta1_penta3",
    "Ratio opv1/opv3"                                  = "r_opv1_opv3",
    "% district with anc1/penta1 in expected ranged"   = "ok_anc1_penta1",
    "% district with penta1/penta3 in expected ranged" = "ok_penta1_penta3",
    "% district with opv1/opv3 in expected ranged"     = "ok_opv1_opv3"
  )

  # Map short IDs -> "no" codes
  id_to_no_map <- if (selected_group == "vaccine") {
    c(
      r_anc1_penta1 = "3a", r_penta1_penta3 = "3b", r_opv1_opv3 = "3c",
      ok_anc1_penta1 = "3f", ok_penta1_penta3 = "3g", ok_opv1_opv3 = "3h"
    )
  } else {
    c(
      r_anc1_penta1 = "3a", r_penta1_penta3 = "3b",
      ok_anc1_penta1 = "3c", ok_penta1_penta3 = "3d"
    )
  }

  metric_lbl_vec <- unlist(default_lbl$metric)

  row_ratios <- ratios_summary %>%
    select(year, starts_with("Ratio"), starts_with("% district with")) %>%
    pivot_longer(-year, names_to = "raw_metric", values_to = "value") %>%
    mutate(
      short_id = raw_to_id_map[raw_metric],
      label_lookup = metric_lbl_vec[short_id],
      `Data Quality Metrics` = coalesce(label_lookup, raw_metric),
      no = id_to_no_map[short_id]
    ) %>%
    filter(!is.na(no)) %>%
    select(-raw_metric, -short_id, -label_lookup) %>%
    pivot_wider(names_from = year, values_from = value)

  # 6. Final Combine
  final_data <- bind_rows(row_1a, row_1b, row_1c, row_2a, row_2b, row_ratios) %>%
    relocate(no, `Data Quality Metrics`)

  # Dynamic Year Selection: Targets any column name that is fully numeric
  year_cols <- grep("^\\d+$", names(final_data), value = TRUE)

  mean_row <- final_data %>%
    filter(no %in% ids_to_average) %>%
    summarise(across(all_of(year_cols), ~ mean(.x, na.rm = TRUE))) %>%
    mutate(
      `Data Quality Metrics` = default_lbl$section$score,
      no = "4"
    )
  
  combined <- final_data %>%
    bind_rows(mean_row) %>%
    arrange(no)

  combined <- combined %>%
    mutate(
      type = case_when(
        startsWith(no, "1") ~ default_lbl$header$h1,
        startsWith(no, "2") ~ default_lbl$header$h2,
        startsWith(no, "3") | no == "4" ~ default_lbl$header$h3,
        TRUE ~ NA_character_
      )
    ) %>%
    select(type, everything())

  new_tibble(
    combined,
    class = "cd_overall_score",
    threshold = threshold
  )
}

#' Standardizes selecting, pivoting, and labeling
#' @noRd
process_metric_row <- function(.data, val_col, label_text, id_code) {
  .data %>%
    select(year, all_of(val_col)) %>%
    pivot_wider(names_from = year, values_from = all_of(val_col)) %>%
    mutate(
      `Data Quality Metrics` = label_text,
      no = id_code
    )
}
