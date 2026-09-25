# Standard report: denominator selection (inst/rmd/denominator_selection_rmncah_template.Rmd and its _fr_ and _pt_
# versions): the DHIS2 population projections against the UN ones, then the denominators compared with survey coverage,
# nationally and by region. There is no vaccine template: the vaccine report compares the denominators on Penta 3 and
# Measles 1 where the RMNCAH one uses Penta 3 and institutional live births. See the standard reports section of
# R/report-builder.R.

.rb_preset_denominator_selection <- function(group) {
  list(
    name = .rb_tx("Denominator selection", "S\u00e9lection du d\u00e9nominateur", "Sele\u00e7\u00e3o do denominador"),
    description = .rb_tx("DHIS2 and UN population projections, and the denominators compared with survey coverage",
                         "Projections de population DHIS2 et ONU, et comparaison des d\u00e9nominateurs avec la couverture des enqu\u00eates",
                         "Proje\u00e7\u00f5es populacionais DHIS2 e ONU, e compara\u00e7\u00e3o dos denominadores com a cobertura dos inqu\u00e9ritos"),
    blocks = .rb_denominator_selection_blocks(group),
    cover_patch = list(
      title = .rb_tx("Denominator selection for {country}", "S\u00e9lection du d\u00e9nominateur pour {country}",
                     "Sele\u00e7\u00e3o do denominador para {country}")
    )
  )
}

