# Standard report: curative health services for children under five (inst/rmd/service_utilization_rmncah_template.Rmd
# and its _fr_ and _pt_ versions), RMNCAH only. See the standard reports section of R/report-builder.R for how these
# files are written.

.rb_preset_service_utilization <- function(group) {
  list(
    name = .rb_tx("Curative health services", "Services de sant\u00e9 curatifs", "Servi\u00e7os de sa\u00fade curativos"),
    description = .rb_tx("Outpatient visits, admissions and case fatality among children under five, and the preventive vs curative index",
                         "Consultations externes, admissions et l\u00e9talit\u00e9 chez les enfants de moins de 5 ans, et l\u2019indice pr\u00e9ventif vs curatif",
                         "Consultas ambulatoriais, admiss\u00f5es e letalidade entre crian\u00e7as menores de 5 anos, e o \u00edndice preventivo vs curativo"),
    blocks = .rb_service_utilization_blocks(),
    cover_patch = list(
      title = .rb_tx("Curative health services for {country}: Countdown analysis",
                     "Services de sant\u00e9 curatifs pour {country} : analyse Countdown",
                     "Servi\u00e7os de sa\u00fade curativos para {country}: an\u00e1lise Countdown")
    )
  )
}

# The template's service utilization data quality table and its regional maps, which no core kind draws
.rb_kinds_service_utilization <- function() list(
  su_dqa = .rb_kind("table", "utilization", "Service utilization data quality", groups = "rmncah"),
  su_map = .rb_kind("chart", "utilization", "Service utilization map by region", variants = c(opd = "Outpatient (OPD)", ipd = "Inpatient (IPD)"), tall = TRUE,
                    year = TRUE, groups = "rmncah")
)

.rb_draw_su_dqa <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  labels <- list(
    header = list(
      h1 = t("title_score_monthly_complete", "1. Completeness of monthly facility reporting (mean of ANC, delivery, immunization)"),
      h2 = t("title_score_extreme_outliers", "2. Extreme outliers (mean of ANC, delivery, immunization)"),
      h3 = t("title_score_service_dqa", "3. Service DQA indicators")
    ),
    indicator = list(
      opd_rr = t("lbl_opd_rr", "% expected monthly facility reports (National)"),
      district_opd_rr = paste0(t("lbl_score_1b_prefix", "% of districts with completeness of facility reporting >= "), cache$performance_threshold),
      mis_opd_under5 = t("lbl_mis_opd_under5", "% non-missing OPD monthly values"),
      mis_ipd_under5 = t("lbl_mis_ipd_under5", "% non-missing IPD monthly values"),
      districts_no_missing_opd = t("lbl_districts_no_missing_opd", "% districts with no missing OPD values"),
      districts_no_missing_ipd = t("lbl_districts_no_missing_ipd", "% districts with no missing IPD values"),
      opd_under5_outlier5std = t("lbl_opd_under5_outlier5std", "% OPD monthly values not extreme outliers"),
      district_no_outlier_opd = t("lbl_district_no_outlier_opd", "% districts with no OPD extreme outliers"),
      ratio_opd_u5_ipd_u5 = t("lbl_ratio_opd_u5_ipd_u5", "Ratio OPD/IPD under 5"),
      perc_opd_under5 = t("lbl_perc_opd_under5", "% OPD under 5"),
      perc_ipd_under5 = t("lbl_perc_ipd_under5", "% IPD under 5")
    )
  )
  ft <- plot(cache$calculate_service_dqa_summary("national", labels = labels), years = cache$data_years,
             title = t("lbl_score_metric_header", "Data Quality Metrics"), width = report_block_size(list(size = "full"))[1])
  # the section rows' text sits in the narrow first column: let it span the row
  rows <- which(!is.na(ft$body$dataset$header))
  for (i in rows) ft <- flextable::merge_at(ft, i = i, j = seq_len(flextable::ncol_keys(ft)), part = "body")
  ft
}

.rb_draw_su_map <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  years <- cache$data_years
  year <- b$year %||% unique(c(min(years), max(years)))
  v <- b$variant %||% "opd"
  labels <- if (identical(v, "ipd")) {
    list(title = t("plt_su_map_title_ipd", "IPD under-five by Region"),
         legend = t("plt_su_map_legend_ipd", "Mean IPD per 100 children per year"))
  } else {
    list(title = t("plt_su_map_title_opd", "OPD under-five by Region"),
         legend = t("plt_su_map_legend_opd", "Mean OPD per child per year"))
  }
  plot(cache$prepare_mapping_service_utlization(v, year), labels = labels)
}

