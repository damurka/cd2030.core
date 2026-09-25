# Standard report: the synthesis chartbook, on the chartbook page (13.93 x 22 in). For RMNCAH it is
# inst/rmd/synthesis_report_rmncah_template.Rmd (all six analysis areas with the questions for the analyst); for vaccines
# inst/rmd/synthesis_report_vaccine_template.Rmd (data quality, national coverage and equity). The French and Portuguese
# texts are those of the _fr_ and _pt_ templates. See the standard reports section of R/report-builder.R for how these
# files are written.

.rb_preset_synthesis <- function(group) {
  vaccine <- identical(group, "vaccine")
  list(
    name = .rb_tx("Synthesis chartbook", "Recueil de synth\u00e8se", "Caderno de s\u00edntese"),
    description = if (vaccine) {
      .rb_tx("Data quality, national coverage and equity with interpretation questions, on the chartbook page",
             "Qualit\u00e9 des donn\u00e9es, couverture nationale et \u00e9quit\u00e9 avec questions d'interpr\u00e9tation, au format du recueil",
             "Qualidade dos dados, cobertura nacional e equidade com perguntas de interpreta\u00e7\u00e3o, no formato do caderno")
    } else {
      .rb_tx("All six analysis areas with interpretation questions, on the chartbook page",
             "Les six domaines d'analyse avec questions d'interpr\u00e9tation, au format du recueil",
             "As seis \u00e1reas de an\u00e1lise com perguntas de interpreta\u00e7\u00e3o, no formato do caderno")
    },
    blocks = if (vaccine) .rb_synthesis_vaccine_blocks() else .rb_synthesis_blocks(),
    design_patch = list(size = "chartbook", margins = "narrow", header = "{report_title} \u00b7 {country}"),
    cover_patch = list(
      kicker = "Countdown to 2030 \u00b7 {country}",
      title = if (vaccine) {
        .rb_tx("Analysis of vaccine health indicators, {first_year}-{latest_year}: synthesis chartbook",
               "Analyse des indicateurs de sant\u00e9 vaccinale, {first_year}-{latest_year} : recueil de synth\u00e8se",
               "An\u00e1lise dos indicadores de sa\u00fade vacinal, {first_year}-{latest_year}: caderno de s\u00edntese")
      } else {
        .rb_tx("Analysis of reproductive, maternal, newborn, child and adolescent health indicators, {first_year}-{latest_year}: synthesis chartbook",
               "Analyse des indicateurs de sant\u00e9 reproductive, maternelle, n\u00e9onatale, infantile et adolescente, {first_year}-{latest_year} : recueil de synth\u00e8se",
               "An\u00e1lise dos indicadores de sa\u00fade reprodutiva, materna, neonatal, infantil e do adolescente, {first_year}-{latest_year}: caderno de s\u00edntese")
      },
      subtitle = .rb_tx(
        "Countdown to 2030 in partnership with the {country} Ministry of Health, Global Financing Facility, WHO, WAHO and UNICEF",
        "Countdown to 2030 en partenariat avec le minist\u00e8re de la Sant\u00e9 de {country}, le M\u00e9canisme de financement mondial, l'OMS, l'OOAS et l'UNICEF",
        "Countdown to 2030 em parceria com o Minist\u00e9rio da Sa\u00fade de {country}, a Global Financing Facility, a OMS, a WAHO e o UNICEF"
      ),
      editors = list(list(name = .rb_tx("Country analytical team", "\u00c9quipe analytique du pays", "Equipa anal\u00edtica do pa\u00eds"),
                          role = .rb_tx("Names and affiliations", "Noms et affiliations", "Nomes e afilia\u00e7\u00f5es")))
    )
  )
}

# ---- texts both chartbooks share -----------------------------------------------------------------------------------

