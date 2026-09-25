# Filter Service Utilization Data for a Specific Region and Indicator

Prepares a `cd_service_utilization` object for non-spatial plotting
(e.g., time series) by filtering by administrative region and indicator
type.

## Usage

``` r
filter_service_utilization_map(
  .data,
  indicator = c("opd", "ipd", "under5", "cfr", "deaths"),
  region = NULL
)
```

## Arguments

- .data:

  A `cd_service_utilization` object created by
  [`compute_service_utilization()`](https://aphrcwaro.github.io/cd2030.core/reference/compute_service_utilization.md).

- indicator:

  Character. The indicator to visualize. Options include `"opd"`,
  `"ipd"`, `"under5"` (proportion under 5), `"cfr"` (case fatality
  rate), or `"deaths"` (proportion of under-5 deaths).

- region:

  Optional. A single region name to filter when data is subnational
  (`adminlevel_1` or `district`).

## Value

A tibble of class `cd_service_utilization_map`, with an attached
`indicator` attribute for plotting.

## Details

This function:

- Validates the `.data` class and `indicator` input

- If data is subnational, filters it by the specified `region`

- If data is national, ensures `region` is not provided

- Returns a filtered tibble tagged with `cd_service_utilization_map`
  class for downstream plotting

## Examples

``` r
if (FALSE) { # \dontrun{
# Filter IPD indicator for Central region
filtered <- filter_service_utilization_map(service_data, indicator = "ipd", region = "Central")
} # }
```
