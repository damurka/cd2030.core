# Standard report: health facility data adjustments (inst/rmd/adjustment_rmncah_template.Rmd and its _fr_ and _pt_
# versions): the numbers before and after the adjustments for incomplete reporting and extreme outliers. There is no vaccine
# template: for the vaccine group BCG doses take the place of institutional live births. See the standard reports section
# of R/report-builder.R for how these files are written.

.rb_preset_adjustment <- function(group) {
  list(
    name = .rb_tx("Data adjustment", "Ajustement des donn\u00e9es", "Ajuste dos dados"),
    description = .rb_tx("Reported numbers before and after the adjustments for completeness and outliers",
                         "Nombres d\u00e9clar\u00e9s avant et apr\u00e8s les ajustements pour la compl\u00e9tude et les valeurs aberrantes",
                         "N\u00fameros reportados antes e depois dos ajustes de completude e outliers"),
    blocks = .rb_adjustment_blocks(group),
    cover_patch = list(
      title = .rb_tx("Data adjustment for {country}: Countdown analysis",
                     "Ajustement des donn\u00e9es pour {country} : analyse Countdown",
                     "Ajuste dos dados para {country}: an\u00e1lise Countdown")
    )
  )
}

.rb_adjustment_blocks <- function(group) {
  vaccine <- identical(group, "vaccine")
  # the heading above a vaccine's chart: {chart_indicator} is the name of the chart under it
  doses_heading <- .rb_tx("Health facility data adjustment: Numerators - reported {chart_indicator} doses",
                          "Ajustement des donn\u00e9es des \u00e9tablissements de sant\u00e9 : Num\u00e9rateurs - doses de {chart_indicator} d\u00e9clar\u00e9es",
                          "Ajuste de dados de instala\u00e7\u00f5es de sa\u00fade: Numeradores - doses de {chart_indicator} reportadas")
  first <- if (vaccine) {
    list(
      heading = doses_heading,
      chart = .rb_chart("adj_comparison", "bcg", admin_level = NULL),
      note = .rb_tx(
        paste("Consider the effect of the adjustment on BCG doses, and mention the difference in the number, as well as the",
              "percent increase in {latest_year}; highlight the year with the greatest impact if there is one; interpret if the",
              "impact of the adjustment on coverage rates is large or small"),
        paste("Consid\u00e9rez l'effet de l'ajustement sur les doses de BCG, et indiquez la diff\u00e9rence en nombre ainsi que le",
              "pourcentage d'augmentation en {latest_year} ; mettez en \u00e9vidence l'ann\u00e9e ayant le plus grand impact le cas \u00e9ch\u00e9ant ;",
              "interpr\u00e9tez si l'impact de l'ajustement sur les taux de couverture est important ou faible."),
        paste("Considere o efeito do ajuste nas doses de BCG, e mencione a diferen\u00e7a no n\u00famero, bem como o aumento percentual",
              "em {latest_year}; destaque o ano com o maior impacto, se houver; interprete se o impacto do ajuste nas taxas de",
              "cobertura \u00e9 grande ou pequeno.")
      )
    )
  } else {
    list(
      heading = .rb_tx("Health facility data adjustment: Numerators - reported {chart_indicator}",
                       "Ajustement des donn\u00e9es des \u00e9tablissements de sant\u00e9 : Num\u00e9rateurs d\u00e9clar\u00e9s - {chart_indicator}",
                       "Ajuste de dados de instala\u00e7\u00f5es de sa\u00fade: Numeradores reportados - {chart_indicator}"),
      chart = .rb_chart("adj_comparison", "instlivebirths", admin_level = NULL),
      note = .rb_tx(
        paste("Consider the effect of the adjustment on live births in health facilities, and mention the difference in the",
              "number, as well as the percent increase in {latest_year}; highlight the year with the greatest impact if there is",
              "one; interpret if the impact of the adjustment on coverage rates is large or small"),
        paste("Consid\u00e9rez l'effet de l'ajustement sur les naissances vivantes dans les \u00e9tablissements de sant\u00e9, et indiquez la",
              "diff\u00e9rence en nombre ainsi que le pourcentage d'augmentation en {latest_year} ; mettez en \u00e9vidence l'ann\u00e9e ayant le",
              "plus grand impact le cas \u00e9ch\u00e9ant ; interpr\u00e9tez si l'impact de l'ajustement sur les taux de couverture est important",
              "ou faible."),
        paste("Considere o efeito do ajuste nos nascimentos vivos nas instala\u00e7\u00f5es de sa\u00fade, e mencione a diferen\u00e7a no n\u00famero,",
              "bem como o aumento percentual em {latest_year}; destaque o ano com o maior impacto, se houver; interprete se o",
              "impacto do ajuste nas taxas de cobertura \u00e9 grande ou pequeno.")
      )
    )
  }

  list(
    .rb_heading(.rb_tx("Health facility data adjustments", "Ajustements des donn\u00e9es des \u00e9tablissements de sant\u00e9",
                       "Ajustes de dados de instala\u00e7\u00f5es de sa\u00fade"), 1),
    .rb_heading(.rb_tx("Background", "Contexte", "Contexto"), 2),
    .rb_text(.rb_tx(
      paste("Completeness of reporting affects analysis, especially if it is low or varies between years. Extreme outliers can",
            "have a large impact, especially on subnational numbers. Several steps are necessary to obtain a clean data set for",
            "\u201cendline\u201d analysis, including adjusting for incomplete reporting and correcting for extreme outliers. These graphs",
            "show the impact on the numbers."),
      paste("La compl\u00e9tude des rapports affecte l'analyse, surtout si elle est faible ou varie d'une ann\u00e9e \u00e0 l'autre. Les valeurs",
            "aberrantes extr\u00eames peuvent avoir un impact important, notamment sur les chiffres sous nationaux. Plusieurs \u00e9tapes sont",
            "n\u00e9cessaires pour obtenir un jeu de donn\u00e9es propre pour l'analyse \u00ab endline \u00bb, notamment en ajustant les rapports",
            "incomplets et en corrigeant les valeurs aberrantes extr\u00eames. Ces graphiques montrent l'impact sur les chiffres."),
      paste("A completude dos relat\u00f3rios afeta a an\u00e1lise, especialmente se for baixa ou variar entre os anos. Outliers extremos",
            "podem ter um grande impacto, especialmente nos n\u00fameros subnacionais. V\u00e1rios passos s\u00e3o necess\u00e1rios para obter um",
            "conjunto de dados limpo para a an\u00e1lise de \u201cendline\u201d, incluindo o ajuste para relat\u00f3rios incompletos e a corre\u00e7\u00e3o de",
            "outliers extremos. Esses gr\u00e1ficos mostram o impacto nos n\u00fameros.")
    )),
    .rb_heading(first$heading, 2),
    first$chart,
    .rb_heading(doses_heading, 2),
    .rb_chart("adj_comparison", "penta1", admin_level = NULL),
    .rb_questions(
      first$note,
      .rb_tx("Make the same description and interpretations for penta1 vaccinations",
             "Faites la m\u00eame description et les m\u00eames interpr\u00e9tations pour les vaccinations Penta 1.",
             "Fa\u00e7a a mesma descri\u00e7\u00e3o e interpreta\u00e7\u00f5es para as vacina\u00e7\u00f5es de penta1."),
      title = .rb_tx("Notes", "Notes", "Notas")
    )
  )
}

# ---- the kind this report adds ----

.rb_kinds_adjustment <- function() list(
  adj_comparison = .rb_kind("chart", "adjustment", "Numbers before and after adjustment",
                            indicators = c("instlivebirths", "ideliv", "anc1", "penta1", "penta3", "bcg", "measles1"))
)

# One indicator's yearly numbers before and after the adjustments for completeness and outliers (the cache's k factors)
.rb_draw_adj_comparison <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  ind <- b$indicator %||% "penta1"
  indicator <- .rb_ind_name(i18n, ind)
  fill <- function(text) gsub("{indicator}", indicator, text, fixed = TRUE)
  cache$countdown_data %>%
    generate_adjustment_values(adjustment = "custom", k_factors = cache$k_factors) %>%
    filter_adjustment_value(ind) %>%
    plot(
      title = fill(t("plt_title_adjust_comparison", "Comparison of number of {indicator} before and after adjustments for completness and outliers")),
      legend_labels = c(
        raw = fill(t("lbl_adjust_n_before", "N of {indicator} before adjustment")),
        adjusted = fill(t("lbl_adjust_n_after", "N of {indicator} after adjustment"))
      )
    )
}
