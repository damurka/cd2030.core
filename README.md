
<!-- README.md is generated from README.Rmd. Please edit that file, then run rmarkdown::render("README.Rmd"). -->

# cd2030.core

Countdown to 2030 analysis of routine health facility data. cd2030.core
loads a country’s facility data, checks its quality, adjusts it for
incomplete reporting and outliers, chooses denominators, and computes
coverage, inequality, mortality, service utilization, health system and
family planning indicators, each with a chart. It also holds everything
the Countdown Shiny apps share: the analysis pages, the Load Data
wizard, the filters and the app frame (`cd_app()`), and Countdown’s
content for the report builder (standard reports, the charts and tables
a report can hold).

It is used in two ways:

- **From R**, as an analysis library: load a dataset, call the
  functions, plot the results.
- **Through the apps**, cd2030.rmncah, cd2030.vaxx and cd2030.pooled,
  which are Shiny front ends to it and run inside DataSuite.

## Where it fits

    DataSuite (VS Code based)
      └─ countdown-analytics            the DataSuite extension: lists the apps, adds the AI tools
           └─ cd2030.rmncah / cd2030.vaxx / cd2030.pooled    the apps, one R package each: run_app()
                └─ cd2030.core          THIS PACKAGE: analysis, Countdown pages, wizard, report content
                     └─ datasuite.ui    generic interface kit, chart options, report builder (knows nothing of Countdown)

