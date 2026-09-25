# Filter and Prepare Mortality Rate Data for Mapping

Filters a `cd_mortality_summary` object by country, indicator, and year.
Optionally joins subnational mapping data and renames geometry for
spatial plotting.

## Usage

``` r
filter_mortality_summary(
  .data,
  country_iso,
  indicator = c("mmr", "sbr"),
  plot_year = NULL,
  subnational_map = NULL
)
```

## Arguments

- .data:

  A `cd_mortality_summary` object created by
  [`create_mortality_summary()`](https://aphrcwaro.github.io/cd2030.core/reference/create_mortality_summary.md).

- country_iso:

  A character string. ISO3 code of the country.

- indicator:

  Character. Mortality indicator to filter (`"mmr"` or `"sbr"`).
  Defaults to `"mmr"`.

- plot_year:

  Optional integer or vector of years to filter.

- subnational_map:

  Optional. A data frame to join with the shapefile to add metadata.

## Value

A tibble of class `cd_mortality_summary_filtered`, ready for geospatial
plotting.

## Details

This function:

- Selects the specified mortality indicator (`mmr_inst` or `sbr_inst`)

- Filters by `plot_year` if provided

- Merges mortality rates with spatial geometry using internal or custom
  subnational mappings

- Ensures geometry is correctly renamed for mapping (`geometry`)

## Examples

``` r
if (FALSE) { # \dontrun{
filter_mortality_rate(
  mortality_data,
  country_iso = "NGA",
  indicator = "sbr",
  plot_year = 2021:2023
)
} # }
```
