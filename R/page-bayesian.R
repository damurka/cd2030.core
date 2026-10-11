# The Bayesian page fits its models in other R processes (an ExtendedTask with future, bayesian_server() below), so the
# app is not frozen meanwhile. The workers are started the first time a Bayesian page is opened with data loaded (its
# `active()`), before its first fit -- not when the app starts, as most sessions never open the page.

#' Bayesian page server for the page registry
#'
#' The server an app lists for its Bayesian pages in its page registry. It calls [bayesian_server()]
#' with an `active` that also starts the background workers ([cd_start_bayes_workers()]) each time
#' it is read as `TRUE`, which happens first when the page is opened with data loaded. Starting them
#' a second time does nothing, so the workers are started once and only for sessions that open the
#' page.
#'
#' @param id The module's id. A page's id is also its entry in the app's page registry.
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param admin_level A string, not a reactive: the level the models are fitted at, `"national"` or
#'   `"adminlevel_1"` (admin level 1). The registry gives it through the page's `server_args`.
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The page
#'   does no work before that.
#'
#' @return What [bayesian_server()] returns: a reactive that holds the key of the tab shown (an
#'   indicator's name, or `"custom"`).
#'
#' @examples
#' \dontrun{
#' # the page's entry in an app's page registry; server_args gives the admin level
#' cd_page_def(
#'   id = "bayesian_national",
#'   ui = bayesian_ui,
#'   server = bayesian_page_server,
#'   title = "title_bayesian_analysis",
#'   section = "title_bayesian_analysis",
#'   subtitle = "sub_bayesian",
#'   server_args = list("national")
#' )
#'
#' # the same page at admin level 1 is a second entry: id = "bayesian_subnational" and
#' # server_args = list("adminlevel_1")
#' }
#'
#' @concept Countdown app pages
#' @export
bayesian_page_server <- function(id, cache, i18n, admin_level, active = reactive(TRUE)) {
  stopifnot(is.reactive(active))
  bayesian_server(id, cache, i18n, admin_level, active = reactive({
    on <- active()
    if (isTRUE(on)) cd_start_bayes_workers()
    on
  }))
}

#' Start the background workers that fit the Bayesian models
#'
#' Sets the R session's `future` plan to `multisession`, so that the Bayesian page fits its models
#' in other R processes and the app stays usable meanwhile. It changes the plan only while the plan
#' is the default (`sequential`): a session that already has a plan of its own keeps it, and a
#' second call does nothing. There is one worker by default, so a fit asked for while another runs
#' waits its turn. `options(cd2030.bayes_workers = )` sets another number (at least one is always
#' used).
#'
#' @return The session's `future` plan, invisibly.
#'
#' @examples
#' \dontrun{
#' cd_start_bayes_workers()
#' future::nbrOfWorkers()
#'
#' # two fits at a time: set the option before the first call
#' options(cd2030.bayes_workers = 2)
#' cd_start_bayes_workers()
#' }
#'
#' @concept Countdown app pages
#' @export
cd_start_bayes_workers <- function() {
  # One worker: a fit runs its four chains in four more R processes, so one fit already fills a four-core
  # computer. Two fits at once took longer than one after the other even with 24 cores (about 135 s for the
  # pair, against 47 s each), and twice the memory.
  workers <- max(1L, as.integer(getOption("cd2030.bayes_workers", 1L)))
  if (inherits(future::plan(), "sequential")) future::plan(future::multisession, workers = workers)
  invisible(future::plan())
}

