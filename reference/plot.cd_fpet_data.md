# Plot family planning estimation tool (FPET) data

Generates a line and ribbon plot for FPET indicators (e.g., mCPR, Demand
Satisfied) displaying median estimates and 95% credible intervals.

## Usage

``` r
# S3 method for class 'cd_fpet_data'
plot(
  x,
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

  An object of class `cd_fpet_data`.

- indicator_labels:

  (Optional) A named list mapping raw indicator names to translated
  legend labels.

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

A `ggplot` object with the chart options applied: one line per indicator
by year, with a shaded band for the credible interval.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
fpet <- cache$fpet_data

plot(fpet)

plot(
  fpet,
  indicator_labels = list(prevalence = "Modern contraceptive prevalence", demand = "Demand satisfied"),
  title = "Family planning in Kenya"
)
```
