# Summarize Completeness-Adjusted Mortality Ratio

Computes and summarizes adjusted mortality ratio estimates based on
completeness correction factors for different
completeness-to-incompleteness ratios (CI ratios).

## Usage

``` r
summarise_completeness_ratio(.data, plot_type = c("mmr", "sbr"), lbr_mean = 0)
```

## Arguments

- .data:

  A data frame of class `cd_mortality_ratio`, containing UN estimates
  and observed ratios.

- plot_type:

  Character. The type of mortality ratio to summarize. Must be one of:

  - `"mmr"`: Maternal mortality ratio

  - `"sbr"`: Stillbirth rate

- lbr_mean:

  Numeric. Mean live birth registration completeness, used for scaling
  completeness ratios. Default is `0`.

## Value

A tibble of class `cd_mortality_ratio_summarised` with columns:

- `ciratio`: The completeness-to-incompleteness ratio used.

- `name`: Label for the UN estimate type (`lower bound`,
  `best estimate`, `upper bound`).

- `rat`: The adjusted mortality ratio value.

## Examples

``` r
if (FALSE) { # \dontrun{
summarise_completeness_ratio(mortality_data, plot_type = "mmr", lbr_mean = 65)
} # }
```
