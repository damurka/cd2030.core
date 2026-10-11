#' Calculate health system metrics
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
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' data <- load_data(path)
#'
#' national <- calculate_health_system_metrics(data, admin_level = "national")
#' national[c("year", "ratio_fac_pop", "ratio_bed_pop", "ratio_hstaff_pop", "score_total")]
#'
#' regions <- calculate_health_system_metrics(data, admin_level = "adminlevel_1")
#' regions[c("adminlevel_1", "ratio_fac_pop", "ratio_hstaff_pop", "score_total")]
#'
#' @export
calculate_health_system_metrics <- function(.data, admin_level = c("national", "adminlevel_1", "district")) {
  check_cd_data(.data)
  local_data_group(.data)
  admin_level <- arg_match(admin_level)
  admin_level_cols <- get_admin_columns(admin_level)

  last_year <- robust_max(.data$year)

  allvars <- c("total_pop", "total_nonprofit", "total_profit", "total_facilities", "total_hospitals", "total_physicians", "total_nonclinique_phys", "total_nurses", "total_beds", "opd_total", "ipd_total", "under5_pop", "opd_under5", "ipd_under5")
  mch_vars <- c('anc1', 'anc4', 'pnc48h', 'bcg', 'penta1', "penta3", 'measles1', 'measles2', 'ideliv')

  metrics <- .data %>%
    filter(year == last_year) %>%
    slice(1, .by = district) %>%
    select(adminlevel_1, district, year, -month, all_of(c(allvars, mch_vars))) %>%
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
      mch_prev_services_index = (anc1 + anc4*3 + pnc48h + bcg + (penta1 + penta3)/2 + penta3 + measles1 + measles2 + ideliv*10) / total_pop_u5,
      curative_services_index = (total_opd_u5 + total_ipd_u5 * 10)/total_pop_u5
    ) %>% 
    select(-any_of(mch_vars))

  new_tibble(
    metrics,
    class = "cd_health_system_metric",
    admin_level = admin_level
  )
}

