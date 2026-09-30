# Plot National Population or Births Metrics

Generates a line graph to visualize national-level demographic data,
comparing DHIS-2 data/projections against UN estimates. This function is
restricted to national-level data.

## Usage

``` r
# S3 method for class 'cd_population_metrics'
plot(
  x,
  metric = c("population", "births", "under1"),
  title = NULL,
  x_label = NULL,
  y_label = NULL,
  legend_labels = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  A `cd_population_metrics` object containing national-level demographic
  data.

- metric:

  A character string specifying the type of data to plot. Must be one
  of:

  - **'population'**: Total population estimates (in thousands).

  - **'births'**: Total live births (in thousands).

  - **'under1'**: Population under 1 year of age (in thousands).

- title:

  Optional. A custom title for the plot. If `NULL`, a default title
  based on the metric is used.

- x_label:

  Optional. Custom label for the x-axis. Defaults to "Year".

- y_label:

  Optional. Custom label for the y-axis. Defaults to "population".

- legend_labels:

  Optional. A character vector of custom labels for the legend items.
  Must match the number of lines plotted for the selected metric:

  - 'population': 2 labels

  - 'births': 3 labels

  - 'under1': 2 labels

- ...:

  Additional arguments passed to the plotting function.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

## Value

A ggplot object.

## Details

The function compares local Health Management Information System
(DHIS-2) data with United Nations (UN) estimates.

**Default Configuration:**

- **Population**: Compares `un_population` vs `totpop_dhis2`.

- **Births**: Compares `un_births` vs `totlivebirths_dhis2` vs
  `totbirths_dhis2`.

- **Under 1**: Compares `un_under1` vs `totunder1_dhis2`.
