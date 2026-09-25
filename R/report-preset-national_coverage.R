# Standard report: national coverage (inst/rmd/national_coverage_rmncah_template.Rmd, with its _fr_ and _pt_ versions):
# national coverage trends from facility data and surveys, the continuum of care, family planning (FPET) and the share of
# districts reaching the international targets. RMNCAH only. See the standard reports section of R/report-builder.R for how
# these files are written.
#
# The French and Portuguese templates have lost some of their structure (charts under the wrong headings, a missing chart
# and notes box); the report follows the English template, with their text where they have it.

.rb_preset_national_coverage <- function(group) {
  list(
    name = .rb_tx("National coverage", "Couverture nationale", "Cobertura nacional"),
    description = .rb_tx(
      "Coverage trends from facility data and surveys, continuum of care, family planning and districts reaching the targets",
      "Tendances de la couverture (donn\u00e9es des \u00e9tablissements et enqu\u00eates), continuum de soins, planification familiale et districts atteignant les cibles",
      "Tend\u00eancias de cobertura (dados das unidades de sa\u00fade e inqu\u00e9ritos), continuidade de cuidados, planeamento familiar e distritos que atingem as metas"
    ),
    blocks = .rb_national_coverage_blocks(),
    cover_patch = list(
      title = .rb_tx("National coverage for {country}", "Couverture nationale pour {country}", "Cobertura nacional para {country}"),
      subtitle = .rb_tx("Countdown analysis", "Analyse Countdown", "An\u00e1lise Countdown")
    )
  )
}

# The chart kinds this report adds: the FPET family planning trend and the sub-national continuum of care heatmap
.rb_kinds_national_coverage <- function() list(
  natcov_fpet = .rb_kind("chart", "national", "Family planning: mCPR and demand satisfied (FPET)", groups = "rmncah"),
  natcov_continuum_region = .rb_kind("chart", "national", "Continuum of care by region",
                                     variants = c(maternal = "Maternal", child = "Child"), groups = "rmncah")
)

# FPET estimates of modern contraceptive prevalence and demand satisfied, from 2010
.rb_draw_natcov_fpet <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  d <- cache$fpet_data
  if (is.null(d) || !nrow(d)) cd_abort(c("x" = "No FPET estimates for this country."))
  d <- dplyr::filter(d, d$year >= 2010)
  if (!nrow(d)) cd_abort(c("x" = "No FPET estimates from 2010."))
  plot(
    d,
    title = paste0(t("title_graph_fpet", "Family planning among currently married women 15-49 years"), ", ", cache$country),
    x_axis = t("title_global_year", "Year"),
    y_axis = t("ylab_fpet", "Percent of currently married women 15-49"),
    caption = t("caption_fpet", "Lines show the median estimates. Shaded bands represent the 95% credible interval.\nSource: FPET Track20 modeling"),
    indicator_labels = list(
      prevalence = t("lbl_fpet_mcpr", "Prevalence of Modern Methods (mCPR)"),
      demand = t("lbl_fpet_demand", "Demand Satisfied with a Modern Method")
    )
  )
}

# The maternal or child continuum of care, by region (heatmap)
.rb_draw_natcov_continuum_region <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  type <- if (identical(b$variant, "child")) "child" else "maternal"
  ind <- if (type == "maternal") c("anc1", "anc_1trimester", "anc4", "ideliv", "instlivebirths", "pnc48h") else c("penta3", "measles1", "bcg", "penta1")
  labels <- stats::setNames(lapply(ind, function(i) .rb_ind_name(i18n, i)), ind)
  plot(
    cache$generate_coverage_data("adminlevel_1", type),
    type = "heatmap",
    title = t("title_cov_profile", "National continuum-of-care profile"),
    subtitle = t("subtitle_cov_profile", "Latest facility, latest survey, and WUENIC where relevant"),
    x_axis = NULL,
    y_axis = t("opt_coverage", "Coverage"),
    fill_label = t("opt_coverage", "Coverage"),
    source_labels = list(facility = t("lbl_src_facility", "Facility"), survey = t("lbl_src_survey", "Survey"),
                         wuenic = t("lbl_src_wuenic", "WUENIC")),
    indicator_labels = labels
  )
}

