# package init hooks live here

# package-level state env
.cd2030_state <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  # defaults for runtime state
  .cd2030_state$selected_group <- NULL
  .cd2030_state$overrides <- list()

  # Countdown's themes, kinds of chart, standard reports and fields, for the report builder
  .cd_register_reports()

  # Countdown's words (indicator names, chart titles, the pages' and wizard's texts), merged after datasuite.ui's
  datasuite.ui::cd_register_translations(system.file("translation", "cd2030.json", package = pkgname))

  # lock immutable defaults if present
  ns <- asNamespace(pkgname)
  if (exists(".cd2030_indicator_groups", envir = ns, inherits = FALSE)) {
    lockBinding(".cd2030_indicator_groups", ns)
  }
}
