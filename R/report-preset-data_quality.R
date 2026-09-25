# Standard report: health facility data quality (inst/rmd/data_quality_rmncah_template.Rmd and its _fr_ and _pt_ versions):
# the data quality score table, the district reporting rates, the consistency ratios and the consistency checks between
# pairs of indicators. There is no vaccine template: for the vaccine group the OPV1/OPV3 pair (which the vaccine score
# table and ratios carry) is added. See the standard reports section of R/report-builder.R for how these files are written.

.rb_preset_data_quality <- function(group) {
  list(
    name = .rb_tx("Data quality", "Qualit\u00e9 des donn\u00e9es", "Qualidade dos dados"),
    description = .rb_tx("Health facility data quality: quality score, reporting rates and internal consistency",
                         "Qualit\u00e9 des donn\u00e9es des \u00e9tablissements de sant\u00e9 : score de qualit\u00e9, taux de rapportage et coh\u00e9rence interne",
                         "Qualidade dos dados das instala\u00e7\u00f5es de sa\u00fade: pontua\u00e7\u00e3o de qualidade, taxas de reporte e consist\u00eancia interna"),
    blocks = .rb_data_quality_blocks(group),
    cover_patch = list(
      title = .rb_tx("Data quality for {country}: Countdown analysis",
                     "Qualit\u00e9 des donn\u00e9es pour {country} : analyse Countdown",
                     "Qualidade dos dados para {country}: an\u00e1lise Countdown")
    )
  )
}

