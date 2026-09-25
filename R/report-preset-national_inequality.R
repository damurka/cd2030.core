# Standard report: national inequality (inst/rmd/national_inequality_rmncah_template.Rmd and its _fr_ and _pt_ versions):
# coverage by region over time, the coverage map and the survey equity charts for two indicators, then coverage by district.
# There is no vaccine template: the vaccine report uses Penta 3 and Measles 1 where the RMNCAH one uses institutional
# deliveries and Penta 3. See the standard reports section of R/report-builder.R.

.rb_preset_national_inequality <- function(group) {
  list(
    name = .rb_tx("National inequality", "In\u00e9galit\u00e9s nationales", "Desigualdade nacional"),
    description = .rb_tx("Coverage by region and district over time, coverage maps and equity by wealth and education",
                         "Couverture par r\u00e9gion et par district dans le temps, cartes de couverture et \u00e9quit\u00e9 selon la richesse et l'\u00e9ducation",
                         "Cobertura por regi\u00e3o e distrito ao longo do tempo, mapas de cobertura e equidade por riqueza e educa\u00e7\u00e3o"),
    blocks = .rb_national_inequality_blocks(group),
    cover_patch = list(
      title = .rb_tx("National inequality for {country}", "In\u00e9galit\u00e9s nationales pour {country}", "Desigualdade nacional para {country}")
    )
  )
}

