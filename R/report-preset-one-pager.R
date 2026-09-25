# Standard report: the sub-national one-page profile, one region on one dense 16:9 slide (a slide deck of one slide,
# see R/report-deck.R). Its charts and tables use the report's region ("@report"). RMNCAH:
# inst/rmd/admin_level_1_one_pager_rmncah_template.Rmd (and _fr_, _pt_); vaccine:
# inst/rmd/admin_level_1_one_pager_vaccine_template.Rmd.

.rb_preset_one_pager <- function(group) {
  list(
    name = .rb_tx("Sub-national one-pager", "Fiche d'une page par r\u00e9gion", "Ficha de uma p\u00e1gina por regi\u00e3o"),
    description = .rb_tx("One region on one slide: data quality, coverage and districts",
                         "Une r\u00e9gion sur une diapositive : qualit\u00e9 des donn\u00e9es, couverture et districts",
                         "Uma regi\u00e3o num diapositivo: qualidade dos dados, cobertura e distritos"),
    kind = "deck",
    slides = list(list(
      id = "op_s1",
      layout = "blank",
      items = if (identical(group, "vaccine")) .rb_one_pager_vaccine_items() else .rb_one_pager_items(),
      notes = NULL
    )),
    design_patch = list(slide_size = "16:9", cover = FALSE, contents = FALSE, page_numbers = FALSE, header = "", footer = "")
  )
}

# One item of a slide, at x, y with size w x h (inches from the slide's top-left); its block's id is the item's with "_b"
.rb_op_item <- function(id, x, y, w, h, block, role = NULL) {
  block$size <- NULL
  item <- list(id = id, x = x, y = y, w = w, h = h)
  if (!is.null(role)) item$role <- role
  item$block <- c(list(id = paste0(id, "_b")), block)
  item
}

# The title and the line under it across the top of the slide, shared by both groups
.rb_one_pager_title_items <- function() {
  list(
    .rb_op_item("op_t", 0.3, 0.18, 12.733, 0.52, role = "title", list(
      type = "paragraph", font_size = 24, valign = "middle",
      text = .rb_tx("<p>Sub-national statistical profile: {region}</p>",
                    "<p>Profil statistique infranational : {region}</p>",
                    "<p>Perfil estat\u00edstico subnacional: {region}</p>"))),
    .rb_op_item("op_st", 0.3, 0.7, 12.733, 0.32, role = "subtitle", list(
      type = "paragraph", font_size = 12, valign = "top",
      text = .rb_tx("<p>{country} \u00b7 health facility data (DHIS2), {first_year}-{latest_year}</p>",
                    "<p>{country} \u00b7 donn\u00e9es des \u00e9tablissements de sant\u00e9 (DHIS2), {first_year}-{latest_year}</p>",
                    "<p>{country} \u00b7 dados das unidades de sa\u00fade (DHIS2), {first_year}-{latest_year}</p>")))
  )
}

# The two tables at the right of the slide: the data quality score above, a district table below
.rb_one_pager_tables <- function(district_kind) {
  list(
    .rb_op_item("op_t1", 8.9, 1.1, 4.133, 2.6, .rb_chart("overall_score", type = "table", admin_level = NULL, region = "@report")),
    .rb_op_item("op_t2", 8.9, 3.85, 4.133, 3.4, .rb_chart(district_kind, type = "table", admin_level = NULL, region = "@report"))
  )
}

# RMNCAH (inst/rmd/admin_level_1_one_pager_rmncah_template.Rmd): penta3, institutional live births and ANC4 in the
# region against the other regions (top row) and over time (bottom row), three charts to a row; the data quality score
# and the coverage of the main indicators by district at the right
.rb_one_pager_items <- function() {
  x <- c(0.3, 3.15, 6)
  y <- c(1.1, 4.25)
  inds <- c("penta3", "instlivebirths", "anc4")
  top <- lapply(1:3, function(k) .rb_op_item(paste0("op_c", k), x[k], y[1], 2.7, 3,
                                             .rb_chart("region_coverage", inds[k], admin_level = NULL, region = "@report")))
  bottom <- lapply(1:3, function(k) .rb_op_item(paste0("op_c", k + 3), x[k], y[2], 2.7, 3,
                                                .rb_chart("coverage", inds[k], admin_level = "adminlevel_1", region = "@report")))
  c(.rb_one_pager_title_items(), top, bottom, .rb_one_pager_tables("district_table"))
}

