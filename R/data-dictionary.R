# The names in the package's data, defined once.
#
# The package builds its column names from a few parts -- an indicator (`penta1`), a denominator (`anc1derived`), a
# population (`totinftpenta`), a prefix (`cov_`, `r_`) -- and the same ids appear as values (the `denominator` column,
# a chart's legend). Their spelling misleads: `anc1` and `penta1` are the ANC1-derived and Penta1-derived denominators,
# while `anc1derived` and `penta1derived` are the population-growth ones. cd_dictionary() says what every part means,
# and cd_describe_columns() reads a column name with it -- so people and the AI read meanings, never spellings.
#
# The ids never change (saved datasets, reports and charts use them); only their labels and descriptions live here.

# The six denominator options (docs: Methodology > Denominators). `key` is the translation key of the label.
.cd_dict_denominators <- data.frame(
  id = c("un", "dhis2", "anc1", "penta1", "anc1derived", "penta1derived"),
  label = c("UN projections", "DHIS2 projections", "ANC1-derived", "Penta1-derived",
            "ANC1 population growth", "Penta1 population growth"),
  meaning = c(
    "The UN estimates of live births and population (UN projections). National only.",
    "The population projections in DHIS2 (live births, total population, under-1s).",
    "Derived each year from that year's reported ANC1 visits and the survey's ANC1 coverage: pregnancies = ANC1 / ANC1 survey coverage, then deliveries, births and infants from them.",
    "Derived each year from that year's reported Penta1 doses and the survey's Penta1 coverage: infants = Penta1 / Penta1 survey coverage, then births, deliveries and pregnancies from them.",
    "The ANC1-derived value of the survey year, carried to the other years with the population growth rate of the chosen population (not re-derived from each year's ANC1).",
    "The Penta1-derived value of the survey year, carried to the other years with the population growth rate of the chosen population (not re-derived from each year's Penta1)."
  ),
  levels = c("national", "national, adminlevel_1, district", "national, adminlevel_1, district",
             "national, adminlevel_1, district", "national, adminlevel_1, district", "national, adminlevel_1, district"),
  key = c("lbl_denom_un_proj", "lbl_denom_dhis2_proj", "lbl_denom_anc1_derived", "lbl_denom_penta1_derived",
          "lbl_denom_anc1_growth", "lbl_denom_penta1_growth"),
  stringsAsFactors = FALSE
)

# The indicators: their data column (a monthly count of services or events) and label. Labels are the apps' own.
.cd_dict_indicator_labels <- c(
  anc1 = "ANC 1", anc_1trimester = "ANC 1st Trimester", anc4 = "ANC 4 Visits", ipt2 = "IPT 2nd Dose",
  ipt3 = "IPT 3rd Dose", syphilis_test = "Syphilis Test", ifa90 = "IFA 90+ Days", hiv_test = "HIV Test",
  sba = "Skilled Birth Attendance", ideliv = "Institutional Deliveries", instlivebirths = "Institutional Live Births",
  csection = "Caesarean Sections", low_bweight = "Low Birth Weight", pnc48h = "PNC within 48 hours",
  total_stillbirth = "Total Stillbirths", stillbirth_f = "Fresh Stillbirths", stillbirth_m = "Macerated Stillbirths",
  maternal_deaths = "Maternal Deaths", neonatal_deaths = "Neonatal Deaths",
  penta1 = "Pentavalent 1", penta2 = "Pentavalent 2", penta3 = "Pentavalent 3", measles1 = "Measles 1",
  measles2 = "Measles 2", measles3 = "MCV 3", bcg = "BCG", ipv1 = "IPV 1", ipv2 = "IPV 2", opv1 = "OPV 1",
  opv2 = "OPV 2", opv3 = "OPV 3", pcv1 = "PCV 1", pcv2 = "PCV 2", pcv3 = "PCV 3", rota1 = "Rotavirus 1",
  rota2 = "Rotavirus 2", opd_total = "OPD Total (Outpatient)", opd_under5 = "OPD Under 5 Years",
  ipd_total = "IPD Total (Inpatient)", ipd_under5 = "IPD Under 5 Years",
  # computed from the counts, not reported
  zerodose = "Zero-dose", undervax = "Under-vaccinated", dropout_penta13 = "Penta 1 to Penta 3 Dropout",
  dropout_penta1mcv1 = "Penta 1 to Measles 1 Dropout", dropout_penta3mcv1 = "Penta 3 to Measles 1 Dropout",
  dropout_measles12 = "Measles 1 to Measles 2 Dropout",
  # a coverage name for ideliv's coverage (cov_instdeliveries_*)
  instdeliveries = "Institutional Deliveries"
)
.cd_dict_computed <- c("zerodose", "undervax", "dropout_penta13", "dropout_penta1mcv1", "dropout_penta3mcv1",
                       "dropout_measles12")

