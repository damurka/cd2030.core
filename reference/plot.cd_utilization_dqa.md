# Plot S3 method for service DQA summary

Draws the service utilization data quality summary as a formatted table,
with the indicators grouped by section and a column for each year.
Completeness and outlier percentages are shaded green at or above the
threshold stored with the summary, yellow from 70 up to the threshold
and red below 70.

## Usage

``` r
# S3 method for class 'cd_utilization_dqa'
plot(x, years = NULL, title = NULL, width = NULL, ..., options = NULL)
```

## Arguments

- x:

  The score dataframe (needs class 'cd_utilization_dqa'), as returned by
  [`generate_service_dqa_summary()`](generate_service_dqa_summary.md).

- years:

  Vector of years to display (e.g., 2020:2024). Required.

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
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cache$adjust_data()
dqa <- cache$calculate_service_dqa_summary("national")

plot(dqa, years = cache$data_years)


.cl-d8bad469{}.cl-29d09b5c{font-family:'sans';font-size:9pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-e0c7d261{font-family:'sans';font-size:9pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-28d672a7{font-family:'sans';font-size:9pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(255, 255, 255, 1.00);background-color:transparent;}.cl-ba026f90{font-family:'sans';font-size:9pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(26, 26, 26, 1.00);background-color:transparent;}.cl-b62513c1{font-family:'DejaVu Sans';font-size:8pt;font-weight:normal;font-style:italic;text-decoration:none;color:rgba(75, 85, 99, 1.00);background-color:transparent;}.cl-56907d49{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:3pt;padding-top:3pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-6a6ee646{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:3pt;padding-top:3pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-6477613b{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-e6dce1a8{width:0.75in;background-color:rgba(243, 244, 246, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 1.25pt solid rgba(107, 114, 128, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-8de02adc{width:3.183in;background-color:rgba(243, 244, 246, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 1.25pt solid rgba(107, 114, 128, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c4cae95c{width:0.75in;background-color:rgba(243, 244, 246, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 1.25pt solid rgba(107, 114, 128, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0c401c3c{width:0.75in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-5ace2c23{width:3.183in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-dd4cbf8e{width:0.75in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-01bf5c25{width:0.75in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-fe9d468f{width:3.183in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-a5668fde{width:0.75in;background-color:rgba(26, 152, 80, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-14a2a5a9{width:0.75in;background-color:rgba(253, 174, 97, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-042a7cc1{width:0.75in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0c2cedd7{width:3.183in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-aa3d02c6{width:0.75in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-8f285de2{width:0.75in;background-color:rgba(215, 48, 39, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-482a8777{width:0.75in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a2f0bf3{width:0.75in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-70bd566b{width:3.183in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-6f1f2b56{width:0.75in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-eec4dc53{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(255, 255, 255, 0.00);border-top: 0 solid rgba(255, 255, 255, 0.00);border-left: 0 solid rgba(255, 255, 255, 0.00);border-right: 0 solid rgba(255, 255, 255, 0.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-eb1a3bbb{width:3.183in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(255, 255, 255, 0.00);border-top: 0 solid rgba(255, 255, 255, 0.00);border-left: 0 solid rgba(255, 255, 255, 0.00);border-right: 0 solid rgba(255, 255, 255, 0.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}

```
