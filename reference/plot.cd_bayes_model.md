# Plot S3 method for Bayesian coverage model

Leverages the bayescoveragemodel package's internal plotting function
and applies the custom Countdown (CD) theme and translated labels.

## Usage

``` r
# S3 method for class 'cd_bayes_model'
plot(
  x,
  region = NULL,
  year = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  national = NULL,
  legend_labels = NULL,
  options = NULL
)
```

## Arguments

- x:

  An object of class `cd_bayes_model` returned by
  [`generate_bayes_model()`](generate_bayes_model.md).

- region:

  (Optional) A region of a sub-national model: its estimates by year are
  drawn, as a national model's are. `NULL` compares the regions in one
  year.

- year:

  (Optional) For a sub-national model. The year the regions are compared
  in; by default the latest year the facility data has. With a `region`,
  the year is marked on its chart.

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

- national:

  (Optional) For a sub-national model. The country's coverage from the
  facility data, with the same denominator: a data frame with `year` and
  `value` (a proportion), as `cache$bayes_national_routine()` gives. The
  comparison draws it as a line and a region's chart as a series.

- legend_labels:

  (Optional) A named list to override the legend's entries, e.g. with
  translations: `model`, `routine` (the facility data) and `national`.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A `ggplot` object with the chart options applied. For a national model,
or the `region` of a sub-national model: the estimated coverage by year.
For a sub-national model with no `region`: the regions compared in
`year`, each with its model estimate and interval and its facility-data
value.

## Examples

``` r
if (FALSE) { # \dontrun{
# `cache` is a dataset with adjusted data; fitting needs the Bayesian model packages
national <- cache$get_bayes_model("national", "penta3")
plot(national)
plot(national, title = "Penta3 coverage, Kenya", y_title = "Coverage")

# a sub-national model: the regions compared, or the trend of one region
regional <- cache$get_bayes_model("adminlevel_1", "penta3")
country <- cache$bayes_national_routine("penta3")
plot(regional, national = country)
plot(regional, year = 2021, national = country)
plot(regional, region = "Nairobi", national = country)
} # }
```
