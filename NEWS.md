# cd2030.core 1.3.9

* Load Data: the required columns are checked at the Data Quality step, not only at Finish. `new_countdown()`'s
  check (`check_required_columns_exist()`) now also covers the population columns (`Total_Population`,
  `Population_under_5years`, `Population_under_1year`, `Live_births`, `Total_births`, `Women_15_49_years`,
  `Pop_growth_rate`) besides the group's indicators and reporting rates, and the wizard asks the same question of
  the unmerged sheets (`check_required_columns_presheet()`), naming what is missing by sheet, as the workbook
  spells it. A workbook without `Pop_growth_rate` used to pass every check and fail at Finish with "`false` must
  be a vector, not `NULL`" in the first district.
* Load Data: every data quality issue can be downloaded as an Excel workbook from the Data Quality step: a
  summary of the checks and one row per issue, with nothing shortened (`quality_issues_table()`,
  `write_quality_issues()`).
* Bayesian model, sub-national: it is fitted. `generate_bayes_model()` stopped with "Column `source` doesn't exist"
  for every indicator: the regional coverage had the survey's `source` as `source.x` beside the admin mapping's own
  `source` (`source.y`), because the mapping was joined whole. Only its two names are joined now
  (`calculate_coverage()` and `calculate_indicator_coverage()` at admin level 1), so regional coverage has `source`
  again and no `admin1_key`.
* The Bayesian models' estimates as tables: `bayes_model_estimates()` (coverage by year, 2010 to 2030, in percent,
  with the 95% and 80% intervals; a row per region for a sub-national model) and a dataset's
  `$bayes_estimates(admin_level)`, every model already fitted at a level in one table.
* The Bayesian Analysis pages are here (`bayesian_ui()`, `bayesian_page_server()`, moved from cd2030.rmncah), for
  every app: their tabs are `cd_cfg("bayes_indicators")` (default `cd_bayes_indicators`). future and promises are
  imported for them.

# cd2030.core 1.3.8

* `calculate_indicator_coverage()`: zero-dose and under-vaccinated coverage were wrong by a factor of about a million
  (the population in thousands was multiplied by 1000 instead of divided: `(pop*1000 - penta1)/pop*1000`), and for the
  ANC1-, Penta1- and derived denominators, which are counts, the 1000 did not belong at all. They are now the share of
  surviving infants without penta1 (zero-dose) or penta3 (under-vaccinated), as in the Countdown 2030 Stata code.
* Measles2 coverage is divided by the infants surviving to the second dose (`totmeasles2_*`), as in the Stata code and
  as the derived denominators already did, not by those surviving to the first.
