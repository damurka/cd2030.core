#' Calculate Health Coverage Indicators
#'
#' `calculate_indicator_coverage` computes key health coverage indicators across
#' specified administrative levels (national, adminlevel_1, and district). The function
#' integrates data from multiple sources, including DHIS-2, UN estimates, ANC-1,
#' and Penta-1 survey data. It calculates coverage rates for a variety of vaccinations
#' and health metrics based on projected, survey-derived, and estimated denominators.
#'
#' @param .data A `cd_data` tibble containing DHIS-2, UN, ANC-1, and Penta-1 data.
#'   This dataset must include columns for key population and vaccination metrics.
#' @param admin_level Character. Specifies the administrative level for calculations.
#'   Options include:`"national", "adminlevel_1"`, and `"district"`.
#' @param derivation_population Character. The population column used as the base
#'   for the DTP1/ANC1-derived denominators (`*derived` columns). One of
#'   `"totbirths_dhis2"`, `"totlivebirths_dhis2"`, `"totunder1_dhis2"`,
#'   `"totpop_dhis2"`, `"un_population"`, `"un_births"` or `"un_under1"`.
#'   Defaults to the first.
#' @param un_estimates Optional. A tibble containing UN population estimates. Required
#'   for national-level calculations.
#' @param survey_estimates Optional. A data frame of subnational survey estimates
#'   (`r_*` columns such as `r_anc1` and `r_penta1`, and optionally mortality
#'   rates). Used for subnational levels to replace the default rates below where
#'   survey values are available. Default is `NULL`.
#' @param subnational_map Optional. A data frame mapping survey regions to
#'   `adminlevel_1` units, used when joining `survey_estimates`. Default is `NULL`.
#' @param region Optional name of an `adminlevel_1` region to restrict the
#'   calculation to. Only valid with `admin_level = "adminlevel_1"`. Default is
#'   `NULL`.
#' @param show_district Logical. When `region` is supplied, whether to return
#'   results by district within that region (`TRUE`, the default) or aggregated
#'   for the region.
#' @param sbr Numeric. The stillbirth rate. Default is `0.02`.
#' @param nmr Numeric. Neonatal mortality rate. Default is `0.025`.
#' @param pnmr Numeric. Post-neonatal mortality rate. Default is `0.024`.
#' @param anc1survey Numeric. Survey-derived coverage rate for ANC-1 (antenatal care, first visit). Default is `0.98`.
#' @param dpt1survey Numeric. Survey-derived coverage rate for Penta-1 (DPT1 vaccination). Default is `0.97`.
#' @param survey_year Interger. The year of Penta-1 survey provided
#' @param twin Numeric. Twin birth rate. Default is `0.015`.
#' @param preg_loss Numeric. Pregnancy loss rate. Default is `0.03`.
#'
#' @return A tibble of class `cd_indicator_coverage` containing calculated coverage
#'   indicators for the specified administrative level.
#'
#' @examples
#' \dontrun{
#' # Calculate coverage indicators at the national level
#' coverage_data <- calculate_indicator_coverage(
#'   .data = dhis2_data,
#'   admin_level = "national",
#'   un_estimates = un_data
#' )
#'
#' # Calculate coverage indicators at the district level
#' coverage_data <- calculate_indicator_coverage(
#'   .data = dhis2_data,
#'   admin_level = "district"
#' )
#' }
#'
#' @export
calculate_indicator_coverage <- function(.data,
                                         admin_level = c("national", "adminlevel_1", "district"),
                                         derivation_population = c('totbirths_dhis2', 'totlivebirths_dhis2', 'totunder1_dhis2', 'totpop_dhis2',
                                                                   'un_population', 'un_births', 'un_under1'),
                                        
                                         un_estimates = NULL,
                                         survey_estimates = NULL,
                                         subnational_map = NULL,

                                         anc1survey = 0.98,
                                         dpt1survey = 0.97,
                                         survey_year = 2019,

                                         region = NULL,
                                         show_district = TRUE,
                                         sbr = 0.02,
                                         nmr = 0.025,
                                         pnmr = 0.024,
                                         twin = 0.015,
                                         preg_loss = 0.03) {

  check_cd_data(.data)
  check_scalar_integerish(survey_year)
  derivation_population <- arg_match(derivation_population)
  admin_level <- arg_match(admin_level)
  country_iso <- attr_or_abort(.data, 'iso3')

  population <- calculate_populations(.data,
    admin_level = admin_level,
    derivation_population = derivation_population,
    un_estimates = un_estimates, survey_estimates = survey_estimates, 
    subnational_map = subnational_map, survey_year = survey_year,
    anc1survey = anc1survey, dpt1survey = dpt1survey,
    region = region, show_district = show_district, sbr = sbr, nmr = nmr, pnmr = pnmr,
    twin = twin, preg_loss = preg_loss
  )

  new_tibble(
    population,
    class = c("cd_indicator_coverage", "cd_population"),
    admin_level = admin_level,
    iso3 = country_iso,
    population = derivation_population,
    survey_year = survey_year,
    region = region
  )
}

