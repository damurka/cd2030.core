# Format Service Utilization Data for Excel Export

Transforms a `cd_service_utilization` object into a wide-format table
with labeled indicators, suitable for export to Excel.

## Usage

``` r
get_excel_version(.data)
```

## Arguments

- .data:

  A `cd_service_utilization` object produced by
  [`compute_service_utilization()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/compute_service_utilization.md).

## Value

A tibble in wide format with:

- One row per indicator per admin unit

- One column per year

- A human-readable label for each indicator (`indiclabel`)

## Details

The output table includes population, OPD/IPD service utilization,
under-5 service metrics, reporting completeness, and case fatality
rates, reshaped to facilitate Excel review or reporting.

## Examples

``` r
if (FALSE) { # \dontrun{
  x <- compute_service_utilization(dat, admin_level = "adminlevel_1")
  get_excel_version(x)
} # }
```
