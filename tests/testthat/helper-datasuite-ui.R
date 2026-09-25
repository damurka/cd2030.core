# The report builder moved to datasuite.ui; the tests here that draw Countdown data with it still use some of its
# internal helpers (.rb_*, .ds_*), which this makes visible to them.
.ui_ns <- asNamespace("datasuite.ui")
for (.name in ls(.ui_ns, all.names = TRUE, pattern = "^\\.(rb|ds)_")) {
  if (!exists(.name, envir = asNamespace("cd2030.core"), inherits = FALSE)) assign(.name, get(.name, envir = .ui_ns))
}
