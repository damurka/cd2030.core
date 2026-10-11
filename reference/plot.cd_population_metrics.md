# Plot national population or births metrics

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
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  legend_labels = NULL,
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

- legend_labels:

  Optional. A character vector of custom labels for the legend items.
  Must match the number of lines plotted for the selected metric:

  - 'population': 2 labels

  - 'births': 3 labels

  - 'under1': 2 labels

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

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

## Examples

``` r
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cache$set_national_estimates(list(sbr = 0.02))
cache$adjust_data()
population <- cache$denominator_metrics

plot(population, metric = "population")

plot(population, metric = "births", title = "Births: DHIS2 and the UN", y_title = "Thousands",
     legend_labels = c("UN live births", "DHIS2 live births", "DHIS2 births"))

```