.rb_syn_quality <- function() list(
  .rb_heading(.rb_tx("1. Health facility data quality assessment: numerators and denominators",
                     "1. \u00c9valuation de la qualit\u00e9 des donn\u00e9es des \u00e9tablissements de sant\u00e9 : num\u00e9rateurs et d\u00e9nominateurs",
                     "1. Avalia\u00e7\u00e3o da qualidade dos dados das unidades sanit\u00e1rias: numeradores e denominadores")),
  .rb_text(.rb_tx(
    paste(
      "<b>Numerators:</b> Routinely reported health facility data are an important data source for health indicators. The data are",
      "reported by health facilities on events such as immunizations given, or live births attended. As with any data, quality is an",
      "issue. Data are assessed for completeness of reporting by health facilities, extreme outliers and internal consistency.",
      "Appropriate adjustments are made to the data before use to compute statistics."
    ),
    paste(
      "<b>Num\u00e9rateurs :</b> Les donn\u00e9es des \u00e9tablissements de sant\u00e9 rapport\u00e9es de fa\u00e7on routini\u00e8re constituent une source importante pour",
      "les indicateurs de sant\u00e9. Les \u00e9tablissements rapportent des \u00e9v\u00e9nements tels que les vaccinations administr\u00e9es ou les naissances",
      "vivantes assist\u00e9es. Comme pour toute donn\u00e9e, la qualit\u00e9 est un enjeu. Les donn\u00e9es sont \u00e9valu\u00e9es pour la compl\u00e9tude du signalement",
      "par les \u00e9tablissements, les valeurs extr\u00eames et la coh\u00e9rence interne. Des ajustements appropri\u00e9s sont effectu\u00e9s sur les donn\u00e9es",
      "avant leur utilisation pour calculer les statistiques."
    ),
    paste(
      "<b>Numeradores:</b> Os dados das unidades sanit\u00e1rias reportados rotineiramente s\u00e3o uma importante fonte de informa\u00e7\u00e3o para os",
      "indicadores de sa\u00fade. Estes dados reportam eventos como imuniza\u00e7\u00f5es administradas ou nascidos vivos atendidos. Tal como acontece",
      "com qualquer dado, a qualidade \u00e9 um desafio. Os dados s\u00e3o avaliados quanto \u00e0 completude dos relat\u00f3rios das unidades sanit\u00e1rias,",
      "valores at\u00edpicos extremos e consist\u00eancia interna. S\u00e3o feitos ajustes apropriados antes da utiliza\u00e7\u00e3o dos dados no c\u00e1lculo das",
      "estat\u00edsticas."
    )
  )),
  .rb_heading(.rb_tx("Summary of reported health facility data quality, DHIS2, {first_year}-{latest_year}",
                     "R\u00e9sum\u00e9 de la qualit\u00e9 des donn\u00e9es des \u00e9tablissements de sant\u00e9 rapport\u00e9es, DHIS2, {first_year}-{latest_year}",
                     "Resumo da qualidade dos dados reportados pelas unidades sanit\u00e1rias, DHIS2, {first_year}-{latest_year}"), 2),
  .rb_chart("overall_score", type = "table", admin_level = NULL),
  .rb_questions(
    .rb_tx("What is the overall quality of the data as assessed by the overall annual data quality score?",
           "Quelle est la qualit\u00e9 globale des donn\u00e9es telle qu'\u00e9valu\u00e9e par le score annuel global de qualit\u00e9 des donn\u00e9es ?",
           "Qual \u00e9 a qualidade global dos dados segundo a pontua\u00e7\u00e3o anual global de qualidade dos dados?"),
    .rb_tx("Is there a data quality pattern by year for which there is an explanation?",
           "Existe-t-il un sch\u00e9ma de qualit\u00e9 des donn\u00e9es par ann\u00e9e pour lequel une explication est disponible ?",
           "Existe algum padr\u00e3o de qualidade dos dados por ano que tenha uma explica\u00e7\u00e3o?"),
    .rb_tx("Are there certain regions or other subnational units that are particularly problematic?",
           "Certaines r\u00e9gions ou autres unit\u00e9s infranationales sont-elles particuli\u00e8rement probl\u00e9matiques ?",
           "Existem regi\u00f5es ou outras unidades subnacionais particularmente problem\u00e1ticas?"),
    .rb_tx("Are there certain reporting forms or services (e.g., antenatal care, labour and delivery, immunization) that are problematic? Was an adjustment done for incomplete reporting (provide the k value)?",
           "Certains formulaires de d\u00e9claration ou services (p. ex., soins pr\u00e9natals, travail et accouchement, vaccination) posent-ils probl\u00e8me ? Un ajustement a-t-il \u00e9t\u00e9 effectu\u00e9 pour les d\u00e9clarations incompl\u00e8tes (fournir la valeur k) ?",
           "Existem formul\u00e1rios de reporte ou servi\u00e7os (por exemplo, CPN, trabalho de parto e parto, imuniza\u00e7\u00e3o) que sejam problem\u00e1ticos? Foi feito algum ajuste para o reporte incompleto (indicar o valor de k)?"),
    .rb_tx("Is there good consistency between reported numbers of ANC1 and penta1? If not, what could be the explanation?",
           "Y a-t-il une bonne coh\u00e9rence entre les nombres d\u00e9clar\u00e9s d'ANC1 et de penta1 ? Sinon, quelle pourrait \u00eatre l'explication ?",
           "H\u00e1 boa consist\u00eancia entre os n\u00fameros reportados de ANC1 e Penta1? Caso contr\u00e1rio, qual poder\u00e1 ser a explica\u00e7\u00e3o?")
  ),
  .rb_heading(.rb_tx("Numerators: facility data quality", "Num\u00e9rateurs : qualit\u00e9 des donn\u00e9es des \u00e9tablissements",
                     "Numeradores: qualidade dos dados das unidades sanit\u00e1rias"), 2),
  .rb_text(.rb_tx("<i>Explain the observation on data quality shown by each chart (one bullet each).</i>",
                  "<i>Expliquer l'observation sur la qualit\u00e9 des donn\u00e9es illustr\u00e9e par chaque graphique (un point chacun).</i>",
                  "<i>Explique a observa\u00e7\u00e3o sobre a qualidade dos dados mostrada por cada gr\u00e1fico (um ponto cada).</i>")),
  .rb_chart("consistency", admin_level = NULL, size = "half"), .rb_chart("reporting_rate", admin_level = NULL, size = "half"),
  .rb_text(.rb_tx(
    paste(
      "<b>Denominators:</b> Service coverage is defined as the population who received the service (numerator) divided by the",
      "population who need the service (the denominator). We test four options for denominator measures using institutional live",
      "births and Penta-3 immunization coverage. The quality of the population projections in DHIS2 is assessed through consistency",
      "over time and comparison with the UN projections. Two denominators are also derived using near universal services such as",
      "ANC-1 and Penta-1. The most plausible is identified for use to generate other statistics."
    ),
    paste(
      "<b>D\u00e9nominateurs :</b> La couverture de service est d\u00e9finie comme la population ayant re\u00e7u le service (num\u00e9rateur) divis\u00e9e par",
      "la population qui a besoin du service (le d\u00e9nominateur). Nous testons quatre options de mesures du d\u00e9nominateur en utilisant les",
      "naissances vivantes institutionnelles et la couverture vaccinale Penta-3. La qualit\u00e9 des projections de population dans DHIS2",
      "est \u00e9valu\u00e9e par la coh\u00e9rence dans le temps et la comparaison avec les projections de l'ONU. Deux d\u00e9nominateurs sont \u00e9galement",
      "d\u00e9riv\u00e9s en utilisant des services quasi universels tels que ANC-1 et Penta-1. Le plus plausible est identifi\u00e9 pour \u00eatre utilis\u00e9",
      "afin de g\u00e9n\u00e9rer d'autres statistiques."
    ),
    paste(
      "<b>Denominadores:</b> A cobertura dos servi\u00e7os \u00e9 definida como a popula\u00e7\u00e3o que recebeu o servi\u00e7o (numerador) dividida pela",
      "popula\u00e7\u00e3o que necessita do servi\u00e7o (denominador). Testamos quatro op\u00e7\u00f5es de denominadores utilizando nascidos vivos",
      "institucionais e cobertura vacinal de Penta3. A qualidade das proje\u00e7\u00f5es populacionais no DHIS2 \u00e9 avaliada pela consist\u00eancia ao",
      "longo do tempo e pela compara\u00e7\u00e3o com as proje\u00e7\u00f5es das Na\u00e7\u00f5es Unidas. Dois denominadores tamb\u00e9m s\u00e3o derivados a partir de",
      "servi\u00e7os quase universais, como ANC1 e Penta1. O mais plaus\u00edvel \u00e9 selecionado para gerar as restantes estat\u00edsticas."
    )
  ))
)