# The target populations the denominators estimate, in thousands (coverage = 100 * count / (population * 1000)).
.cd_dict_populations <- data.frame(
  id = c("totpreg", "totdeliv", "totbirths", "totlbirths", "totlivebirths", "totinftpenta", "totinftmeasles",
         "totmeasles2", "totpop", "totunder1"),
  label = c("Pregnancies", "Deliveries", "Total births", "Live births", "Live births", "Infants eligible for Penta",
            "Infants eligible for Measles 1", "Children eligible for Measles 2", "Total population",
            "Children under 1"),
  meaning = c(
    "Expected pregnancies: the denominator of the antenatal care indicators.",
    "Expected deliveries: the denominator of institutional deliveries and caesarean sections.",
    "Expected births, live and stillborn (DHIS2 denominator of BCG, live births, low birth weight, PNC).",
    "Expected live births (ANC1- and Penta1-derived denominator of BCG, live births, low birth weight, PNC).",
    "Live births in the DHIS2 projections (the base of the DHIS2 denominators).",
    "Infants surviving the neonatal period: the denominator of Penta, PCV, rotavirus, IPV, OPV, zero-dose, under-vaccinated and the Penta dropouts.",
    "Infants surviving to the age of Measles 1: the denominator of Measles 1 and its dropouts.",
    "Children surviving to the age of Measles 2: the denominator of Measles 2.",
    "Total population in the DHIS2 projections.",
    "Children under 1 in the DHIS2 projections."
  ),
  unit = "thousands",
  stringsAsFactors = FALSE
)

# Reporting-rate columns: `<service group>_rr`, percent of expected reports received.
.cd_dict_rr_groups <- c(anc = "antenatal care", idelv = "institutional deliveries", vacc = "vaccination",
                        opd = "outpatient", ipd = "inpatient", mean = "all services (mean)")

# Columns with fixed names.
.cd_dict_fixed <- c(
  country = "The country.",
  iso3 = "The country's ISO3 code.",
  adminlevel_1 = "The first administrative level (region, province).",
  district = "The district.",
  year = "The year.",
  month = "The month.",
  denominator = paste0("A denominator option id: un = UN projections, dhis2 = DHIS2 projections, anc1 = ANC1-derived, ",
                       "penta1 = Penta1-derived, anc1derived = ANC1 population growth, penta1derived = Penta1 population growth."),
  indicator = "An indicator id (see the indicators).",
  un_births = "Live births in the UN projections (thousands).",
  un_population = "Total population in the UN projections (thousands).",
  un_under1 = "Children under 1 in the UN projections (thousands).",
  un_popgrowth = "Annual population growth rate in the UN projections.",
  population_growth_change = "Population change from the survey year to this year (percent, annualised log2), used to carry the population-growth denominators.",
  population_proportion = "This unit's share of the national population in the survey year."
)

# How the parts combine.
.cd_dict_grammar <- data.frame(
  pattern = c("<indicator>", "cov_<indicator>_<denominator>", "<population>_<denominator>",
              "<population>_<denominator>derived", "r_<indicator>", "ul_<indicator>", "ll_<indicator>",
              "<group>_rr", "nat_<name>", "admin1_<name>", "<name>_survey"),
  meaning = c(
    "The number of services or events reported for the indicator (a count).",
    "Coverage of the indicator (%) with that denominator option.",
    "The target population (thousands) as estimated by that denominator option.",
    "The same population carried from the survey year with population growth (the population-growth options).",
    "The indicator's coverage in the survey (%).",
    "The upper bound of the survey estimate's confidence interval (%).",
    "The lower bound of the survey estimate's confidence interval (%).",
    "Reporting rate of that service group (% of expected reports received).",
    "The national value of <name> (intermediate).",
    "The first-administrative-level value of <name> (intermediate).",
    "<name> in the survey year."
  ),
  example = c("penta1", "cov_penta3_penta1derived", "totinftpenta_penta1", "totinftpenta_penta1derived",
              "r_penta1", "ul_penta1", "ll_penta1", "vacc_rr", "nat_pop", "admin1_pop", "penta1_survey"),
  stringsAsFactors = FALSE
)

