# Plot District Reporting Rate Summary

Generates a bar plot displaying the percentage of districts with
reporting rates below the defined threshold for multiple indicators
across various years. This plot provides a quick visual assessment of
district-level reporting compliance across indicators like ANC,
Institutional Delivery, PNC, Vaccination, OPD, and IPD.

## Usage

``` r
# S3 method for class 'cd_district_reporting_rate'
plot(
  x,
  title = NULL,
  x_axis = NULL,
  y_axis = NULL,
  caption = NULL,
  indicator_labels = NULL,
  facet_ncol = 3,
  ...,
  options = NULL
)
```

## Arguments

- x:

  A `cd_district_reporting_rate` data frame containing reporting rate
  data, processed by
  [`calculate_district_reporting_rate()`](calculate_district_reporting_rate.md).

- title:

  Optional plot title. Defaults to a title that includes the
  reporting-rate threshold.

- x_axis, y_axis:

  Optional x- and y-axis titles. By default the x axis has no title and
  the y axis is labelled with a percent sign.

- caption:

  Optional plot caption. Defaults to a note stating the low-reporting
  threshold.

- indicator_labels:

  Optional named character vector of panel titles, keyed by short
  indicator name (`anc`, `idelv`, `vacc`, `pnc`, `opd`, `ipd`). Supplied
  entries replace the defaults.

- facet_ncol:

  How many service-panel columns the facet grid uses (default 3,
  unchanged from before this param existed – e.g. 4 services lay out
  3-then-1). Additive: every existing caller keeps its current layout
  unless it explicitly asks for a different one.

- ...:

  Additional parameters passed to the plotting function.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

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
