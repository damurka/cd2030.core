# match_country(): the country a name refers to, and no other.

matched <- function(x) match_country(x)$iso3

test_that("a country is found by any of its names, whatever the case, accents or punctuation", {
  expect_identical(matched("Kenya"), "KEN")
  expect_identical(matched("  KENYA "), "KEN")
  expect_identical(matched("KEN"), "KEN")
  expect_identical(matched("Bénin"), "BEN")
  expect_identical(matched("Côte d’Ivoire"), "CIV")
  expect_identical(matched("Cote d Ivoire"), "CIV")
  expect_identical(matched("Ivory Coast"), "CIV")
  expect_identical(matched("Guinea Bissau"), "GNB")
  expect_identical(matched("Swaziland"), "SWZ")
  expect_identical(matched("Tchad"), "TCD")
  expect_identical(matched("Moçambique"), "MOZ")
  expect_identical(matched("Republic of Kenya"), "KEN")
  expect_identical(matched("United Republic of Tanzania"), "TZA")
  expect_identical(matched("The Gambia"), "GMB")
  expect_identical(matched("Gambia"), "GMB")
  expect_named(match_country("Kenya"), c("alternate", "iso3"))
})

test_that("the Democratic Republic of the Congo and the Central African Republic are found by their short names", {
  for (name in c("DRC", "RDC", "DR Congo", "Congo", "Democratic Republic of the Congo", "République Démocratique du Congo")) {
    expect_identical(matched(name), "COD", info = name)
  }
  for (name in c("CAR", "RCA", "Central African Republic", "Centrafrique")) expect_identical(matched(name), "CAF", info = name)
})

test_that("a misspelling of one country is that country", {
  expect_identical(matched("Kenia"), "KEN")
  expect_identical(matched("Sierra Leon"), "SLE")
  expect_identical(matched("Ouganda"), "UGA")
  expect_identical(matched("Ethiopie"), "ETH")
  expect_identical(matched("Madagaskar"), "MDG")
  expect_identical(matched("Burkina"), "BFA")
})

test_that("another country's name is not taken for one that looks like it", {
  # each of these was matched to the country beside it
  others <- c(Sudan = "South Sudan", Libya = "Liberia", Tonga = "Togo", Guyana = "Ghana", Mauritius = "Mauritania",
              Zanzibar = "Zambia", Somaliland = "Somalia", "Congo Brazzaville" = "DRC", "Republic of the Congo" = "DRC",
              "Equatorial Guinea" = "Guinea", Malta = "Mali", Lesotho = "", Atlantis = "")
  for (name in names(others)) expect_error(match_country(name), "not one of the", class = "cd2030_error", info = name)
})

test_that("a misspelling that fits two countries is not guessed, and both are named", {
  err <- tryCatch(match_country("Nigera"), error = function(e) conditionMessage(e))
  expect_match(err, "Nigeria", fixed = TRUE)
  expect_match(err, "Niger\\b")
  # a short name must be exact: one letter off "Mali" or "Togo" is too many names
  expect_error(match_country("Malo"), class = "cd2030_error")
  expect_error(match_country("Toga"), class = "cd2030_error")
})

test_that("a name far from every country gets no suggestion, a near one does", {
  far <- tryCatch(match_country("Atlantis"), error = function(e) conditionMessage(e))
  expect_no_match(far, "Did you mean")
  near <- tryCatch(match_country("Mozambik"), error = function(e) conditionMessage(e))
  expect_match(near, "Mozambique", fixed = TRUE)
})

test_that("what is not one name is refused", {
  expect_error(match_country(c("Kenya", "Uganda")), "multiple", class = "cd2030_error")
  expect_error(match_country("K"), "valid country name", class = "cd2030_error")
  expect_error(match_country("??"), "valid country name", class = "cd2030_error")
})

test_that("every country in the table is found by each of its own names", {
  table <- cd2030.core:::countries
  for (i in seq_len(nrow(table))) {
    own <- c(strsplit(table$country[i], "|", fixed = TRUE)[[1]], table$alternate[i], table$iso3[i])
    own <- setdiff(own, "Sudan") # the table gives it to South Sudan; it is Sudan's
    for (name in own) expect_identical(matched(name), table$iso3[i], info = paste(table$iso3[i], name))
  }
})
