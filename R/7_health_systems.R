#' Calculate Health System Metrics
#'
#' Aggregates data at national, admin level 1, or district level and computes
#' ratios and performance scores.
#'
#' @param .data A data frame with health system indicators and population data.
#' @param admin_level One of 'national', 'adminlevel_1', or 'district'.
#'
#' @return A summarized data frame with calculated metrics: ratios (facility,
#'   beds, workforce, service use) and performance scores.
#'
#' @export
calculate_health_system_metrics <- function(.data, admin_level = c("national", "adminlevel_1", "district")) {
  check_cd_data(.data)
  admin_level <- arg_match(admin_level)
  admin_level_cols <- get_admin_columns(admin_level)

  last_year <- robust_max(.data$year)

  allvars <- c("total_pop", "total_nonprofit", "total_profit", "total_facilities", "total_hospitals", "total_physicians", "total_nonclinique_phys", "total_nurses", "total_beds", "opd_total", "ipd_total", "under5_pop", "opd_under5", "ipd_under5")

  metrics <- .data %>%
    filter(year == last_year) %>%
    slice(1, .by = district) %>%
    select(adminlevel_1, district, year, -month, all_of(c(allvars))) %>%
    mutate(
      across(
        all_of(allvars),
        ~ if_else(is.na(.x), round(robust_max(median(.x, na.rm = TRUE)), 1), .x)
      ),
      .by = adminlevel_1
    ) %>%
    rename(
      total_nursemidwife = total_nurses,
      total_opd = opd_total,
      total_ipd = ipd_total,
      total_pop_u5 = under5_pop,
      total_opd_u5 = opd_under5,
      total_ipd_u5 = ipd_under5
    ) %>%
    mutate(total_healthstaff = rowSums(select(., total_physicians, total_nonclinique_phys, total_nursemidwife), na.rm = TRUE)) %>%
    summarise(across(-any_of(c("adminlevel_1", "district", "year")), ~ sum(.x, na.rm = TRUE)), .by = all_of(c(admin_level_cols, "year"))) %>%
    mutate(
      # Ratios
      ratio_fac_pop = (total_facilities / total_pop) * 10000,
      ratio_hos_pop = (total_hospitals / total_pop) * 100000,
      ratio_hstaff_pop = (total_healthstaff / total_pop) * 10000,
      ratio_phys_pop = (total_physicians / total_pop) * 10000,
      ratio_nursemidwife_pop = (total_nursemidwife / total_pop) * 10000,
      ratio_bed_pop = (total_beds / total_pop) * 10000,

      ratio_opd_pop = total_opd / total_pop,
      ratio_ipd_pop = (total_ipd / total_pop) * 100,
      ratio_opd_u5_pop = total_opd_u5 / total_pop_u5,
      ratio_ipd_u5_pop = (total_ipd_u5 / total_pop_u5) * 100,

      perc_opd_under5 = 100 * total_opd_u5 /total_opd,
      perc_ipd_under5 = 100 * total_ipd_u5 / total_ipd,

      ratio_opd_ipd = total_opd/total_ipd,
      ratio_opd_u5_ipd_u5 = total_opd_u5/total_ipd_u5,

      skill_mix = total_nursemidwife / total_physicians,
      private_facility_share = total_profit / total_facilities*100,
      ngo_facility_share = total_nonprofit/total_facilities*100, 
      hospital_share = total_hospitals/total_facilities*100,

      # Scores
      score_infrastructure = (((ratio_fac_pop / 2) + (ratio_bed_pop / 25)) / 2) * 100,
      score_workforce = (ratio_hstaff_pop / 23) * 100,
      score_utilization = (((ratio_opd_pop / 5) + (ratio_ipd_pop / 10)) / 2) * 100,
      score_infrastructure = if_else(score_infrastructure > 100, 100, score_infrastructure),
      score_workforce = if_else(score_workforce > 100, 100, score_workforce),
      score_utilization = if_else(score_utilization > 100, 100, score_utilization),
      score_total = (score_infrastructure + score_workforce + score_utilization) / 3,
      score_total = if_else(score_total > 100, 100, score_total),
    )

  new_tibble(
    metrics,
    class = "cd_health_system_metric",
    admin_level = admin_level
  )
}

