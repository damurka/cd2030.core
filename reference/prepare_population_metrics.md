# Compute Population Metrics for DHIS-2 and UN Data

`prepare_population_metrics` calculates demographic metrics such as
total population, live births, growth rates, and related indicators
using DHIS-2 population data. For national-level data, it optionally
integrates UN estimates to provide comparative metrics. The function
supports aggregation at different administrative levels, including
national, adminlevel_1, and district levels.

## Usage

``` r
prepare_population_metrics(
  .data,
  admin_level = c("national", "adminlevel_1", "district"),
  un_estimates = NULL,
  region = NULL
)
```

## Arguments

- .data:

  A `cd_data` tibble containing processed DHIS-2 health facility data
  with population indicators. This dataset must include columns for
  metrics like `total_pop`, `live_births`, and `pop_rate`.

- admin_level:

  Character. Specifies the administrative level for aggregation.
  Available options are: `'national'`, `'adminlevel_1'`, and
  `'district'`. Default is `'national'`.

- un_estimates:

  Optional. A tibble containing UN population estimates with columns for
  `un_population`, `un_births`, `un_popgrowth`, and related metrics.
  This parameter is only required for national-level calculations.

## Value

A tibble of class `cd_population_metrics` containing demographic metrics
for the specified administrative level and years. Metrics include:

- **For all levels**: DHIS-2 metrics such as `totpop_dhis2` (total
  population) and `totlivebirths_dhis2` (total live births).

- **For national level**: Both DHIS-2 and UN metrics for comparison.

## Examples

``` r
if (FALSE) { # \dontrun{
# National-level demographic metrics
population_data <- prepare_population_metrics(
  .data = dhis2_data,
  admin_level = "national",
  un_estimates = un_data
)

# District-level demographic metrics
population_data <- prepare_population_metrics(
  .data = dhis2_data,
  admin_level = "district"
)
} # }
```