.rb_national_inequality_blocks <- function(group) {
  # the two indicators
  inds <- if (identical(group, "vaccine")) c("penta3", "measles1") else c("instlivebirths", "penta3")
  palettes <- c("Blues", "Greens")
  notes_title <- .rb_tx("Notes", "Notes", "Observa\u00e7\u00f5es")
  # the heading above an indicator's charts: {chart_indicator} is the name of the chart under it
  by_admin1 <- .rb_tx("Regional coverage distribution: {chart_indicator} by admin1",
                      "R\u00e9partition r\u00e9gionale de la couverture : {chart_indicator} par admin1",
                      "Distribui\u00e7\u00e3o regional da cobertura: {chart_indicator} por admin1")
  by_district <- .rb_tx("Regional coverage distribution: {chart_indicator} by district",
                        "R\u00e9partition r\u00e9gionale de la couverture : {chart_indicator} par district",
                        "Distribui\u00e7\u00e3o regional da cobertura: {chart_indicator} por distrito")
  background <- list(
    .rb_heading(.rb_tx("Background", "Contexte", "Contexto"), 2),
    .rb_text(.rb_tx(
      paste("Monitoring the coverage of interventions is a critical and direct output of health systems. It is most useful if",
            "the national plan has meaningful targets. Both health facility and survey data need to be used."),
      paste("Surveiller la couverture des interventions est un r\u00e9sultat critique et direct des syst\u00e8mes de sant\u00e9. C'est le plus",
            "utile lorsque le plan national comporte des objectifs significatifs. Les donn\u00e9es des \u00e9tablissements de sant\u00e9 et les",
            "enqu\u00eates doivent \u00eatre utilis\u00e9es."),
      paste("Monitorar a cobertura das interven\u00e7\u00f5es \u00e9 um resultado cr\u00edtico e direto dos sistemas de sa\u00fade. \u00c9 mais \u00fatil se o",
            "plano nacional tiver metas significativas. Tanto os dados das unidades de sa\u00fade quanto os dados de pesquisas",
            "precisam ser usados.")
    ))
  )
  q_quality <- .rb_tx(
    paste("First address data quality: Are the levels and trends plausible? Is there good consistency between the facility",
          "and survey data?"),
    paste("Commencez par aborder la qualit\u00e9 des donn\u00e9es : les niveaux et les tendances sont-ils plausibles ? Y a-t-il une",
          "bonne coh\u00e9rence entre les donn\u00e9es des \u00e9tablissements et les donn\u00e9es d'enqu\u00eate ?"),
    paste("Primeiro, aborde a qualidade dos dados: os n\u00edveis e tend\u00eancias s\u00e3o plaus\u00edveis? H\u00e1 boa consist\u00eancia entre os dados",
          "das unidades de sa\u00fade e os dados das pesquisas?")
  )
  q_interpret <- .rb_tx(
    paste("Then, interpret the data if there is sufficient confidence in the observed levels and trends. The interpretation",
          "should focus on whether inequalities have reduced over time and to what extent global targets for subnational",
          "coverage have been met."),
    paste("Ensuite, interpr\u00e9tez les donn\u00e9es s'il existe une confiance suffisante dans les niveaux et les tendances observ\u00e9s.",
          "L'interpr\u00e9tation doit se concentrer sur la r\u00e9duction des in\u00e9galit\u00e9s au fil du temps et sur la mesure dans laquelle",
          "les objectifs mondiaux de couverture sous-nationale ont \u00e9t\u00e9 atteints."),
    paste("Em seguida, interprete os dados se houver confian\u00e7a suficiente nos n\u00edveis e tend\u00eancias observados. A interpreta\u00e7\u00e3o",
          "deve focar se as desigualdades foram reduzidas ao longo do tempo e em que medida as metas globais para cobertura",
          "subnacional foram atingidas.")
  )
  q_cci <- .rb_tx(
    paste("The Countdown Composite Coverage Index (CCI) is used to provide a broad overview of inequalities. The CCI combines",
          "9 indicators in the program areas of family planning, maternal and newborn care, immunization and treatment of sick",
          "children."),
    paste("Le Countdown Composite Coverage Index (CCI) est utilis\u00e9 pour offrir une vue d'ensemble des in\u00e9galit\u00e9s. Le CCI",
          "combine 9 indicateurs dans les domaines du planning familial, des soins maternels et n\u00e9onatals, de la vaccination et",
          "du traitement des enfants malades."),
    paste("O Countdown Composite Coverage Index (CCI) \u00e9 usado para fornecer uma vis\u00e3o geral das desigualdades. O CCI combina",
          "9 indicadores nas \u00e1reas de planejamento familiar, cuidados maternos e neonatais, imuniza\u00e7\u00e3o e tratamento de crian\u00e7as",
          "doentes.")
  )
  q_wealth <- .rb_tx(
    "Wealth: are the gaps between the rich and poor large, have they changed over time? What pattern of inequality (bottom, linear, top)?",
    "Richesse : les \u00e9carts entre les riches et les pauvres sont-ils importants, ont-ils \u00e9volu\u00e9 dans le temps ? Quel type d'in\u00e9galit\u00e9 (bas, lin\u00e9aire, haut) ?",
    "Renda: as lacunas entre ricos e pobres s\u00e3o grandes, elas mudaram ao longo do tempo? Qual padr\u00e3o de desigualdade (base, linear, topo)?"
  )
  q_education <- .rb_tx(
    paste("Education: are the gaps in coverage by mother's education large, have they changed over time? How should this be",
          "interpreted in relation to increasing levels of female education?"),
    paste("\u00c9ducation : les \u00e9carts de couverture selon le niveau d'\u00e9ducation de la m\u00e8re sont-ils importants, ont-ils chang\u00e9 au",
          "fil du temps ? Comment interpr\u00e9ter cela par rapport \u00e0 l'augmentation du niveau d'\u00e9ducation des femmes ?"),
    paste("Educa\u00e7\u00e3o: as lacunas na cobertura por n\u00edvel de escolaridade da m\u00e3e s\u00e3o grandes, elas mudaram ao longo do tempo?",
          "Como isso deve ser interpretado em rela\u00e7\u00e3o ao aumento dos n\u00edveis de escolaridade feminina?")
  )

  # one indicator by region: the trend by region, the map, the equity charts and the notes
  region_section <- function(i) {
    ind <- inds[[i]]
    list(
      .rb_heading(by_admin1, 2),
      .rb_chart("inequality", ind, admin_level = "adminlevel_1"),
      .rb_chart("map", ind, admin_level = NULL, variant = palettes[[i]]),
      .rb_chart("equity", ind, admin_level = NULL, size = "half", variant = "wealth"),
      .rb_chart("equity", ind, admin_level = NULL, size = "half", variant = "education"),
      .rb_questions(q_quality, q_interpret, q_cci, q_wealth, q_education, title = notes_title)
    )
  }

  c(
    list(.rb_heading(.rb_tx("Admin level 1 inequality trends", "Tendances des in\u00e9galit\u00e9s au niveau admin 1",
                            "Tend\u00eancias de desigualdade no n\u00edvel administrativo 1"))),
    background,
    region_section(1),
    list(.rb_break()),
    region_section(2),
    list(
      .rb_break(),
      .rb_heading(.rb_tx("District inequality trends", "Tendances des in\u00e9galit\u00e9s au niveau du district",
                         "Tend\u00eancias de desigualdade por distrito"))
    ),
    background,
    list(
      .rb_heading(by_district, 2),
      .rb_chart("inequality", inds[[1]], admin_level = "district"),
      .rb_heading(by_district, 2),
      .rb_chart("inequality", inds[[2]], admin_level = "district"),
      .rb_questions(q_quality, q_interpret, title = notes_title)
    )
  )
}