#' @export
get_national_rates <- function(.data,
                               admin_level = c("national", "adminlevel_1", "district"),
                               anc1survey = 0.98,
                               dpt1survey = 0.97,
                               sbr = 0.02,
                               nmr = 0.025,
                               pnmr = 0.024,
                               twin = 0.015,
                               preg_loss = 0.03,
                              subnational_map = NULL) {
  check_survey_data(.data, admin_level)
  admin_level <- arg_match(admin_level)
  admin_level_cols <- get_admin_columns(admin_level)

  .data <- .data %>% 
    join_subnational_map(admin_level, subnational_map)

  est <- .data %>%
    # select(year, any_of(admin_level_cols), starts_with('r_')) %>%
    rename_with(~ str_remove(.x, 'r_'), starts_with('r_')) %>%
    select(year, any_of(admin_level_cols), penta1, anc1, any_of(c('pnmr', 'nmr', 'sbr'))) %>%
    # rename(dpt1survey = penta1, anc1survey = anc1) %>%
    pivot_longer(cols = -c(year, any_of(admin_level_cols))) %>%
    filter(!is.na(value)) %>%
    slice_max(year, n = 1, with_ties = F, by = c(admin_level_cols, name)) %>%
    arrange(admin_level_cols) %>%
    select(-year) %>%
    pivot_wider(names_from = name, values_from = value) %>%
    ensure_cols() %>% 
    mutate(
      pnmr = if_else(is.na(pnmr), !!pnmr, pnmr/1000),
      nmr = if_else(is.na(nmr), !!nmr, nmr/1000),
      sbr = if_else(is.na(sbr), !!sbr, sbr/1000),
      preg_loss = if_else(is.na(preg_loss), !!preg_loss, preg_loss/1000),
      anc1survey = if_else(is.na(anc1), !!anc1survey, anc1/100),
      dpt1survey = if_else(is.na(penta1), !!dpt1survey, penta1/100),
      twin = if_else(is.na(twin), !!twin, twin/1000),
    ) %>% 
    select(-anc1, -penta1)
}

ensure_cols <- function(df) {
  missing <- setdiff(c("pnmr", "nmr", "sbr", "preg_loss", "anc1", "penta1", "twin"), names(df))
  mutate(df, !!!setNames(rep(list(NA_real_), length(missing)), missing))
}