# Vaccine (inst/rmd/admin_level_1_one_pager_vaccine_template.Rmd): penta3 and institutional live births in the region
# against the other regions and over time, two charts to a row; the data quality score and the population and coverage
# of each district with the region's totals at the right
.rb_one_pager_vaccine_items <- function() {
  x <- c(0.3, 4.575)
  y <- c(1.1, 4.25)
  inds <- c("penta3", "instlivebirths")
  top <- lapply(1:2, function(k) .rb_op_item(paste0("op_c", k), x[k], y[1], 4.125, 3,
                                             .rb_chart("region_coverage", inds[k], admin_level = NULL, region = "@report")))
  bottom <- lapply(1:2, function(k) .rb_op_item(paste0("op_c", k + 2), x[k], y[2], 4.125, 3,
                                                .rb_chart("coverage", inds[k], admin_level = "adminlevel_1", region = "@report")))
  c(.rb_one_pager_title_items(), top, bottom, .rb_one_pager_tables("op_district_population"))
}

.rb_kinds_one_pager <- function() list(
  op_district_population = .rb_kind("table", "region", "Population and coverage by district in a region", year = TRUE,
                                    regional = TRUE)
)

# Population (total, live births, under 1) and coverage (ANC1, institutional births, penta1, penta3, MCV1, MCV3) of each
# district of one region in one year, under a first row with the region's totals (sums of the populations, means of the
# coverages)
.rb_draw_op_district_population <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  region <- b$region
  if (is.null(region) || identical(region, "@report") || !nzchar(region)) cd_abort(c("x" = "Choose a region."))
  year <- b$year %||% robust_max(cache$data_years)

  cov <- cache$indicator_coverage_district
  cov <- cov[cov$adminlevel_1 == region & cov$year == year, , drop = FALSE]
  if (!nrow(cov)) cd_abort(c("x" = "No district coverage for {region} in {year}."))

  pop <- cache$countdown_data
  pop <- pop[pop$adminlevel_1 == region & pop$year == year, , drop = FALSE]
  pop <- unique(as.data.frame(pop)[, intersect(c("district", "total_pop", "live_births"), names(pop)), drop = FALSE])
  pop <- pop[!duplicated(pop$district), , drop = FALSE]
  under1 <- as.data.frame(cov)[, intersect(c("district", "totunder1_dhis2"), names(cov)), drop = FALSE]
  table <- merge(pop, under1, by = "district", all = TRUE)
  pop_cols <- intersect(c("total_pop", "live_births", "totunder1_dhis2"), names(table))
  for (col in pop_cols) table[[col]] <- round(as.numeric(table[[col]]))

  wanted <- c("anc1", "instlivebirths", "penta1", "penta3", "measles1", "measles3")
  cols <- vapply(wanted, function(ind) paste0("cov_", ind, "_", cache$get_denominator(ind) %||% ""), character(1))
  keep <- cols[cols %in% names(cov)]
  cov_data <- as.data.frame(cov)[, c("district", keep), drop = FALSE]
  for (col in keep) cov_data[[col]] <- round(as.numeric(cov_data[[col]]), 1)
  table <- merge(table, cov_data, by = "district", all = TRUE)
  table <- table[order(table$district), , drop = FALSE]

  totals <- table[1, , drop = FALSE]
  totals$district <- region
  for (col in pop_cols) totals[[col]] <- round(sum(table[[col]], na.rm = TRUE), 1)
  for (col in keep) totals[[col]] <- round(mean(table[[col]], na.rm = TRUE), 1)
  out <- rbind(totals, table)
  out <- out[, c("district", pop_cols, keep), drop = FALSE]

  pop_labels <- c(total_pop = t("opt_population", "Population"), live_births = t("opt_births", "Live births"),
                  totunder1_dhis2 = t("opt_under1", "Under 1"))
  ind_labels <- c(anc1 = t("opt_anc1", "ANC 1"), instlivebirths = t("opt_instlivebirths", "Inst. births"),
                  penta1 = t("opt_penta1", "Penta 1"), penta3 = t("opt_penta3", "Penta 3"),
                  measles1 = t("opt_measles1", "MCV 1"), measles3 = t("opt_measles3", "MCV 3"))
  header <- c(district = t("lbl_rb_district", "District"), pop_labels[pop_cols], stats::setNames(ind_labels[names(keep)], keep))

  ft <- flextable::flextable(out)
  ft <- flextable::set_header_labels(ft, values = as.list(header))
  ft <- flextable::fontsize(ft, size = 11, part = "all")
  ft <- flextable::bold(ft, part = "header")
  ft <- flextable::bold(ft, i = 1, part = "body")
  ft <- flextable::bg(ft, i = 1, part = "body", bg = "grey90")
  flextable::autofit(ft)
}
