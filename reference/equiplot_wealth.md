# A specialized dot plot for wealth quintile analysis

Plots survey estimates of an indicator by year for each wealth quintile.

## Usage

``` r
equiplot_wealth(
  .data,
  indicator,
  dot_size = NULL,
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

- .data:

  Equity survey data with `year`, `level` and `r_<indicator>` columns.

- indicator:

  Character. The indicator to plot; its `r_<indicator>` column is used.

- dot_size:

  Optional dot size, clamped to 1-5. Defaults to 4.

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

  Optional named vector or list mapping group names to display labels.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A `ggplot` object: the dot plot drawn by [`equiplot()`](equiplot.md),
with one row per survey year and one dot for each wealth quintile (Q1 to
Q5), and the chart options applied.

## Examples

``` r
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

# the dataset object gives the package's survey estimates for the country, by wealth quintile
equiplot_wealth(cache$wiq_survey, "instlivebirths")


equiplot_wealth(cache$wiq_survey, "instlivebirths", title = "Institutional live births by wealth",
                legend_title = "Quintile", caption = "Source: household surveys")

```
