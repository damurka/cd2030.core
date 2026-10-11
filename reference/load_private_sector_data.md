# Load and prepare private sector data

Loads raw prevalence data for public/private sector analysis and applies
internal preprocessing for c-section share calculation.

## Usage

``` r
load_private_sector_data(
  path = NULL,
  .data = NULL,
  country_iso = NULL,
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

  ISO3 country code. When the data holds several countries (an `iso`
  column with more than one code), the rows of this one are kept; data
  for one country is used as it is.

- level:

  Either `"national"` or `"area"` indicating the data level.

## Value

A tibble of class `"cd_private_sector_data"` with a `"level"` attribute.

## Details

Loads the data from `path`, or uses `.data`, and checks that it matches
`level`: area data has a `level` column and national data does not.
Then:

- Assigns `"Public"` or `"Private"` to the `sector` column based on
  `indic` suffix.

- Removes sector suffix from `indic`.

- Computes number of c-sections (`num_csection`) and sector share of
  c-sections (`share_csection`) within each country and survey year, and
  within each value of the `level` column for area data.

- If level is `"area"`, parses `level` string into `area = "Urban"` or
  `"Rural"`.

## Output columns

- `indic`: cleaned indicator name (without "pub"/"priv")

- `sector`: `"Public"` or `"Private"`

- `share_csection`: share of c-sections attributable to each sector

- `area`: (only if `level == "area"`)

## See also

[`load_csection_estimates()`](load_csection_estimates.md),
[`prepare_private_sector_plot_data()`](prepare_private_sector_plot_data.md)

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