* Notebook data: a dataset's notebooks get every table the CacheConnection has (51: the data, the results each page
  shows, the reference data), each listed with what it holds (`ds_list()`'s new `description`, and the list DataSuite
  shows in Stata's `dslist`). `notebook_data("prepare", tables = )` writes only the tables asked for, so Stata
  notebooks get a table when a cell first uses it; Python's are the usual twelve, as before. `wealth_survey` is the
  wealth-quintile survey again (it read a member that does not exist, so it was always empty).
* `notebook_data("describe")`: the notebook's dataset's tables with their columns and what each column holds
  (`cd_describe_columns()`), its grain and key columns, read from the `.rds` without changing it. DataSuite gives it to
  its assistant when it writes a notebook's code, and shows it when you hover a table or a column in a notebook.
* In R notebooks, the attached data (`datasuite:data`) names its tables in the attribute `jovian.tables`, so the
  kernel's variables pane and data viewer list and show them without reading the others or the `ds_*` functions.
* Requires datasuite.ui 0.4.3: charts and tables already drawn follow a change of language.
* `STATA-DIFFERENCES.md` lists where the package and the Countdown 2030 Stata code still differ, by choice.

# cd2030.core 1.3.7

* `cd_table_card_ui()` / `cd_table_card_server()`: a flextable in a chart card, with its picture and its data (Excel)
  in the card's header; the screen and the picture are drawn by the same function. The Overall Score page uses it (and
  rmncah's Service Utilization data quality and national Health System pages). DataSuite's AI can read the table.
* `cd_upload_data_ui()` / `cd_upload_data_server()`: the Load Data screen the apps had each kept a copy of; `cd_app()`
  uses it unless the app passes its own. An app describes its part of the wizard with `options(cd2030.wizard = ...)`
  as before.
* `cd_minimal_theme()`: `ggplot2::theme_minimal()` with a choice of grid lines (the subnational coverage dot plot and
  heat map, and cd2030.pooled's charts). The colours several charts share (the traffic-light categories, the year
  colours, Data Adjustment's steps...) and the theme pieces they repeated (the dashed grid, the maps' theme) are
  defined once (`R/utils-plot-themes.R`); the charts look as before.
* A failed reference-data upload (UN, WUENIC or UN mortality estimates) says why in its banner, instead of
  "Unsupported file format" for every error, and no longer prints the error to the console.
* sf is used through `sf::` instead of imported, so loading cd2030.core no longer loads sf (and GDAL, GEOS and PROJ)
  until a map is drawn or a shapefile read. officer is no longer imported whole (`officer::fp_border()` is its only
  use). No longer imports janitor, which nothing used.
* Needs datasuite.ui 0.4.2: inside DataSuite, `cd_request_bayes_packages()` asks it to install the Bayesian model's
  packages through `datasuite.ui::ds_host_request()`.

# cd2030.core 1.3.6

* `notebook_data()`: a folder's Countdown datasets for DataSuite's notebooks (an app's `notebookData`) -- by name in
  R, and as Stata files for Python and Stata notebooks, made again when their `.rds` changes.
* The Bayesian model's packages are installed when it is first wanted: `cd_bayes_packages_missing()` (checked without
  loading Stan), `cd_request_bayes_packages()` (inside DataSuite, asks it to install them) and
  `cd_bayes_install_command()` (the `install.packages()` call, for plain R). DESCRIPTION's `Config/datasuite/onDemand`
  keeps DataSuite's background install from fetching them; R itself ignores it.
* No longer suggests chromote, countrycode, png, ragg, rsvg, svglite or systemfonts, which nothing used.

# cd2030.core 1.3.5

* Data Adjustment is one page for the data kept and how it is corrected (the Remove Years page is gone; its years
  are the page's first section):
  - Remove years everywhere, or a region's or district's data for some or every year.
  - Completeness by each indicator group's k or an indicator's own, outliers and missing values -- each can be
    switched off everywhere or for a region or district, with its own k; a district's rules come before its
    region's, a region's before everywhere's.
  - Beside each setting, what the check pages found (reporting rates, districts below the threshold, outliers and
    missing values by indicator: `adjustment_evidence()`).
  - The settings are saved in the dataset (`cache$adjustment_settings`, `cache$set_adjustment_settings()`); a dataset
    saved before reads its k-factors and removed years as settings (`adjustment_settings_from_k()`).
  - New: `adjustment_settings_default()`, `adjustment_settings_check()`, `adjustment_settings_footnote()` (the rules in
    a sentence each, for reports) and `adjustment_steps_used()`; `adjust_service_data()` and
    `generate_adjustment_values()` take `settings` (and the latter an `area` and `level`).
* Data Adjustment Changes shows, for each year, the reported count beside the adjusted count made of its parts
  (completeness, missing values, the outliers' correction; a correction that lowers the count drawn as removed), with
  the same in a table -- a step an indicator does not get reads "Off" -- for every area, a region or a district, and
  the rules in force. The adjustment report chart is the same.
* Tables show a table's loader while they are computed.
* Bayesian models: `bayes_model_key()`, `bayes_model_cached()`, `bayes_model_inputs()` and `keep_bayes_model()`, so
  an app can fit a model in the background and keep it.
* Requires datasuite.ui 0.4.0 (reports written by Quire's writers).

# cd2030.core 1.3.4

* The AI can read and change a saved report instead of replacing it: new AI bridge actions (datasuite.ui 0.3.4's
  `report_list()`, `report_read()` and `report_update_blocks()`):
  - `listReports` (read): the reports saved in the dataset.
  - `readReport` (read): a report's blocks in order -- the text of its headings, paragraphs and notes, and for each
    chart and table its kind, settings, options and a short table of the data it shows -- and its language.
  - `updateBlocks` (replace): targeted changes by block id -- write or rewrite text, change a chart's kind, settings,
    chart options or layout, insert blocks after one, remove or move blocks -- checked as a whole and saved once,
    with the report's id kept; everything else in the report stays as it is. The user's permission setting may ask
    them first, with a summary such as `Write 5 paragraphs in the report "Benin National Coverage" (benin.rds)` or
    each change (`Chart "Coverage trend" (anc4): Coverage trend -> Coverage map; year none -> 2023`). The Reports
    page shows the change at once, the open report too.
* A report the AI saves (`saveReport`) carries its own id, as the builder's reports do: the Reports page saves edits
  by it, so edits to a report the AI had saved were not saved (datasuite.ui 0.3.4 also repairs the reports saved
  before).
* Needs datasuite.ui 0.3.4; every package in Imports has a minimum version.

# cd2030.core 1.3.3

* `CacheConnection$denominator_comparison(indicator, admin_level, region)`: the Denominator Selection comparison as
  one tidy table -- for each indicator and year, its coverage under each denominator option (id and label) next to
  the survey estimate of that year with its bounds, the difference in percentage points, and which denominator is
  the one chosen for the indicator. The same numbers as the Denominator Selection charts
  (`calculate_derived_coverage()`), one row per denominator, so the Countdown AI can compare the options in one call.
  By default it compares the indicators the page does. It is chartable, defined in `cache_definition()`, and its
  new columns (`denominator_label`, `selected`, `coverage`, `survey`, `survey_lower`, `survey_upper`, `difference`,
  `survey_year`) are in the data dictionary.

# cd2030.core 1.3.2

* Portuguese: the translations and the report presets' questions read as Portuguese is written in Mozambique and Angola (European norm) instead of Brazilian Portuguese ("Contagem decrescente para 2030", "nados vivos", "Dados em falta", "Transferir"...).

# cd2030.core 1.3.1

* A data dictionary: `cd_dictionary()` says what the ids and column names in the package's data mean -- the six
  denominator options (id, label, what it is, levels), indicators, target populations, reporting rates, fixed columns
  and how names are built (`cov_<indicator>_<denominator>`, `<population>_<denominator>`, `r_<indicator>`, ...).
  `cd_describe_columns()` reads column names with it ("Coverage of Pentavalent 3 (%), denominator: Penta1 population
  growth (penta1derived)") and never guesses a name it can't read. `cd_denominator_labels()` gives the labels,
  translated when given a translator.
* The denominators have one set of labels everywhere -- UN projections, DHIS2 projections, ANC1-derived,
  Penta1-derived, ANC1 population growth, Penta1 population growth -- in the denominator chip, the Denominator
  Selection charts, the reports and the plot legends (new translation keys `lbl_denom_anc1_growth` and
  `lbl_denom_penta1_growth`). `anc1`/`penta1` are the -derived options and `anc1derived`/`penta1derived` the
  population-growth ones; the ids are unchanged.
* `inst/scripts/export-data-dictionary.R` writes the docs' "Data dictionary" reference page from it.
* Every public member of `CacheConnection` is defined (`R/cache-definitions.R`): `cache_definition()` says what each
  data point is in the methodology's terms -- its kind (data, setting, reference, mapping, check, value, store,
  state, method, action), its grain (what one row is) and key columns, its unit, where the user sets it in the app
  and which pages show it, the methodology docs section it comes from, the defaults it follows (ids of
  `cd_methodology_defaults()`) and the members it is computed from. Columns are left to the data dictionary.
  `cache_manifest()` includes each member's `definition`. A test fails when a member is added without one, or when a
  docs link or default reference doesn't resolve. Eight members are marked draft with a note (among them
  `get_regional_estimates()`, which fails for a region because it reads an undefined object).
* `inst/scripts/export-cache-reference.R` writes the docs' "CacheConnection reference" page from the definitions.

# cd2030.core 1.3.0

The constants of the Countdown methodology are defined once, in `R/methodology-defaults.R`:

* `cd_methodology_defaults()` lists them (the adjustment's k and reporting-rate cutoff, the 5 x MAD outlier rule, the
  district reporting threshold, the ratio ranges and score components, the default rates of the denominators, the
  coverage targets, the mortality flags), each with its step, indicator group, unit, label, note and source file.
  The functions that use them read them from there, so the documented values are the ones the code runs with.
* `inst/scripts/export-methodology-defaults.R` writes them as the JSON the DataSuite docs read; the AI guide sync
  workflow also regenerates it on each release and opens a pull request on the docs.

The AI bridge actions:

* `setFilters` only changes the view; `saveReport` and `addGraph` add, or replace when the id given is already saved;
  `generateReport` adds a file, or replaces one of the same name. Each describes itself for the user's confirmation,
  which DataSuite asks only before a replacement.
* A report's image block that names a figure the AI saved in the dataset's analysis folder is stored in the dataset as
  a picture, so the report keeps it (PNG or JPEG from that folder only, up to 5 MB).
* Generated reports go in the analysis folder's `reports/`.
* Requires datasuite.ui 0.3.0.

# cd2030.core 1.2.0

For the Countdown AI in DataSuite (countdown-analytics/docs/AI-PLAN.md), everything around `CacheConnection`:

* The MCP server (`cd2030_mcp_server()` and its tools) is removed; the AI works from `CacheConnection` itself.
* `cache_manifest()`: every public member of `CacheConnection` with its arguments (defaults, allowed values), its
  documentation and whether it writes or can be charted, plus the report kinds, read from the installed package.
* `CacheConnection$decompose_change()`: which districts (or regions) drive a change in an indicator's coverage between
  two years, split into service delivery and denominator, with a reporting-rate flag.
* `CacheConnection$revision` goes up with every saved change; `init_CacheConnection(read_only = TRUE)` opens a dataset
  without ever writing it (the AI's copy).
* Custom charts: report kind `custom_chart` (data from a `CacheConnection` member, fixed transforms, a plot
  description; never code), `cd_chartable_members()`, `cd_member_data()`, `cd_custom_chart_data()`, and saved graphs
  in the dataset (`set_graph()`, `graphs`), which reports can use.
* The AI bridge: the Countdown pages' charts and tables say which report kind they are and with which options; the
  state has the dataset's path, country and revision; new actions `saveReport`, `addGraph` and `generateReport`.
* Requires datasuite.ui 0.2.0.

# cd2030.core 1.1.1

Documentation only; no change to the code.

* A new README: what the package does, where it fits (DataSuite, the Countdown apps, datasuite.ui), installing from
  r-universe, a walkthrough on the bundled Kenya data, `CacheConnection`, indicator groups, reports, building an app
  with `cd_app()`, developing and releasing.
* `?cd2030.core` and `?countdown-pages` give overviews of the entry points and the Countdown pages.
* The pkgdown reference index lists every help topic; `URL` and `BugReports` point to github.com/damurka/cd2030.core.
* The Bayesian coverage packages come from https://alkemalab.r-universe.dev (`Additional_repositories`).

# cd2030.core 1.1.0

* Report builder: standard reports rebuilt as blocks (`report_presets()`), exported to Word, PowerPoint and PDF
  through datasuite.ui's report engine; `cd_report_context()` is a dataset's report context.
* The Countdown pages every Countdown app shares (data quality, denominators, coverage, equity, the Load Data
  wizard, filters, nav sections and `cd_app()`) moved here from the apps, built on datasuite.ui.
* Chart options (`cd_chart_options()` and friends) and the report engine now live in datasuite.ui; they are
  imported and re-exported here, so existing code keeps working.
* Countdown's translations (indicator names, chart titles, page texts) are in `inst/translation/cd2030.json`.

# cd2030.core 1.0.0
* Initial Release
* `CacheConnection` now names a file-backed cache after its source file's
  basename (`<stem>.rds`) instead of `<country>_<timestamp>.rds`, and loads
  an existing matching cache directly instead of treating a fresh parse as
  authoritative when one is already present -- this decision now lives
  entirely in `CacheConnection` itself, so it applies uniformly regardless
  of caller.
* Added `cd2030_mcp_server()`, an optional (`mcptools`/`ellmer` `Suggests`)
  Model Context Protocol server exposing read-only tools -- data quality,
  coverage, inequality, mortality, service utilization, health system, and
  private-sector queries, plus report generation and coverage charts -- over
  an already-processed `.rds` cache, for use with LLM clients like Claude
  Desktop or Claude Code.
* Expanded the MCP server from 12 to 38 tools, covering every remaining
  read-only `CacheConnection` method (mutating setters and non-data methods
  remain deliberately unreachable).
* Standardized MCP tool naming/documentation against the CD2030 analytical
  framework's own vocabulary (`get_coverage_targets`, `get_continuum_of_care`
  renamed to match; DQA/mortality/health-system tool descriptions now cite
  the framework's official metric IDs and named indices), and added the
  three "Equity Assessment" equiplot tools (`get_equiplot_area`,
  `get_equiplot_wealth`, `get_equiplot_education`), bringing the total to 41.
* Fixed stray `print()` debug statements in `generate_report()`,
  `generate_coverage_data()`, and `generate_bayes_model()` that corrupted the
  MCP server's stdio JSON-RPC stream (stdout doubles as the wire protocol,
  so any incidental console output there breaks every client response).
* MCP tool results are now also capped by total cell count
  (`max_cells`, default 5000), not just row count: a row-only cap doesn't
  protect against a very wide table (e.g. `get_indicator_coverage` at
  district level, ~190 columns), where even a handful of rows produced a
  megabyte-scale response that crashed a live client connection.
* Six MCP tools (`get_overall_score`, `get_inequality`,
  `get_completeness_summary`, `get_outliers_summary`, `get_reporting_rate`,
  `get_service_utilization_summary`) now read `CacheConnection`'s cached
  active bindings (e.g. `reporting_rate_district`) instead of always calling
  the always-recomputing `calculate_*`/`compute_*` method, whenever no
  `region` filter is requested -- the exact case those bindings cover.
  Verified identical output to a direct recompute for all six.
