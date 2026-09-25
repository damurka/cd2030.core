# Prepare Private Sector Plot Data

Processes reshaped private sector data and c-section correction
estimates to produce a tidy dataset for plotting public/private sector
shares.

## Usage

``` r
prepare_private_sector_plot_data(.data, csection_data)
```

## Arguments

- .data:

  A data frame of class `"cd_private_sector_data"` returned by
  [`load_private_sector_data()`](https://aphrcwaro.github.io/cd2030.core/reference/load_private_sector_data.md).
  Must include `share_csection`, `r_raw`, and `sector` columns.

- csection_data:

  A data frame of class `"cd_csection_estimates"` returned by
  [`load_csection_estimates()`](https://aphrcwaro.github.io/cd2030.core/reference/load_csection_estimates.md).
  Must match the level of `.data` (`"national"` or `"area"`).

## Value

A tibble of class `"cd_private_sector_plot_data"` with attributes:

- `level`: `"national"` or `"area"`

- Columns reshaped from wide to include `r_raw_Public`, `r_raw_Private`,
  etc.

- Computed columns:

  - `privateShare`: percent share of private sector

  - `totalPrevalence`: total prevalence (public + private)

## Details

This function:

- Joins private sector data with correction estimates using `iso`,
  `year`, and `indic`.

- For `"csection"` rows, applies adjustment:
  `r_raw = estimate * share_csection`.

- Drops intermediate columns and reshapes data to wide format.

- Calculates private sector share and total prevalence.

Used as input to
[`plot.cd_private_sector_plot_data()`](https://aphrcwaro.github.io/cd2030.core/reference/plot.cd_private_sector_plot_data.md)
for visualisation.

## Examples

``` r
if (FALSE) { # \dontrun{
dt <- load_private_sector_data("National estimates.dta", country_iso = "KEN", level = "national")
cs <- load_csection_estimates("csection_national.dta", country_iso = "KEN", level = "national")
plot_data <- prepare_private_sector_plot_data(dt, cs)
} # }
```