.rb_denominator_selection_blocks <- function(group) {
  notes <- .rb_tx("Notes", "Notes", "Notas")
  # the two indicators the denominators are compared on (the template: Penta 3 and institutional live births)
  second <- if (identical(group, "vaccine")) "measles1" else "instlivebirths"
  # the heading above each indicator's charts: {chart_indicator} is the name of the chart under it
  ind_heading <- .rb_heading(.rb_tx("Denominator selection based on {chart_indicator} coverage",
                                    "S\u00e9lection du d\u00e9nominateur bas\u00e9e sur la couverture {chart_indicator}",
                                    "Sele\u00e7\u00e3o de denominador baseada na cobertura {chart_indicator}"), 2)
  national <- .rb_text(.rb_tx("<b>National</b>", "<b>National</b>", "<b>Nacional</b>"))
  subnational <- .rb_text(.rb_tx("<b>Sub-national</b>", "<b>Sous-national</b>", "<b>Subnacional</b>"))
  background <- .rb_heading(.rb_tx("Background", "Contexte", "Contexto"), 2)

  list(
    .rb_heading(.rb_tx(
      "Health facility data denominator assessment: DHIS2, UN population and live births projections",
      "\u00c9valuation du d\u00e9nominateur des donn\u00e9es des \u00e9tablissements de sant\u00e9 : projections DHIS2, population de l'ONU et naissances vivantes",
      "Avalia\u00e7\u00e3o do denominador de dados de instala\u00e7\u00f5es de sa\u00fade: proje\u00e7\u00f5es DHIS2, Popula\u00e7\u00e3o da ONU e nascimentos vivos"
    )),
    background,
    .rb_text(.rb_tx(
      paste("Service coverage is defined as the population who received the service divided by the population who need the",
            "services: the denominator. The quality of the population projections in DHIS2 is assessed through consistency over",
            "time and comparison with the UN projections."),
      paste("La couverture des services est d\u00e9finie comme la population ayant re\u00e7u le service divis\u00e9e par la population qui a",
            "besoin des services : le d\u00e9nominateur. La qualit\u00e9 des projections de population dans DHIS2 est \u00e9valu\u00e9e par la",
            "coh\u00e9rence dans le temps et la comparaison avec les projections de l'ONU."),
      paste("Cobertura de servi\u00e7o \u00e9 definida como a popula\u00e7\u00e3o que recebeu o servi\u00e7o dividida pela popula\u00e7\u00e3o que necessita dos",
            "servi\u00e7os: o denominador. A qualidade das proje\u00e7\u00f5es populacionais no DHIS2 \u00e9 avaliada por meio da consist\u00eancia ao",
            "longo do tempo e da compara\u00e7\u00e3o com as proje\u00e7\u00f5es da ONU.")
    )),
    .rb_heading(.rb_tx("Total population projections: DHIS2 and UN populations",
                       "Projections de la population totale : DHIS2 et populations de l'ONU",
                       "Proje\u00e7\u00f5es da Popula\u00e7\u00e3o Total: DHIS2 e Popula\u00e7\u00f5es da ONU"), 2),
    .rb_chart("denominator_trend", admin_level = NULL, variant = "population"),
    .rb_heading(.rb_tx("Live births projections: DHIS2 and UN live births",
                       "Projections des naissances vivantes : DHIS2 et naissances vivantes de l'ONU",
                       "Proje\u00e7\u00f5es de Nascimentos Vivos: DHIS2 e Nascimentos Vivos da ONU"), 2),
    .rb_chart("denominator_trend", admin_level = NULL, variant = "births"),
    .rb_heading(.rb_tx("Under 1 projections: DHIS2 and UN under 1",
                       "Projections des moins de 1 an : DHIS2 et moins de 1 an de l'ONU",
                       "Proje\u00e7\u00f5es de Menores de 1 Ano: DHIS2 e Menores de 1 Ano da ONU"), 2),
    .rb_chart("denominator_trend", admin_level = NULL, variant = "under1"),
    .rb_questions(
      .rb_tx(
        paste("The interpretation should focus on the extent to which the DHIS2 projections are considered robust, which is the",
              "case when: 1) the DHIS2 total population projection is consistent over time with regular population growth;",
              "2) the DHIS2 total live birth projection is consistent over time (regular trend); 3) the projected numbers of total",
              "population and live births are close to the UN population projection; 4) the DHIS2 population projections are",
              "consistent with UN estimates for crude birth rate and crude death rate."),
        paste("L'interpr\u00e9tation doit se concentrer sur la mesure dans laquelle les projections DHIS2 sont consid\u00e9r\u00e9es comme",
              "robustes, ce qui est le cas lorsque : 1) la projection de la population totale DHIS2 est coh\u00e9rente dans le temps",
              "avec une croissance d\u00e9mographique r\u00e9guli\u00e8re ; 2) la projection des naissances vivantes totales DHIS2 est coh\u00e9rente",
              "dans le temps (tendance r\u00e9guli\u00e8re) ; 3) les chiffres projet\u00e9s de la population totale et des naissances vivantes",
              "sont proches de la projection de population de l'ONU ; 4) les projections de population DHIS2 sont coh\u00e9rentes avec",
              "les estimations de l'ONU du taux de natalit\u00e9 brut et du taux de mortalit\u00e9 brut."),
        paste("A interpreta\u00e7\u00e3o deve focar na medida em que as proje\u00e7\u00f5es DHIS2 s\u00e3o consideradas robustas, o que ocorre quando:",
              "1) a proje\u00e7\u00e3o total da popula\u00e7\u00e3o DHIS2 \u00e9 consistente ao longo do tempo com crescimento populacional regular;",
              "2) a proje\u00e7\u00e3o total de nascimentos vivos DHIS2 \u00e9 consistente ao longo do tempo (tend\u00eancia regular); 3) os n\u00fameros",
              "projetados de popula\u00e7\u00e3o total e nascimentos vivos est\u00e3o pr\u00f3ximos da proje\u00e7\u00e3o populacional da ONU; 4) as proje\u00e7\u00f5es",
              "populacionais DHIS2 s\u00e3o consistentes com as estimativas da ONU para taxa bruta de natalidade e taxa bruta de",
              "mortalidade.")
      ),
      .rb_tx("Make your overall conclusion about the quality of the DHIS2 projection, especially live births.",
             "Formulez votre conclusion globale sur la qualit\u00e9 de la projection DHIS2, en particulier les naissances vivantes.",
             "Fa\u00e7a sua conclus\u00e3o geral sobre a qualidade da proje\u00e7\u00e3o DHIS2, especialmente em rela\u00e7\u00e3o aos nascimentos vivos."),
      title = notes
    ),
    .rb_break(),

    .rb_heading(.rb_tx("Selection of the best denominator", "S\u00e9lection du meilleur d\u00e9nominateur", "Sele\u00e7\u00e3o do melhor denominador")),
    background,
    .rb_text(.rb_tx(
      paste("The best performing denominator for coverage analysis with facility data is selected by comparing how close the",
            "different denominator methods are to survey coverage for a nearby year. This is done at the national and subnational",
            "levels (using the median difference with the survey)."),
      paste("Le meilleur d\u00e9nominateur pour l'analyse de la couverture avec les donn\u00e9es des \u00e9tablissements est s\u00e9lectionn\u00e9 en",
            "comparant la proximit\u00e9 des diff\u00e9rentes m\u00e9thodes de d\u00e9nominateur avec la couverture d'enqu\u00eate pour une ann\u00e9e proche.",
            "Cela se fait aux niveaux national et sous-national (en utilisant la diff\u00e9rence m\u00e9diane avec l'enqu\u00eate)."),
      paste("O denominador com melhor desempenho para an\u00e1lise de cobertura com dados de instala\u00e7\u00f5es \u00e9 selecionado comparando o",
            "qu\u00e3o pr\u00f3ximo os diferentes m\u00e9todos de denominador est\u00e3o da cobertura da pesquisa para um ano pr\u00f3ximo. Isso \u00e9 feito",
            "nos n\u00edveis nacional e subnacional (usando a diferen\u00e7a mediana em rela\u00e7\u00e3o \u00e0 pesquisa).")
    )),
    ind_heading,
    national,
    .rb_chart("derived_coverage", "penta3", admin_level = "national"),
    subnational,
    .rb_chart("derived_coverage", "penta3", admin_level = "adminlevel_1"),
    ind_heading,
    national,
    .rb_chart("derived_coverage", second, admin_level = "national"),
    subnational,
    .rb_chart("derived_coverage", second, admin_level = "adminlevel_1"),
    .rb_questions(
      .rb_tx("Which denominator methods performed best at the national level for the two indicators?",
             "Quelles m\u00e9thodes de d\u00e9nominateur ont donn\u00e9 les meilleurs r\u00e9sultats au niveau national pour les deux indicateurs ?",
             "Quais m\u00e9todos de denominador tiveram melhor desempenho no n\u00edvel nacional para os dois indicadores?"),
      .rb_tx("Which denominator methods performed best at the subnational level for the two indicators?",
             "Quelles m\u00e9thodes de d\u00e9nominateur ont donn\u00e9 les meilleurs r\u00e9sultats au niveau sous-national pour les deux indicateurs ?",
             "Quais m\u00e9todos de denominador tiveram melhor desempenho no n\u00edvel subnacional para os dois indicadores?"),
      .rb_tx("What selection is made for the indicators in the coverage analyses?",
             "Quelle s\u00e9lection est faite pour les indicateurs dans les analyses de couverture ?",
             "Qual sele\u00e7\u00e3o foi feita para os indicadores nas an\u00e1lises de cobertura?"),
      title = notes
    )
  )
}


