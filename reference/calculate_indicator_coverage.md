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
  derivation_population = c("totbirths_dhis2", "totlivebirths_dhis2", "totunder1_dhis2",
    "totpop_dhis2", "un_population", "un_births", "un_under1"),
  un_estimates = NULL,
  survey_estimates = NULL,
  subnational_map = NULL,
  anc1survey = .cd_method$denominators$anc1survey,
  dpt1survey = .cd_method$denominators$dpt1survey,
  survey_year = .cd_method$denominators$survey_year,
  region = NULL,
  show_district = TRUE,
  sbr = .cd_method$denominators$sbr,
  nmr = .cd_method$denominators$nmr,
  pnmr = .cd_method$denominators$pnmr,
  twin = .cd_method$denominators$twin,
  preg_loss = .cd_method$denominators$preg_loss
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

- derivation_population:

  Character. The population column used as the base for the
  DTP1/ANC1-derived denominators (`*derived` columns). One of
  `"totbirths_dhis2"`, `"totlivebirths_dhis2"`, `"totunder1_dhis2"`,
  `"totpop_dhis2"`, `"un_population"`, `"un_births"` or `"un_under1"`.
  Defaults to the first.

- un_estimates:

  Optional. A tibble containing UN population estimates. Required for
  national-level calculations.

- survey_estimates:

  Optional. A data frame of subnational survey estimates (`r_*` columns
  such as `r_anc1` and `r_penta1`, and optionally mortality rates). Used
  for subnational levels to replace the default rates below where survey
  values are available. Default is `NULL`.

- subnational_map:

  Optional. A data frame mapping survey regions to `adminlevel_1` units,
  used when joining `survey_estimates`. Default is `NULL`.

- anc1survey:

  Numeric. Survey-derived coverage rate for ANC-1 (antenatal care, first
  visit). Default is `0.98`.

- dpt1survey:

  Numeric. Survey-derived coverage rate for Penta-1 (DPT1 vaccination).
  Default is `0.97`.

- survey_year:

  Interger. The year of Penta-1 survey provided

- region:

  Optional name of an `adminlevel_1` region to restrict the calculation
  to. Only valid with `admin_level = "adminlevel_1"`. Default is `NULL`.

- show_district:

  Logical. When `region` is supplied, whether to return results by
  district within that region (`TRUE`, the default) or aggregated for
  the region.

- sbr:

  Numeric. The stillbirth rate. Default is `0.02`.

- nmr:

  Numeric. Neonatal mortality rate. Default is `0.025`.

- pnmr:

  Numeric. Post-neonatal mortality rate. Default is `0.024`.

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
