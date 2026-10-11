#' Calculate health coverage indicators
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

                                         anc1survey = .cd_method$denominators$anc1survey,
                                         dpt1survey = .cd_method$denominators$dpt1survey,
                                         survey_year = .cd_method$denominators$survey_year,

                                         region = NULL,
                                         show_district = TRUE,
                                         sbr = .cd_method$denominators$sbr,
                                         nmr = .cd_method$denominators$nmr,
                                         pnmr = .cd_method$denominators$pnmr,
                                         twin = .cd_method$denominators$twin,
                                         preg_loss = .cd_method$denominators$preg_loss) {

  check_cd_data(.data)
  local_data_group(.data)
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

#' Get the rates the denominators use from survey data
#'
#' Takes the most recent survey value of ANC1 coverage, Penta1 coverage and the stillbirth,
#' neonatal and post-neonatal mortality rates, and converts each to a proportion. A rate the
#' survey data does not have is filled with the value given in the matching argument. The result
#' has the rates that [calculate_indicator_coverage()] takes as arguments.
#'
#' @param .data A `cd_survey_data` object with `year` and `r_*` columns (`r_anc1` and `r_penta1`
#'   in percent, and optionally `r_sbr`, `r_nmr` and `r_pnmr` per 1,000). National survey data
#'   for `admin_level = "national"`, regional survey data (with an `adminlevel_1` column)
#'   otherwise.
#' @param admin_level Character. The administrative level of the survey data: `"national"`,
#'   `"adminlevel_1"` or `"district"`.
#' @param anc1survey Numeric. ANC1 coverage (a proportion) to use where the survey has no value.
#' @param dpt1survey Numeric. Penta1 coverage (a proportion) to use where the survey has no value.
#' @param sbr Numeric. Stillbirth rate (a proportion) to use where the survey has no value.
#' @param nmr Numeric. Neonatal mortality rate (a proportion) to use where the survey has no value.
#' @param pnmr Numeric. Post-neonatal mortality rate (a proportion) to use where the survey has no
#'   value.
#' @param twin Numeric. Twin birth rate (a proportion). It is not read from the survey data, so
#'   this value is always the one returned.
#' @param preg_loss Numeric. Pregnancy loss rate (a proportion). It is not read from the survey
#'   data, so this value is always the one returned.
#' @param subnational_map Optional. A data frame mapping survey regions to `adminlevel_1` units,
#'   used for subnational levels. Default is `NULL`.
#'
#' @return A tibble with one row for national data, or one row per unit for subnational data,
#'   and the columns `pnmr`, `nmr`, `sbr`, `preg_loss`, `twin`, `anc1survey` and `dpt1survey`, all
#'   as proportions. Subnational results also have the admin column or columns.
#'
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' cache <- load_cache_data(path)
#' rates <- get_national_rates(cache$national_survey)
#' rates
#'
#' # A stillbirth rate of your own, used because the survey has none
#' get_national_rates(cache$national_survey, sbr = 0.015)$sbr
#'
#' # The rates of each survey region
#' regional <- get_national_rates(cache$regional_survey, admin_level = "adminlevel_1")
#' regional
#'
#' @export
get_national_rates <- function(.data,
                               admin_level = c("national", "adminlevel_1", "district"),
                               anc1survey = .cd_method$denominators$anc1survey,
                               dpt1survey = .cd_method$denominators$dpt1survey,
                               sbr = .cd_method$denominators$sbr,
                               nmr = .cd_method$denominators$nmr,
                               pnmr = .cd_method$denominators$pnmr,
                               twin = .cd_method$denominators$twin,
                               preg_loss = .cd_method$denominators$preg_loss,
                              subnational_map = NULL) {
  check_survey_data(.data, admin_level)
  admin_level <- arg_match(admin_level)
  admin_level_cols <- get_admin_columns(admin_level)

  .data <- .data %>% 
    join_subnational_map(admin_level, subnational_map)

  .data %>%
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

# What each coverage is a share of: `cov_<name>_<source>` is 100 * numerator / population, the population being the
# column of that kind in the source (.cd_coverage_population()). 2_denominators.do writes these once per source (UN,
# DHIS2, ANC1, Penta1) and per level; here they are written once. `all` is computed for every dataset, the others for
# their indicator group.
.cd_coverage_defs <- list(
  all = list(
    anc1 = c("anc1", "preg"),
    instlivebirths = c("instlivebirths", "lbirths"),
    # the live births in facilities over the deliveries, as in Stata (not the deliveries in facilities)
    instdeliveries = c("instlivebirths", "deliv"),
    bcg = c("bcg", "lbirths"),
    penta1 = c("penta1", "inftpenta"),
    penta3 = c("penta3", "inftpenta"),
    measles1 = c("measles1", "inftmeasles"),
    measles2 = c("measles2", "measles2")
  ),
  rmncah = list(
    anc_1trimester = c("anc_1trimester", "preg"),
    anc4 = c("anc4", "preg"),
    ipt2 = c("ipt2", "preg"),
    ipt3 = c("ipt3", "preg"),
    ifa90 = c("ifa90", "preg"),
    syphilis_test = c("syphilis_test", "preg"),
    hiv_test = c("hiv_test", "preg"),
    sba = c("sba", "lbirths"),
    low_bweight = c("low_bweight", "lbirths"),
    csection = c("csection", "deliv"),
    pnc48h = c("pnc48h", "lbirths")
  ),
  vaccine = list(
    penta2 = c("penta2", "inftpenta"),
    opv1 = c("opv1", "inftpenta"),
    opv2 = c("opv2", "inftpenta"),
    opv3 = c("opv3", "inftpenta"),
    pcv1 = c("pcv1", "inftpenta"),
    pcv2 = c("pcv2", "inftpenta"),
    pcv3 = c("pcv3", "inftpenta"),
    rota1 = c("rota1", "inftpenta"),
    rota2 = c("rota2", "inftpenta"),
    ipv1 = c("ipv1", "inftpenta"),
    ipv2 = c("ipv2", "inftpenta")
  )
)

# The column holding a kind of population in a source: tot<kind>_<source>, but the live births, which the UN and
# DHIS2 give as they are (the ANC1 and Penta1 denominators estimate them).
.cd_coverage_population <- function(kind, source) {
  if (kind == "lbirths") {
    return(switch(source, un = "un_births", dhis2 = "totlivebirths_dhis2", paste0("totlbirths_", source)))
  }
  paste0("tot", kind, "_", source)
}

# The coverage columns of one source, as expressions for mutate().
.cd_coverage_exprs <- function(source, group = get_selected_group()) {
  # the UN's and DHIS2's populations are in thousands
  population <- function(kind) {
    column <- sym(.cd_coverage_population(kind, source))
    if (source %in% c("un", "dhis2")) expr(!!column * 1000) else column
  }
  defs <- c(.cd_coverage_defs$all, .cd_coverage_defs[[group]])
  out <- lapply(defs, function(def) expr(100 * !!sym(def[1]) / !!population(def[2])))
  names(out) <- paste0("cov_", names(defs), "_", source)
  if (group == "vaccine") out <- c(out, .cd_coverage_gap_exprs(population("inftpenta"), source))
  out
}

# The vaccine group's children not reached (of the `infants` expected) and its dropouts between two doses, which are
# the same on every denominator.
.cd_coverage_gap_exprs <- function(infants, source) {
  out <- exprs(
    zerodose = 100 * (!!infants - penta1) / !!infants,
    undervax = 100 * (!!infants - penta3) / !!infants,
    dropout_penta13 = ((penta1 - penta3) / penta1) * 100,
    dropout_measles12 = ((measles1 - measles2) / measles1) * 100,
    dropout_penta3mcv1 = ((penta3 - measles1) / penta3) * 100,
    dropout_penta1mcv1 = ((penta1 - measles1) / penta1) * 100
  )
  names(out) <- paste0("cov_", names(out), "_", source)
  out
}

calculate_populations <- function(.data,
                                  admin_level = c("national", "adminlevel_1", "district"),
                                  derivation_population = c('totbirths_dhis2', 'totlivebirths_dhis2', 'totunder1_dhis2', 'totpop_dhis2',
                                                            'un_population', 'un_births', 'un_under1'),
                                  un_estimates = NULL,
                                  survey_estimates = NULL,
                                  subnational_map = NULL,

                                  anc1survey = .cd_method$denominators$anc1survey,
                                  dpt1survey = .cd_method$denominators$dpt1survey,
                                  survey_year,

                                  region = NULL,
                                  show_district = TRUE,
                                  sbr = .cd_method$denominators$sbr,
                                  nmr = .cd_method$denominators$nmr,
                                  pnmr = .cd_method$denominators$pnmr,
                                  twin = .cd_method$denominators$twin,
                                  preg_loss = .cd_method$denominators$preg_loss) {

  check_cd_data(.data)
  local_data_group(.data)

  admin_level <- arg_match(admin_level)
  derivation_population <- arg_match(derivation_population)
  if (admin_level == 'national' && !is_integerish(survey_year)) {
    cd_abort(c("x" = "{.arg survey_year} should be an integer"))
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
        totmeasles2_un = totinftpenta_un - totinftpenta_un * (2 * pnmr)
      )
  }

  # The coverage of every indicator on every denominator: defined once (.cd_coverage_defs), computed for each source.
  group <- get_selected_group()
  for (source in c(if (admin_level == "national") "un", "dhis2", "anc1", "penta1")) {
    output_data <- mutate(output_data, !!!.cd_coverage_exprs(source, group))
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

  if (group == "vaccine") {
    for (source in c("penta1derived", "anc1derived")) {
      output_data <- mutate(output_data, !!!.cd_coverage_gap_exprs(sym(paste0("totinftpenta_", source)), source))
    }
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