calculate_populations <- function(.data,
                                  admin_level = c("national", "adminlevel_1", "district"),
                                  derivation_population = c('totbirths_dhis2', 'totlivebirths_dhis2', 'totunder1_dhis2', 'totpop_dhis2',
                                                            'un_population', 'un_births', 'un_under1'),
                                  un_estimates = NULL,
                                  survey_estimates = NULL,
                                  subnational_map = NULL,

                                  anc1survey = 0.98,
                                  dpt1survey = 0.97,
                                  survey_year,

                                  region = NULL,
                                  show_district = TRUE,
                                  sbr = 0.02,
                                  nmr = 0.025,
                                  pnmr = 0.024,
                                  twin = 0.015,
                                  preg_loss = 0.03) {

  check_cd_data(.data)

  admin_level <- arg_match(admin_level)
  derivation_population <- arg_match(derivation_population)
  if (admin_level == 'national' && !is_integerish(survey_year)) {
    cd_abort("x" = "{.arg survey_year} should be an integer")
  }

  iso3 <- attr_or_abort(.data, 'iso3')

  national_population <- prepare_population_metrics(.data, admin_level = admin_level, un_estimates = un_estimates, region = region, show_district = show_district)
  indicator_numerator <- compute_indicator_numerator(.data, admin_level = admin_level, region = region, show_district = show_district)

  group_vars <- get_admin_columns(admin_level, region, show_district)

  output_data <- national_population %>%
    inner_join(indicator_numerator, by = c(group_vars, "year"))

  if (admin_level != 'national') {
    survey_admin_level <- if (admin_level == "district") "adminlevel_1" else admin_level
    est <- get_national_rates(survey_estimates, survey_admin_level, anc1survey, dpt1survey, sbr, nmr, pnmr, twin, preg_loss, subnational_map = subnational_map)

    join_cols <- if (admin_level == "district" || admin_level == 'adminlevel_1' && !is.null(region)) "adminlevel_1" else group_vars
    output_data <- output_data %>%
      left_join(est, by = join_cols)
  }

  output_data <- output_data %>%
    mutate(
      # DHIS2 Estimates
      totpreg_dhis2 = totlivebirths_dhis2 * (1 - 0.5 * twin) / ((1 - sbr) * (1 - preg_loss)),
      totdeliv_dhis2 = totpreg_dhis2 * (1 - preg_loss),
      totbirths_dhis2 = totlivebirths_dhis2 / (1 - sbr),
      totinftpenta_dhis2 = totlivebirths_dhis2 - totlivebirths_dhis2 * nmr,
      totinftmeasles_dhis2 = totinftpenta_dhis2 - totinftpenta_dhis2 * pnmr,
      totmeasles2_dhis2 = totinftpenta_dhis2 - totinftpenta_dhis2 * (2 * pnmr),

      # ANC1 Estimates
      totpreg_anc1 = anc1 / anc1survey,
      totdeliv_anc1 = totpreg_anc1 * (1 - preg_loss),
      totbirths_anc1 = totdeliv_anc1 / (1 - 0.5 * twin),
      totlbirths_anc1 = totbirths_anc1 * (1 - sbr),
      totinftpenta_anc1 = totlbirths_anc1 * (1 - nmr),
      totinftmeasles_anc1 = totinftpenta_anc1 * (1 - pnmr),
      totmeasles2_anc1 = totinftpenta_anc1 * (1 - (2 * pnmr)),

      # Penta1 Estimates
      totinftpenta_penta1 = penta1 / dpt1survey,
      totinftmeasles_penta1 = totinftpenta_penta1 * (1 - pnmr),
      totmeasles2_penta1 = totinftpenta_penta1 * (1 - (2 * pnmr)),
      totlbirths_penta1 = totinftpenta_penta1 / (1 - nmr),
      totbirths_penta1 = totlbirths_penta1 / (1 - sbr),
      totdeliv_penta1 = totbirths_penta1 * (1 - 0.5 * twin),
      totpreg_penta1 = totdeliv_penta1 / (1 - preg_loss),
    )

  if (admin_level == "national") {
    output_data <- output_data %>%
      mutate(
        totpreg_un = un_births * (1 - 0.5 * twin) / ((1 - sbr) * (1 - preg_loss)),
        totdeliv_un = totpreg_un * (1 - preg_loss),
        totbirths_un = un_births / (1 - sbr),
        totinftpenta_un = un_births - un_births * nmr,
        totinftmeasles_un = totinftpenta_un - totinftpenta_un * pnmr,
        totmeasles2_un = totinftpenta_un - totinftpenta_un * (2 * pnmr),

        cov_anc1_un = 100 * anc1/(totpreg_un * 1000),
        cov_instlivebirths_un = 100 * instlivebirths/(un_births * 1000),
        cov_instdeliveries_un = 100 * instlivebirths/(totdeliv_un * 1000),
        cov_bcg_un = 100 * bcg/(un_births * 1000),
        cov_penta1_un = 100 * penta1/(totinftpenta_un * 1000),
        cov_penta3_un = 100 * penta3/(totinftpenta_un * 1000),
        cov_measles1_un = 100 * measles1/(totinftmeasles_un * 1000),
        cov_measles2_un = 100 * measles2/(totinftmeasles_un * 1000)
      )

      if (get_selected_group() == 'rmncah') {
        output_data <- output_data %>%
          mutate(
            cov_anc_1trimester_un = 100 * anc_1trimester/(totpreg_un * 1000),
            cov_anc4_un = 100 * anc4/(totpreg_un * 1000),

            cov_ipt2_un = 100 * ipt2/(totpreg_un * 1000),
            cov_ipt3_un = 100 * ipt3/(totpreg_un * 1000),
            cov_ifa90_un = 100 * ifa90/(totpreg_un * 1000),
            cov_syphilis_test_un = 100 * syphilis_test/(totpreg_un * 1000),
            cov_hiv_test_un = 100 * hiv_test/(totpreg_un * 1000),

            cov_sba_un = 100 * sba/(un_births * 1000),

            cov_low_bweight_un = 100 * low_bweight/(un_births * 1000),
            cov_csection_un = 100 * csection/(totdeliv_un * 1000),
            cov_pnc48h_un = 100 * pnc48h/(un_births * 1000)
          )
      }

    if (get_selected_group() == 'vaccine') {
      output_data <- output_data %>%
        mutate(
          cov_penta2_un = 100 * penta2/(totinftpenta_un * 1000),

          cov_opv1_un = 100 * opv1/(totinftpenta_un * 1000),
          cov_opv2_un = 100 * opv2/(totinftpenta_un * 1000),
          cov_opv3_un = 100 * opv3/(totinftpenta_un * 1000),

          cov_pcv1_un = 100 * pcv1/(totinftpenta_un * 1000),
          cov_pcv2_un = 100 * pcv2/(totinftpenta_un * 1000),
          cov_pcv3_un = 100 * pcv3/(totinftpenta_un * 1000),

          cov_rota1_un = 100 * rota1/(totinftpenta_un * 1000),
          cov_rota2_un = 100 * rota2/(totinftpenta_un * 1000),

          cov_ipv1_un = 100 * ipv1/(totinftpenta_un * 1000),
          cov_ipv2_un = 100 * ipv2/(totinftpenta_un * 1000),

          cov_zerodose_un = 100 * ((totinftpenta_un * 1000 - penta1)/totinftpenta_un * 1000),
          cov_undervax_un = 100 * ((totinftpenta_un * 1000 - penta3)/totinftpenta_un * 1000),
          cov_dropout_penta13_un = ((penta1 - penta3)/penta1) * 100,
          cov_dropout_measles12_un = ((measles1 - measles2)/measles1) * 100,
          cov_dropout_penta3mcv1_un = ((penta3 - measles1)/penta3) * 100,
          cov_dropout_penta1mcv1_un = ((penta1-measles1)/penta1) * 100
        )
    }
  }

  # From DHIS2 Derived Denominators
  output_data <- output_data %>%
    # Compute coverage  based on projected lives births in DHIS-2
    mutate(
      cov_anc1_dhis2 = 100 * anc1/(totpreg_dhis2 * 1000),
      cov_instlivebirths_dhis2 = 100 * instlivebirths/(totlivebirths_dhis2 * 1000),
      cov_instdeliveries_dhis2 = 100 * instlivebirths/(totdeliv_dhis2 * 1000),
      cov_bcg_dhis2 = 100 * bcg/(totlivebirths_dhis2 * 1000),
      cov_penta1_dhis2 = 100 * penta1/(totinftpenta_dhis2 * 1000),
      cov_penta3_dhis2 = 100 * penta3/(totinftpenta_dhis2 * 1000),
      cov_measles1_dhis2 = 100 * measles1/(totinftmeasles_dhis2 * 1000),
      cov_measles2_dhis2 = 100 * measles2/(totinftmeasles_dhis2 * 1000)
    )

  if (get_selected_group() == 'rmncah') {
    output_data <- output_data %>%
      mutate(
        cov_anc_1trimester_dhis2 = 100 * anc_1trimester/(totpreg_dhis2 * 1000),
        cov_anc4_dhis2 = 100 * anc4/(totpreg_dhis2 * 1000),

        cov_ipt2_dhis2 = 100 * ipt2/(totpreg_dhis2 * 1000),
        cov_ipt3_dhis2 = 100 * ipt3/(totpreg_dhis2 * 1000),
        cov_ifa90_dhis2 = 100 * ifa90/(totpreg_dhis2 * 1000),
        cov_syphilis_test_dhis2 = 100 * syphilis_test/(totpreg_dhis2 * 1000),
        cov_hiv_test_dhis2 = 100 * hiv_test/(totpreg_dhis2 * 1000),

        cov_sba_dhis2 = 100 * sba/(totlivebirths_dhis2 * 1000),

        cov_low_bweight_dhis2 = 100 * low_bweight/(totlivebirths_dhis2 * 1000),
        cov_csection_dhis2 = 100 * csection/(totdeliv_dhis2 * 1000),
        cov_pnc48h_dhis2 = 100 * pnc48h/(totlivebirths_dhis2 * 1000)
      )
  }

  if (get_selected_group() == 'vaccine') {
    output_data <- output_data %>%
      mutate(
        cov_penta2_dhis2 = 100 * penta2/(totinftpenta_dhis2 * 1000),

        cov_opv1_dhis2 = 100 * opv1/(totinftpenta_dhis2 * 1000),
        cov_opv2_dhis2 = 100 * opv2/(totinftpenta_dhis2 * 1000),
        cov_opv3_dhis2 = 100 * opv3/(totinftpenta_dhis2 * 1000),

        cov_pcv1_dhis2 = 100 * pcv1/(totinftpenta_dhis2 * 1000),
        cov_pcv2_dhis2 = 100 * pcv2/(totinftpenta_dhis2 * 1000),
        cov_pcv3_dhis2 = 100 * pcv3/(totinftpenta_dhis2 * 1000),

        cov_rota1_dhis2 = 100 * rota1/(totinftpenta_dhis2 * 1000),
        cov_rota2_dhis2 = 100 * rota2/(totinftpenta_dhis2 * 1000),

        cov_ipv1_dhis2 = 100 * ipv1/(totinftpenta_dhis2 * 1000),
        cov_ipv2_dhis2 = 100 * ipv2/(totinftpenta_dhis2 * 1000),

        cov_zerodose_dhis2 = 100 * ((totinftpenta_dhis2 * 1000 - penta1)/totinftpenta_dhis2 * 1000),
        # generating undervax indicators
        cov_undervax_dhis2 = 100 * ((totinftpenta_dhis2 * 1000 - penta3)/totinftpenta_dhis2 * 1000),
        # generating drop-out indicators
        cov_dropout_penta13_dhis2 = ((penta1 - penta3)/penta1) * 100,
        cov_dropout_measles12_dhis2 = ((measles1 - measles2)/measles1) * 100,
        cov_dropout_penta3mcv1_dhis2 = ((penta3 - measles1)/penta3) * 100,
        cov_dropout_penta1mcv1_dhis2 = ((penta1 - measles1)/penta1) * 100
      )
  }

    # From ANC-1 Derived Denominators
  output_data <- output_data %>%
    mutate(
      cov_anc1_anc1 = 100 * anc1/totpreg_anc1,
      cov_instlivebirths_anc1 = 100 * instlivebirths/totlbirths_anc1,
      cov_instdeliveries_anc1 = 100 * instlivebirths/totdeliv_anc1,
      cov_bcg_anc1 = 100 * bcg/totlbirths_anc1,
      cov_penta1_anc1 = 100 * penta1/totinftpenta_anc1,
      cov_penta3_anc1 = 100 * penta3/totinftpenta_anc1,
      cov_measles1_anc1 = 100 * measles1/totinftmeasles_anc1,
      cov_measles2_anc1 = 100 * measles2/totinftmeasles_anc1
    )

  if (get_selected_group() == 'rmncah') {
    output_data <- output_data %>%
      mutate(
        cov_anc_1trimester_anc1 = 100 * anc_1trimester/totpreg_anc1,
        cov_anc4_anc1 = 100 * anc4/totpreg_anc1,

        cov_ipt2_anc1 = 100 * ipt2/totpreg_anc1,
        cov_ipt3_anc1 = 100 * ipt3/totpreg_anc1,
        cov_ifa90_anc1 = 100 * ifa90/totpreg_anc1,
        cov_syphilis_test_anc1 = 100 * syphilis_test/totpreg_anc1,
        cov_hiv_test_anc1 = 100 * hiv_test/totpreg_anc1,

        cov_sba_anc1 = 100 * sba/totlbirths_anc1,
        cov_low_bweight_anc1 = 100 * low_bweight/totlbirths_anc1,
        cov_csection_anc1 = 100 * csection/totdeliv_anc1,
        cov_pnc48h_anc1 = 100 * pnc48h/totlbirths_anc1,
      )
  }

  if (get_selected_group() == 'vaccine') {
    output_data <- output_data %>%
      mutate(
        cov_penta2_anc1 = 100 * penta2/totinftpenta_anc1,

        cov_opv1_anc1 = 100 * opv1/totinftpenta_anc1,
        cov_opv2_anc1 = 100 * opv2/totinftpenta_anc1,
        cov_opv3_anc1 = 100 * opv3/totinftpenta_anc1,

        cov_pcv1_anc1 = 100 * pcv1/totinftpenta_anc1,
        cov_pcv2_anc1 = 100 * pcv2/totinftpenta_anc1,
        cov_pcv3_anc1 = 100 * pcv3/totinftpenta_anc1,

        cov_rota1_anc1 = 100 * rota1/totinftpenta_anc1,
        cov_rota2_anc1 = 100 * rota2/totinftpenta_anc1,

        cov_ipv1_anc1 = 100 * ipv1/totinftpenta_anc1,
        cov_ipv2_anc1 = 100 * ipv2/totinftpenta_anc1,

        cov_zerodose_anc1 = 100 * ((totinftpenta_anc1 * 1000 - penta1)/totinftpenta_anc1 * 1000),
        # generating undervax indicators
        cov_undervax_anc1 = 100 * ((totinftpenta_anc1 * 1000 - penta3)/totinftpenta_anc1 * 1000),
        # generating drop-out indicators
        cov_dropout_penta13_anc1 = ((penta1 - penta3)/penta1) * 100,
        cov_dropout_measles12_anc1 = ((measles1 - measles2)/measles1) * 100,
        cov_dropout_penta3mcv1_anc1 = ((penta3-measles1)/penta3) * 100,
        cov_dropout_penta1mcv1_anc1 = ((penta1 - measles1)/penta1) * 100
      )
  }

    # From PENTA-1 Derived Denominators
  output_data <- output_data %>%
    mutate(
      cov_anc1_penta1 = 100 * anc1/totpreg_penta1,
      cov_instlivebirths_penta1 = 100 * instlivebirths/totlbirths_penta1,
      cov_instdeliveries_penta1 = 100 * instlivebirths/totdeliv_penta1,
      cov_bcg_penta1 = 100 * bcg/totlbirths_penta1,
      cov_penta1_penta1 = 100 * penta1/totinftpenta_penta1,
      cov_penta3_penta1 = 100 * penta3/totinftpenta_penta1,
      cov_measles1_penta1 = 100 * measles1/totinftmeasles_penta1,
      cov_measles2_penta1 = 100 * measles2/totinftmeasles_penta1
    )

  if (get_selected_group() == 'rmncah') {
    output_data <- output_data %>%
      mutate(
        cov_anc_1trimester_penta1 = 100 * anc_1trimester/totpreg_penta1,
        cov_anc4_penta1 = 100 * anc4/totpreg_penta1,

        cov_ipt2_penta1 = 100 * ipt2/totpreg_penta1,
        cov_ipt3_penta1 = 100 * ipt3/totpreg_penta1,
        cov_ifa90_penta1 = 100 * ifa90/totpreg_penta1,
        cov_syphilis_test_penta1 = 100 * syphilis_test/totpreg_penta1,
        cov_hiv_test_penta1 = 100 * hiv_test/totpreg_penta1,

        cov_sba_penta1 = 100 * sba/totlbirths_penta1,

        cov_low_bweight_penta1 = 100 * low_bweight/totlbirths_penta1,
        cov_csection_penta1 = 100 * csection/totdeliv_penta1,
        cov_pnc48h_penta1 = 100 * pnc48h/totlbirths_penta1,
      )
  }

  if (get_selected_group() == 'vaccine') {
    output_data <- output_data %>%
      mutate(
        cov_penta2_penta1 = 100 * penta2/totinftpenta_penta1,

        cov_opv1_penta1 = 100 * opv1/totinftpenta_penta1,
        cov_opv2_penta1 = 100 * opv2/totinftpenta_penta1,
        cov_opv3_penta1 = 100 * opv3/totinftpenta_penta1,

        cov_pcv1_penta1 = 100 * pcv1/totinftpenta_penta1,
        cov_pcv2_penta1 = 100 * pcv2/totinftpenta_penta1,
        cov_pcv3_penta1 = 100 * pcv3/totinftpenta_penta1,

        cov_rota1_penta1 = 100 *rota1/totinftpenta_penta1,
        cov_rota2_penta1 = 100 * rota2/totinftpenta_penta1,

        cov_ipv1_penta1 = 100 * ipv1/totinftpenta_penta1,
        cov_ipv2_penta1 = 100 * ipv2/totinftpenta_penta1,

        cov_zerodose_penta1 = 100 * ((totinftpenta_penta1 * 1000 - penta1)/totinftpenta_penta1 * 1000),
        # generating undervax indicators
        cov_undervax_penta1 = 100 * ((totinftpenta_penta1 * 1000 - penta3)/totinftpenta_penta1 * 1000),
        # generating drop-out indicators
        cov_dropout_penta13_penta1 = ((penta1 - penta3)/penta1) * 100,
        cov_dropout_measles12_penta1 = ((measles1 - measles2)/measles1) * 100,
        cov_dropout_penta3mcv1_penta1 = ((penta3 - measles1)/penta3) * 100,
        cov_dropout_penta1mcv1_penta1 = ((penta1 - measles1)/penta1) * 100
      )
  }

  # =========================================================================
  # CD2030 DTP1-DERIVED DENOMINATORS: Intelligent Envelope Fallback
  # Implements Steps 1-7 with dynamic Admin 1 vs National fallback
  # =========================================================================
  survey_year <- survey_year - 1
  survey_year <- robust_max(c(survey_year, min(output_data$year, na.rm = TRUE)), 2025)
  population_col <- sym(derivation_population)
  derivation_estimates <- c(outer(c('totinftpenta', 'totinftmeasles', 'totmeasles2', 'totlbirths', 'totbirths', 'totdeliv', 'totpreg'),
                              c('penta1', 'anc1'),
                              paste,
                              sep = '_'))

  # ---------------------------------------------------------
  # STEPS 1-3: Calculate National Envelope (The Ultimate Fallback)
  # ---------------------------------------------------------
  nat_summary <- output_data %>%
    summarise(
      across(any_of(c(derivation_population, derivation_estimates)), ~ sum(.x, na.rm = TRUE)),
      .by = year
    )

  nat_survey_df <- nat_summary %>%
    filter(year == survey_year) %>%
    select(survey_year = year, nat_survey_pop = !!population_col, any_of(derivation_estimates)) %>%
    rename_with(~ paste0(.x, '_survey'), any_of(derivation_estimates))

  nat_summary <- nat_summary %>%
    rename(nat_pop = !!population_col) %>%
    cross_join(nat_survey_df) %>%
    mutate(
      year_diff = year - survey_year,
      # nat_survey_change_diff = (nat_pop - nat_survey_pop) / nat_survey_pop * 100,
      nat_survey_change = if_else(year_diff == 0 , 0, 1/year_diff) * if_else(year_diff < 0, log2(nat_survey_pop/ nat_pop), log2(nat_pop / nat_survey_pop)) * 100,
      # across(
      #   any_of(paste0(derivation_estimates, '_survey')), 
      #   ~ .x * (1 + nat_survey_change_diff/100), 
      #   .names = 'nat_{str_remove(.col, "_survey")}derived_diff'
      # ),
      across(
        any_of(paste0(derivation_estimates, '_survey')), 
        ~ .x * (1 + nat_survey_change/100), 
        .names = 'nat_{str_remove(.col, "_survey")}derived'
      ),
    ) %>%
    select(-any_of(derivation_estimates), -ends_with('_survey'))

  # ---------------------------------------------------------
  # Process Subnational (Admin 1 & Admin 2) or National
  # ---------------------------------------------------------
  if (admin_level == 'national') {
    output_data <- output_data %>%
      left_join(nat_summary, by = "year") %>%
      select(-nat_pop) %>%
      # rename(population_growth_change_diff = nat_survey_change_diff, population_growth_change = nat_survey_change) %>%
      rename(population_growth_change = nat_survey_change) %>%
      rename_with(~ str_remove(., "^nat_"), starts_with("nat_")) %>%
      arrange(year)
  } else {
    # Calculate the Admin 1 Envelope
    admin1_summary <- output_data %>%
      summarise(
        across(any_of(c(derivation_population, derivation_estimates)), ~ sum(.x, na.rm = TRUE)),
        .by = c(year, adminlevel_1)
      )

    admin1_survey_df <- admin1_summary %>%
      filter(year == survey_year) %>%
      select(adminlevel_1, admin1_survey_pop = !!population_col, any_of(derivation_estimates)) %>%
      rename_with(~ paste0(.x, '_survey'), any_of(derivation_estimates))

    admin1_summary <- admin1_summary %>%
      rename(admin1_pop = !!population_col) %>%
      left_join(admin1_survey_df, by = "adminlevel_1") %>%
      mutate(
        year_diff = year - survey_year,
        admin1_survey_change = if_else(year_diff == 0 , 0, (1/year_diff)) * if_else(year_diff < 0, log2(admin1_survey_pop/ admin1_pop), log2(admin1_pop / admin1_survey_pop)) * 100,
        # admin1_survey_change_diff = (admin1_pop - admin1_survey_pop) / admin1_survey_pop * 100,
        # across(
        #   any_of(paste0(derivation_estimates, '_survey')), 
        #   ~ .x * (1 + admin1_survey_change_diff/100), 
        #   .names = 'admin1_{str_remove(.col, "_survey")}derived_diff'
        # )
        across(
          any_of(paste0(derivation_estimates, '_survey')), 
          ~ .x * (1 + admin1_survey_change/100), 
          .names = 'admin1_{str_remove(.col, "_survey")}derived'
        )
      ) %>%
      select(-any_of(derivation_estimates), -ends_with('_survey'), -year_diff)

    # Extract Local Subnational Survey Population (for the specific unit)
    local_survey_df <- output_data %>%
      filter(year == survey_year) %>%
      select(all_of(group_vars), local_survey_pop = !!population_col)

    # Join everything and apply fallback logic (Steps 4-7)
    output_data <- output_data %>%
      left_join(nat_summary, by = "year") %>%
      left_join(admin1_summary, by = c("year", "adminlevel_1")) %>%
      left_join(local_survey_df, by = group_vars) %>%
      group_by(across(any_of(group_vars))) %>%
      arrange(year, .by_group = TRUE) %>%
      mutate(
        # FALLBACK RULE: Does this Admin 1 have a valid baseline in the survey year?
        use_admin1 = !is.na(admin1_survey_pop) & admin1_survey_pop > 0,

        # Determine the active envelope population based on the rule
        envelope_pop = if_else(use_admin1, admin1_pop, nat_pop),

        # CD2030 Step 4 & 6: Subnational share of the chosen envelope
        population_proportion = !!population_col / envelope_pop,
      ) %>%
      ungroup() %>% 
      mutate(
        across(
          starts_with(paste0("admin1_", derivation_estimates, "derived")),
          ~ if_else(use_admin1, .x, get(sub("^admin1_", "nat_", cur_column()))) * population_proportion,
          .names = "{sub('^admin1_', '', .col)}"
        )
      ) %>%
      # rename(population_growth_change_diff = admin1_survey_change_diff, population_growth_change = admin1_survey_change) %>%
      rename(population_growth_change = admin1_survey_change)# %>%
      # select(-starts_with("nat_"), -starts_with("admin1_"), -envelope_pop, -use_admin1, -local_survey_pop)
  }

  # --------------------------------------------------------------
  # Calculate Final Coverage Percentages for Derived Denominators
  # ---------------------------------------------------------
  output_data <- output_data %>%
    mutate(
      across(any_of(get_coverage_indicators()), ~ {
        pop_col <- get_population_column(cur_column(), "anc1derived")
        den <- get(pop_col)
        ifelse(den > 0, .x / den * 100, NA_real_)
      }, .names = 'cov_{.col}_anc1derived'),
      # across(any_of(get_coverage_indicators()), ~ {
      #   pop_col <- get_population_column(cur_column(), "anc1derived_diff")
      #   den <- get(pop_col)
      #   ifelse(den > 0, .x / den * 100, NA_real_)
      # }, .names = 'cov_{.col}_anc1derived_diff'),
      across(any_of(get_coverage_indicators()), ~ {
        pop_col <- get_population_column(cur_column(), "penta1derived")
        den <- get(pop_col)
        ifelse(den > 0, .x / den * 100, NA_real_)
      }, .names = 'cov_{.col}_penta1derived'),
      # across(any_of(get_coverage_indicators()), ~ {
      #   pop_col <- get_population_column(cur_column(), "penta1derived_diff")
      #   den <- get(pop_col)
      #   ifelse(den > 0, .x / den * 100, NA_real_)
      # }, .names = 'cov_{.col}_penta1derived_diff')
    )

  if (get_selected_group() == 'vaccine') {

    output_data <- output_data %>%
      mutate(
        cov_zerodose_penta1derived = 100 * ((totinftpenta_penta1derived * 1000 - penta1)/totinftpenta_penta1derived * 1000),
        # generating undervax indicators
        cov_undervax_penta1derived = 100 * ((totinftpenta_penta1derived * 1000 - penta3)/totinftpenta_penta1derived * 1000),
        # generating drop-out indicators
        cov_dropout_penta13_penta1derived = ((penta1 - penta3)/penta1) * 100,
        cov_dropout_measles12_penta1derived = ((measles1 - measles2)/measles1) * 100,
        cov_dropout_penta3mcv1_penta1derived = ((penta3 - measles1)/penta3) * 100,
        cov_dropout_penta1mcv1_penta1derived = ((penta1 - measles1)/penta1) * 100,

        cov_zerodose_anc1derived = 100 * ((totinftpenta_anc1derived * 1000 - penta1)/totinftpenta_anc1derived * 1000),
        # generating undervax indicators
        cov_undervax_anc1derived = 100 * ((totinftpenta_anc1derived * 1000 - penta3)/totinftpenta_anc1derived * 1000),
        # generating drop-out indicators
        cov_dropout_penta13_anc1derived = ((penta1 - penta3)/penta1) * 100,
        cov_dropout_measles12_anc1derived = ((measles1 - measles2)/measles1) * 100,
        cov_dropout_penta3mcv1_anc1derived = ((penta3 - measles1)/penta3) * 100,
        cov_dropout_penta1mcv1_anc1derived = ((penta1 - measles1)/penta1) * 100
      )
  }

  new_tibble(
    output_data,
    class = "cd_population",
    admin_level = admin_level,
    population = derivation_population,
    survey_year = survey_year,
    region = region,
    iso3 = iso3
  )
}

coalesce_join <- function(x, y, by = NULL, suffix = c(".x", ".y"), join = left_join, ...) {
  joined <- join(x, y, by = by, suffix = suffix, ...)

  # Identify columns with suffixes
  x_cols_suffix <- names(joined)[str_ends(names(joined), fixed(suffix[1]))]
  y_cols_suffix <- names(joined)[str_ends(names(joined), fixed(suffix[2]))]

  # Base names (remove suffix)
  x_base <- str_remove(x_cols_suffix, fixed(suffix[1]))
  y_base <- str_remove(y_cols_suffix, fixed(suffix[2]))

  # Columns truly common to x and y
  common_cols <- intersect(x_base, y_base)

  # Build coalesced columns
  coalesced_cols <- map(common_cols, function(col) {
    coalesce(
      joined[[paste0(col, suffix[1])]],
      joined[[paste0(col, suffix[2])]]
    )
  }) %>% set_names(common_cols)

  # Build final tibble
  joined %>%
    mutate(!!!coalesced_cols) %>%
    select(
      -any_of(paste0(common_cols, suffix[1])),
      -any_of(paste0(common_cols, suffix[2]))
    )
}