#' Fit one Bayesian coverage model in a background worker
#'
#' Hands one fit to a `future` worker and returns at once. The worker runs [generate_bayes_model()]
#' on the coverage data, overall score, indicator and denominator in `inputs`, with `cd2030.core`
#' attached and a parallel-safe random seed. The Bayesian page uses this function as the task of its
#' `shiny::ExtendedTask`. With the default `sequential` plan the fit runs in the calling process;
#' see [cd_start_bayes_workers()].
#'
#' @param inputs A list with `key`, `coverage_data`, `overall_score`, `indicator` and `denominator`,
#'   as the dataset's `bayes_model_inputs()` method returns ([CacheConnection]).
#'
#' @return A promise of a list with two elements: `key`, which is `inputs$key` unchanged, and
#'   `model`, the fitted model. The key lets the caller keep the model for the request it was fitted
#'   for.
#'
#' @examples
#' \dontrun{
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$set_national_estimates(list(sbr = 0.02))
#' cache$adjust_data()
#'
#' # one fit, kept in the dataset when it ends (it takes minutes)
#' inputs <- cache$bayes_model_inputs("national", "penta3")
#' promises::then(cd_bayes_fit_task(inputs), function(out) cache$keep_bayes_model(out$key, out$model))
#'
#' # in a Shiny server: the task of an ExtendedTask
#' fit <- ExtendedTask$new(cd_bayes_fit_task)
#' fit$invoke(inputs)
#' }
#'
#' @concept Countdown app pages
#' @export
cd_bayes_fit_task <- function(inputs) {
  # The worker is sent `inputs` and nothing else (`globals` says so), from a function of the package and not of
  # the page. Left to find what the code needs, future also sent the environment the request was written in
  # (the dataset, the Shiny session and all they reach): packing it took the app's process 211 seconds
  # (profiled, for inputs of 0.3 MB), with every page waiting.
  promises::future_promise(
    list(key = inputs$key, model = cd2030.core::generate_bayes_model(
      coverage_data = inputs$coverage_data,
      overall_score = inputs$overall_score,
      indicator = inputs$indicator,
      denominator = inputs$denominator
    )),
    globals = list(inputs = inputs), packages = "cd2030.core", seed = TRUE
  )
}

#' Indicators the Bayesian coverage model can be fitted for
#'
#' The indicators the Bayesian coverage model has a survey series for. They are the default tabs of
#' the Bayesian page ([bayesian_ui()]). An app shows only the ones its data has by setting
#' `bayes_indicators` in `options(cd2030.config = )`, which the page reads with
#' `cd_cfg("bayes_indicators")` (the vaccine app: penta3 and measles1).
#'
#' @format A character vector of five indicator names: `"anc4"`, `"anc_1trimester"`, `"ideliv"`,
#'   `"measles1"` and `"penta3"`.
#'
#' @examples
#' cd_bayes_indicators
#'
#' # the tabs an app shows: its own setting, or these
#' cd_cfg("bayes_indicators", cd_bayes_indicators)
#'
#' @concept Countdown app pages
#' @export
cd_bayes_indicators <- c('anc4', 'anc_1trimester', 'ideliv', 'measles1', 'penta3')

#' Indicators the Bayesian page shows as tabs
#'
#' @return A character vector: the app's `bayes_indicators` setting, or `cd_bayes_indicators` when
#'   it has none.
#' @noRd
bayesian_indicators <- function() cd_cfg("bayes_indicators", cd_bayes_indicators)

#' Bayesian coverage model page
#'
#' The Bayesian coverage model page, shared by the apps and used at national level and at admin
#' level 1. It has one card of charts with a tab for each indicator the app lists
#' (`cd_cfg("bayes_indicators")`, by default [cd_bayes_indicators]), the only ones the model takes; each tab plots
#' the model's coverage estimates by year. A model takes minutes to fit, so the fit runs in a
#' background worker ([cd_bayes_fit_task()]) and the chart shows its loader meanwhile. A fit starts
#' only when its tab is shown, from the dataset's `bayes_model_inputs()`; the result is kept in the
#' dataset (`keep_bayes_model()`) and read back with `bayes_model_cached()`, so it is fitted once
#' for an admin level, indicator and denominator. While the model's packages are missing
#' ([cd_bayes_packages_missing()]) the page shows a notice and fits nothing: inside DataSuite the
#' notice has a button that asks it to install them, elsewhere it shows the R command to run.
#'
#' The page has no filters of its own. Apps register it with [bayesian_page_server()], which also
#' starts the workers.
#'
#' @param id The module's id. A page's id is also its entry in the app's page registry.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param label Not used.
#'
#' @return `bayesian_ui()` returns the page's UI as Shiny tags. `bayesian_server()` returns a
#'   reactive that holds the key of the tab shown: an indicator's name, or `"custom"`.
#'
#' @examples
#' \dontrun{
#' # a page of your own with the same charts: start the workers, then call the server.
#' # The id must be a page in the app's page registry.
#' my_bayes_ui <- function(id, i18n) bayesian_ui(id, i18n)
#' my_bayes_server <- function(id, cache, i18n, active = reactive(TRUE)) {
#'   cd_start_bayes_workers()
#'   bayesian_server(id, cache, i18n, "adminlevel_1", active = active)
#' }
#' }
#'
#' @concept Countdown app pages
#' @export
bayesian_ui <- function(id, i18n, label) {
  ns <- NS(id)

  cd_page_ui(id, i18n,
    # the model's packages are installed when it is first wanted (see bayesian_server)
    uiOutput(ns("needs_packages")),
    cd_tabbed_charts_ui(ns("panel"), i18n, "title_bayesian_analysis", cd_coverage_plot_ui,
      indicators = bayesian_indicators(), showCustom = FALSE
    )
  )
}

