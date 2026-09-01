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