#' Compare Health System Metrics Across Levels
#'
#' Returns a merged dataset of health coverage and system metrics at district and
#' admin level 1 for the latest year.
#'
#' @param .data A data frame containing raw health system inputs including year,
#'   population, coverage, and facility indicators.
#' @param sbr Numeric. The stillbirth rate (default: 0.02).
#' @param nmr Numeric. The neonatal mortality rate (default: 0.025).
#' @param pnmr Numeric. The post-neonatal mortality rate (default: 0.024).
#' @param anc1survey Numeric. Survey-based ANC-1 coverage rate (default: 0.98).
#' @param dpt1survey Numeric. Survey-based Penta-1 coverage rate (default: 0.97).
#' @param survey_year Integer. The year of Penta-1 survey provided
#' @param twin Numeric. The twin birth rate (default: 0.015).
#' @param preg_loss Numeric. The pregnancy loss rate (default: 0.03).
#'
#' @return A data frame with admin 1 and district metrics joined side by side for
#'   comparison.
#'
#' @export
calculate_health_system_comparison <- function(.data, admin1_coverage_data, admin2_coverage_data) {
  check_cd_data(.data)

  last_year <- robust_max(admin1_coverage_data$year)

  # nat <- calculate_indicator_coverage(.data, un_estimates = un_est) %>%
  #   select(year, matches('^cov_(anc1|sba|instdeliveries|csection|pnc48|penta3)_(anc1|dhis2|penta1)$')) %>%
  #   rename_with(~ paste0('nat_', .x), .cols = starts_with('cov_'))

  ad1_cov <- admin1_coverage_data %>%
    select(year, adminlevel_1, matches("^cov_(anc1|sba|instdeliveries|csection|pnc48|penta3)_(anc1|dhis2|penta1)$")) %>%
    rename_with(~ paste0("ad1_", .x), .cols = starts_with("cov_"))

  dis_cov <- admin2_coverage_data %>%
    select(year, adminlevel_1, district, matches("^cov_(anc1|sba|instdeliveries|csection|pnc48|penta3)_(anc1|dhis2|penta1)$")) %>%
    rename_with(~ paste0("dis_", .x), .cols = starts_with("cov_"))

  ad1_metric <- calculate_health_system_metrics(.data, admin_level = "adminlevel_1") %>%
    select(year, adminlevel_1, starts_with("ratio_")) %>%
    rename_with(~ paste0("ad1_", .x), .cols = starts_with("ratio_"))

  dis_metric <- calculate_health_system_metrics(.data, admin_level = "district") %>%
    select(year, adminlevel_1, district, starts_with("ratio_")) %>%
    rename_with(~ paste0("dis_", .x), .cols = starts_with("ratio_"))

  metrics <- dis_cov %>%
    left_join(ad1_cov, join_by(adminlevel_1, year)) %>%
    # left_join(nat, join_by(year)) %>%
    left_join(ad1_metric, join_by(adminlevel_1, year)) %>%
    left_join(dis_metric, join_by(adminlevel_1, district, year)) %>%
    filter(year == last_year)

  new_tibble(
    metrics,
    class = "cd_health_system_comparison"
  )
}

#' Generate Health System Metrics Data
#'
#' @param metric_data A dataframe or list containing the yearly health system values.
#' @param labels (Optional) A nested list of localized labels for sections, indicators, and units.
#'
#' @export
generate_health_system_table <- function(metric_data, labels = NULL) {
  check_cd_class(metric_data, 'cd_health_system_metric')

  admin_level <- attr_or_abort(metric_data, 'admin_level')
  if (admin_level != 'national') {
    cd_abort(c('x' = 'Only national data can gener'))
  }
  
  # 1. Define English Defaults (Matching overall_score structure)
  default_lbl <- list(
    section = list(
      infrastructure = "Health infrastructure",
      workforce      = "Health workforce",
      private_sector = "Role of private sector"
    ),
    indicator = list(
      fac_density   = "Health facility density",
      hosp_share    = "Share of facilities that are hospitals",
      hosp_density  = "Hospital density",
      bed_density   = "Inpatient bed density",
      hwf_density   = "Health workforce density",
      skill_mix     = "Skills mix ratio nurse-midwives per physician",
      private_share = "Share of Private facilities",
      ngo_share     = "Share of NGO facilities"
    ),
    unit = list(
      per_10k  = "per 10,000",
      per_100k = "per 100,000",
      pct      = "%"
    )
  )
  
  # 2. Merge Translations (Fallback to English if missing)
  if (!is.null(labels)) {
    if (!is.null(labels$section))   default_lbl$section   <- modifyList(default_lbl$section, as.list(labels$section))
    if (!is.null(labels$indicator)) default_lbl$indicator <- modifyList(default_lbl$indicator, as.list(labels$indicator))
    if (!is.null(labels$unit))      default_lbl$unit      <- modifyList(default_lbl$unit, as.list(labels$unit))
  }
  
  # 3. Build the Tidy Tibble
  table_data <- tibble(
    section = c(
      rep(default_lbl$section$infrastructure, 4),
      rep(default_lbl$section$workforce, 2),
      rep(default_lbl$section$private_sector, 2)
    ),
    indicator = c(
      default_lbl$indicator$fac_density,
      default_lbl$indicator$hosp_share,
      default_lbl$indicator$hosp_density,
      default_lbl$indicator$bed_density,
      default_lbl$indicator$hwf_density,
      default_lbl$indicator$skill_mix,
      default_lbl$indicator$private_share,
      default_lbl$indicator$ngo_share
    ),
    value = c(
      metric_data$ratio_fac_pop,
      metric_data$hospital_share,
      metric_data$ratio_hos_pop,
      metric_data$ratio_bed_pop,
      metric_data$ratio_hstaff_pop,
      metric_data$skill_mix,
      metric_data$private_facility_share,
      metric_data$ngo_facility_share
    ),
    unit = c(
      default_lbl$unit$per_10k,
      default_lbl$unit$pct,
      default_lbl$unit$per_100k,
      default_lbl$unit$per_10k,
      default_lbl$unit$per_10k,
      NA, 
      default_lbl$unit$pct,
      default_lbl$unit$pct
    )
  )
  
  # 4. Return as S3 Class
  new_tibble(
    table_data,
    class = "cd_health_system_table"
  )
}