# DHIS2 and UN projections of one population (the template's three denominator_metrics charts)
.rb_draw_ds_projection <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  metric <- b$variant %||% "population"
  metric <- if (metric %in% c("population", "births", "under1")) metric else "population"
  switch(
    metric,
    population = plot(cache$denominator_metrics, metric = "population",
                      title = t("plt_title_denom_pop", "Total Population (in thousands), DHIS2 and UN projections"),
                      x_label = t("title_global_year", "Year"), y_label = t("opt_population", "Population"),
                      legend_labels = c(t("lbl_leg_denom_un_pop", "UN Population (in 1000)"),
                                        t("lbl_leg_denom_dhis2_pop", "DHIS-2 Population Projection (in 1000)"))),
    births = plot(cache$denominator_metrics, metric = "births",
                  title = t("plt_title_denom_births", "Total Live Births (in thousands), DHIS2 and UN projections"),
                  x_label = t("title_global_year", "Year"), y_label = t("opt_live_births", "Live births"),
                  legend_labels = c(t("lbl_leg_denom_un_births", "UN Live Births (in 1000)"),
                                    t("lbl_leg_denom_dhis2_live_births", "DHIS-2 Live Births Projection (in 1000)"),
                                    t("lbl_leg_denom_dhis2_tot_births", "DHIS-2 Total Births Projection (in 1000)"))),
    under1 = plot(cache$denominator_metrics, metric = "under1",
                  title = t("plt_title_denom_under1", "Under 1 (in thousands), DHIS2 and UN projections"),
                  x_label = t("title_global_year", "Year"), y_label = t("opt_under1", "Under 1"),
                  legend_labels = c(t("lbl_leg_denom_un_under1", "UN Under 1 (in 1000)"),
                                    t("lbl_leg_denom_dhis2_under1", "DHIS-2 Under 1 Projection (in 1000)")))
  )
}

# Coverage of one indicator with each denominator against the survey, nationally (bars and the survey line) or by region
.rb_draw_ds_survey_comparison <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  fill <- function(text, indicator, year) gsub("{year}", year, gsub("{indicator}", indicator, text, fixed = TRUE), fixed = TRUE)
  ind <- b$indicator %||% "penta3"
  level <- if (identical(b$admin_level, "adminlevel_1")) "adminlevel_1" else "national"
  name <- .rb_ind_name(i18n, ind)
  year <- cache$survey_year %||% ""
  data <- cache$calculate_derived_coverage(ind, level)
  if (level == "national") {
    plot(data,
         title = fill(t("plt_title_denom_survey_comp",
                        "{indicator} Coverage, DHIS2-based with different denominators, and survey coverage for {year}"), name, year),
         y_label = fill(t("lbl_axis_y_coverage", "{indicator} Coverage (%)"), name, year),
         legend_labels = list(
           un = t("lbl_denom_un_proj", "UN projection"), dhis2 = t("lbl_denom_dhis2_proj", "DHIS2 projection"),
           anc1 = t("lbl_denom_anc1_derived", "ANC1-derived"), penta1 = t("lbl_denom_penta1_derived", "Penta1-derived"),
           penta1derived = t("opt_penta1derived", "Penta1 Population Growth"), anc1derived = t("opt_anc1derived", "ANC1 Population Growth"),
           facility = t("lbl_denom_facility_based", "Facility-based coverage (%)"),
           survey_national = t("lbl_denom_survey_national", "Coverage survey, national")
         ))
  } else {
    plot(data,
         title = fill(t("plt_title_cross_section_subnat",
                        "Comparison of {indicator} Coverage Estimates by Region and Denominator in {year}"), name, year),
         x_label = t("opt_coverage", "Coverage"), y_label = t("lbl_axis_y_region", "Region"),
         legend_labels = list(
           un = t("opt_un", "UN"), dhis2 = t("opt_dhis2", "DHIS2"), anc1 = t("opt_anc1", "ANC1"), penta1 = t("opt_penta1", "Penta1"),
           penta1derived = t("opt_penta1derived", "Penta1 Population Growth"), anc1derived = t("opt_anc1derived", "ANC1 Population Growth")
         ))
  }
}
