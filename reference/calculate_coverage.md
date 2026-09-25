# Combine Immunization Coverage Data

`calculate_coverage` integrates immunization coverage data from three
sources: DHIS2 (District Health Information Software), survey-based
estimates, and WUENIC (WHO-UNICEF estimates). The combined dataset is
prepared for analysis at various administrative levels.

## Usage

``` r
calculate_coverage(
  .data,
  admin_level = c("national", "adminlevel_1", "district"),
  survey_data,
  wuenic_data,
  region = NULL,
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

  A `cd_data` data frame with DHIS2 coverage metrics.

- admin_level:

  Character. Specifies the administrative level for calculations.
  Options include:`"national", "adminlevel_1"`, and `"district"`.

- survey_data:

  A data frame containing survey-based immunization estimates.

- wuenic_data:

  A data frame containing WHO-UNICEF (WUENIC) coverage estimates.

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

  Integer. The year of Penta-1 survey provided

- twin:

  Numeric. Twin birth rate. Default is `0.015`.

- preg_loss:

  Numeric. Pregnancy loss rate

- subnational_map:

  (Optional) A data frame mapping subnational regions to parent regions,
  required for subnational-level analyses. Default is `NULL`.

## Value

A `cd_coverage` data frame containing harmonized coverage estimates for
each year from DHIS2, WUENIC, and survey data. Includes metadata for
administrative levels, regions, and denominators.

## Examples

``` r
if (FALSE) { # \dontrun{
calculate_coverage(precomputed_data, survey_df, wuenic_df)
} # }
```
