# Plot S3 method for overall score

Draws the overall data quality score as a formatted table, with the
metrics grouped by type and a column for each year. Percentage scores
are shaded green at or above the threshold stored with the scores,
yellow from 70 up to the threshold and red below 70.

## Usage

``` r
# S3 method for class 'cd_overall_score'
plot(x, years = NULL, title = NULL, width = NULL, ..., options = NULL)
```

## Arguments

- x:

  The score dataframe (class `cd_overall_score`), as returned by
  [`calculate_overall_score()`](calculate_overall_score.md).

- years:

  Vector of years to display. Required: each must be a year column of
  `x`.

- title:

  (Optional) Custom title for the table

- width:

  (Optional) Total width in inches. If NULL, autofit is used.

- ...:

  Additional arguments

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

## Value

A `flextable` object (from the flextable package), not a ggplot. Chart
options change ggplots only, so `options` has no effect on this table.

## Examples

``` r
data <- load_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
score <- calculate_overall_score(data, threshold = 90)

plot(score, years = 2019:2023)


.cl-d8bad469{}.cl-29d09b5c{font-family:'sans';font-size:9pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-e0c7d261{font-family:'sans';font-size:9pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-28d672a7{font-family:'sans';font-size:9pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(255, 255, 255, 1.00);background-color:transparent;}.cl-ba026f90{font-family:'sans';font-size:9pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(26, 26, 26, 1.00);background-color:transparent;}.cl-ff0db0f9{font-family:'sans';font-size:9pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(26, 26, 26, 1.00);background-color:transparent;}.cl-39e96436{font-family:'sans';font-size:9pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(255, 255, 255, 1.00);background-color:transparent;}.cl-56907d49{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:3pt;padding-top:3pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-6a6ee646{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:3pt;padding-top:3pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-7a24ac16{width:0.444in;background-color:rgba(243, 244, 246, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 1.25pt solid rgba(107, 114, 128, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-7c617368{width:4.065in;background-color:rgba(243, 244, 246, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 1.25pt solid rgba(107, 114, 128, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-e5a81e72{width:0.633in;background-color:rgba(243, 244, 246, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 1.25pt solid rgba(107, 114, 128, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-a6cd61a3{width:0.444in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-20f2dbc5{width:4.065in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-a8ae20b7{width:0.633in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-6072f1d6{width:0.444in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-09dbb073{width:4.065in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2bbb814d{width:0.633in;background-color:rgba(26, 152, 80, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b40e5722{width:0.633in;background-color:rgba(253, 174, 97, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534bcfd9{width:0.444in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c860899a{width:4.065in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2215284b{width:0.633in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3edbc02e{width:0.633in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b2db4a37{width:0.444in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0098522f{width:4.065in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-16d24591{width:0.633in;background-color:rgba(253, 174, 97, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-5f274dd1{width:0.633in;background-color:rgba(26, 152, 80, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}

```