# The national coverage report (inst/rmd/national_coverage_rmncah_template.Rmd) as a block list
.rb_national_coverage_blocks <- function() {
  notes_title <- .rb_tx("Notes", "Notes", "Notas")
  trend_notes <- function() .rb_questions(
    .rb_tx(
      "First address data quality: Are the levels and trends plausible? Is there good consistency between the facility and survey data?",
      "Commencez par la qualit\u00e9 des donn\u00e9es : les niveaux et les tendances sont-ils plausibles ? Y a-t-il une bonne coh\u00e9rence entre les donn\u00e9es des \u00e9tablissements et les donn\u00e9es d\u2019enqu\u00eate ?",
      "Primeiro, aborde a qualidade dos dados: os n\u00edveis e tend\u00eancias s\u00e3o plaus\u00edveis? H\u00e1 boa consist\u00eancia entre os dados das unidades de sa\u00fade e os dados de pesquisa?"
    ),
    .rb_tx(
      "Then, interpret the data if there is sufficient confidence in the observed levels and trends. How does the coverage perform compared to the targets? Is this a positive trend? Are there explanations for the observed levels and trends?",
      "Ensuite, interpr\u00e9tez les donn\u00e9es si vous avez une confiance suffisante dans les niveaux et les tendances observ\u00e9s. Comment la couverture se compare-t-elle aux objectifs ? S\u2019agit-il d\u2019une tendance positive ? Existe-t-il des explications aux niveaux et aux tendances observ\u00e9s ?",
      "Em seguida, interprete os dados se houver confian\u00e7a suficiente nos n\u00edveis e tend\u00eancias observados. Como a cobertura se compara \u00e0s metas? \u00c9 uma tend\u00eancia positiva? Existem explica\u00e7\u00f5es para os n\u00edveis e tend\u00eancias observados?"
    ),
    title = notes_title
  )
  bold <- function(en, fr, pt) .rb_text(.rb_tx(paste0("<b>", en, "</b>"), paste0("<b>", fr, "</b>"), paste0("<b>", pt, "</b>")))
  # the title above each coverage trend chart: {chart_indicator} is the name of the chart under it
  trend_title <- function() bold("Coverage Trends for {chart_indicator}", "Tendances de la couverture pour {chart_indicator}",
                                 "Tend\u00eancias de Cobertura para {chart_indicator}")
  background <- .rb_heading(.rb_tx("Background", "Contexte", "Contexto"), 2)

  list(
    .rb_heading(.rb_tx(
      "5. National Estimates: National Vaccination Coverage trends",
      "5. Estimations nationales : tendances de la couverture vaccinale nationale",
      "5. Estimativas Nacionais: Tend\u00eancias de Cobertura de Vacina\u00e7\u00e3o Nacional"
    )),
    background,
    .rb_text(.rb_tx(
      "Monitoring the coverage of interventions is a critical and direct output of health systems. It is most useful if the national plan has meaningful targets. Both health facility and survey data need to be used.",
      "Le suivi de la couverture des interventions est un r\u00e9sultat critique et direct des syst\u00e8mes de sant\u00e9. Il est le plus utile lorsque le plan national comporte des objectifs pertinents. Les donn\u00e9es des \u00e9tablissements de sant\u00e9 et les enqu\u00eates doivent \u00eatre utilis\u00e9es.",
      "Monitorar a cobertura das interven\u00e7\u00f5es \u00e9 um resultado cr\u00edtico e direto dos sistemas de sa\u00fade. \u00c9 mais \u00fatil se o plano nacional tiver metas significativas. Tanto os dados de unidades de sa\u00fade quanto os de pesquisas precisam ser usados."
    )),

    .rb_heading(.rb_tx("ANC Indicators", "Indicateurs ANC", "Indicadores de ANC"), 2),
    trend_title(),
    .rb_chart("coverage", "anc4"),
    trend_title(),
    .rb_chart("coverage", "anc_1trimester"),
    trend_notes(),

    .rb_heading(.rb_tx("Delivery Care", "Soins d\u2019accouchement", "Cuidados de Parto"), 2),
    trend_title(),
    .rb_chart("coverage", "ideliv"),
    trend_title(),
    .rb_chart("coverage", "instlivebirths"),
    trend_notes(),

    .rb_heading(.rb_tx("Postnatal Indicators", "Indicateurs postnatals", "Indicadores P\u00f3s-natais"), 2),
    trend_title(),
    .rb_chart("coverage", "pnc48h"),
    trend_title(),
    .rb_chart("coverage", "low_bweight"),
    trend_notes(),

    .rb_heading(.rb_tx("Vaccines", "Vaccins", "Vacinas"), 2),
    trend_title(),
    .rb_chart("coverage", "penta3"),
    trend_title(),
    .rb_chart("coverage", "measles1"),
    trend_notes(),

    .rb_heading(.rb_tx("Maternal Continuum of Care", "Continuum de soins maternels", "Continuidade de Cuidados Maternos"), 2),
    .rb_chart("continuum", variant = "maternal"),
    .rb_heading(.rb_tx("Child Continuum of Care", "Continuum de soins infantiles", "Continuidade de Cuidados Infantis"), 2),
    .rb_chart("continuum", variant = "child"),
    .rb_break(),

    .rb_heading(.rb_tx(
      "National coverage trends: family planning",
      "Tendances nationales de la couverture : planification familiale",
      "Tend\u00eancias de cobertura nacional: planejamento familiar"
    )),
    background,
    .rb_text(.rb_tx(
      "Monitoring progress in the uptake and equitable access to family planning services is central to achieving global health and development goals, particularly the Sustainable Development Goal (SDG) 3.7.1, which aims to ensure universal access to sexual and reproductive healthcare services, including for family planning, by 2030. Two key indicators commonly used to assess family planning performance are the Prevalence of Modern Contraceptive Methods (mCPR) and the Percentage of Demand for Family Planning Satisfied with a Modern Method. These indicators not only reflect the extent of contraceptive use among women of reproductive age, particularly those currently married or in union, but also signal the health system\u2019s responsiveness to reproductive intentions and rights. The modern contraceptive prevalence rate (mCPR) indicates the percentage of women utilizing any contemporary method of contraception, providing a direct measure of family planning adoption. In contrast, demand satisfied with a modern method accounts for both current use and unmet need, thereby offering a more comprehensive measure of whether women's reproductive health needs are being fulfilled. Together, these indicators provide insight into both supply- and demand-side dynamics within the family planning landscape.",
      "Le suivi des progr\u00e8s dans l\u2019adoption et l\u2019acc\u00e8s \u00e9quitable aux services de planification familiale est essentiel pour atteindre les objectifs mondiaux de sant\u00e9 et de d\u00e9veloppement, en particulier l\u2019Objectif de D\u00e9veloppement Durable (ODD) 3.7.1, qui vise \u00e0 garantir un acc\u00e8s universel aux services de sant\u00e9 sexuelle et reproductive, y compris la planification familiale, d\u2019ici 2030. Deux indicateurs cl\u00e9s couramment utilis\u00e9s pour \u00e9valuer la performance de la planification familiale sont la Pr\u00e9valence des M\u00e9thodes Contraceptives Modernes (mCPR) et le Pourcentage de la Demande de Planification Familiale Satisfaite par une M\u00e9thode Moderne. Ces indicateurs refl\u00e8tent non seulement l\u2019\u00e9tendue de l\u2019utilisation contraceptive chez les femmes en \u00e2ge de procr\u00e9er, en particulier celles mari\u00e9es ou en union, mais signalent \u00e9galement la r\u00e9activit\u00e9 du syst\u00e8me de sant\u00e9 aux intentions et droits reproductifs. Le taux de pr\u00e9valence des contraceptifs modernes (mCPR) indique le pourcentage de femmes utilisant une m\u00e9thode contraceptive contemporaine, offrant une mesure directe de l\u2019adoption de la planification familiale. En revanche, la demande satisfaite par une m\u00e9thode moderne prend en compte \u00e0 la fois l\u2019utilisation actuelle et les besoins non satisfaits, offrant ainsi une mesure plus compl\u00e8te de la satisfaction des besoins de sant\u00e9 reproductive des femmes. Ensemble, ces indicateurs donnent un aper\u00e7u des dynamiques c\u00f4t\u00e9 offre et c\u00f4t\u00e9 demande dans le paysage de la planification familiale.",
      "Monitorar o progresso na ado\u00e7\u00e3o e no acesso equitativo aos servi\u00e7os de planejamento familiar \u00e9 fundamental para alcan\u00e7ar metas globais de sa\u00fade e desenvolvimento, particularmente o Objetivo de Desenvolvimento Sustent\u00e1vel (ODS) 3.7.1, que visa garantir acesso universal a servi\u00e7os de sa\u00fade sexual e reprodutiva, incluindo o planejamento familiar, at\u00e9 2030. Dois indicadores chave comumente usados para avaliar o desempenho do planejamento familiar s\u00e3o a Preval\u00eancia de M\u00e9todos Contraceptivos Modernos (mCPR) e a Percentagem de Demanda por Planejamento Familiar Satisfeita com um M\u00e9todo Moderno. Esses indicadores n\u00e3o apenas refletem a extens\u00e3o do uso contraceptivo entre mulheres em idade reprodutiva, particularmente aquelas casadas ou em uni\u00e3o, mas tamb\u00e9m sinalizam a capacidade de resposta do sistema de sa\u00fade \u00e0s inten\u00e7\u00f5es e direitos reprodutivos. A taxa de preval\u00eancia de contraceptivos modernos (mCPR) indica a percentagem de mulheres que utilizam qualquer m\u00e9todo contraceptivo contempor\u00e2neo, fornecendo uma medida direta da ado\u00e7\u00e3o do planejamento familiar. Em contraste, a demanda satisfeita com um m\u00e9todo moderno considera tanto o uso atual quanto a necessidade n\u00e3o atendida, oferecendo uma medida mais abrangente de se as necessidades de sa\u00fade reprodutiva das mulheres est\u00e3o sendo atendidas. Juntos, esses indicadores fornecem insights sobre as din\u00e2micas do lado da oferta e da demanda no cen\u00e1rio do planejamento familiar."
    )),
    .rb_text(.rb_tx(
      "Analyzing trends in mCPR and demand satisfied over time allows policymakers, researchers, and program implementers to identify whether countries are making adequate progress, facing stagnation, or experiencing disparities in access. The Family Planning Estimation Tool (FPET), developed by Track20, uses Bayesian modeling to generate national estimates and projections, accommodating irregular survey intervals and enabling tracking toward 2030 targets. However, while aggregate trends are useful, interpreting the relationship between mCPR and demand satisfied is particularly crucial: a scenario where mCPR increases but demand satisfied does not may suggest persistent inequities, service delivery gaps, or a growing unmet need among specific subgroups.",
      "L\u2019analyse des tendances du mCPR et de la demande satisfaite au fil du temps permet aux d\u00e9cideurs, chercheurs et acteurs de programmes d\u2019identifier si les pays progressent de mani\u00e8re ad\u00e9quate, stagnent ou connaissent des disparit\u00e9s d\u2019acc\u00e8s. L\u2019outil d\u2019estimation de la planification familiale (FPET), d\u00e9velopp\u00e9 par Track20, utilise la mod\u00e9lisation bay\u00e9sienne pour g\u00e9n\u00e9rer des estimations nationales et des projections, en tenant compte d\u2019intervalles d\u2019enqu\u00eate irr\u00e9guliers et en permettant le suivi des objectifs \u00e0 l\u2019horizon 2030. Cependant, bien que les tendances agr\u00e9g\u00e9es soient utiles, interpr\u00e9ter la relation entre le mCPR et la demande satisfaite est particuli\u00e8rement crucial : un sc\u00e9nario o\u00f9 le mCPR augmente mais la demande satisfaite n\u2019\u00e9volue pas peut sugg\u00e9rer des in\u00e9galit\u00e9s persistantes, des lacunes dans la prestation de services ou un besoin non satisfait croissant parmi certains sous-groupes.",
      "Analisar as tend\u00eancias de mCPR e demanda satisfeita ao longo do tempo permite que formuladores de pol\u00edticas, pesquisadores e implementadores de programas identifiquem se os pa\u00edses est\u00e3o fazendo progresso adequado, enfrentando estagna\u00e7\u00e3o ou experimentando disparidades no acesso. A Ferramenta de Estimativa de Planejamento Familiar (FPET), desenvolvida pelo Track20, usa modelagem bayesiana para gerar estimativas e proje\u00e7\u00f5es nacionais, acomodando intervalos irregulares entre pesquisas e permitindo acompanhar o progresso rumo \u00e0s metas de 2030. No entanto, embora as tend\u00eancias agregadas sejam \u00fateis, interpretar a rela\u00e7\u00e3o entre o mCPR e a demanda satisfeita \u00e9 particularmente crucial: um cen\u00e1rio em que o mCPR aumenta, mas a demanda satisfeita n\u00e3o, pode sugerir desigualdades persistentes, lacunas na presta\u00e7\u00e3o de servi\u00e7os ou uma necessidade n\u00e3o atendida crescente entre subgrupos espec\u00edficos."
    )),
    .rb_chart("natcov_fpet", admin_level = NULL),
    .rb_questions(
      .rb_tx(
        "<b>What are the overall trends observed over time for both indicators?</b> Examine whether there is consistent progress in the prevalence of modern contraceptive methods (mCPR) and the proportion of demand satisfied with a modern method. Are the trends linear, exponential, or showing signs of stagnation or reversal?",
        "<b>Quelles sont les tendances globales observ\u00e9es au fil du temps pour les deux indicateurs ?</b> Examinez s\u2019il existe une progression constante de la pr\u00e9valence des m\u00e9thodes contraceptives modernes (mCPR) et de la proportion de la demande satisfaite par une m\u00e9thode moderne. Les tendances sont-elles lin\u00e9aires, exponentielles ou montrent-elles des signes de stagnation ou de retournement ?",
        "<b>Quais s\u00e3o as tend\u00eancias gerais observadas ao longo do tempo para ambos os indicadores?</b> Examine se h\u00e1 progresso consistente na preval\u00eancia de m\u00e9todos contraceptivos modernos (mCPR) e na propor\u00e7\u00e3o de demanda satisfeita com um m\u00e9todo moderno. As tend\u00eancias s\u00e3o lineares, exponenciais ou mostram sinais de estagna\u00e7\u00e3o ou revers\u00e3o?"
      ),
      .rb_tx(
        "<b>How does the country's performance align with national or global targets (e.g., SDG 3.7.1)?</b> Assess whether the observed trajectory suggests that the country is on track to meet the Sustainable Development Goal (SDG) target 3.7.1 by 2030, which aims to ensure universal access to sexual and reproductive health-care services, including for family planning.",
        "<b>Comment la performance du pays s\u2019aligne-t-elle avec les objectifs nationaux ou mondiaux (par ex., ODD 3.7.1) ?</b> \u00c9valuez si la trajectoire observ\u00e9e sugg\u00e8re que le pays est en bonne voie pour atteindre l\u2019objectif de l\u2019Objectif de D\u00e9veloppement Durable (ODD) 3.7.1 d\u2019ici 2030, qui vise \u00e0 garantir un acc\u00e8s universel aux services de sant\u00e9 sexuelle et reproductive, y compris la planification familiale.",
        "<b>Como o desempenho do pa\u00eds se alinha com metas nacionais ou globais (por exemplo, ODS 3.7.1)?</b> Avalie se a trajet\u00f3ria observada sugere que o pa\u00eds est\u00e1 no caminho certo para alcan\u00e7ar a meta do Objetivo de Desenvolvimento Sustent\u00e1vel (ODS) 3.7.1 at\u00e9 2030, que visa garantir acesso universal a servi\u00e7os de sa\u00fade sexual e reprodutiva, incluindo o planejamento familiar."
      ),
      .rb_tx(
        "<b>What are the implications if mCPR is increasing while demand satisfied with a modern method is not?</b> Analyze whether a divergence in these trends may indicate a persistently high level of unmet need for family planning, suggesting that while more women are using modern methods, an even greater proportion are still unable to meet their contraceptive needs.",
        "<b>Quelles sont les implications si le mCPR augmente alors que la demande satisfaite par une m\u00e9thode moderne n\u2019\u00e9volue pas ?</b> Analysez si une divergence de ces tendances peut indiquer un niveau persistamment \u00e9lev\u00e9 de besoins non satisfaits en planification familiale, sugg\u00e9rant que bien que davantage de femmes utilisent des m\u00e9thodes modernes, une proportion encore plus grande ne parvient pas \u00e0 r\u00e9pondre \u00e0 leurs besoins contraceptifs.",
        "<b>Quais s\u00e3o as implica\u00e7\u00f5es se o mCPR est\u00e1 aumentando enquanto a demanda satisfeita com um m\u00e9todo moderno n\u00e3o est\u00e1?</b> Analise se uma diverg\u00eancia nessas tend\u00eancias pode indicar um n\u00edvel persistentemente alto de necessidade n\u00e3o atendida de planejamento familiar, sugerindo que, embora mais mulheres estejam usando m\u00e9todos modernos, uma propor\u00e7\u00e3o ainda maior n\u00e3o consegue atender \u00e0s suas necessidades contraceptivas."
      ),
      title = notes_title
    ),
    .rb_break(),

    .rb_heading(.rb_tx(
      "Subnational coverage: assessment of percent of regions that have reached international targets",
      "Couverture sous-nationale : \u00e9valuation du pourcentage de r\u00e9gions ayant atteint les objectifs internationaux",
      "Cobertura subnacional: avalia\u00e7\u00e3o da percentagem de regi\u00f5es que atingiram metas internacionais"
    )),
    background,
    .rb_text(.rb_tx(
      "The global health community has committed to eliminating preventable maternal and newborn deaths through a series of interconnected targets and strategic frameworks. Two key initiatives\u2014Ending Preventable Maternal Mortality (EPMM) and Every Newborn Action Plan (ENAP)\u2014jointly provide a coordinated roadmap to strengthen health systems, ensure equitable access to quality care, and improve accountability for maternal and newborn outcomes. Central to these frameworks are measurable coverage indicators and time-bound targets that track progress toward universal health coverage and the Sustainable Development Goals (SDGs), particularly SDG 3.1 and 3.2.",
      "La communaut\u00e9 mondiale de la sant\u00e9 s\u2019est engag\u00e9e \u00e0 \u00e9liminer les d\u00e9c\u00e8s maternels et n\u00e9onatals \u00e9vitables gr\u00e2ce \u00e0 une s\u00e9rie d\u2019objectifs interconnect\u00e9s et de cadres strat\u00e9giques. Deux initiatives cl\u00e9s \u2014 Ending Preventable Maternal Mortality (EPMM) et Every Newborn Action Plan (ENAP) \u2014 offrent conjointement une feuille de route coordonn\u00e9e pour renforcer les syst\u00e8mes de sant\u00e9, garantir un acc\u00e8s \u00e9quitable \u00e0 des soins de qualit\u00e9 et am\u00e9liorer la responsabilit\u00e9 en mati\u00e8re de r\u00e9sultats maternels et n\u00e9onatals. Au c\u0153ur de ces cadres se trouvent des indicateurs de couverture mesurables et des objectifs temporels qui suivent les progr\u00e8s vers la couverture sant\u00e9 universelle et les Objectifs de D\u00e9veloppement Durable (ODD), en particulier les ODD 3.1 et 3.2.",
      "A comunidade global de sa\u00fade comprometeu-se a eliminar mortes maternas e neonatais evit\u00e1veis por meio de uma s\u00e9rie de metas interconectadas e estruturas estrat\u00e9gicas. Duas iniciativas chave \u2014 Ending Preventable Maternal Mortality (EPMM) e Every Newborn Action Plan (ENAP) \u2014 fornecem conjuntamente um roteiro coordenado para fortalecer os sistemas de sa\u00fade, garantir acesso equitativo a cuidados de qualidade e melhorar a responsabiliza\u00e7\u00e3o pelos resultados maternos e neonatais. No centro dessas estruturas est\u00e3o indicadores de cobertura mensur\u00e1veis e metas com prazos que acompanham o progresso rumo \u00e0 cobertura universal de sa\u00fade e aos Objetivos de Desenvolvimento Sustent\u00e1vel (ODS), particularmente ODS 3.1 e 3.2."
    )),
    .rb_heading("{chart_indicator}", 2),
    .rb_chart("threshold", "anc4", admin_level = NULL),
    .rb_heading("{chart_indicator}", 2),
    .rb_chart("threshold", "instlivebirths", admin_level = NULL),
    .rb_heading("{chart_indicator}", 2),
    .rb_chart("threshold", "vaccine", admin_level = NULL),
    .rb_questions(
      .rb_tx("Interpret in line with the expected subnational targets:",
             "Interpr\u00e9tez en fonction des cibles infranationales attendues :",
             "Interpretar em conformidade com as metas subnacionais esperadas:"),
      .rb_tx("ANC 4+ time attendances: at least 80% of the districts should have a coverage of at least 70%",
             "Au moins 4 visites de soins pr\u00e9natals (ANC 4+) : au moins 80 % des districts devraient avoir une couverture d\u2019au moins 70 %",
             "ANC 4+ atendimentos: pelo menos 80% dos distritos devem ter cobertura de pelo menos 70%"),
      .rb_tx("Institutional delivery: at least 80% of the districts should have a coverage of at least 80%",
             "Accouchement en \u00e9tablissement : au moins 80 % des districts devraient avoir une couverture d\u2019au moins 80 %",
             "Parto institucional: pelo menos 80% dos distritos devem ter cobertura de pelo menos 80%"),
      .rb_tx("Postnatal care within 48 hours: at least 80% of the districts should have a coverage of at least 60%",
             "Soins postnatals dans les 48 heures : au moins 80 % des districts devraient avoir une couverture d\u2019au moins 60 %",
             "Cuidados p\u00f3s-natais dentro de 48 horas: pelo menos 80% dos distritos devem ter cobertura de pelo menos 60%"),
      .rb_tx("Immunization indicators: at least 80% of the districts should have a coverage of at least 90%",
             "Indicateurs de vaccination : au moins 80 % des districts devraient avoir une couverture d\u2019au moins 90 %",
             "Indicadores de imuniza\u00e7\u00e3o: pelo menos 80% dos distritos devem ter cobertura de pelo menos 90%"),
      title = notes_title
    ),

    .rb_heading(.rb_tx("Subnational Maternal Continuum of Care", "Continuum de soins maternels sous-national",
                       "Continuidade de Cuidados Maternos Subnacional"), 2),
    .rb_chart("natcov_continuum_region", admin_level = NULL, variant = "maternal"),
    .rb_heading(.rb_tx("Subnational Child Continuum of Care", "Continuum de soins subnational pour enfants",
                       "Continuidade de Cuidados Infantil Subnacional"), 2),
    .rb_chart("natcov_continuum_region", admin_level = NULL, variant = "child")
  )
}