# The questions under the denominator charts; `maternal` names the maternal indicator in the three languages
.rb_syn_denominator_questions <- function(maternal) .rb_questions(
  .rb_tx("How well does the national projection of births align with the UN projection?",
         "Dans quelle mesure la projection nationale des naissances s'aligne-t-elle avec la projection de l'ONU ?",
         "Em que medida a proje\u00e7\u00e3o nacional de nascimentos est\u00e1 alinhada com a proje\u00e7\u00e3o das Na\u00e7\u00f5es Unidas?"),
  .rb_tx("Which denominator methods performed best at the national level for the live births coverage and penta3 coverage? And at the subnational level for the two indicators?",
         "Quelles m\u00e9thodes de d\u00e9nominateur ont donn\u00e9 les meilleurs r\u00e9sultats au niveau national pour la couverture des naissances vivantes et la couverture penta3 ? Et au niveau infranational pour les deux indicateurs ?",
         "Que m\u00e9todos de denominador tiveram melhor desempenho a n\u00edvel nacional para a cobertura de nascidos vivos e de Penta3? E ao n\u00edvel subnacional para os dois indicadores?"),
  .rb_tx(paste0("What denominators are selected for the maternal (", maternal$en, ") and vaccination (penta3) indicators in the coverage analyses?"),
         paste0("Quels d\u00e9nominateurs sont s\u00e9lectionn\u00e9s pour les indicateurs maternels (", maternal$fr, ") et de vaccination (penta3) dans les analyses de couverture ?"),
         paste0("Que denominadores s\u00e3o selecionados para os indicadores maternos (", maternal$pt, ") e de vacina\u00e7\u00e3o (penta3) nas an\u00e1lises de cobertura?"))
)

.rb_syn_coverage_heading <- function() .rb_heading(.rb_tx(
  "2. National coverage trends: facility data and surveys",
  "2. Tendances de la couverture nationale : donn\u00e9es des \u00e9tablissements et enqu\u00eates",
  "2. Tend\u00eancias nacionais de cobertura: dados das unidades sanit\u00e1rias e inqu\u00e9ritos"
))

.rb_syn_q_plausible <- function() .rb_tx(
  "Are the levels and trends plausible? Is there good consistency between the facility and survey data?",
  "Les niveaux et les tendances sont-ils plausibles ? Y a-t-il une bonne coh\u00e9rence entre les donn\u00e9es des \u00e9tablissements et les donn\u00e9es d'enqu\u00eate ?",
  "Os n\u00edveis e as tend\u00eancias s\u00e3o plaus\u00edveis? Existe boa consist\u00eancia entre os dados das unidades sanit\u00e1rias e os dados dos inqu\u00e9ritos?"
)

.rb_syn_q_targets <- function() .rb_tx(
  "How does the coverage perform compared to the targets? Is this a positive trend?",
  "Comment la couverture se compare-t-elle aux objectifs ? S'agit-il d'une tendance positive ?",
  "Como a cobertura se comporta em rela\u00e7\u00e3o \u00e0s metas? Trata-se de uma tend\u00eancia positiva?"
)

.rb_syn_threshold_heading <- function() .rb_heading(.rb_tx(
  "Percent of districts achieving high coverage targets",
  "Pourcentage de districts atteignant les objectifs de haute couverture",
  "Percentagem de distritos que atingem metas elevadas de cobertura"
), 2)

