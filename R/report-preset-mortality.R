# Standard report: institutional mortality (inst/rmd/mortality_rmncah_template.Rmd and its _fr_ and _pt_ versions),
# RMNCAH only. See the standard reports section of R/report-builder.R for how these files are written.

.rb_preset_mortality <- function(group) {
  list(
    name = .rb_tx("Mortality", "Mortalit\u00e9", "Mortalidade"),
    description = .rb_tx("Institutional maternal, stillbirth and neonatal mortality, and the completeness of death reporting",
                         "Mortalit\u00e9 maternelle, mortinatalit\u00e9 et mortalit\u00e9 n\u00e9onatale en \u00e9tablissement, et compl\u00e9tude de la d\u00e9claration des d\u00e9c\u00e8s",
                         "Mortalidade materna, natimortalidade e mortalidade neonatal institucionais, e completude da notifica\u00e7\u00e3o de \u00f3bitos"),
    blocks = .rb_mortality_blocks(),
    cover_patch = list(
      title = .rb_tx("Mortality for {country}: Countdown analysis", "Mortalit\u00e9 pour {country} : analyse Countdown",
                     "Mortalidade para {country}: an\u00e1lise Countdown")
    )
  )
}

# The template draws the neonatal mortality trend, which no core kind offers
.rb_kinds_mortality <- function() list(
  mort_nn_trend = .rb_kind("chart", "mortality", "Institutional neonatal mortality trend", groups = "rmncah")
)

.rb_draw_mort_nn_trend <- function(cache, b, i18n) {
  b$variant <- "nn_inst"
  .rb_draw_mortality_trend(cache, b, i18n)
}

# The national institutional mortality trend with the regions' points (kinds mortality_trend and mort_nn_trend), in the
# report's language; the indicator is the block's variant
.rb_draw_mortality_trend <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  v <- b$variant %||% "mmr_inst"
  titles <- list(
    mmr_inst = t("plt_mort_title_mmr_inst", "Maternal mortality per 100,000 live births in health facilities"),
    ratio_md_sb = t("plt_mort_title_ratio_md_sb", "Ratio number of stillbirths to maternal deaths in health facilities"),
    sbr_inst = t("plt_mort_title_sbr_inst", "Stillbirths per 1,000 births in health facilities"),
    nn_inst = t("plt_mort_title_nn_inst", "Neonatal deaths before discharge per 1,000 live births in health facilities")
  )
  national <- list(
    mmr_inst = t("plt_mort_national_mmr_inst", "National inst. MMR"),
    ratio_md_sb = t("plt_mort_national_ratio_md_sb", "National SB/MM ratio"),
    sbr_inst = t("plt_mort_national_sbr_inst", "National inst. SBR"),
    nn_inst = t("plt_mort_national_nn_inst", "National NN")
  )
  plot(cache$mortality_summary, indicator = v,
       labels = list(title = titles[[v]], national = national[[v]], regions = t("plt_lbl_regions", "Regions")))
}

# A figure caption from the template, under its chart
.rb_mortality_caption <- function(en, fr, pt) .rb_text(.rb_tx(paste0("<i>", en, "</i>"), paste0("<i>", fr, "</i>"), paste0("<i>", pt, "</i>")))