.rb_service_utilization_blocks <- function() {
  cap <- function(en, fr, pt) .rb_text(.rb_tx(paste0("<i>", en, "</i>"), paste0("<i>", fr, "</i>"), paste0("<i>", pt, "</i>")))
  notes <- .rb_tx("Notes", "Notes", "Observa\u00e7\u00f5es")
  background <- .rb_tx("Background", "Contexte", "Contexto")
  heading <- .rb_tx("Curative health services: admission and case fatality rates among children under-5",
                    "Services de sant\u00e9 curatifs : taux d'admission et de l\u00e9talit\u00e9 parmi les enfants de moins de 5 ans",
                    "Servi\u00e7os de sa\u00fade curativos: taxas de admiss\u00e3o e letalidade entre crian\u00e7as menores de 5 anos")
  background_text <- .rb_tx(
    "Data on inpatient admissions among under-fives are indicators of access to curative services. In-patient mortality (case fatality rates) is an indicator of quality of care.",
    "Les donn\u00e9es sur les admissions hospitali\u00e8res des moins de cinq ans sont des indicateurs d'acc\u00e8s aux services curatifs. La mortalit\u00e9 hospitali\u00e8re (taux de l\u00e9talit\u00e9) est un indicateur de la qualit\u00e9 des soins.",
    "Dados sobre admiss\u00f5es hospitalares de menores de cinco anos s\u00e3o indicadores de acesso a servi\u00e7os curativos. A mortalidade hospitalar (taxas de letalidade) \u00e9 um indicador da qualidade do atendimento."
  )

  list(
    .rb_heading(heading),
    .rb_heading(background, 2),
    .rb_text(background_text),
    .rb_heading(.rb_tx("Service Utilization DQA", "DQA d'utilisation des services", "DQA de Utiliza\u00e7\u00e3o de Servi\u00e7os"), 2),
    .rb_table("su_dqa"),
    .rb_chart("service_utilization", admin_level = NULL, variant = "opd"),
    cap("Figure 6a: OPD service use by children and all ages, national",
        "Figure 6a : Utilisation des consultations externes par les enfants et tous \u00e2ges confondus, niveau national",
        "Figura 6a: Uso de consultas ambulatoriais por crian\u00e7as e por todas as idades, nacional"),
    .rb_chart("su_map", admin_level = NULL, variant = "opd"),
    cap("Figure 6b: Map of OPD service use by children, by region",
        "Figure 6b : Carte de l'utilisation des consultations externes par les enfants, par r\u00e9gion",
        "Figura 6b: Mapa do uso de consultas ambulatoriais por crian\u00e7as, por regi\u00e3o"),
    .rb_questions(
      .rb_tx(
        "What can be said about the data quality for OPD visits? Is there consistency of reported numbers between years? What is the % of OPD visits that are under-5 and are they within an expected range of 15-40%?",
        "Que peut-on dire de la qualit\u00e9 des donn\u00e9es pour les visites en consultation externe (OPD) ? Y a-t-il une coh\u00e9rence des nombres rapport\u00e9s d'une ann\u00e9e \u00e0 l'autre ? Quel est le % des visites en consultation externe qui concernent les moins de 5 ans et sont-elles dans la fourchette attendue de 15-40 % ?",
        "O que pode ser dito sobre a qualidade dos dados das visitas ambulatoriais (OPD)? H\u00e1 consist\u00eancia nos n\u00fameros reportados entre os anos? Qual \u00e9 a % de visitas OPD que s\u00e3o de menores de 5 anos e elas est\u00e3o dentro da faixa esperada de 15-40%?"
      ),
      .rb_tx(
        "What is the number of OPD visits per child per year during {first_year}-{latest_year}, is it increasing? Is it lower than 1 visit per year, which is considered indicative of low access? What % of OPD visits are for children under 5?",
        "Quel est le nombre de visites en consultation externe par enfant par an pendant {first_year}-{latest_year}, augmente-t-il ? Est-il inf\u00e9rieur \u00e0 1 visite par an, ce qui est consid\u00e9r\u00e9 comme indicatif d'un faible acc\u00e8s ? Quel % des visites en consultation externe concerne les enfants de moins de 5 ans ?",
        "Qual \u00e9 o n\u00famero de visitas OPD por crian\u00e7a por ano durante {first_year}-{latest_year}, est\u00e1 aumentando? \u00c9 inferior a 1 visita por ano, o que \u00e9 considerado indicativo de baixo acesso? Qual % das visitas OPD s\u00e3o para crian\u00e7as menores de 5 anos?"
      ),
      .rb_tx(
        "What can be said about the OPD visits per child per year by region/province in {latest_year}? How large is the difference between top and bottom regions?",
        "Que peut-on dire des visites en consultation externe par enfant par an selon la r\u00e9gion/province en {latest_year} ? Quelle est l'ampleur de la diff\u00e9rence entre les r\u00e9gions les plus \u00e9lev\u00e9es et les plus basses ?",
        "O que pode ser dito sobre as visitas OPD por crian\u00e7a por ano por regi\u00e3o/prov\u00edncia em {latest_year}? Qual a magnitude da diferen\u00e7a entre as regi\u00f5es com maior e menor n\u00famero?"
      ),
      title = notes
    ),
    .rb_break(),

    .rb_heading(heading),
    .rb_heading(background, 2),
    .rb_text(background_text),
    .rb_chart("service_utilization", admin_level = NULL, variant = "ipd"),
    cap("Figure 6c: Admissions per 100 children and case fatality rates per 100 admissions under-5, national",
        "Figure 6c : Admissions pour 100 enfants et taux de l\u00e9talit\u00e9 pour 100 admissions chez les moins de 5 ans, niveau national",
        "Figura 6c: Admiss\u00f5es por 100 crian\u00e7as e taxas de letalidade por 100 admiss\u00f5es de menores de 5 anos, nacional"),
    .rb_chart("su_map", admin_level = NULL, variant = "ipd"),
    cap("Figure 6d: Map of admissions per 100 children under-5, by region",
        "Figure 6d : Carte des admissions pour 100 enfants de moins de 5 ans, par r\u00e9gion",
        "Figura 6d: Mapa das admiss\u00f5es por 100 crian\u00e7as menores de 5 anos, por regi\u00e3o"),
    .rb_questions(
      .rb_tx(
        "What can be said about the data quality? Is there consistency of reported numbers of admissions / admission rates over time? Is the percent of admissions that are children under-5 plausible (within an expected range 15-40%)?",
        "Que peut-on dire de la qualit\u00e9 des donn\u00e9es ? Y a-t-il une coh\u00e9rence des nombres rapport\u00e9s d'admissions / taux d'admission au fil du temps ? Le pourcentage d'admissions qui concernent les enfants de moins de 5 ans est-il plausible (dans une fourchette attendue de 15-40 %) ?",
        "O que pode ser dito sobre a qualidade dos dados? H\u00e1 consist\u00eancia nos n\u00fameros reportados de admiss\u00f5es / taxas de admiss\u00e3o ao longo do tempo? A porcentagem de admiss\u00f5es que s\u00e3o de crian\u00e7as menores de 5 anos \u00e9 plaus\u00edvel (dentro da faixa esperada de 15-40%)?"
      ),
      .rb_tx(
        "What is the number of admissions per 100 children under 5 per year during {first_year}-{latest_year}? Trend? Is it low or high?",
        "Quel est le nombre d'admissions pour 100 enfants de moins de 5 ans par an pendant {first_year}-{latest_year} ? Tendance ? Est-il bas ou \u00e9lev\u00e9 ?",
        "Qual \u00e9 o n\u00famero de admiss\u00f5es por 100 crian\u00e7as menores de 5 anos por ano durante {first_year}-{latest_year}? Tend\u00eancia? \u00c9 baixo ou alto?"
      ),
      .rb_tx(
        "What is the case fatality rate among admissions under-5, what is the trend? What does this say about the quality of care?",
        "Quel est le taux de l\u00e9talit\u00e9 parmi les admissions de moins de 5 ans, quelle est la tendance ? Que cela indique-t-il sur la qualit\u00e9 des soins ?",
        "Qual \u00e9 a taxa de letalidade entre as admiss\u00f5es de menores de 5 anos, qual \u00e9 a tend\u00eancia? O que isso indica sobre a qualidade do atendimento?"
      ),
      .rb_tx(
        "What can be said about admissions per 100 children under-5 per year by region/province in {latest_year}?",
        "Que peut-on dire des admissions pour 100 enfants de moins de 5 ans par an selon la r\u00e9gion/province en {latest_year} ?",
        "O que pode ser dito sobre as admiss\u00f5es por 100 crian\u00e7as menores de 5 anos por ano por regi\u00e3o/prov\u00edncia em {latest_year}?"
      ),
      title = notes
    ),
    .rb_heading(.rb_tx("MCH Preventive vs Curative Index", "Indice Pr\u00e9ventif vs Curatif MCH", "\u00cdndice Preventivo vs Curativo MCH"), 2),
    .rb_chart("mch_index", admin_level = NULL)
  )
}
