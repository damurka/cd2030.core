# Select one mortality rate, ready to map

Selects one institutional mortality rate from a `cd_mortality_summary`
object, optionally for given years, and joins the admin level 1
boundaries of the country so the result can be mapped.

## Usage

``` r
select_mortality_summary(
  .data,
  country_iso,
  indicator = c("mmr", "sbr", "nn"),
  plot_year = NULL,
  subnational_map = NULL,
  palette = c("Reds", "Blues", "Greens", "Purples", "YlGnBu")
)
```

## Arguments

- .data:

  A `cd_mortality_summary` object created by
  [`create_mortality_summary()`](create_mortality_summary.md).

- country_iso:

  A character string. ISO3 code of the country, used to load its
  boundaries.

- indicator:

  Character. Mortality indicator to select: `"mmr"`, `"sbr"` or `"nn"`.
  Defaults to `"mmr"`.

- plot_year:

  Optional integer or vector of years to filter.

- subnational_map:

  Optional. A data frame to join with the shapefile to add metadata.

- palette:

  Character. RColorBrewer sequential palette for the map (default
  `"Reds"`).

## Value

A tibble of class `cd_mortality_summary_filtered`, ready for geospatial
plotting.

## Details

Selects the column of the mortality indicator (`mmr_inst`, `sbr_inst` or
`nn_inst`) and keeps only `plot_year` when it is given. Joins the rates
to the admin level 1 boundaries by unit name, or through
`subnational_map` when the names in the data differ from those of the
shapefile, and renames the geometry column to `geometry`.

## Examples

``` r
if (FALSE) { # \dontrun{
select_mortality_summary(
  mortality_data,
  country_iso = "NGA",
  indicator = "sbr",
  plot_year = 2021:2023
)
} # }
```
