#' MCP Session Store
#'
#' @description
#' The MCP server can have several `CacheConnection` objects open at once
#' (one per loaded `.rds` cache), keyed by the cache's normalized file path.
#' This is a small in-process, environment-backed store with least-recently-used
#' (LRU) eviction so the pool of open caches stays bounded.
#'
#' @keywords internal
#' @name mcp_session
NULL

.mcp_session_state <- new.env(parent = emptyenv())
.mcp_session_state$sessions <- list()

#' @describeIn mcp_session Resolve a user-supplied path to the stable key used
#'   to identify a session. Aborts if the path does not point to an existing file.
#' @noRd
mcp_session_key <- function(path, call = caller_env()) {
  check_file_path(path, call = call)
  normalizePath(path, winslash = "/", mustWork = TRUE)
}

#' @describeIn mcp_session Store (or replace) a session under `key`, then evict
#'   the least-recently-used sessions beyond `max_sessions`.
#' @noRd
mcp_session_store <- function(key, value, max_sessions = 3L) {
  .mcp_session_state$sessions[[key]] <- list(value = value, last_used = Sys.time())
  mcp_session_evict_lru(max_sessions)
  invisible(value)
}

#' @describeIn mcp_session Fetch a previously stored session, marking it as
#'   most-recently-used. Returns `NULL` if nothing is stored under `key`.
#' @noRd
mcp_session_get <- function(key) {
  session <- .mcp_session_state$sessions[[key]]
  if (is.null(session)) {
    return(NULL)
  }
  .mcp_session_state$sessions[[key]]$last_used <- Sys.time()
  session$value
}

#' @describeIn mcp_session Drop the oldest sessions until at most `max_sessions` remain.
#' @noRd
mcp_session_evict_lru <- function(max_sessions) {
  n <- length(.mcp_session_state$sessions)
  if (n <= max_sessions) {
    return(invisible())
  }

  last_used <- vapply(.mcp_session_state$sessions, function(s) as.numeric(s$last_used), numeric(1))
  drop_keys <- names(sort(last_used))[seq_len(n - max_sessions)]
  .mcp_session_state$sessions[drop_keys] <- NULL
  invisible()
}

#' @describeIn mcp_session Number of sessions currently held.
#' @noRd
mcp_session_count <- function() {
  length(.mcp_session_state$sessions)
}

#' @describeIn mcp_session Clear every stored session. Used by tests.
#' @noRd
mcp_session_reset <- function() {
  .mcp_session_state$sessions <- list()
  invisible()
}
