# Plot district reporting rate summary

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
  indicator_labels = NULL,
  facet_ncol = 3,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  A `cd_district_reporting_rate` data frame containing reporting rate
  data, processed by
  [`calculate_district_reporting_rate()`](calculate_district_reporting_rate.md).

- indicator_labels:

  Optional named character vector of panel titles, keyed by short
  indicator name (`anc`, `idelv`, `vacc`, `pnc`, `opd`, `ipd`). Supplied
  entries replace the defaults.

- facet_ncol:

  Integer. The number of columns the service panels are laid out in.
  Default is `3`, so four services are drawn as a row of three and a row
  of one.

- title:

  The chart's title.

- subtitle:

  The line under the title.

- caption:

  The note under the chart.

- x_title:

  The title of the horizontal axis.

- y_title:

  The title of the vertical axis.

- legend_title:

  The title of the legend.

- ...:

  Chart options by name (see
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)):
  background, fonts, sizes, axes, grid, legend, colours. Other arguments
  are ignored.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A ggplot object visualizing reporting rates across indicators and years.

## Details

Inverts the percentages in `x` (the percentage of districts at or above
the threshold) to display the percentage of districts with rates below
the threshold for each indicator (e.g., if 95% of districts reach the
threshold, 5% are shown as below it). Each indicator is visualized in a
separate panel with data grouped by year, providing an overview of
performance trends over time.

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
