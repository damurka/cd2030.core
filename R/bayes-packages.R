# The Bayesian coverage model's packages (bayescoveragemodel, bayescoveragedeploy and, through them, rstan and Stan)
# are a large download that not every analysis uses, so they are installed when the model is first wanted: inside
# DataSuite DESCRIPTION's `Config/datasuite/onDemand` keeps its background install from fetching them, and the app
# asks for them with cd_request_bayes_packages(); in plain R they stay suggested packages, installed as usual.

.bayes_packages <- c("bayescoveragemodel", "bayescoveragedeploy")
.bayes_repos <- c("https://alkemalab.r-universe.dev", "https://cloud.r-project.org")

#' The Bayesian model's packages that are not installed
#'
#' Checks without loading them (loading brings in Stan).
#'
#' @return A character vector: the packages [generate_bayes_model()] needs and that are not installed, empty when
#'   the model can run.
#' @examples
#' cd_bayes_packages_missing()
#'
#' if (length(cd_bayes_packages_missing()) == 0) {
#'   message("The Bayesian model can run.")
#' }
#' @export
cd_bayes_packages_missing <- function() {
  .bayes_packages[!vapply(.bayes_packages, function(p) length(find.package(p, quiet = TRUE)) > 0, logical(1))]
}

#' Ask DataSuite to install the Bayesian model's packages
#'
#' Inside DataSuite (an app it started), asks it to install them: it shows the progress in its status bar and then
#' offers to restart the app. Outside DataSuite it does nothing; install them with [cd_bayes_install_command()].
#'
#' @param packages The packages to install, by default the missing ones.
#' @return `TRUE` when DataSuite was asked, invisibly.
#' @examples
#' \dontrun{
#' # in an app DataSuite started, before the model is first used
#' if (length(cd_bayes_packages_missing()) > 0) {
#'   cd_request_bayes_packages()
#' }
#'
#' # one package only
#' cd_request_bayes_packages("bayescoveragedeploy")
#' }
#' @export
cd_request_bayes_packages <- function(packages = cd_bayes_packages_missing()) {
  packages <- intersect(packages, .bayes_packages)
  if (!length(packages) || !nzchar(Sys.getenv("CDSUITE_SHINY_ID"))) return(invisible(FALSE))
  # DataSuite's "installPackages" request (Jovian's host channel, or a line on the R session's output); the packages
  # as a list, so that one package is still sent as an array
  datasuite.ui::ds_host_request("installPackages", list(packages = as.list(packages)))
}

#' The R command that installs the Bayesian model's packages
#'
#' For R outside DataSuite.
#'
#' @param packages The packages to install, by default the missing ones.
#' @return The command, as a string.
#' @examples
#' cd_bayes_install_command(c("bayescoveragemodel", "bayescoveragedeploy"))
#'
#' # only what is missing
#' missing <- cd_bayes_packages_missing()
#' if (length(missing) > 0) cd_bayes_install_command(missing)
#' @export
cd_bayes_install_command <- function(packages = cd_bayes_packages_missing()) {
  # nothing to install: no command (it was install.packages(c(""), ...))
  if (!length(packages)) return(character())
  sprintf("install.packages(c(%s), repos = c(%s))",
    paste0('"', packages, '"', collapse = ", "), paste0('"', .bayes_repos, '"', collapse = ", "))
}
