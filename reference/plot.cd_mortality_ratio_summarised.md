# Plot completeness of facility reporting ratios

Calculates and plots the estimated completeness of facility reporting
for maternal deaths or stillbirths based on UN estimates and assumed
community-to-institution ratios.

## Usage

``` r
# S3 method for class 'cd_mortality_ratio_summarised'
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

  A `cd_mortality_ratio_summarised ` object from completeness
  estimation.

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

  (Optional) A named list to override the legend's entries, e.g. with
  translations: `lower`, `best` and `upper` (the UN lower bound, best
  estimate and upper bound). Defaults to `NULL`.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A ggplot object with ratio lines, labels, and reference points.

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
completeness <- cache$summarise_completeness_ratio("mmr")

plot(completeness)

plot(completeness, title = "Completeness of maternal death reporting", y_title = "Completeness (%)",
     legend_labels = list(lower = "UN lower bound", best = "UN best estimate", upper = "UN upper bound"))

```
