test_that("every public CacheConnection member has a definition", {
  defs <- cache_definition()
  members <- .cd_public_members()
  missing <- setdiff(members, names(defs))
  expect(length(missing) == 0,
         sprintf("Define these CacheConnection members in R/cache-definitions.R: %s", paste(missing, collapse = ", ")))
  expect_setequal(names(defs), members)
})

test_that("definitions are well formed", {
  kinds <- c("data", "setting", "reference", "mapping", "check", "value", "store", "state", "method", "action")
  for (name in names(cache_definition())) {
    d <- cache_definition(name)
    expect_true(d$kind %in% kinds, info = name)
    expect_true(is.character(d$what) && nzchar(d$what), info = name)
    expect_true(d$status %in% c("defined", "draft"), info = name)
    if (identical(d$status, "draft")) expect_true(is.character(d$note) && nzchar(d$note), info = name)
    if (!is.null(d$grain)) expect_identical(d$columns_from, "dictionary", info = name)
  }
  expect_null(cache_definition("not_a_member"))
  expect_error(cache_definition(c("a", "b")))
})

test_that("what a definition depends on is another member", {
  members <- .cd_public_members()
  for (name in names(cache_definition())) {
    deps <- cache_definition(name)$depends_on
    expect_true(all(deps %in% members), info = paste(name, "->", paste(setdiff(deps, members), collapse = ", ")))
  }
})

test_that("defaults and ranges refer to methodology constants", {
  ids <- cd_methodology_defaults()$id
  for (name in names(cache_definition())) {
    d <- cache_definition(name)
    refs <- c(d$default, d$range)
    # a range given as text ("0 to 100 ...") is not a reference
    refs <- refs[!grepl(" ", refs)]
    expect_true(all(refs %in% ids), info = paste(name, "->", paste(setdiff(refs, ids), collapse = ", ")))
  }
})

test_that("setters and clearers are defined through the member they change", {
  defs <- cache_definition()
  expect_identical(defs$set_k_factors$depends_on, "k_factors")
  expect_identical(defs$set_k_factors$set_on, defs$k_factors$set_on)
  expect_match(defs$clear_survey_mapping$what, "^Clears `survey_mapping`")
  expect_identical(defs$set_report_project$depends_on, "report_projects")
  setters <- grep("^(set|clear|reset)_", names(defs), value = TRUE)
  expect_true(all(vapply(defs[setters], function(d) d$kind == "action", logical(1))))
  expect_true(all(vapply(defs[setters], function(d) d$status == "defined", logical(1))),
              info = "a setter whose member has no definition of its own")
})

test_that("method links point to sections of the methodology docs", {
  urls <- unique(unlist(lapply(cache_definition(), function(d) d$method)))
  expect_true(all(startsWith(urls, "https://datasuite.damurka.com/en/docs/methodology/")))
  # the docs corpus (countdown-analytics ai/corpus.json) lists every page's anchors, as the site builds them
  corpus_file <- Sys.getenv("CD_DOCS_CORPUS", test_path("..", "..", "..", "countdown-analytics", "ai", "corpus.json"))
  skip_if_not(file.exists(corpus_file), "The docs corpus is not next to this package.")
  skip_if_not_installed("jsonlite")
  corpus <- jsonlite::fromJSON(corpus_file, simplifyVector = FALSE)
  known <- unlist(lapply(corpus$pages, function(p) {
    c(p$url, vapply(p$sections, function(s) if (nzchar(s$anchor)) paste0(p$url, "#", s$anchor) else p$url, ""))
  }))
  unknown <- setdiff(urls, known)
  expect(length(unknown) == 0, sprintf("Not in the docs: %s", paste(unknown, collapse = ", ")))
})

test_that("cache_manifest() carries each member's definition", {
  m <- cache_manifest()
  names <- vapply(m$members, function(x) x$name, "")
  expect_true(all(vapply(m$members, function(x) !is.null(x$definition), logical(1))))
  adjusted <- m$members[[which(names == "adjusted_data")]]
  expect_identical(adjusted$definition$kind, "data")
  expect_match(adjusted$definition$grain, "district x year x month")
})
