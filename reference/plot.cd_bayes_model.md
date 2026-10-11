# Plot S3 method for Bayesian coverage model

Leverages the bayescoveragemodel package's internal plotting function
and applies the custom Countdown (CD) theme and translated labels.

## Usage

``` r
# S3 method for class 'cd_bayes_model'
plot(
  x,
  region = NULL,
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

  An object of class `cd_bayes_model` returned by
  [`generate_bayes_model()`](generate_bayes_model.md).

- region:

  (Optional) Specific region code to plot for subnational data.

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

A `ggplot` object with the chart options applied: the estimated coverage
by year for a national model or for the `region` of a sub-national
model, or a comparison of the regions in 2025 for a sub-national model
when `region` is `NULL`.

## Examples

``` r
if (FALSE) { # \dontrun{
# `cache` is a dataset with adjusted data; fitting needs the Bayesian model packages
national <- cache$get_bayes_model("national", "penta3")
plot(national)
plot(national, title = "Penta3 coverage, Kenya", y_title = "Coverage")

# a sub-national model: the regions compared, or the trend of one region
regional <- cache$get_bayes_model("adminlevel_1", "penta3")
plot(regional)
plot(regional, region = "Nairobi")
} # }
```