.rb_syn_threshold_questions <- function() .rb_questions(.rb_tx(
  "Has the proportion of districts that achieved the target varied over time?",
  "La proportion de districts ayant atteint l'objectif a-t-elle vari\u00e9 dans le temps ?",
  "A propor\u00e7\u00e3o de distritos que atingiram a meta variou ao longo do tempo?"
))

# The survey equity charts (institutional live births and penta3) with their questions, and the geographical inequality
# heading; the caller adds the facility charts and .rb_syn_geo_questions()
.rb_syn_equity <- function() {
  third <- function(...) .rb_chart(..., size = "third")
  list(
    .rb_heading(.rb_tx("3. Equity", "3. \u00c9quit\u00e9", "3. Equidade")),
    .rb_heading(.rb_tx("Equity by wealth, education and rural-urban residence (from surveys)",
                       "\u00c9quit\u00e9 selon la richesse, l'\u00e9ducation et la r\u00e9sidence rurale-urbaine (\u00e0 partir des enqu\u00eates)",
                       "Equidade por riqueza, educa\u00e7\u00e3o e resid\u00eancia rural-urbana (a partir dos inqu\u00e9ritos)"), 2),
    .rb_text("<b>{chart_indicator}</b>"),
    third("equity", "instlivebirths", admin_level = NULL, variant = "area"),
    third("equity", "instlivebirths", admin_level = NULL, variant = "wealth"),
    third("equity", "instlivebirths", admin_level = NULL, variant = "education"),
    .rb_text("<b>{chart_indicator}</b>"),
    third("equity", "penta3", admin_level = NULL, variant = "area"),
    third("equity", "penta3", admin_level = NULL, variant = "wealth"),
    third("equity", "penta3", admin_level = NULL, variant = "education"),
    .rb_questions(
      .rb_tx("Can you observe any systematic differences, such as specific groups consistently being left behind?",
             "Pouvez-vous observer des diff\u00e9rences syst\u00e9matiques, par exemple des groupes sp\u00e9cifiques constamment laiss\u00e9s pour compte ?",
             "\u00c9 poss\u00edvel observar diferen\u00e7as sistem\u00e1ticas, como grupos espec\u00edficos que ficam consistentemente para tr\u00e1s?"),
      .rb_tx("Are there observable patterns of inequality (e.g., linear, concentrated at the top or bottom)? If so, what potential strategies could be implemented to reduce these inequalities?",
             "Existe-t-il des sch\u00e9mas d'in\u00e9galit\u00e9 observables (p. ex., lin\u00e9aire, concentr\u00e9 en haut ou en bas) ? Le cas \u00e9ch\u00e9ant, quelles strat\u00e9gies potentielles pourraient \u00eatre mises en \u0153uvre pour r\u00e9duire ces in\u00e9galit\u00e9s ?",
             "Existem padr\u00f5es observ\u00e1veis de desigualdade (por exemplo, linear, concentrada no topo ou na base)? Se sim, que estrat\u00e9gias potenciais poderiam ser implementadas para reduzir essas desigualdades?"),
      .rb_tx("Are all subgroups experiencing increases or decreases in coverage at the same pace?",
             "Tous les sous-groupes connaissent-ils des augmentations ou des diminutions de la couverture au m\u00eame rythme ?",
             "Todos os subgrupos est\u00e3o a registar aumentos ou redu\u00e7\u00f5es de cobertura ao mesmo ritmo?"),
      .rb_tx("Are inequalities changing over time?", "Les in\u00e9galit\u00e9s \u00e9voluent-elles dans le temps ?",
             "As desigualdades est\u00e3o a mudar ao longo do tempo?")
    ),
    .rb_heading(.rb_tx("Geographical inequalities: health facility data",
                       "In\u00e9galit\u00e9s g\u00e9ographiques : donn\u00e9es des \u00e9tablissements de sant\u00e9",
                       "Desigualdades geogr\u00e1ficas: dados das unidades sanit\u00e1rias"), 2)
  )
}

.rb_syn_geo_questions <- function() .rb_questions(
  .rb_tx("How has coverage evolved over time?", "Comment la couverture a-t-elle \u00e9volu\u00e9 au fil du temps ?",
         "Como a cobertura evoluiu ao longo do tempo?"),
  .rb_tx("Has there been any change in inequality? Are the data points becoming more or less dispersed over time? Are the MADM (mean absolute deviation from the median) estimates changing throughout the period?",
         "Y a-t-il eu un changement dans les in\u00e9galit\u00e9s ? Les points de donn\u00e9es deviennent-ils plus ou moins dispers\u00e9s au fil du temps ? Les estimations de la MADM (\u00e9cart absolu moyen \u00e0 la m\u00e9diane) \u00e9voluent-elles sur la p\u00e9riode ?",
         "Houve alguma mudan\u00e7a na desigualdade? Os pontos de dados est\u00e3o se tornando mais ou menos dispersos ao longo do tempo? As estimativas de MADM (desvio absoluto m\u00e9dio da mediana) est\u00e3o mudando ao longo do per\u00edodo?"),
  .rb_tx("Which regions or districts are the best and worst performers?",
         "Quelles r\u00e9gions ou quels districts pr\u00e9sentent les meilleures et les moins bonnes performances ?",
         "Quais regi\u00f5es ou distritos apresentam o melhor e o pior desempenho?")
)