.rb_data_quality_blocks <- function(group) {
  vaccine <- identical(group, "vaccine")
  notes <- .rb_tx("Notes", "Notes", "Observa\u00e7\u00f5es")

  consistency_q <- if (vaccine) {
    .rb_tx("Interpret the consistency of the reported data for ANC1 and penta1 at the national level; same for penta1 and penta3, and for OPV1 and OPV3.",
           "Interpr\u00e9ter la coh\u00e9rence des donn\u00e9es rapport\u00e9es pour ANC1 et penta1 au niveau national ; idem pour penta1 et penta3, et pour OPV1 et OPV3.",
           "Interprete a consist\u00eancia dos dados reportados para ANC1 e penta1 a n\u00edvel nacional; o mesmo para penta1 e penta3, e para OPV1 e OPV3.")
  } else {
    .rb_tx("Interpret the consistency of the reported data for ANC1 and penta1 at the national level; same for penta1 and penta3.",
           "Interpr\u00e9ter la coh\u00e9rence des donn\u00e9es rapport\u00e9es pour ANC1 et penta1 au niveau national ; idem pour penta1 et penta3.",
           "Interprete a consist\u00eancia dos dados reportados para ANC1 e penta1 a n\u00edvel nacional; o mesmo para penta1 e penta3.")
  }
  range_q <- if (vaccine) {
    .rb_tx("Interpret the data on the percent of districts that have ANC1 to penta1 ratios within the expected range; same for penta1 to penta3, and for OPV1 to OPV3.",
           "Interpr\u00e9ter les donn\u00e9es sur le pourcentage de districts dont les ratios ANC1/penta1 sont dans la fourchette attendue ; idem pour penta1/penta3, et pour OPV1/OPV3.",
           "Interprete os dados sobre a percentagem de distritos que t\u00eam raz\u00f5es ANC1 para penta1 dentro da faixa esperada; o mesmo para penta1 para penta3, e para OPV1 para OPV3.")
  } else {
    .rb_tx("Interpret the data on the percent of districts that have ANC1 to penta1 ratios within the expected range; same for penta1 to penta3.",
           "Interpr\u00e9ter les donn\u00e9es sur le pourcentage de districts dont les ratios ANC1/penta1 sont dans la fourchette attendue ; idem pour penta1/penta3.",
           "Interprete os dados sobre a percentagem de distritos que t\u00eam raz\u00f5es ANC1 para penta1 dentro da faixa esperada; o mesmo para penta1 para penta3.")
  }

  c(
    list(
      .rb_heading(.rb_tx("1. Health facility data quality assessment",
                         "1. \u00c9valuation de la qualit\u00e9 des donn\u00e9es des \u00e9tablissements de sant\u00e9",
                         "1. Avalia\u00e7\u00e3o da qualidade dos dados das instala\u00e7\u00f5es de sa\u00fade"), 1),
      .rb_heading(.rb_tx("Background", "Contexte", "Contexto"), 2),
      .rb_text(.rb_tx(
        paste("Routinely reported health facility data are an important data source for health indicators. The data are reported",
              "by health facilities on events such as immunizations given, or live births attended. As with any data, quality is an",
              "issue. Data are checked to consider completeness of reporting by health facilities, identify extreme outliers, and",
              "internal consistency."),
        paste("Les donn\u00e9es des \u00e9tablissements de sant\u00e9 rapport\u00e9es de fa\u00e7on routini\u00e8re sont une source de donn\u00e9es importante pour les",
              "indicateurs de sant\u00e9. Les donn\u00e9es sont rapport\u00e9es par les \u00e9tablissements de sant\u00e9 sur des \u00e9v\u00e9nements tels que les",
              "vaccinations administr\u00e9es, ou les naissances vivantes assist\u00e9es. Comme pour toutes les donn\u00e9es, la qualit\u00e9 est un enjeu.",
              "Les donn\u00e9es sont v\u00e9rifi\u00e9es afin de consid\u00e9rer la compl\u00e9tude du reporting par les \u00e9tablissements de sant\u00e9, d'identifier",
              "les valeurs extr\u00eames aberrantes, et la coh\u00e9rence interne."),
        paste("Os dados das instala\u00e7\u00f5es de sa\u00fade reportados rotineiramente s\u00e3o uma fonte importante de dados para indicadores de",
              "sa\u00fade. Os dados s\u00e3o reportados pelas instala\u00e7\u00f5es de sa\u00fade sobre eventos como imuniza\u00e7\u00f5es administradas, ou nascimentos",
              "vivos assistidos. Como em qualquer dado, a qualidade \u00e9 uma quest\u00e3o. Os dados s\u00e3o verificados para considerar a",
              "completude do reporte pelas instala\u00e7\u00f5es de sa\u00fade, identificar outliers extremos, e a consist\u00eancia interna.")
      )),
      .rb_heading(.rb_tx("Data quality summary table", "Tableau r\u00e9capitulatif de la qualit\u00e9 des donn\u00e9es",
                         "Tabela resumo da qualidade dos dados"), 2),
      .rb_table("overall_score"),
      .rb_heading(.rb_tx("District reporting rates", "Taux de reporting des districts", "Taxas de reporte dos distritos"), 2),
      .rb_chart("reporting_rate", admin_level = NULL),
      .rb_questions(
        .rb_tx("Make a statement about the data quality overall score and trend: is it good, is it going in the right direction?",
               "Faire une d\u00e9claration concernant le score global de la qualit\u00e9 des donn\u00e9es et la tendance : est-il bon, va-t-il dans la bonne direction ?",
               "Fa\u00e7a uma declara\u00e7\u00e3o sobre a pontua\u00e7\u00e3o geral da qualidade dos dados e a tend\u00eancia: est\u00e1 boa, est\u00e1 indo na dire\u00e7\u00e3o certa?"),
        .rb_tx("Interpret the completeness of reporting data: is it good, going in the right direction?",
               "Interpr\u00e9ter la compl\u00e9tude des donn\u00e9es de reporting : est-elle bonne, va-t-elle dans la bonne direction ?",
               "Interprete a completude dos dados de reporte: est\u00e1 boa, est\u00e1 indo na dire\u00e7\u00e3o certa?"),
        .rb_tx("Interpret the data on extreme outliers: is it good, are districts doing well?",
               "Interpr\u00e9ter les donn\u00e9es sur les valeurs extr\u00eames aberrantes : sont-elles bonnes, les districts se portent-ils bien ?",
               "Interprete os dados sobre outliers extremos: est\u00e1 bom, os distritos est\u00e3o indo bem?"),
        consistency_q,
        range_q,
        title = notes
      ),
      .rb_heading(if (vaccine) .rb_tx("ANC1/Penta1, Penta1/Penta3 and OPV1/OPV3 ratios", "Ratios ANC1/Penta1, Penta1/Penta3 et OPV1/OPV3",
                                      "Raz\u00f5es ANC1/Penta1, Penta1/Penta3 e OPV1/OPV3")
                  else .rb_tx("ANC1/Penta1 and Penta1/Penta3 ratios", "Ratios ANC1/Penta1 et Penta1/Penta3", "Raz\u00f5es ANC1/Penta1 e Penta1/Penta3"), 2),
      .rb_chart("dq_ratios", admin_level = NULL),
      .rb_chart("consistency", admin_level = NULL, variant = "anc1_penta1"),
      .rb_chart("consistency", admin_level = NULL, variant = "penta1_penta3")
    ),
    if (vaccine) list(.rb_chart("consistency", admin_level = NULL, variant = "opv1_opv3")),
    list(.rb_questions(consistency_q, range_q, title = notes))
  )
}

# ---- the kinds this report adds ----

.rb_kinds_data_quality <- function() list(
  dq_ratios = .rb_kind("chart", "quality", "Consistency ratios compared with expected ratios")
)

# The block's region, NULL for national
.rb_dq_region <- function(b) {
  region <- b$region
  if (is.null(region) || identical(region, "@report") || identical(region, "")) NULL else region
}

# `text` with each {name} replaced by the value given (the template's str_glue())
.rb_dq_fill <- function(text, ...) {
  values <- list(...)
  for (name in names(values)) text <- gsub(paste0("{", name, "}"), values[[name]], text, fixed = TRUE)
  text
}

