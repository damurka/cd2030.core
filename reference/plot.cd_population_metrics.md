# Plot National Population or Births Metrics

This function generates a plot to visualize national-level demographic
data for total population or live births over time.It compares DHIS-2
and UN projections for the specified metric, limited to national-level
data due to the availability of UN estimates.

## Usage

``` r
# S3 method for class 'cd_population_metrics'
plot(x, metric = c("population", "births"), ...)
```

## Arguments

- x:

  A `cd_population_metrics` object containing national-level demographic
  data.

- metric:

  A character string specifying the type of data to plot. It must be one
  of:

  - **'population'**: Plots total population estimates in thousands from
    DHIS-2 and UN sources.

  - **'births'**: Plots total live births in thousands from DHIS-2 and
    UN sources.

- ...:

  Additional arguments (not used in this function).

## Value

A ggplot object visualizing the selected demographic data over time.

## Details

The `plot_population_metrics` function provides visualizations based on
the selected `metric`:

- **Population Plot**: Shows total population (in thousands) by year,
  with separate lines for DHIS-2 and UN projections.

- **Live Births Plot**: Displays total live births (in thousands) by
  year, comparing DHIS-2 and UN projections.

This function supports only national-level data as UN estimates are not
available at subnational levels. Attempting to plot subnational data
will result in an error.

## Examples

``` r
if (FALSE) { # \dontrun{
# Plot total population estimates at the national level
plot(population_metrics_data, metric = "population")

# Plot total live births estimates at the national level
plot(population_metrics_data, metric = "births")
} # }
```