#' The data dictionary: what the ids and column names in the package's data mean
#'
#' The package names its data from a few parts: an indicator (`penta1`), a denominator option (`anc1derived`), a
#' target population (`totinftpenta`) and prefixes such as `cov_` (coverage) or `r_` (survey estimate). This is what
#' each part means, and how they combine. Read meanings from here, not from the spelling: `anc1` and `penta1` are the
#' **ANC1-derived** and **Penta1-derived** denominators, while `anc1derived` and `penta1derived` are the **population
#' growth** ones.
#'
#' @return A list of data frames: `denominators` (id, label, meaning, levels, key -- the label's translation key),
#'   `indicators` (id, label, group, computed), `populations` (id, label, meaning, unit), `reporting_rates` (id,
#'   meaning), `columns` (fixed column names: id, meaning) and `grammar` (pattern, meaning, example).
#' @seealso [cd_describe_columns()] to read column names with it.
#' @examples
#' cd_dictionary()$denominators[, c("id", "label")]
#' @export
cd_dictionary <- function() {
  groups <- .get_all_groups()
  group_of <- vapply(names(.cd_dict_indicator_labels), function(id) {
    hit <- character()
    for (g in names(groups)) for (cat in names(groups[[g]])) if (id %in% groups[[g]][[cat]]) hit <- c(hit, cat)
    if (length(hit)) paste(unique(hit), collapse = ", ") else if (id %in% .cd_dict_computed) "vacc" else NA_character_
  }, character(1))
  list(
    denominators = .cd_dict_denominators,
    indicators = data.frame(id = names(.cd_dict_indicator_labels), label = unname(.cd_dict_indicator_labels),
                            group = unname(group_of), computed = names(.cd_dict_indicator_labels) %in% .cd_dict_computed,
                            stringsAsFactors = FALSE),
    populations = .cd_dict_populations,
    reporting_rates = data.frame(id = paste0(names(.cd_dict_rr_groups), "_rr"),
                                 meaning = paste0("Reporting rate, ", unname(.cd_dict_rr_groups), " (% of expected reports received)."),
                                 stringsAsFactors = FALSE),
    columns = data.frame(id = names(.cd_dict_fixed), meaning = unname(.cd_dict_fixed), stringsAsFactors = FALSE),
    grammar = .cd_dict_grammar
  )
}

#' The denominator options' labels
#'
#' @param i18n Optional translator (`i18n$t(key)`); without it, the English labels.
#' @param ids Which denominators, in this order. Default: all six.
#' @return A named character vector, id -> label.
#' @examples
#' cd_denominator_labels()
#' @export
cd_denominator_labels <- function(i18n = NULL, ids = .cd_dict_denominators$id) {
  d <- .cd_dict_denominators[match(ids, .cd_dict_denominators$id), ]
  labels <- if (is.null(i18n)) d$label else vapply(seq_len(nrow(d)), function(i) {
    out <- tryCatch(i18n$t(d$key[i]), error = function(e) NULL)
    if (is.character(out) && length(out) == 1 && nzchar(out) && !identical(out, d$key[i])) out else d$label[i]
  }, character(1))
  stats::setNames(labels, ids)
}

#' Read column names with the data dictionary
#'
#' Splits each name into its parts ([cd_dictionary()]) and says in plain words what the column holds -- e.g.
#' `cov_penta3_penta1derived`: "Coverage of Pentavalent 3 (%), denominator: Penta1 population growth". A name it
#' cannot read gets type `"unknown"` and no description: it never guesses.
#'
#' @param names Column names.
#' @return A data frame, one row per name: `column`, `type` (count, coverage, population, population_growth,
#'   survey, survey_upper, survey_lower, reporting_rate, fixed, unknown), `indicator`, `denominator`,
#'   `population` (the parts' ids, or `NA`) and `description`.
#' @examples
#' cd_describe_columns(c("cov_penta3_penta1derived", "totinftpenta_anc1", "r_penta1",
#'                       "vacc_rr", "year", "xyz"))
#' @export
cd_describe_columns <- function(names) {
  rows <- lapply(as.character(names), .cd_describe_column)
  data.frame(
    column = as.character(names),
    type = vapply(rows, `[[`, character(1), "type"),
    indicator = vapply(rows, `[[`, character(1), "indicator"),
    denominator = vapply(rows, `[[`, character(1), "denominator"),
    population = vapply(rows, `[[`, character(1), "population"),
    description = vapply(rows, `[[`, character(1), "description"),
    stringsAsFactors = FALSE
  )
}

