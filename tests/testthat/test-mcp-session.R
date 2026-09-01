test_that("mcp_session_store/get round-trips a value", {
  mcp_session_reset()
  on.exit(mcp_session_reset())

  mcp_session_store("k1", "v1", max_sessions = 3)
  expect_identical(mcp_session_get("k1"), "v1")
  expect_identical(mcp_session_count(), 1L)
})

test_that("mcp_session_get returns NULL for an unknown key", {
  mcp_session_reset()
  on.exit(mcp_session_reset())

  expect_null(mcp_session_get("missing"))
})

test_that("mcp_session_store replaces an existing session under the same key", {
  mcp_session_reset()
  on.exit(mcp_session_reset())

  mcp_session_store("k1", "v1", max_sessions = 3)
  mcp_session_store("k1", "v2", max_sessions = 3)
  expect_identical(mcp_session_get("k1"), "v2")
  expect_identical(mcp_session_count(), 1L)
})

test_that("mcp_session_evict_lru drops the least-recently-used session once over the cap", {
  mcp_session_reset()
  on.exit(mcp_session_reset())

  mcp_session_store("a", "A", max_sessions = 2)
  Sys.sleep(0.01)
  mcp_session_store("b", "B", max_sessions = 2)
  Sys.sleep(0.01)
  # touching "a" makes it more-recently-used than "b"
  mcp_session_get("a")
  Sys.sleep(0.01)

  mcp_session_store("c", "C", max_sessions = 2)

  expect_identical(mcp_session_count(), 2L)
  expect_null(mcp_session_get("b"))
  expect_identical(mcp_session_get("a"), "A")
  expect_identical(mcp_session_get("c"), "C")
})

test_that("mcp_session_key rejects a path that doesn't exist", {
  expect_error(mcp_session_key(tempfile(fileext = ".rds")), class = "cd2030_error")
})
