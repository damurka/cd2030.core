# Get Mapping Data for Subnational Coverage Analysis

Merges coverage data with a country's shapefile to enable spatial
visualization of health indicators. It computes subnational indicator
coverage using UN estimates and survey rates, and joins results with
geographic features.

## Usage

``` r
get_mapping_data(
  .data,
  admin_level = c("adminlevel_1", "district"),
  un_estimates = NULL,
  sbr = 0.02,
  nmr = 0.025,
  pnmr = 0.024,
  anc1survey = 0.98,
  dpt1survey = 0.97,
  survey_year = 2019,
  twin = 0.015,
  preg_loss = 0.03,
  subnational_map = NULL
)
```

## Arguments

- .data:

  A data frame of input data containing model output or estimates. Must
  include metadata attribute `iso3` (ISO3 country code).

- admin_level:

  Character. The subnational level of analysis. Must be one of
  `"adminlevel_1"` (default) or `"district"`.

- un_estimates:

  A data frame of UN estimates including population and birth rates.

- sbr:

  Numeric. Stillbirth rate. Default = `0.02`.

- nmr:

  Numeric. Neonatal mortality rate. Default = `0.025`.

- pnmr:

  Numeric. Post-neonatal mortality rate. Default = `0.024`.

- anc1survey:

  Numeric. Survey coverage for ANC1. Default = `0.98`.

- dpt1survey:

  Numeric. Survey coverage for Penta1. Default = `0.97`.

- survey_year:

  Integer. Year of survey used in indicator estimation. Default =
  `2019`.

- twin:

  Numeric. Twin birth rate. Default = `0.015`.

- preg_loss:

  Numeric. Pregnancy loss rate. Default = `0.03`.

- subnational_map:

  Optional. A data frame to join with the shapefile to add metadata.

## Value

A `tibble` of class `"cd_mapping"` that combines the input data with
shapefile geometries.

## Examples

``` r
if (FALSE) { # \dontrun{
rates <- list(
  sbr = 0.02, nmr = 0.03, pnmr = 0.02, anc1 = 0.8, penta1 = 0.75,
  twin_rate = 0.015, preg_loss = 0.03
)

get_mapping_data(
  .data = data,
  un_estimates = un_estimates,
  sbr = rates$sbr,
  nmr = rates$nmr,
  pnmr = rates$pnmr,
  anc1survey = rates$anc1,
  dpt1survey = rates$penta1,
  survey_year = 2021,
  twin = rates$twin_rate,
  preg_loss = rates$preg_loss
)
} # }
```
