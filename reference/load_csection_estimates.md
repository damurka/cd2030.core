# Load C-section Share Estimates

Loads c-section correction estimates for national or area-level
adjustment.

## Usage

``` r
load_csection_estimates(
  path = NULL,
  .data = NULL,
  country_iso,
  level = c("national", "area")
)
```

## Arguments

- path:

  Optional. File path to a `.dta` file. Required if `.data` is not
  provided.

- .data:

  Optional. A pre-loaded dataset. Used directly if provided.

- country_iso:

  Required. ISO3 country code to filter the data.

- level:

  Either `"national"` or `"area"` indicating the data level.

## Value

A tibble of class `"cd_csection_estimates"` with a `"level"` attribute.

## Details

- Filters data for the specified `country_iso`.

- Validates whether the data level matches `"national"` or `"area"`.

- For `"area"` level, parses the `level` column to extract `area`.

- Returns only relevant columns for merging (`iso`, `year`, `indic`, and
  either `national` or `area_est`).

## See also

[`load_private_sector_data()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/load_private_sector_data.md),
[`prepare_private_sector_plot_data()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/prepare_private_sector_plot_data.md)

## Examples

``` r
if (FALSE) { # \dontrun{
cs <- load_csection_estimates(
  path = "csection_national.dta",
  country_iso = "KEN",
  level = "national"
)
} # }
```