#' @rdname bayesian_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param admin_level A string, not a reactive: the level the models are fitted at, `"national"` or
#'   `"adminlevel_1"` (admin level 1).
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The page
#'   does no work before that.
#' @export
bayesian_server <- function(id, cache, i18n, admin_level, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns

      # The model's packages (Stan and its packages: a large download not every analysis needs) are installed on
      # demand. Inside DataSuite a button asks it to install them (then it offers to restart the app); in plain R
      # the page shows the command. No fit is started while they are missing.
      missing_packages <- cd_bayes_packages_missing()
      output$needs_packages <- renderUI({
        if (!length(missing_packages)) return(NULL)
        in_datasuite <- nzchar(Sys.getenv("CDSUITE_SHINY_ID"))
        div(
          class = "alert alert-info",
          p(i18n$t("msg_bayes_needs_packages")),
          if (in_datasuite) {
            actionButton(ns("install_packages"), i18n$t("btn_bayes_install_packages"), icon = icon("download"))
          } else {
            tags$pre(cd_bayes_install_command(missing_packages))
          }
        )
      })
      observeEvent(input$install_packages, {
        cd_request_bayes_packages(missing_packages)
        showNotification(i18n$t("msg_bayes_installing_packages"), type = "message")
      })

      cd_tabbed_charts_server(
        "panel",
        serverInput = function(id, current_indicator) {

          # A fit (rstan) takes minutes: it runs in another R process (an ExtendedTask with future), so the app stays
          # usable while it runs and the chart shows its loader meanwhile. Each result comes back with the key it was
          # fitted for (admin level, indicator, denominator) and is kept in the dataset under it, so a fit that ends
          # after the denominator changed is kept for the one it was asked for, not shown for the new one.
          fit <- ExtendedTask$new(cd_bayes_fit_task)
          asked <- reactiveVal(NULL)

          # Shiny computes every bound output once on a session's first flush, before it has heard back from
          # the client about which ones are actually visible -- so without req(active()), a fit would start for
          # every indicator, at both admin levels, for a page no one has opened yet. active() (page_is(), see
          # app.R) keeps it from starting until this tab is actually open; and it starts only when the chart asks
          # for the model (the indicator's tab shown), the same fix mortality_mapping_server() already needed.
          model <- reactive({
            req(cache(), active())
            validate(need(!length(missing_packages), i18n$t("msg_bayes_needs_packages")))
            dataset <- cache()
            done <- dataset$bayes_model_cached(admin_level, current_indicator)
            if (!is.null(done)) return(done)
            key <- dataset$bayes_model_key(admin_level, current_indicator)
            if (!identical(isolate(asked()), key)) {
              isolate({
                asked(key)
                fit$invoke(dataset$bayes_model_inputs(admin_level, current_indicator))
              })
            }
            # running: the output stays busy (the chart's loader); an error is shown as the chart's
            out <- fit$result()
            dataset$keep_bayes_model(out$key, out$model)
            req(identical(out$key, key))
            out$model
          })

          cd_coverage_plot_server(
            id = id, # or just ind if inside the same module id
            filename = reactive(paste0(current_indicator, "_bayesian")),
            data_fn = model,
            sheet_name = reactive('bayesian'),
            plot_fun = function(d) {
             nice_indicator <- i18n$t(paste0('opt_', current_indicator))
              
              plot(
                d,
                # Dynamically paste the translated plot title and the translated indicator name
                title = paste(i18n$t("plot_title_bayes_coverage"), "-", nice_indicator),
                x_title = i18n$t("title_global_year"),
                y_title = i18n$t("opt_coverage"),
                caption = i18n$t("plot_legend_source")
              )
            },
            i18n = i18n
          )
        },
        indicators = bayesian_indicators(),
        showCustom = FALSE
      )
      
    }
  )
}