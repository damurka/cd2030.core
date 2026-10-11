# Plot national coverage data

Generates a line plot to visualize immunization coverage data across
years, allowing comparison between different estimates (e.g., DHIS2
estimates, WUENIC estimates, and Survey estimates).

## Usage

``` r
# S3 method for class 'cd_coverage_filtered'
plot(
  x,
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

  A data frame of type `cd_coverage_filtered`, containing year-wise
  coverage data for the specified indicator.

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

  (Optional) A named list or vector to override the legend keys for
  translation. Valid keys: `dhis2`, `wuenic`, `survey`, `ci`. Defaults
  to `NULL`.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A `ggplot` object displaying a line plot of the coverage data.

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
coverage <- cache$get_filtered_coverage("penta3", "national")

plot(coverage)

plot(coverage, title = "Penta3 coverage, Kenya", y_title = "Coverage (%)",
     legend_labels = list(dhis2 = "Facility data", survey = "Household surveys"))

```