.rb_mortality_blocks <- function() {
  cap <- .rb_mortality_caption
  notes <- .rb_tx("Notes", "Notes", "Notas")
  background <- .rb_tx("Background", "Contexte", "Contexto")
  q_sb_level <- .rb_tx(
    "Is the level of stillbirths from the facility data as expected? What can be said about the regional variation? Are there regions with low stillbirth rates, and is this plausible?",
    "Le niveau de mort-n\u00e9s provenant des donn\u00e9es des \u00e9tablissements est-il conforme aux attentes ? Que peut-on dire de la variation r\u00e9gionale ? Existe-t-il des r\u00e9gions avec des taux de mort-n\u00e9s faibles, et cela est-il plausible ?",
    "O n\u00edvel de natimortos dos dados da instala\u00e7\u00e3o est\u00e1 como esperado? O que pode ser dito sobre a varia\u00e7\u00e3o regional? Existem regi\u00f5es com taxas baixas de natimortos, e isso \u00e9 plaus\u00edvel?"
  )
  q_sb_completeness <- .rb_tx(
    "What can be said about the estimated level of completeness of reporting of stillbirths? Which assumptions are most plausible, in terms of population level of SBR (e.g., median, lower or upper bound from UN estimates) and the ratio community to institutional mortality?",
    "Que peut-on dire du niveau estim\u00e9 de compl\u00e9tude du signalement des mort-n\u00e9s ? Quelles hypoth\u00e8ses sont les plus plausibles, en termes de niveau de population du SBR (par ex. m\u00e9diane, borne inf\u00e9rieure ou sup\u00e9rieure des estimations de l\u2019ONU) et du ratio mortalit\u00e9 communaut\u00e9 vs institutionnelle ?",
    "O que pode ser dito sobre o n\u00edvel estimado de completude da notifica\u00e7\u00e3o de natimortos? Quais suposi\u00e7\u00f5es s\u00e3o mais plaus\u00edveis, em termos de n\u00edvel populacional de SBR (por exemplo, mediana, limite inferior ou superior das estimativas da ONU) e a propor\u00e7\u00e3o mortalidade comunit\u00e1ria para institucional?"
  )
  q_nn <- .rb_tx(
    "What is the neonatal mortality (before discharge) nationally? How do these compare with the national estimate of neonatal mortality per 1,000 live births? What can be said about reporting completeness, are the health facility rates plausible?",
    "Quelle est la mortalit\u00e9 n\u00e9onatale (avant sortie) au niveau national ? Comment cela se compare-t-il \u00e0 l\u2019estimation nationale de la mortalit\u00e9 n\u00e9onatale pour 1 000 naissances vivantes ? Que peut-on dire de la compl\u00e9tude du signalement, les taux des \u00e9tablissements de sant\u00e9 sont-ils plausibles ?",
    "Qual \u00e9 a mortalidade neonatal (antes da alta) nacionalmente? Como isso se compara com a estimativa nacional de mortalidade neonatal por 1.000 nascidos vivos? O que pode ser dito sobre a completude da notifica\u00e7\u00e3o, as taxas das instala\u00e7\u00f5es de sa\u00fade s\u00e3o plaus\u00edveis?"
  )

  list(
    .rb_heading(.rb_tx("Maternal Mortality in Health Facilities", "Mortalit\u00e9 maternelle dans les \u00e9tablissements de sant\u00e9",
                       "Mortalidade Materna em Instala\u00e7\u00f5es de Sa\u00fade")),
    .rb_heading(background, 2),
    .rb_text(.rb_tx(
      "The main challenge with mortality data from health facilities is underreporting of deaths. Deaths may not be recorded in the maternity register, or not reported. Also, maternal deaths in other hospital wards are more likely to be missed, e.g., deaths associated with abortion or sepsis. The main aim is to estimate the level of underreporting in DHIS2 or MPDSR.",
      "Le principal d\u00e9fi concernant les donn\u00e9es de mortalit\u00e9 provenant des \u00e9tablissements de sant\u00e9 est la sous-d\u00e9claration des d\u00e9c\u00e8s. Les d\u00e9c\u00e8s peuvent ne pas \u00eatre enregistr\u00e9s dans le registre de maternit\u00e9, ou ne pas \u00eatre signal\u00e9s. De plus, les d\u00e9c\u00e8s maternels dans d\u2019autres services hospitaliers sont plus susceptibles d\u2019\u00eatre manqu\u00e9s, par exemple les d\u00e9c\u00e8s associ\u00e9s \u00e0 un avortement ou \u00e0 une septic\u00e9mie. L\u2019objectif principal est d\u2019estimer le niveau de sous-d\u00e9claration dans DHIS2 ou MPDSR.",
      "O principal desafio com os dados de mortalidade das instala\u00e7\u00f5es de sa\u00fade \u00e9 a subnotifica\u00e7\u00e3o de \u00f3bitos. Os \u00f3bitos podem n\u00e3o ser registrados no registro de maternidade, ou n\u00e3o ser reportados. Al\u00e9m disso, \u00f3bitos maternos em outras alas do hospital t\u00eam maior probabilidade de serem perdidos, por exemplo, \u00f3bitos associados a aborto ou sepse. O objetivo principal \u00e9 estimar o n\u00edvel de subnotifica\u00e7\u00e3o no DHIS2 ou MPDSR."
    )),
    .rb_chart("mortality_trend", admin_level = NULL, variant = "mmr_inst"),
    cap("Figure 5a: Maternal mortality per 100,000 live births in health facilities, based on the reported data in DHIS2",
        "Figure 5a : Mortalit\u00e9 maternelle pour 100 000 naissances vivantes dans les \u00e9tablissements de sant\u00e9, d\u2019apr\u00e8s les donn\u00e9es d\u00e9clar\u00e9es dans DHIS2",
        "Figura 5a: Mortalidade materna por 100.000 nascidos vivos nas instala\u00e7\u00f5es de sa\u00fade, com base nos dados reportados no DHIS2"),
    .rb_chart("mortality_plausibility", admin_level = NULL),
    cap("Figure 5b: Ratio of stillbirths to maternal deaths in health facilities, based on the reported data in DHIS2",
        "Figure 5b : Ratio mort-n\u00e9s / d\u00e9c\u00e8s maternels dans les \u00e9tablissements de sant\u00e9, d\u2019apr\u00e8s les donn\u00e9es d\u00e9clar\u00e9es dans DHIS2",
        "Figura 5b: Raz\u00e3o entre natimortos e \u00f3bitos maternos nas instala\u00e7\u00f5es de sa\u00fade, com base nos dados reportados no DHIS2"),
    .rb_chart("mortality_trend", admin_level = NULL, variant = "sbr_inst"),
    cap("Figure 5c: Stillbirth rates in health facilities, based on the reported data in DHIS2",
        "Figure 5c : Taux de mortinatalit\u00e9 dans les \u00e9tablissements de sant\u00e9, d\u2019apr\u00e8s les donn\u00e9es d\u00e9clar\u00e9es dans DHIS2",
        "Figura 5c: Taxas de natimortalidade nas instala\u00e7\u00f5es de sa\u00fade, com base nos dados reportados no DHIS2"),
    .rb_chart("mort_nn_trend", admin_level = NULL),
    cap("Figure 5d: Neonatal mortality before discharge per 1,000 live births in health facilities, based on the reported data in DHIS2",
        "Figure 5d : Mortalit\u00e9 n\u00e9onatale avant la sortie pour 1 000 naissances vivantes dans les \u00e9tablissements de sant\u00e9, d\u2019apr\u00e8s les donn\u00e9es d\u00e9clar\u00e9es dans DHIS2",
        "Figura 5d: Mortalidade neonatal antes da alta por 1.000 nascidos vivos nas instala\u00e7\u00f5es de sa\u00fade, com base nos dados reportados no DHIS2"),
    .rb_questions(
      .rb_tx(
        "Is the level of MMR from the facility data as expected? What can be said about the regional variation? Are there regions with low MMR and is this plausible?",
        "Le niveau de MMR provenant des donn\u00e9es des \u00e9tablissements est-il conforme aux attentes ? Que peut-on dire de la variation r\u00e9gionale ? Existe-t-il des r\u00e9gions avec un MMR faible et cela est-il plausible ?",
        "\u00c9 o n\u00edvel de MMR dos dados da instala\u00e7\u00e3o como esperado? O que pode ser dito sobre a varia\u00e7\u00e3o regional? Existem regi\u00f5es com MMR baixo e isso \u00e9 plaus\u00edvel?"
      ),
      .rb_tx(
        "What can be said about the regional variation? What percent of regions has very low MMR (< 25) and very low SBR (< 6)? Is this plausible or is underreporting of deaths likely?",
        "Que peut-on dire de la variation r\u00e9gionale ? Quel pourcentage de r\u00e9gions pr\u00e9sente un MMR tr\u00e8s bas (< 25) et un SBR tr\u00e8s bas (< 6) ? Cela est-il plausible ou la sous-d\u00e9claration des d\u00e9c\u00e8s est-elle probable ?",
        "O que pode ser dito sobre a varia\u00e7\u00e3o regional? Qual porcentagem de regi\u00f5es tem MMR muito baixo (< 25) e SBR muito baixo (< 6)? Isso \u00e9 plaus\u00edvel ou a subnotifica\u00e7\u00e3o de \u00f3bitos \u00e9 prov\u00e1vel?"
      ),
      .rb_tx(
        "What is the ratio stillbirth to maternal deaths? Is it in the range of 5-15? How can this be interpreted? Is this suggestive of underreporting of maternal deaths relative to stillbirths?",
        "Quel est le ratio mort-n\u00e9s sur d\u00e9c\u00e8s maternels ? Se situe-t-il dans la fourchette de 5-15 ? Comment peut-on interpr\u00e9ter cela ? Cela sugg\u00e8re-t-il une sous-d\u00e9claration des d\u00e9c\u00e8s maternels par rapport aux mort-n\u00e9s ?",
        "Qual \u00e9 a propor\u00e7\u00e3o de natimortos para \u00f3bitos maternos? Est\u00e1 na faixa de 5-15? Como isso pode ser interpretado? Isso sugere subnotifica\u00e7\u00e3o de \u00f3bitos maternos em rela\u00e7\u00e3o aos natimortos?"
      ),
      q_sb_level, q_sb_completeness, q_nn,
      title = notes
    ),
    .rb_break(),

    .rb_heading(.rb_tx("Underreporting of maternal deaths and stillbirths", "Sous-d\u00e9claration des d\u00e9c\u00e8s maternels et des mort-n\u00e9s",
                       "Subnotifica\u00e7\u00e3o de \u00f3bitos maternos e natimortos")),
    .rb_heading(background, 2),
    .rb_text(.rb_tx(
      "The main challenge with health facility data on stillbirths and neonatal deaths is underreporting. We can estimate the level of underreporting of stillbirths based on different assumptions: 1) using population mortality estimates from the UN: lower bound, best estimate and upper bound 2) community to institutional mortality ratio: assumptions ranging from half as low to at least 2 times higher community mortality.",
      "Le principal d\u00e9fi avec les donn\u00e9es des \u00e9tablissements de sant\u00e9 concernant les mort-n\u00e9s et les d\u00e9c\u00e8s n\u00e9onatals est la sous-d\u00e9claration. Nous pouvons estimer le niveau de sous-d\u00e9claration des mort-n\u00e9s en nous basant sur diff\u00e9rentes hypoth\u00e8ses : 1) utilisation des estimations de mortalit\u00e9 de la population de l\u2019ONU : borne inf\u00e9rieure, meilleure estimation et borne sup\u00e9rieure 2) ratio mortalit\u00e9 communaut\u00e9 vs institutionnelle : hypoth\u00e8ses allant d\u2019une moiti\u00e9 aussi basse \u00e0 au moins deux fois plus \u00e9lev\u00e9e mortalit\u00e9 communautaire.",
      "O principal desafio com os dados das instala\u00e7\u00f5es de sa\u00fade sobre natimortos e \u00f3bitos neonatais \u00e9 a subnotifica\u00e7\u00e3o. Podemos estimar o n\u00edvel de subnotifica\u00e7\u00e3o de natimortos com base em diferentes suposi\u00e7\u00f5es: 1) usando as estimativas de mortalidade populacional da ONU: limite inferior, melhor estimativa e limite superior 2) propor\u00e7\u00e3o de mortalidade comunit\u00e1ria para institucional: suposi\u00e7\u00f5es que v\u00e3o de uma mortalidade comunit\u00e1ria metade da institucional at\u00e9 pelo menos 2 vezes mais alta."
    )),
    .rb_chart("mortality_ratio", admin_level = NULL, variant = "mmr"),
    cap("Figure 5e: Completeness of facility maternal death reporting (%), based on UN MMR estimates and community to institutional ratio",
        "Figure 5e : Compl\u00e9tude de la d\u00e9claration des d\u00e9c\u00e8s maternels en \u00e9tablissement (%), d\u2019apr\u00e8s les estimations du MMR de l\u2019ONU et le ratio communaut\u00e9 / \u00e9tablissement",
        "Figura 5e: Completude da notifica\u00e7\u00e3o de \u00f3bitos maternos nas instala\u00e7\u00f5es (%), com base nas estimativas de MMR da ONU e na raz\u00e3o comunidade / institui\u00e7\u00e3o"),
    .rb_chart("mortality_ratio", admin_level = NULL, variant = "sbr"),
    cap("Figure 5f: Completeness of facility stillbirth reporting (%), based on UN stillbirth estimates and community to institutional ratio",
        "Figure 5f : Compl\u00e9tude de la d\u00e9claration des mort-n\u00e9s en \u00e9tablissement (%), d\u2019apr\u00e8s les estimations de mortinatalit\u00e9 de l\u2019ONU et le ratio communaut\u00e9 / \u00e9tablissement",
        "Figura 5f: Completude da notifica\u00e7\u00e3o de natimortos nas instala\u00e7\u00f5es (%), com base nas estimativas de natimortalidade da ONU e na raz\u00e3o comunidade / institui\u00e7\u00e3o"),
    .rb_questions(q_sb_level, q_sb_completeness, q_nn, title = notes)
  )
}