# The data quality score table, with its rows translated (the template's translated_labels)
.rb_draw_dq_score <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  vaccine <- identical(get_selected_group(), "vaccine")
  region <- .rb_dq_region(b)
  labels <- list(
    header = list(
      h1 = t("title_score_monthly_complete", "1. Completeness of monthly facility reporting (mean of ANC, delivery, immunization)"),
      h2 = t("title_score_extreme_outliers", "2. Extreme outliers (mean of ANC, delivery, immunization)"),
      h3 = t("title_score_consist_annual", "3. Consistency of annual reporting")
    ),
    section = list(
      r1a = t("lbl_score_1a", "% of expected monthly facility reports (national)"),
      r1b = paste0(t("lbl_score_1b_prefix", "% of districts with completeness of facility reporting >= "), cache$performance_threshold),
      r1c = if (vaccine) t("lbl_score_1c_vaccine", "% of districts with no missing values (mean for common vaccines)")
            else t("lbl_score_1c_rmncah", "% of districts with no missing values for the 4 forms"),
      r2a = t("lbl_score_2a", "% of monthly values that are not extreme outliers (national)"),
      r2b = t("lbl_score_2b", "% of districts with no extreme outliers in the year"),
      score = t("lbl_score_annual_score", "Annual data quality score")
    ),
    metric = c(
      list(
        r_anc1_penta1 = t("lbl_consist_ratio_anc1_penta1", "Ratio anc1/penta1"),
        r_penta1_penta3 = t("lbl_consist_ratio_penta1_penta3", "Ratio penta1/penta3"),
        ok_anc1_penta1 = t("lbl_score_range_anc1_penta1", "% district with anc1/penta1 in expected ranged"),
        ok_penta1_penta3 = t("lbl_score_range_penta1_penta3", "% district with penta1/penta3 in expected ranged")
      ),
      if (vaccine) list(
        r_opv1_opv3 = t("lbl_consist_ratio_opv1_opv3", "Ratio opv1/opv3"),
        ok_opv1_opv3 = t("lbl_score_range_opv1_opv3", "% district with opv1/opv3 in expected ranged")
      )
    )
  )
  score <- if (is.null(region)) {
    cache$calculate_overall_score("national", labels = labels)
  } else {
    cache$calculate_overall_score("adminlevel_1", region = region, labels = labels)
  }
  plot(score, cache$data_years, width = 8,
       title = paste0(t("lbl_score_metric_header", "Data Quality Metrics"), if (!is.null(region)) paste0(": ", region) else ""))
}

# Percent of districts with a low reporting rate, by service and year
.rb_draw_dq_reporting_rate <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  region <- .rb_dq_region(b)
  rate <- cache$performance_threshold
  title <- .rb_dq_fill(t("plt_title_rr_national", "Percent of districts with low reporting rate (< {reporting_rate}%) by service"),
                       reporting_rate = rate)
  plot(
    cache$calculate_district_reporting_rate(region = region),
    title = paste0(title, if (!is.null(region)) paste0(": ", region) else ""),
    caption = .rb_dq_fill(t("plt_caption_rr_national", "Low reporting rate (< {reporting_rate}%)"), reporting_rate = rate),
    indicator_labels = c(anc = t("opt_anc", "ANC"), idelv = t("opt_idelv", "Delivery"), vacc = t("opt_vacc", "Vaccination"),
                         opd = t("opt_opd", "OPD"))
  )
}

# The ANC1/Penta1 and Penta1/Penta3 (and OPV1/OPV3) ratios by year, against the expected ratios
.rb_draw_dq_ratios <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  plot(
    cache$ratios_summary,
    title = t("plt_title_consist_ratios", "Ratios of the number of children vaccinated compared with expected ratios"),
    x_labels = c(anc1_penta1 = t("lbl_consist_ratio_anc1_penta1", "Ratio anc1/penta1"),
                 penta1_penta3 = t("lbl_consist_ratio_penta1_penta3", "Ratio penta1/penta3"),
                 opv1_opv3 = t("lbl_consist_ratio_opv1_opv3", "Ratio opv1/opv3"))
  )
}

# Reported numbers of two indicators by district and year (plot_comparison_anc1_penta1() and its kin)
.rb_draw_dq_consistency <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  variant <- b$variant %||% "anc1_penta1"
  if (!variant %in% c("anc1_penta1", "penta1_penta3", "opv1_opv3")) variant <- "anc1_penta1"
  pair <- strsplit(variant, "_", fixed = TRUE)[[1]]
  vacc1 <- .rb_ind_name(i18n, pair[1])
  vacc2 <- .rb_ind_name(i18n, pair[2])
  plot_comparison(
    cache$countdown_data,
    x_var = pair[1],
    y_var = pair[2],
    title = .rb_dq_fill(t("plt_title_consist_checks", "Relationship between reported numbers of {vacc1} and {vacc2} by year"),
                        vacc1 = vacc1, vacc2 = vacc2),
    x_label = vacc1,
    y_label = vacc2,
    legend = c(district = t("lbl_leg_consist_district", "District"), linear_fit = t("lbl_leg_consist_linear_fit", "Linear fit"),
               diagonale = t("lbl_leg_consist_diagonal", "Diagonal"))
  ) +
    # the legend's entries say what they are (its title would be the name of an aesthetic)
    ggplot2::labs(colour = NULL, linetype = NULL, shape = NULL)
}
