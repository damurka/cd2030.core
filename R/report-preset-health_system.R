# Standard report: health system performance (inst/rmd/health_system_rmncah_template.Rmd and its _fr_ and _pt_ versions):
# the national health system inputs table, the inputs by region, and service outputs by inputs (primary health care
# performance), each with the notes for the analyst. RMNCAH only. See the standard reports section of R/report-builder.R.

.rb_preset_health_system <- function(group) {
  list(
    name = .rb_tx("Health system performance", "Performance du syst\u00e8me de sant\u00e9", "Desempenho do sistema de sa\u00fade"),
    description = .rb_tx("Health system inputs nationally and by region, and service outputs by inputs",
                         "Intrants du syst\u00e8me de sant\u00e9 au niveau national et par r\u00e9gion, et r\u00e9sultats des services selon les intrants",
                         "Insumos do sistema de sa\u00fade a n\u00edvel nacional e por regi\u00e3o, e resultados dos servi\u00e7os segundo os insumos"),
    blocks = .rb_health_system_blocks(),
    cover_patch = list(
      title = .rb_tx("Health system performance for {country}: Countdown analysis",
                     "Performance du syst\u00e8me de sant\u00e9 pour {country} : analyse Countdown",
                     "Desempenho do sistema de sa\u00fade para {country}: an\u00e1lise Countdown")
    )
  )
}

.rb_health_system_blocks <- function() {
  notes <- function(...) .rb_questions(..., title = .rb_tx("Notes", "Notes", "Notas"))
  list(
    .rb_heading(.rb_tx("Health system performance assessment: indicators",
                       "\u00c9valuation de la performance du syst\u00e8me de sant\u00e9 : indicateurs",
                       "Avalia\u00e7\u00e3o do desempenho do sistema de sa\u00fade: indicadores")),
    .rb_heading(.rb_tx("Background", "Contexte", "Contexto"), 2),
    .rb_text(.rb_tx(
      paste("Subnational analyses of health system inputs and service outputs are critical: districts and regions are key units of",
            "the health systems and their service delivery. This includes assessment of system inputs (health workforce,",
            "infrastructure) and outputs (use, coverage)."),
      paste("Les analyses sous-nationales des intrants du syst\u00e8me de sant\u00e9 et des r\u00e9sultats des services sont essentielles : les",
            "districts et les r\u00e9gions sont des unit\u00e9s cl\u00e9s des syst\u00e8mes de sant\u00e9 et de leur prestation de services. Cela comprend",
            "l'\u00e9valuation des intrants du syst\u00e8me (effectif de sant\u00e9, infrastructures) et des r\u00e9sultats (utilisation, couverture)."),
      paste("An\u00e1lises subnacionais de insumos do sistema de sa\u00fade e resultados dos servi\u00e7os s\u00e3o cr\u00edticas: distritos e regi\u00f5es s\u00e3o",
            "unidades-chave dos sistemas de sa\u00fade e de sua presta\u00e7\u00e3o de servi\u00e7os. Isso inclui a avalia\u00e7\u00e3o dos insumos do sistema",
            "(for\u00e7a de trabalho em sa\u00fade, infraestrutura) e dos resultados (uso, cobertura).")
    )),
    .rb_heading(.rb_tx("National health system indicators", "Indicateurs du syst\u00e8me de sant\u00e9 national",
                       "Indicadores do sistema nacional de sa\u00fade"), 2),
    .rb_table("health_system_table"),
    .rb_heading(.rb_tx("Subnational health system indicators", "Indicateurs du syst\u00e8me de sant\u00e9 sous-national",
                       "Indicadores subnacionais do sistema de sa\u00fade"), 2),
    .rb_chart("health_system_region", admin_level = NULL, size = "half", variant = "ratio_fac_pop"),
    .rb_chart("health_system_region", admin_level = NULL, size = "half", variant = "ratio_hos_pop"),
    .rb_chart("health_system_region", admin_level = NULL, size = "half", variant = "ratio_hstaff_pop"),
    .rb_chart("health_system_region", admin_level = NULL, size = "half", variant = "ratio_bed_pop"),
    notes(
      .rb_tx("What can be said about the data quality?",
             "Que peut-on dire de la qualit\u00e9 des donn\u00e9es ?",
             "O que pode ser dito sobre a qualidade dos dados?"),
      .rb_tx("Describe comparison with health system data in WHO database and other countries? Does this suggest under- or overreporting?",
             "D\u00e9crire la comparaison avec les donn\u00e9es du syst\u00e8me de sant\u00e9 dans la base de donn\u00e9es de l'OMS et d'autres pays ? Cela sugg\u00e8re-t-il une sous-d\u00e9claration ou une surd\u00e9claration ?",
             "Descreva a compara\u00e7\u00e3o com os dados do sistema de sa\u00fade no banco de dados da OMS e de outros pa\u00edses? Isso sugere subnotifica\u00e7\u00e3o ou supernotifica\u00e7\u00e3o?"),
      .rb_tx("Is the pattern by region/province as expected?",
             "Le sch\u00e9ma par r\u00e9gion/province est-il conforme aux attentes ?",
             "O padr\u00e3o por regi\u00e3o/prov\u00edncia est\u00e1 conforme o esperado?"),
      .rb_tx("Any reasons for unusual data?",
             "Des raisons expliquant des donn\u00e9es inhabituelles ?",
             "Existem raz\u00f5es para dados incomuns?")
    ),
    .rb_heading(.rb_tx("Primary health care performance", "Performance des soins de sant\u00e9 primaires",
                       "Desempenho da aten\u00e7\u00e3o prim\u00e1ria \u00e0 sa\u00fade")),
    .rb_chart("phc_scatter", admin_level = NULL, variant = "ratio_fac_pop"),
    .rb_chart("phc_scatter", admin_level = NULL, variant = "ratio_hstaff_pop"),
    notes(
      .rb_tx("The interpretation should focus on whether the obtained picture has validity. This may be posited if it confirms some expectations such as more developed regions doing better.",
             "L'interpr\u00e9tation doit se concentrer sur la validit\u00e9 du tableau obtenu. Cela peut \u00eatre avanc\u00e9 s'il confirme certaines attentes, comme le fait que les r\u00e9gions plus d\u00e9velopp\u00e9es obtiennent de meilleurs r\u00e9sultats.",
             "A interpreta\u00e7\u00e3o deve focar em se a imagem obtida tem validade. Isso pode ser sugerido se confirmar algumas expectativas, como regi\u00f5es mais desenvolvidas apresentarem melhor desempenho."),
      .rb_tx("Describe poor and good performing regions/provinces.",
             "D\u00e9crire les r\u00e9gions/provinces aux performances faibles et fortes.",
             "Descreva as regi\u00f5es/prov\u00edncias com desempenho ruim e bom.")
    )
  )
}
