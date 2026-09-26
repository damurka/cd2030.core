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

The constants of the Countdown methodology are defined once, in `R/methodology-defaults.R`:

* `cd_methodology_defaults()` lists them (the adjustment's k and reporting-rate cutoff, the 5 x MAD outlier rule, the
  district reporting threshold, the ratio ranges and score components, the default rates of the denominators, the
  coverage targets, the mortality flags), each with its step, indicator group, unit, label, note and source file.
  The functions that use them read them from there, so the documented values are the ones the code runs with.
* `inst/scripts/export-methodology-defaults.R` writes them as the JSON the DataSuite docs read; the AI guide sync
  workflow also regenerates it on each release and opens a pull request on the docs.

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
