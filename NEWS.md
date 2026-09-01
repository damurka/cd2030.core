# cd2030.core (development version)
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