#' Compare health system metrics across levels
#'
#' Returns a merged dataset of health coverage and system metrics at district and
#' admin level 1 for the latest year.
#'
#' @param .data A `cd_data` object containing raw health system inputs including
#'   year, population, and facility indicators.
#' @param admin1_coverage_data A coverage data frame at admin level 1 (with
#'   `year`, `adminlevel_1` and `cov_*` columns), such as the output of
#'   [calculate_indicator_coverage()] for `admin_level = "adminlevel_1"`. Its
#'   latest year defines the year kept in the result.
#' @param admin2_coverage_data A coverage data frame at district level (with
#'   `year`, `adminlevel_1`, `district` and `cov_*` columns), such as the output
#'   of [calculate_indicator_coverage()] for `admin_level = "district"`.
#'
#' @return A data frame with admin level 1 and district metrics joined side by side for
#'   comparison.
#'
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' cache <- load_cache_data(path)
#' cache$set_national_estimates(list(sbr = 0.02))
#' cache$adjust_data()
#'
#' comparison <- calculate_health_system_comparison(
#'   cache$adjusted_data,
#'   admin1_coverage_data = cache$indicator_coverage_admin1,
#'   admin2_coverage_data = cache$indicator_coverage_district
#' )
#' comparison[c("adminlevel_1", "district", "ad1_ratio_fac_pop", "dis_ratio_fac_pop")]
#'
#' @export
calculate_health_system_comparison <- function(.data, admin1_coverage_data, admin2_coverage_data) {
  check_cd_data(.data)
  local_data_group(.data)

  last_year <- robust_max(admin1_coverage_data$year)

  # nat <- calculate_indicator_coverage(.data, un_estimates = un_est) %>%
  #   select(year, matches('^cov_(anc1|sba|ideliv|csection|pnc48|penta3)_(anc1|dhis2|penta1)$')) %>%
  #   rename_with(~ paste0('nat_', .x), .cols = starts_with('cov_'))

  # instdeliveries: the chart of delivery coverage against workforce reads it (it was left out, so that chart, the
  # default one, stopped with "object 'ad1_cov_instdeliveries_...' not found")
  cov_columns <- "^cov_(anc1|sba|ideliv|instdeliveries|csection|pnc48|penta3)_(anc1|dhis2|penta1)$"

  ad1_cov <- admin1_coverage_data %>%
    select(year, adminlevel_1, matches(cov_columns)) %>%
    rename_with(~ paste0("ad1_", .x), .cols = starts_with("cov_"))

  dis_cov <- admin2_coverage_data %>%
    select(year, adminlevel_1, district, matches(cov_columns)) %>%
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

#' Generate health system metrics data
#'
#' Arranges national health system metrics as a table of eight indicators in three sections: health
#' infrastructure, health workforce and the role of the private sector. Each row has the indicator's
#' label, its value and its unit, ready for [plot.cd_health_system_table()].
#'
#' @param metric_data A `cd_health_system_metric` object for the national level, as returned by
#'   [calculate_health_system_metrics()] with `admin_level = "national"`.
#' @param labels (Optional) A nested list of localized labels for sections, indicators, and units
#'   (elements `section`, `indicator` and `unit`). English labels are used for whatever it does not set.
#'
#' @return A tibble of class `cd_health_system_table` with one row per indicator and the columns
#'   `section`, `indicator`, `value` and `unit` (`NA` where the indicator has no unit).
#'
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' data <- load_data(path)
#' metrics <- calculate_health_system_metrics(data, admin_level = "national")
#'
#' generate_health_system_table(metrics)
#'
#' # labels in another language: what is not given stays in English
#' generate_health_system_table(metrics, labels = list(section = list(workforce = "Personnel de sante")))
#'
#' @export
generate_health_system_table <- function(metric_data, labels = NULL) {
  check_cd_health_system_metric(metric_data)

  admin_level <- attr_or_abort(metric_data, 'admin_level')
  if (admin_level != 'national') {
    cd_abort(c('x' = 'The health system table is made from national metrics only.'))
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

#' Generate PHC performance scatter data
#'
#' Pairs a health system input (facility density or health workforce density) with a service
#' coverage index for each admin level 1 unit, for [plot.cd_phc_scatter()]. The service coverage
#' index is the mean of the MCH preventive services index and the curative services index.
#'
#' @param .data A `cd_health_system_metric` object, as returned by
#'   [calculate_health_system_metrics()] with `admin_level = "adminlevel_1"`.
#' @param x_indicator Independent variable ('ratio_fac_pop' or 'ratio_hstaff_pop').
#'
#' @return A tibble of class `cd_phc_scatter` with one row per admin level 1 unit and the columns
#'   `adminlevel_1`, the column named by `x_indicator`, `service_coverage` and `is_outlier` (`TRUE`
#'   when `service_coverage` is below the first quartile or above the third quartile). The
#'   attribute `indicator` holds `x_indicator`.
#'
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' data <- load_data(path)
#' metrics <- calculate_health_system_metrics(data, admin_level = "adminlevel_1")
#'
#' generate_phc_scatter_data(metrics, x_indicator = "ratio_fac_pop")
#'
#' # against the density of health workers
#' workforce <- generate_phc_scatter_data(metrics, x_indicator = "ratio_hstaff_pop")
#' plot(workforce)
#'
#' @export
generate_phc_scatter_data <- function(.data, 
                                      x_indicator = c("ratio_fac_pop", "ratio_hstaff_pop")) {
  
  check_cd_health_system_metric(.data)
  
  x_indicator <- arg_match(x_indicator)

  # 2. Pivot the data longer
  plot_data <- .data %>%
    mutate(
      service_coverage = rowMeans(select(., mch_prev_services_index, curative_services_index), na.rm = TRUE)
    ) %>%
    select(adminlevel_1, !!sym(x_indicator), service_coverage)

  # 3. Calculate outliers (Bottom 25% or Top 25%) and save as a boolean flag
  plot_data <- plot_data %>%
    # group_by(index_name) %>%
    mutate(
      is_outlier = service_coverage < quantile(service_coverage, 0.25, na.rm = TRUE) | 
                   service_coverage > quantile(service_coverage, 0.75, na.rm = TRUE)
    )

  # 4. Return as Custom S3 Class with attributes
  new_tibble(
    plot_data,
    class = "cd_phc_scatter",
    indicator = x_indicator
  )
}

#' Generate private sector ownership data
#'
#' Reshapes health system metrics into the share of health facilities that are private, NGO and
#' public in each admin level 1 unit, for [plot.cd_private_sector()]. The public share is what
#' remains after the private and NGO shares.
#'
#' @param .data Data frame containing subnational health indicators, with the columns
#'   `adminlevel_1`, `private_facility_share` and `ngo_facility_share`, such as the output of
#'   [calculate_health_system_metrics()] with `admin_level = "adminlevel_1"`.
#' @param legend_labels (Optional) A named list to override default legend labels (elements
#'   `Private`, `NGO` and `Public`).
#'
#' @return A tibble of class `cd_private_sector` with one row per admin level 1 unit and facility
#'   type, and the columns `adminlevel_1`, `facility_type` (a factor ordered private, NGO, public,
#'   with the labels as its levels) and `share` (percent). The attributes `lbl_prv`, `lbl_ngo` and
#'   `lbl_pub` hold the labels used.
#'
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' data <- load_data(path)
#' metrics <- calculate_health_system_metrics(data, admin_level = "adminlevel_1")
#'
#' generate_private_sector_data(metrics)
#'
#' # with another label in the legend
#' shares <- generate_private_sector_data(metrics, legend_labels = list(Private = "For profit"))
#' plot(shares)
#'
#' @export
generate_private_sector_data <- function(.data, legend_labels = NULL) {
  
  # 1. Setup default legend labels and apply user overrides if provided
  default_leg <- list(Private = "Private", NGO = "NGO", Public = "Public")
  
  if (!is.null(legend_labels)) {
    default_leg <- modifyList(default_leg, as.list(legend_labels))
  }
  
  lbl_prv <- default_leg$Private
  lbl_ngo <- default_leg$NGO
  lbl_pub <- default_leg$Public
  
  # 2. Prepare the data
  plot_data <- .data %>%
    mutate(Public = 100 - private_facility_share - ngo_facility_share) %>%
    select(adminlevel_1, Public, private_facility_share, ngo_facility_share) %>%
    pivot_longer(
      cols = c(private_facility_share, ngo_facility_share, Public),
      names_to = "facility_type",
      values_to = "share"
    ) %>%
    mutate(
      # Recode based on our final translated labels
      facility_type = recode(facility_type,
                             private_facility_share = lbl_prv,
                             ngo_facility_share = lbl_ngo,
                             Public = lbl_pub),
      # Lock factor levels to maintain stack order (Private bottom, NGO middle, Public top)
      facility_type = factor(facility_type, levels = c(lbl_prv, lbl_ngo, lbl_pub))
    )
  
  # 3. Return as Custom S3 Class with attributes
  new_tibble(
    plot_data,
    class = "cd_private_sector",
    lbl_prv = lbl_prv,
    lbl_ngo = lbl_ngo,
    lbl_pub = lbl_pub
  )
}
