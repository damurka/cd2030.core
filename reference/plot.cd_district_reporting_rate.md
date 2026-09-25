# Plot District Reporting Rate Summary

Generates a bar plot displaying the percentage of districts with
reporting rates below the defined threshold for multiple indicators
across various years. This plot provides a quick visual assessment of
district-level reporting compliance across indicators like ANC,
Institutional Delivery, PNC, Vaccination, OPD, and IPD.

## Usage

``` r
# S3 method for class 'cd_district_reporting_rate'
plot(x, ...)
```

## Arguments

- x:

  A `cd_district_reporting_rate` data frame containing reporting rate
  data, processed by
  [`calculate_district_reporting_rate()`](https://aphrcwaro.github.io/cd2030.core/reference/calculate_district_reporting_rate.md).

- ...:

  Additional parameters passed to the plotting function.

## Value

A ggplot object visualizing reporting rates across indicators and years.

## Details

This function inverts reporting rate percentages to display the
proportion of districts with rates below the threshold for each
indicator (e.g., if a district achieves a 95% rate, it shows as 5% below
threshold). Each indicator is visualized in a separate panel with data
grouped by year, providing an overview of performance trends over time.

Indicators plotted include:

- **Antenatal Care (ANC)** - Percentage of districts meeting or
  exceeding target rates

- **Institutional Delivery** - Institutional delivery compliance over
  time

- **Postnatal Care (PNC)** - Districts' PNC service rates against
  thresholds

- **Vaccination** - Vaccination service coverage at district level

- **Outpatient Department (OPD)** - OPD reporting rates in districts

- **Inpatient Department (IPD)** - IPD reporting compliance by district

The plot output includes a title, axis labels, and a legend for year,
allowing users to identify service areas with low reporting compliance.

## Examples

``` r
if (FALSE) { # \dontrun{
# Generate a plot of district reporting rates below a threshold of 90%
plot(cd_district_reporting_rate(data), threshold = 90)
} # }
```
