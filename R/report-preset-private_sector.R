# Standard report: the public/private share (inst/rmd/private_sector_rmncah_template.Rmd and its _fr_ and _pt_ versions):
# ownership of health facilities by region, and the private share of services nationally and by area. RMNCAH only. See the
# standard reports section of R/report-builder.R.

.rb_preset_private_sector <- function(group) {
  list(
    name = .rb_tx("Public/private share", "Part public/priv\u00e9", "Participa\u00e7\u00e3o p\u00fablica/privada"),
    description = .rb_tx("Ownership of health facilities and the private share of services, nationally and by area",
                         "Propri\u00e9t\u00e9 des \u00e9tablissements de sant\u00e9 et part priv\u00e9e des services, au niveau national et par zone",
                         "Propriedade das instala\u00e7\u00f5es de sa\u00fade e participa\u00e7\u00e3o privada dos servi\u00e7os, a n\u00edvel nacional e por \u00e1rea"),
    blocks = .rb_private_sector_blocks(),
    cover_patch = list(
      title = .rb_tx("Public/private share for {country}", "Part public/priv\u00e9 pour {country}",
                     "Participa\u00e7\u00e3o p\u00fablica/privada para {country}")
    )
  )
}

.rb_private_sector_blocks <- function() {
  list(
    .rb_heading(.rb_tx("National ownership of health facilities", "Propri\u00e9t\u00e9 nationale des \u00e9tablissements de sant\u00e9",
                       "Propriedade nacional de instala\u00e7\u00f5es de sa\u00fade")),
    .rb_chart("ps_ownership", admin_level = NULL),
    .rb_heading(.rb_tx("National private share of services", "Part priv\u00e9e nationale des services",
                       "Participa\u00e7\u00e3o privada nacional de servi\u00e7os")),
    .rb_chart("private_share", admin_level = NULL, variant = "national"),
    .rb_heading(.rb_tx("Sub-national private share of services by area", "Part priv\u00e9e sous-nationale des services par zone",
                       "Participa\u00e7\u00e3o privada subnacional de servi\u00e7os por \u00e1rea")),
    .rb_chart("private_share", admin_level = NULL, variant = "area")
  )
}

.rb_kinds_private_sector <- function() list(
  ps_ownership = .rb_kind("chart", "private_sector", "Ownership of health facilities by region", groups = "rmncah")
)

# Share of public, private and NGO facilities in each region (the template's "National ownership of health facilities")
.rb_draw_ps_ownership <- function(cache, b, i18n) {
  t <- function(key, fallback) .rb_t(i18n, key, fallback)
  data <- cache$generate_private_sector_data(
    legend_labels = list(Private = t("lbl_private", "Private"), NGO = t("lbl_ngo", "NGO"), Public = t("lbl_public", "Public"))
  )
  plot(data, title = t("title_private_sector_graph", "Ownership of health facilities (DHIS2)"),
       x_axis = t("xlab_private_sector", ""), y_axis = t("ylab_private_sector", "Percent of facilities"))
}
