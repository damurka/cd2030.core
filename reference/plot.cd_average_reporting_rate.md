# Plot Sub-National Reporting Rates by Year and Unit

Visualizes reporting rates for selected health service indicators at
sub-national levels, using heat maps or bar plots. Intended for use with
outputs from
[`calculate_average_reporting_rate()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/calculate_average_reporting_rate.md)
at `"adminlevel_1"` or `"district"` level.

## Usage

``` r
# S3 method for class 'cd_average_reporting_rate'
plot(
  x,
  plot_type = c("heat_map", "bar"),
  indicator = c("anc_rr", "idelv_rr", "vacc_rr", "opd_rr", "ipd_rr"),
  threshold = 90,
  ...
)
```

## Arguments

- x:

  A `cd_average_reporting_rate` object, typically the output from
  [`calculate_average_reporting_rate()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/calculate_average_reporting_rate.md).
  Must contain subnational data.

- plot_type:

  Either `"heat_map"` or `"bar"`:

  - `"heat_map"`: Shows reporting rates using color-coded tiles by year
    and unit.

  - `"bar"`: Displays reporting rates as bars, grouped by year and
    faceted by unit.

- indicator:

  One of the following:

  - `"anc_rr"`: Antenatal care

  - `"idelv_rr"`: Institutional deliveries

  - `"vacc_rr"`: Vaccination

  - `"opd_rr"`: Outpatient visits

  - `"ipd_rr"`: Inpatient admissions

- threshold:

  Numeric value (default = 90). Used only in `"heat_map"` mode to define
  the boundary for high reporting rates.

- ...:

  Reserved for future use.

## Value

A `ggplot` object.

## Details

Only subnational objects are accepted. If the data was computed at
`"adminlevel_1"` with a `region` argument, the object is automatically
treated as `"district"` level and plotted by district name.

**Heat Map Mode**:

- Each tile represents a reporting rate for a unit and year.

- Colors:

  - Green: `>= threshold`

  - Orange: `70 <= value < threshold`

  - Red: `< 70`

- Labels display the actual percentage.

**Bar Mode**:

- Bars show values per year.

- Units (regions or districts) appear as facets.

- Color gradient shows low to high reporting.

## Examples

``` r
if (FALSE) { # \dontrun{
# Heat map for vaccination at district level
x <- calculate_average_reporting_rate(data, admin_level = "district")
plot(x, plot_type = "heat_map", indicator = "vacc_rr")

# Bar chart by district in selected region
x <- calculate_average_reporting_rate(data, admin_level = "adminlevel_1", region = "Nairobi")
plot(x, plot_type = "bar", indicator = "idelv_rr")
} # }
```
