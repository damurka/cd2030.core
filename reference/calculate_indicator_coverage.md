# Calculate Health Coverage Indicators

`calculate_indicator_coverage` computes key health coverage indicators
across specified administrative levels (national, adminlevel_1, and
district). The function integrates data from multiple sources, including
DHIS-2, UN estimates, ANC-1, and Penta-1 survey data. It calculates
coverage rates for a variety of vaccinations and health metrics based on
projected, survey-derived, and estimated denominators.

## Usage

``` r
calculate_indicator_coverage(
  .data,
  admin_level = c("national", "adminlevel_1", "district"),
  un_estimates = NULL,
  region = NULL,
  sbr = 0.02,
  nmr = 0.025,
  pnmr = 0.024,
  anc1survey = 0.98,
  dpt1survey = 0.97,
  survey_year = 2019,
  twin = 0.015,
  preg_loss = 0.03
)
```

## Arguments

- .data:

  A `cd_data` tibble containing DHIS-2, UN, ANC-1, and Penta-1 data.
  This dataset must include columns for key population and vaccination
  metrics.

- admin_level:

  Character. Specifies the administrative level for calculations.
  Options include:`"national", "adminlevel_1"`, and `"district"`.

- un_estimates:

  Optional. A tibble containing UN population estimates. Required for
  national-level calculations.

- sbr:

  Numeric. The stillbirth rate. Default is `0.02`.

- nmr:

  Numeric. Neonatal mortality rate. Default is `0.025`.

- pnmr:

  Numeric. Post-neonatal mortality rate. Default is `0.024`.

- anc1survey:

  Numeric. Survey-derived coverage rate for ANC-1 (antenatal care, first
  visit). Default is `0.98`.

- dpt1survey:

  Numeric. Survey-derived coverage rate for Penta-1 (DPT1 vaccination).
  Default is `0.97`.

- survey_year:

  Interger. The year of Penta-1 survey provided

- twin:

  Numeric. Twin birth rate. Default is `0.015`.

- preg_loss:

  Numeric. Pregnancy loss rate. Default is `0.03`.

## Value

A tibble of class `cd_indicator_coverage` containing calculated coverage
indicators for the specified administrative level.

## Examples

``` r
if (FALSE) { # \dontrun{
# Calculate coverage indicators at the national level
coverage_data <- calculate_indicator_coverage(
  .data = dhis2_data,
  admin_level = "national",
  un_estimates = un_data
)

# Calculate coverage indicators at the district level
coverage_data <- calculate_indicator_coverage(
  .data = dhis2_data,
  admin_level = "district"
)
} # }
```
