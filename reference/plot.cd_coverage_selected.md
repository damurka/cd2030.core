# Plot S3 method for coverage data

Draws the latest coverage of a set of indicators. National data, or the
data of one region, is drawn as a profile (bars by indicator and source)
or as the gap between the facility and the survey estimate. Subnational
data is drawn as dots by unit, one panel per indicator, or as a heatmap
of units by indicator.

## Usage

``` r
# S3 method for class 'cd_coverage_selected'
plot(
  x,
  type = NULL,
  source_labels = NULL,
  indicator_labels = NULL,
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

  An object of class `cd_coverage_selected`.

- type:

  "profile" or "gap" (for national), "dot" or "heatmap" (for
  subnational).

- source_labels:

  (Optional) Named list to translate 'facility', 'survey', 'wuenic'.

- indicator_labels:

  (Optional) Named list to translate indicator names (e.g. 'anc4').

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

A `ggplot` object with the chart options applied. Which chart it is
depends on `type` and on the admin level of `x`.

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

# national: a profile of the indicators, or the gap between facility data and the survey
national <- cache$generate_coverage_data("national", "maternal")
plot(national, type = "profile")

plot(national, type = "gap", title = "Facility data against the survey", legend_position = "bottom")
#> Warning: Removed 1 row containing missing values or values outside the scale range
#> (`geom_segment()`).
#> Warning: Removed 1 row containing missing values or values outside the scale range
#> (`geom_point()`).


# by region: a heatmap (or "dot")
regions <- cache$generate_coverage_data("adminlevel_1", "child")
plot(regions, type = "heatmap", legend_title = "Coverage (%)")

```