# ---- the RMNCAH chartbook (inst/rmd/synthesis_report_rmncah_template.Rmd) ------------------------------------------

.rb_synthesis_blocks <- function() {
  third <- function(...) .rb_chart(..., size = "third")
  half <- function(...) .rb_chart(..., size = "half")
  q <- .rb_tx
  c(
    .rb_syn_quality(),
    list(
      third("denominator_trend", admin_level = NULL), third("derived_coverage", "instlivebirths"),
      third("derived_coverage", "instlivebirths", admin_level = "adminlevel_1"),
      .rb_syn_denominator_questions(q("institutional live births", "naissances vivantes institutionnelles", "nascidos vivos institucionais")),
      .rb_break(),

      .rb_syn_coverage_heading(),
      # {chart_indicators}: the indicators of the charts under the heading, as they are set
      .rb_heading(q("Antenatal care: {chart_indicators}", "Soins pr\u00e9natals : {chart_indicators}",
                    "Cuidados pr\u00e9-natais: {chart_indicators}"), 2),
      half("coverage", "anc4"), half("coverage", "anc_1trimester"),
      .rb_questions(.rb_syn_q_plausible()),
      .rb_heading("{chart_indicator}", 2),
      half("coverage", "instlivebirths"),
      .rb_questions(.rb_syn_q_plausible(), .rb_syn_q_targets()),
      .rb_heading(q("Immunization: {chart_indicators}", "Vaccination : {chart_indicators}", "Imuniza\u00e7\u00e3o: {chart_indicators}"), 2),
      half("coverage", "penta3"), half("coverage", "measles1"),
      .rb_questions(
        q("Are the levels and trends plausible? Is there good consistency between the facility and survey data? How do the results compare to the UN estimates (WUENIC)?",
          "Les niveaux et les tendances sont-ils plausibles ? Y a-t-il une bonne coh\u00e9rence entre les donn\u00e9es des \u00e9tablissements et les donn\u00e9es d'enqu\u00eate ? Comment les r\u00e9sultats se comparent-ils aux estimations de l'ONU (WUENIC) ?",
          "Os n\u00edveis e as tend\u00eancias s\u00e3o plaus\u00edveis? Existe boa consist\u00eancia entre os dados das unidades sanit\u00e1rias e os dados dos inqu\u00e9ritos? Como os resultados se comparam com as estimativas das Na\u00e7\u00f5es Unidas (WUENIC)?"),
        .rb_syn_q_targets()
      ),
      .rb_syn_threshold_heading(),
      half("threshold", "anc4", admin_level = NULL), half("threshold", "vaccine", admin_level = NULL),
      .rb_syn_threshold_questions(),
      .rb_break()
    ),

    .rb_syn_equity(),
    list(
      half("inequality", "instlivebirths", admin_level = "adminlevel_1"), half("inequality", "penta3", admin_level = "adminlevel_1"),
      half("map", "instlivebirths", admin_level = NULL, variant = "Blues"), half("map", "penta3", admin_level = NULL, variant = "Blues"),
      .rb_syn_geo_questions(),
      .rb_break(),

      .rb_heading(q("4. Institutional mortality", "4. Mortalit\u00e9 institutionnelle", "4. Mortalidade institucional")),
      .rb_heading(q("Institutional mortality trends (iMMR, iSBR)", "Tendances de la mortalit\u00e9 institutionnelle (iMMR, iSBR)",
                    "Tend\u00eancias da mortalidade institucional (iMMR, iSBR)"), 2),
      half("mortality_trend", admin_level = NULL, variant = "mmr_inst"), half("mortality_trend", admin_level = NULL, variant = "sbr_inst"),
      .rb_questions(q(
        "What can be said about the level and trend? Is this in line with what is expected based on UN estimates?",
        "Que peut-on dire du niveau et de la tendance ? Sont-ils conformes \u00e0 ce qui est attendu d'apr\u00e8s les estimations des Nations Unies ?",
        "O que pode ser dito sobre o n\u00edvel e a tend\u00eancia? Isso est\u00e1 alinhado com o que se espera com base nas estimativas da ONU?"
      )),
      .rb_heading(q("Institutional mortality by region", "Mortalit\u00e9 institutionnelle par r\u00e9gion", "Mortalidade institucional por regi\u00e3o"), 2),
      half("mortality_region", admin_level = NULL, variant = "mmr"), half("mortality_region", admin_level = NULL, variant = "sbr"),
      .rb_questions(
        q("What are the 3 highest iMMR regions and the lowest iMMR and iSBR regions (name with level)? Is this as expected, or does it suggest data quality issues?",
          "Quelles sont les 3 r\u00e9gions ayant l'iMMR le plus \u00e9lev\u00e9 et les r\u00e9gions ayant l'iMMR et l'iSBR les plus bas (nom et niveau) ? Est-ce conforme aux attentes, ou cela sugg\u00e8re-t-il des probl\u00e8mes de qualit\u00e9 des donn\u00e9es ?",
          "Quais s\u00e3o as 3 regi\u00f5es com iMMR mais alta e as regi\u00f5es com iMMR e iSBR mais baixas (nome e n\u00edvel)? Isso est\u00e1 conforme o esperado ou sugere problemas de qualidade dos dados?"),
        q("Are these more advanced regions where mortality is expected to be lower, or are there less-developed regions with low mortality, which could indicate major underreporting of deaths?",
          "S'agit-il de r\u00e9gions plus avanc\u00e9es o\u00f9 l'on s'attend \u00e0 une mortalit\u00e9 plus faible, ou de r\u00e9gions moins d\u00e9velopp\u00e9es \u00e0 faible mortalit\u00e9, ce qui pourrait indiquer une sous-d\u00e9claration importante des d\u00e9c\u00e8s ?",
          "S\u00e3o regi\u00f5es mais avan\u00e7adas onde se espera que a mortalidade seja menor, ou h\u00e1 regi\u00f5es menos desenvolvidas com baixa mortalidade, o que poderia indicar subnotifica\u00e7\u00e3o significativa de \u00f3bitos?")
      ),
      .rb_heading(q("Data quality: stillbirths per maternal death", "Qualit\u00e9 des donn\u00e9es : mortinaissances par d\u00e9c\u00e8s maternel",
                    "Qualidade dos dados: natimortos por \u00f3bito materno"), 2),
      .rb_text(q("Ratio of stillbirths to maternal deaths in the health facility data at national level.",
                 "Rapport entre les mortinaissances et les d\u00e9c\u00e8s maternels dans les donn\u00e9es des \u00e9tablissements de sant\u00e9 au niveau national.",
                 "Raz\u00e3o de natimortos para \u00f3bitos maternos nos dados das unidades de sa\u00fade a n\u00edvel nacional.")),
      half("mortality_plausibility", admin_level = NULL),
      .rb_questions(
        q("A plausible ratio is in the range of 5 to 25 stillbirths per maternal death. Is the national ratio within the expected range?",
          "Un rapport plausible se situe entre 5 et 25 mortinaissances par d\u00e9c\u00e8s maternel. Le rapport national se situe-t-il dans la fourchette attendue ?",
          "Uma raz\u00e3o plaus\u00edvel est\u00e1 na faixa de 5 a 25 natimortos por \u00f3bito materno. A raz\u00e3o nacional est\u00e1 dentro da faixa esperada?"),
        q("What can be said about the top 3 and bottom 3 regions?",
          "Que peut-on dire des 3 premi\u00e8res et des 3 derni\u00e8res r\u00e9gions ?",
          "O que pode ser dito sobre as 3 regi\u00f5es superiores e as 3 inferiores?"),
        q("If the ratio is above 25, maternal deaths may be more underreported than stillbirths. If it is below 5, stillbirths are likely underreported. If the ratio is within the range, the reporting may be good if the mortality levels are in the expected range; if not, both maternal deaths and stillbirths are underreported.",
          "Si le rapport est sup\u00e9rieur \u00e0 25, les d\u00e9c\u00e8s maternels sont peut-\u00eatre davantage sous-d\u00e9clar\u00e9s que les mortinaissances. S'il est inf\u00e9rieur \u00e0 5, les mortinaissances sont probablement sous-d\u00e9clar\u00e9es. Si le rapport est dans la fourchette, la d\u00e9claration peut \u00eatre bonne si les niveaux de mortalit\u00e9 sont dans la fourchette attendue ; sinon, les d\u00e9c\u00e8s maternels et les mortinaissances sont tous deux sous-d\u00e9clar\u00e9s.",
          "Se a raz\u00e3o for superior a 25, os \u00f3bitos maternos podem estar mais subnotificados que os natimortos. Se for inferior a 5, os natimortos provavelmente est\u00e3o subnotificados. Se a raz\u00e3o estiver dentro da faixa, o reporte pode ser bom se os n\u00edveis de mortalidade estiverem dentro do esperado; caso contr\u00e1rio, tanto os \u00f3bitos maternos quanto os natimortos est\u00e3o subnotificados.")
      ),
      .rb_heading(q("Estimated completeness of facility maternal death and stillbirth reporting",
                    "Compl\u00e9tude estim\u00e9e de la d\u00e9claration des d\u00e9c\u00e8s maternels et des mortinaissances dans les \u00e9tablissements",
                    "Estimativa de completude da notifica\u00e7\u00e3o de \u00f3bitos maternos e natimortos nas unidades de sa\u00fade"), 2),
      half("mortality_ratio", admin_level = NULL, variant = "mmr"), half("mortality_ratio", admin_level = NULL, variant = "sbr"),
      .rb_questions(q(
        "Comment on the completeness of reporting of institutional MMR and SBR based on the population MMR and the community to institutional ratio.",
        "Commentez la compl\u00e9tude de la d\u00e9claration du MMR et du SBR institutionnels sur la base du MMR de la population et du rapport communaut\u00e9/\u00e9tablissement.",
        "Comente sobre a completude da notifica\u00e7\u00e3o de MMR e SBR institucionais com base no MMR populacional e na raz\u00e3o comunidade para institucional."
      )),
      .rb_break(),

      .rb_heading(q("5. Curative health service utilization for sick children",
                    "5. Utilisation des services de sant\u00e9 curatifs pour les enfants malades",
                    "5. Utiliza\u00e7\u00e3o de servi\u00e7os de sa\u00fade curativos para crian\u00e7as doentes")),
      .rb_heading(q("Outpatient and inpatient service utilization", "Utilisation des services ambulatoires et d'hospitalisation",
                    "Utiliza\u00e7\u00e3o de servi\u00e7os ambulatoriais e hospitalares"), 2),
      half("service_utilization", admin_level = NULL, variant = "opd"), half("service_utilization", admin_level = NULL, variant = "ipd"),
      .rb_questions(
        q("What is the number of OPD visits per child per year in the latest year, and the trend over time? Is it lower than 1 visit per year, which suggests low access?",
          "Quel est le nombre de consultations externes (OPD) par enfant et par an au cours de la derni\u00e8re ann\u00e9e, et quelle est la tendance ? Est-il inf\u00e9rieur \u00e0 1 consultation par an, ce qui sugg\u00e8re un acc\u00e8s faible ?",
          "Qual \u00e9 o n\u00famero de visitas ambulatoriais (OPD) por crian\u00e7a por ano no \u00faltimo ano e a tend\u00eancia ao longo do tempo? \u00c9 inferior a 1 visita por ano, o que sugeriria baixo acesso?"),
        q("What can be said about the data quality for OPD and IPD visits? Is there consistency of reported numbers between years?",
          "Que peut-on dire de la qualit\u00e9 des donn\u00e9es des consultations externes (OPD) et des hospitalisations (IPD) ? Les nombres d\u00e9clar\u00e9s sont-ils coh\u00e9rents d'une ann\u00e9e \u00e0 l'autre ?",
          "O que pode ser dito sobre a qualidade dos dados das visitas OPD e IPD? H\u00e1 consist\u00eancia nos n\u00fameros reportados entre os anos?"),
        q("What is the number of IPD visits per 100 children per year, and is it increasing? Is it lower than 2 per 100 children under five, which suggests low access?",
          "Quel est le nombre d'hospitalisations (IPD) pour 100 enfants par an, et augmente-t-il ? Est-il inf\u00e9rieur \u00e0 2 pour 100 enfants de moins de cinq ans, ce qui sugg\u00e8re un acc\u00e8s faible ?",
          "Qual \u00e9 o n\u00famero de visitas hospitalares (IPD) por 100 crian\u00e7as por ano, e est\u00e1 aumentando? \u00c9 inferior a 2 por 100 crian\u00e7as menores de cinco anos, o que sugeriria baixo acesso?"),
        q("What can be said about the OPD visits and admissions by region? How large is the difference between top and bottom regions?",
          "Que peut-on dire des consultations externes et des hospitalisations par r\u00e9gion ? Quelle est l'ampleur de l'\u00e9cart entre les meilleures et les moins bonnes r\u00e9gions ?",
          "O que pode ser dito sobre as visitas OPD e admiss\u00f5es por regi\u00e3o? Qual a magnitude da diferen\u00e7a entre as regi\u00f5es superiores e inferiores?")
      ),
      .rb_heading(q("MCH preventive vs curative index", "Indice pr\u00e9ventif vs curatif de la SMI", "\u00cdndice preventivo vs curativo de SMI"), 2),
      half("mch_index", admin_level = NULL),
      .rb_questions(
        q("What is the case fatality among admissions under five? What are the trends?",
          "Quelle est la l\u00e9talit\u00e9 parmi les hospitalisations d'enfants de moins de cinq ans ? Quelles sont les tendances ?",
          "Qual \u00e9 a taxa de letalidade entre admiss\u00f5es de menores de cinco anos? Quais s\u00e3o as tend\u00eancias?"),
        q("What does this say about the quality of care?", "Qu'est-ce que cela indique sur la qualit\u00e9 des soins ?",
          "O que isso indica sobre a qualidade do atendimento?")
      ),
      .rb_break(),

      .rb_heading(q("6. Health system progress and performance", "6. Progr\u00e8s et performance du syst\u00e8me de sant\u00e9",
                    "6. Progresso e desempenho do sistema de sa\u00fade")),
      .rb_heading(q("Health system inputs", "Intrants du syst\u00e8me de sant\u00e9", "Insumos do sistema de sa\u00fade"), 2),
      .rb_chart("health_system_table", type = "table", admin_level = NULL),
      .rb_questions(
        q("Note on completeness of the data (private sector included)?",
          "Remarque sur la compl\u00e9tude des donn\u00e9es (secteur priv\u00e9 inclus) ?",
          "Observa\u00e7\u00e3o sobre a completude dos dados (incluindo o setor privado)?"),
        q("What can be said about the national health system inputs? How do they compare to the benchmarks: health facility density (2 per 10,000), bed density (25 per 10,000), health workforce density (23 per 10,000 for major progress on maternal and child mortality; 44.5 per 10,000 for universal health coverage)?",
          "Que peut-on dire des intrants du syst\u00e8me de sant\u00e9 national ? Comment se comparent-ils aux valeurs de r\u00e9f\u00e9rence : densit\u00e9 des \u00e9tablissements de sant\u00e9 (2 pour 10 000), densit\u00e9 des lits (25 pour 10 000), densit\u00e9 du personnel de sant\u00e9 (23 pour 10 000 pour des progr\u00e8s majeurs sur la mortalit\u00e9 maternelle et infantile ; 44,5 pour 10 000 pour la couverture sanitaire universelle) ?",
          "O que pode ser dito sobre os insumos do sistema de sa\u00fade nacional? Como eles se comparam aos referenciais: densidade de unidades de sa\u00fade (2 por 10.000), densidade de leitos (25 por 10.000), densidade da for\u00e7a de trabalho em sa\u00fade (23 por 10.000 para avan\u00e7ar significativamente na redu\u00e7\u00e3o da mortalidade materna e infantil; 44,5 por 10.000 para alcan\u00e7ar a cobertura universal de sa\u00fade)?")
      ),
      .rb_heading(q("Health system inputs by region", "Intrants du syst\u00e8me de sant\u00e9 par r\u00e9gion", "Insumos do sistema de sa\u00fade por regi\u00e3o"), 2),
      third("health_system_region", admin_level = NULL, variant = "ratio_fac_pop"),
      third("health_system_region", admin_level = NULL, variant = "ratio_hos_pop"),
      third("health_system_region", admin_level = NULL, variant = "ratio_hstaff_pop"),
      .rb_questions(
        q("How does the number of health facilities vary by region?",
          "Comment le nombre d'\u00e9tablissements de sant\u00e9 varie-t-il selon les r\u00e9gions ?",
          "Como varia o n\u00famero de unidades de sa\u00fade por regi\u00e3o?"),
        q("How does hospital density vary by region?", "Comment la densit\u00e9 hospitali\u00e8re varie-t-elle selon les r\u00e9gions ?",
          "Como varia a densidade hospitalar por regi\u00e3o?"),
        q("How does health workforce density vary by region?",
          "Comment la densit\u00e9 du personnel de sant\u00e9 varie-t-elle selon les r\u00e9gions ?",
          "Como varia a densidade da for\u00e7a de trabalho em sa\u00fade por regi\u00e3o?"),
        q("What are the top and bottom regions? Are they consistent across all indicators?",
          "Quelles sont les meilleures et les moins bonnes r\u00e9gions ? Sont-elles les m\u00eames pour tous les indicateurs ?",
          "Quais s\u00e3o as regi\u00f5es superiores e inferiores? Elas s\u00e3o consistentes em todos os indicadores?")
      ),
      .rb_heading(q("Health system outputs by inputs at the subnational level",
                    "R\u00e9sultats du syst\u00e8me de sant\u00e9 selon les intrants au niveau infranational",
                    "Resultados do sistema de sa\u00fade por insumos a n\u00edvel subnacional"), 2),
      half("phc_scatter", admin_level = NULL, variant = "ratio_fac_pop"),
      .rb_questions(
        q("Does the picture look valid, for example by confirming expectations such as more developed regions doing better?",
          "L'image obtenue semble-t-elle valide, par exemple en confirmant des attentes telles que de meilleurs r\u00e9sultats dans les r\u00e9gions plus d\u00e9velopp\u00e9es ?",
          "A imagem obtida parece v\u00e1lida, por exemplo, confirmando expectativas como regi\u00f5es mais desenvolvidas apresentarem melhores resultados?"),
        q("Describe the poor and good performing regions.", "D\u00e9crivez les r\u00e9gions peu performantes et les r\u00e9gions performantes.",
          "Descreva as regi\u00f5es com desempenho ruim e bom.")
      ),
      .rb_heading(q("Private sector and RMNCAH services", "Secteur priv\u00e9 et services de SRMNIA", "Setor privado e servi\u00e7os de SRMNIA"), 2),
      half("private_share", admin_level = NULL, variant = "national"), half("private_share", admin_level = NULL, variant = "area"),
      .rb_questions(
        q("Which indicators have a higher private share?", "Quels indicateurs ont une part du secteur priv\u00e9 plus \u00e9lev\u00e9e ?",
          "Quais indicadores t\u00eam maior participa\u00e7\u00e3o do setor privado?"),
        q("Are there rural and urban differences?", "Existe-t-il des diff\u00e9rences entre zones rurales et urbaines ?",
          "Existem diferen\u00e7as entre \u00e1reas rurais e urbanas?")
      )
    )
  )
}