.rb_ni_fill <- function(text, indicator) gsub("{indicator}", indicator, text, fixed = TRUE)

# Coverage in each region (or district) by year, with the national coverage and the MADM
.rb_draw_ni_inequality <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  ind <- b$indicator %||% "instlivebirths"
  level <- if (identical(b$admin_level, "district")) "district" else "adminlevel_1"
  name <- .rb_ind_name(i18n, ind)
  plot(
    cache$get_filtered_inequality(indicator = ind, admin_level = level),
    title = name,
    subtitle = if (level == "district") t("lbl_inequ_subnat_district", "Subnational unit: district level")
               else t("lbl_inequ_subnat_admin1", "Subnational unit: admin 1 level"),
    x_axis = t("title_global_year", "Year"),
    y_axis = .rb_ni_fill(t("lbl_axis_y_coverage", "{indicator} Coverage (%)"), name),
    caption = t(paste0("plt_caption_equity_", cache$get_denominator(ind) %||% ""), NULL),
    legend_labels = list(subnational = t("lbl_inequ_coverage_subnat", "Coverage at subnational unit"),
                         national = t("title_coverage_national", "National Coverage"))
  )
}

# Coverage by region on the map, for the years picked on the mapping page (else the first and the latest)
.rb_draw_ni_map <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  ind <- b$indicator %||% "instlivebirths"
  name <- .rb_ind_name(i18n, ind)
  years <- cache$data_years
  year <- b$year %||% cache$mapping_years %||% unique(c(min(years), robust_max(years)))
  plot(
    cache$get_filtered_mapping_data(ind, "adminlevel_1", b$variant %||% "Blues", plot_year = year),
    title = .rb_ni_fill(t("plt_title_map_dist", "Distribution of {indicator} by Regions"), name),
    caption = t("plt_caption_map_dhis2", "Source: DHIS2"),
    legend = .rb_ni_fill(t("lbl_axis_y_coverage", "{indicator} Coverage (%)"), name)
  )
}

# Coverage by wealth quintile or by mother's education, from the surveys
.rb_draw_ni_equity <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  ind <- b$indicator %||% "instlivebirths"
  name <- .rb_ind_name(i18n, ind)
  axis <- .rb_ni_fill(t("lbl_axis_y_coverage", "{indicator} Coverage (%)"), name)
  if (identical(b$variant, "education")) {
    equiplot_education(
      cache$education_survey, ind,
      title = .rb_ni_fill(t("plt_title_equity_education", "Inequalities in {indicator} coverage by maternal education"), name),
      x_title = axis,
      legend_title = t("lbl_leg_equity_education", "Maternal education"),
      legend_labels = c("No education" = t("lbl_equity_edu_none", "No education"),
                        "Primary" = t("lbl_equity_edu_primary", "Primary"),
                        "Secondary or higher" = t("lbl_equity_edu_secondary", "Secondary or higher"))
    )
  } else {
    equiplot_wealth(
      cache$wiq_survey, ind,
      title = .rb_ni_fill(t("plt_title_equity_wealth", "Inequalities in {indicator} coverage by wealth quintile"), name),
      x_title = axis,
      legend_title = t("lbl_leg_equity_wealth", "Wealth quintile")
    )
  }
}