- **datasuite.ui** (<https://github.com/damurka/datasuite.ui>) is the
  generic layer: Shiny/React components, the page frame, chart options
  and the Word/PowerPoint/PDF report engine. cd2030.core plugs Countdown
  into it (its report content through `report_register()`, its
  translations through `cd_register_translations()`, both in `.onLoad`).
  datasuite.ui never calls cd2030.core.
- **The apps** (<https://github.com/damurka/cd2030.rmncah>, `.vaxx`,
  `.pooled`) each set their options, list their pages and call
  `cd_app()`.
- **countdown-analytics**
  (<https://github.com/damurka/countdown-analytics>) is the DataSuite
  extension. Its `shinyApps` entries name each app’s package; DataSuite
  installs it when the extension is installed, updates it when the
  extension is updated, and launches it.
- Every package is published at **<https://damurka.r-universe.dev>**
  (built on each push to `main`). The Bayesian model uses
  bayescoveragemodel and bayescoveragedeploy, suggested packages from
  <https://alkemalab.r-universe.dev>.

## Installation

``` r
install.packages(
  "cd2030.core",
  repos = c("https://damurka.r-universe.dev", "https://alkemalab.r-universe.dev", "https://cloud.r-project.org")
)
```

Many features use suggested packages: PDF export (chromote with Chrome,
or Word/LibreOffice), editable PowerPoint charts (rvg), pictures
(magick, rsvg, svglite, ragg), the MCP server (mcptools, ellmer), the
Bayesian model. Install them with `dependencies = TRUE`. DataSuite
installs them for the apps.

## Using it from R

``` r
library(cd2030.core)

# A dataset: the Countdown Excel workbook (Admin, Population, Reporting and service sheets), a Stata .dta master
# file, or a saved .rds. The result is a CacheConnection: the data plus every choice made about it.
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
data <- cache$countdown_data      # the checked data (a cd_data tibble); load_data(path) gives just this

# Data quality
calculate_average_reporting_rate(data)
calculate_outliers_summary(data)
calculate_overall_score(data, threshold = 90)
plot(calculate_district_reporting_rate(data, threshold = 90))

# Adjustment, denominators and coverage go through the cache, which remembers each choice. Coverage also needs the
# national rates and survey estimates the Load Data wizard collects (cache$set_national_estimates(),
# cache$set_survey_estimates(), ...); the apps' pages show what each analysis needs.
cache$set_k_factors(c(anc = 0.25, idelv = 0.25, vacc = 0.25, opd = 0.25))   # opd only for rmncah
coverage <- cache$calculate_indicator_coverage("national")

# A standard report, written as Word (or "pdf", or "pptx" for a slide deck)
reports <- report_presets("en")
export_report(cache, reports[["data_quality"]], "data_quality.docx", format = "docx")

# Save the dataset and its choices next to the data, to reopen later with load_cache_data("kenya.rds")
cache$set_cache_path("kenya.rds")
```

The functions are grouped by analysis step in the reference
(`help(package = "cd2030.core")`, and the package overview
`?cd2030.core`). A few things worth knowing:

- **CacheConnection** (`?CacheConnection`) is the dataset object. The
  apps pass it to every page; its setters record choices (excluded
  years, adjustment factors, denominators, surveys, region mappings,
  chart options, saved reports) and its methods compute results with
  them. It saves itself to an `.rds` named after the data file.
- **Indicator groups** decide which indicators a dataset has. Two are
  built in, `"rmncah"` and `"vaccine"`, and `load_data()` detects which
  one fits (`indicator_group = "auto"`). `register_indicator_group()`
  adds a custom one; `set_selected_group()` picks the group the package
  works with; `list_indicator_groups()` lists them.
- **Chart options and reports.** Every chart is finished with its saved
  options (`cd_finish_plot()`, options from datasuite.ui’s
  `cd_chart_options()`, re-exported here). `report_presets()` are
  Countdown’s standard reports; `export_report()` (datasuite.ui,
  re-exported) writes any report for a dataset.
- **AI analysis.** `cd2030_mcp_server()` runs an MCP server with
  read-only tools over a dataset’s `.rds`, for an AI assistant
  (`Rscript -e "cd2030.core::cd2030_mcp_server()"`).

## Building an app on it

An app is a small package whose `run_app()` says what is particular to
it and calls `cd_app()`. `cd2030.rmncah::run_app()` is the complete
example; in outline:

``` r
run_app <- function(language = "en", selected_file = NA) {
  set_selected_group("rmncah")                       # the app's indicator group
  options(
    cd2030.app_group = "rmncah",
    cd2030.config = list(                            # what the shared pages show for this app (see ?countdown-pages)
      nat_cov_indicators = c("anc4", "instlivebirths", "penta3", "measles1"),
      consistency_pairs = list(c("anc1", "penta1"), c("penta1", "penta3")),
      has_maternal = TRUE
    ),
    cd2030.help_dir = system.file("intro", package = "myapp")   # the Introduction page's help, per language
  )

  # translations (datasuite.ui's cd_translations()): datasuite.ui's, cd2030.core's (registered when it loads) and the
  # app's own file, merged
  i18n <- shiny.i18n::init_i18n(translation_json_path = cd_translations(system.file("translation", "translation.json", package = "myapp")))
  i18n$set_translation_language(language)
  cd_use_i18n(i18n)

  cd_app(
    app_name = "My app", app_version = "1.0.0", theme = "rmncah",
    nav_sections = list(cd_nav_start(), cd_nav_quality(), cd_nav_denominators()),  # the sidebar
    registry = my_pages(),                           # every page: the shared ones and the app's own
    i18n = i18n, language = language, selected_file = selected_file,
    upload_ui = upload_data_ui, upload_server = upload_data_server
  )
}
```

`?countdown-pages` lists the shared pages, the Load Data wizard, the
filters and the `cd2030.config` keys. The interface kit they are built
from is documented in datasuite.ui (`docs/README.md`,
`docs/COMPONENTS.md`).

## Developing

``` r
devtools::load_all()     # work on the package
devtools::test()         # tests/testthat (uses inst/extdata/kenya.xlsx)
devtools::document()     # after changing roxygen comments
devtools::check()        # must stay at 0 errors, 0 warnings, 0 notes
```

- **Install locally** with
  `devtools::install(quick = TRUE, upgrade = FALSE, dependencies = FALSE)`,
  after installing your local datasuite.ui. Without
  `dependencies = FALSE`, the `Remotes: damurka/datasuite.ui` field
  makes devtools reinstall datasuite.ui from GitHub over your local
  copy.
- **Stop running apps first** on Windows: a running Shiny app has the
  package loaded, and its files can’t be replaced.
- **R sources must be ASCII** (R CMD check): write other characters as
  `\u` escapes in strings.
- **Translations** for text shown in the apps are in
  `inst/translation/cd2030.json` (English, French, Portuguese).
- Undefined-global notes from dplyr code are silenced in `R/globals.R`;
  add new column names there.

## Releasing

1.  Bump `Version:` in `DESCRIPTION` and add a section to `NEWS.md`.
2.  `devtools::check()` clean.
3.  Commit, tag (`git tag -a vX.Y.Z -m "cd2030.core X.Y.Z"`) and push
    `main` and the tag.
4.  r-universe builds it from `main` (within minutes when its GitHub app
    is installed, otherwise within about an hour); see
    <https://damurka.r-universe.dev/builds>.
5.  If an app needs the new version, raise its `cd2030.core (>= X.Y.Z)`
    in the app’s `DESCRIPTION`.

See [NEWS.md](NEWS.md) for what changed in each version.

## Getting help

Report bugs at <https://github.com/damurka/cd2030.core/issues>.
