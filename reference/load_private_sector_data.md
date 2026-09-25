# Load and Prepare Private Sector Data

Loads raw prevalence data for public/private sector analysis and applies
internal preprocessing for c-section share calculation.

## Usage

``` r
load_private_sector_data(
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

A tibble of class `"cd_private_sector_data"` with a `"level"` attribute.

## Details

This function:

- Loads and filters data for the specified `country_iso`.

- Assigns `"Public"` or `"Private"` to the `sector` column based on
  `indic` suffix.

- Removes sector suffix from `indic`.

- Computes number of c-sections (`num_csection`) and sector share of
  c-sections (`share_csection`) within groupings defined by `iso` or
  `iso + area`.

- If level is `"area"`, parses `level` string into `area = "Urban"` or
  `"Rural"`.

## Output columns

- `indic`: cleaned indicator name (without "pub"/"priv")

- `sector`: `"Public"` or `"Private"`

- `share_csection`: share of c-sections attributable to each sector

- `area`: (only if `level == "area"`)

## See also

[`load_csection_estimates()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/load_csection_estimates.md),
[`prepare_private_sector_plot_data()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/prepare_private_sector_plot_data.md)

## Examples

``` r
if (FALSE) { # \dontrun{
dt <- load_private_sector_data(
  path = "National estimates.dta",
  country_iso = "KEN",
  level = "national"
)
} # }
```
