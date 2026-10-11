# Corrects the C-section rows of the built-in public/private shares (`private_share`, in R/sysdata.rda).
#
# What was wrong. load_private_sector_data() gave each sector its share of the C-sections of the WHOLE file -- every
# country together -- where it should be the sector's share within its own country and year (and area). The built-in
# shares were made that way from a file of 32 countries, so a country's two C-section bars added up to its survey rate
# times the country's share of all 32 countries' C-sections: Kenya 2022 was drawn at 1.8 % where its survey rate is
# 16.5 %. The private share (the ratio of the two bars) was right; their heights were not.
#
# What this does. A country's two bars keep their ratio and are scaled to add up to its C-section rate:
#   corrected = rate * bar / (public bar + private bar)
# The rate is the survey's own (survey_data$all, survey_data$area: r_csection of the same country, year and area),
# which is what the correction file held: with it, the 32 countries' old shares add up to 1 (0.998 from the 31 that
# have a survey record here). Somalia 2006 has no survey record in the package; its rate is what is left of that
# total, old total / (1 - the others' shares), about 2 %.
#
# The source files (the national and area estimates and the C-section corrections) are not in this repository. If
# they are found, rebuild from them with the corrected load_private_sector_data() and drop this script.
#
# Run from the package's folder:  Rscript data-raw/private_share_csection.R

suppressPackageStartupMessages(library(dplyr))

file <- "R/sysdata.rda"
data <- new.env()
load(file, envir = data)

correct <- function(shares, survey, by_area) {
  keys <- c("iso", "year", if (by_area) "area")
  rates <- survey %>%
    transmute(iso = .data$iso3, year = .data$year, area = if (by_area) tolower(.data$level) else NA_character_,
              rate = .data$r_csection / 100) %>%
    select(all_of(c(keys, "rate"))) %>%
    distinct()

  csection <- shares %>%
    filter(.data$indic == "csection") %>%
    mutate(old_total = .data$r_raw_Public + .data$r_raw_Private) %>%
    left_join(rates, by = keys) %>%
    # a country with no survey record: what the others leave of the total (1), within the same group of rows
    mutate(
      left = 1 - sum(.data$old_total / .data$rate, na.rm = TRUE),
      rate = if_else(is.na(.data$rate), .data$old_total / .data$left, .data$rate),
      .by = any_of(if (by_area) "area")
    )
  stopifnot(!anyNA(csection$rate), all(csection$rate > 0 & csection$rate < 1))

  csection <- csection %>%
    mutate(
      r_raw_Public = .data$rate * .data$r_raw_Public / .data$old_total,
      r_raw_Private = .data$rate * .data$r_raw_Private / .data$old_total,
      totalPrevalence = .data$r_raw_Public + .data$r_raw_Private,
      privateShare = .data$r_raw_Private / .data$totalPrevalence * 100
    ) %>%
    select(all_of(names(shares)))

  out <- shares
  rows <- which(out$indic == "csection")
  stopifnot(identical(out[rows, keys], csection[, keys]))
  for (column in c("r_raw_Public", "r_raw_Private", "totalPrevalence", "privateShare")) out[[column]][rows] <- csection[[column]]
  out
}

before <- data$private_share
data$private_share$national <- correct(before$national, data$survey_data$all, by_area = FALSE)
data$private_share$area <- correct(before$area, data$survey_data$area, by_area = TRUE)

# nothing but the C-section bars and their total changed; the private share is as it was
for (level in c("national", "area")) {
  old <- before[[level]]; new <- data$private_share[[level]]
  stopifnot(identical(class(old), class(new)), identical(attr(old, "level"), attr(new, "level")),
            identical(names(old), names(new)), nrow(old) == nrow(new))
  stopifnot(identical(old[old$indic != "csection", ], new[new$indic != "csection", ]))
  stopifnot(isTRUE(all.equal(old$privateShare, new$privateShare)))
  untouched <- setdiff(names(old), c("r_raw_Public", "r_raw_Private", "totalPrevalence", "privateShare"))
  stopifnot(identical(old[untouched], new[untouched]))
}

save(list = ls(data), envir = data, file = file, compress = "xz", version = 3)
shown <- data$private_share$national %>% filter(.data$indic == "csection") %>%
  transmute(.data$iso, .data$year, percent = round(.data$totalPrevalence * 100, 1), private_share = round(.data$privateShare, 1))
print(as.data.frame(shown))