# ---- the vaccine chartbook (inst/rmd/synthesis_report_vaccine_template.Rmd) ----------------------------------------

.rb_synthesis_vaccine_blocks <- function() {
  third <- function(...) .rb_chart(..., size = "third")
  half <- function(...) .rb_chart(..., size = "half")
  q <- .rb_tx
  c(
    .rb_syn_quality(),
    list(
      third("denominator_trend", admin_level = NULL), third("derived_coverage", "ideliv"), third("derived_coverage", "penta3"),
      .rb_syn_denominator_questions(q("institutional deliveries", "accouchements en \u00e9tablissement", "partos institucionais")),
      .rb_break(),

      .rb_syn_coverage_heading(),
      .rb_heading("{chart_indicators}", 2),
      half("coverage", "anc1"), half("coverage", "ideliv"),
      .rb_questions(.rb_syn_q_plausible()),
      .rb_heading("{chart_indicators}", 2),
      half("coverage", "penta3"), half("coverage", "measles1"),
      .rb_questions(.rb_syn_q_plausible(), .rb_syn_q_targets()),
      .rb_syn_threshold_heading(),
      half("threshold", "vaccine", admin_level = NULL), half("threshold", "dropout", admin_level = NULL),
      .rb_syn_threshold_questions(),
      .rb_break()
    ),

    .rb_syn_equity(),
    list(
      half("inequality", "ideliv", admin_level = "adminlevel_1"), half("inequality", "penta3", admin_level = "adminlevel_1"),
      half("map", "ideliv", admin_level = NULL, variant = "Greens"), half("map", "penta3", admin_level = NULL, variant = "Blues"),
      .rb_syn_geo_questions()
    )
  )
}