.cd_describe_column <- function(name, depth = 0) {
  out <- function(type, description = NA_character_, indicator = NA_character_, denominator = NA_character_,
                  population = NA_character_) {
    list(type = type, indicator = indicator, denominator = denominator, population = population, description = description)
  }
  unknown <- out("unknown")
  if (is.na(name) || !nzchar(name)) return(unknown)
  ind_label <- function(id) unname(.cd_dict_indicator_labels[id])
  den <- .cd_dict_denominators
  den_label <- function(id) den$label[match(id, den$id)]
  # longest ids first, so anc1derived is never read as anc1 + "derived"
  den_alt <- paste(den$id[order(-nchar(den$id))], collapse = "|")
  ind_ids <- names(.cd_dict_indicator_labels)
  ind_alt <- paste(ind_ids[order(-nchar(ind_ids))], collapse = "|")
  pops <- .cd_dict_populations
  pop_alt <- paste(pops$id[order(-nchar(pops$id))], collapse = "|")
  m <- function(pattern) regmatches(name, regexec(pattern, name))[[1]]

  if (name %in% names(.cd_dict_fixed)) return(out("fixed", unname(.cd_dict_fixed[name])))
  if (name %in% ind_ids) {
    what <- if (name %in% .cd_dict_computed) "computed from the reported counts" else "number reported"
    return(out("count", paste0(ind_label(name), " (", what, ")"), indicator = name))
  }
  p <- m(paste0("^cov_(", ind_alt, ")_(", den_alt, ")$"))
  if (length(p)) {
    return(out("coverage", paste0("Coverage of ", ind_label(p[2]), " (%), denominator: ", den_label(p[3]), " (", p[3], ")"),
               indicator = p[2], denominator = p[3]))
  }
  p <- m(paste0("^(", pop_alt, ")_(anc1|penta1)derived$"))
  if (length(p)) {
    growth <- paste0(p[3], "derived")
    return(out("population_growth", paste0(pops$label[match(p[2], pops$id)], " (thousands), ", den_label(growth),
                                           " (", growth, "): the survey year's ", den_label(p[3]),
                                           " value carried with population growth"),
               denominator = growth, population = p[2]))
  }
  p <- m(paste0("^(", pop_alt, ")_(", den_alt, ")$"))
  if (length(p)) {
    return(out("population", paste0(pops$label[match(p[2], pops$id)], " (thousands) estimated with the ",
                                    den_label(p[3]), " denominator (", p[3], ")"),
               denominator = p[3], population = p[2]))
  }
  p <- m(paste0("^(r|ul|ll)_(", ind_alt, ")$"))
  if (length(p)) {
    what <- switch(p[2], r = "Survey coverage of ", ul = "Upper bound of the survey coverage of ", ll = "Lower bound of the survey coverage of ")
    type <- switch(p[2], r = "survey", ul = "survey_upper", ll = "survey_lower")
    return(out(type, paste0(what, ind_label(p[3]), " (%)"), indicator = p[3]))
  }
  p <- m(paste0("^(", paste(names(.cd_dict_rr_groups), collapse = "|"), ")_rr$"))
  if (length(p)) {
    return(out("reporting_rate", paste0("Reporting rate, ", unname(.cd_dict_rr_groups[p[2]]), " (% of expected reports received)")))
  }
  # intermediates: nat_<x>, admin1_<x>, <x>_survey (read once more, no deeper)
  if (depth == 0) {
    p <- m("^(nat|admin1)_(.+)$")
    if (length(p)) {
      inner <- .cd_describe_column(p[3], depth + 1)
      if (!is.na(inner$description)) {
        inner$description <- paste0(if (p[2] == "nat") "National" else "First-administrative-level", " value: ", inner$description)
        return(inner)
      }
    }
    p <- m("^(.+)_survey$")
    if (length(p)) {
      inner <- .cd_describe_column(p[2], depth + 1)
      if (!is.na(inner$description)) {
        inner$description <- paste0(inner$description, ", in the survey year")
        return(inner)
      }
    }
  }
  unknown
}
