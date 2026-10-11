# Plot coverage by region

Generates a bar chart comparing indicator coverage across regions,
highlighting a specific region and categorizing performance as lower,
average, or higher.

## Usage

``` r
# S3 method for class 'cd_coverage'
plot(
  x,
  indicator = NULL,
  denominator = NULL,
  year = NULL,
  region = NULL,
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

  Data frame containing the coverage data.

- indicator:

  Character string specifying the indicator (e.g., 'penta1').

- denominator:

  Character string specifying the denominator ('penta1', 'anc1',
  'dhis2', 'penta1derived', 'anc1derived').

- year:

  Integer representing the year to plot.

- region:

  Character string for the specific region to highlight in yellow.

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

  (Optional) Named list to override the default category labels (e.g.,
  `list(lower = "Low", average = "Avg", higher = "High")`).

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A `ggplot` object with the chart options applied: one bar per unit for
the selected year, ordered by coverage and coloured by category (the
lower, middle and upper third of the values).

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
coverage <- cache$calculate_coverage("adminlevel_1")

# `region` is the unit drawn in yellow
plot(coverage, indicator = "penta3", denominator = "penta1", year = 2023, region = "Nairobi")
#> Warning: Removed 7 rows containing missing values or values outside the scale range
#> (`geom_col()`).

plot(coverage, indicator = "penta3", denominator = "penta1", year = 2023, region = "Nairobi",
     title = "Penta3 coverage by region, 2023", y_title = "Coverage (%)",
     legend_labels = list(lower = "Lowest third", average = "Middle third", higher = "Highest third"))
#> Warning: Removed 7 rows containing missing values or values outside the scale range
#> (`geom_col()`).

```
