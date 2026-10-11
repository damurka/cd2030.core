# Select one service utilization indicator

Prepares a `cd_service_utilization` object for non-spatial plotting
(e.g., time series) by filtering by administrative region and indicator
type.

## Usage

``` r
select_service_utilization(
  .data,
  indicator = c("opd", "ipd", "under5", "cfr", "deaths"),
  region = NULL
)
```

## Arguments

- .data:

  A `cd_service_utilization` object created by
  [`compute_service_utilization()`](compute_service_utilization.md).

- indicator:

  Character. The indicator to visualize. Options include `"opd"`,
  `"ipd"`, `"under5"` (proportion under 5), `"cfr"` (case fatality
  rate), or `"deaths"` (proportion of under-5 deaths).

- region:

  A single unit name to filter by. Required when data is subnational
  (`adminlevel_1` or `district`); must be `NULL` for national data.

## Value

A tibble of class `cd_service_utilization_filtered`, with an attached
`indicator` attribute for plotting.

## Details

Checks the class of `.data` and the `indicator` value. Subnational data
is filtered to the unit named by `region`; for national data `region`
must not be given. The result keeps every column of `.data` and is
tagged with the `cd_service_utilization_filtered` class for plotting.

## Examples

``` r
if (FALSE) { # \dontrun{
# Filter IPD indicator for Central region
filtered <- select_service_utilization(service_data, indicator = "ipd", region = "Central")
} # }
```
