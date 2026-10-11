# Generate health system metrics data

Arranges national health system metrics as a table of eight indicators
in three sections: health infrastructure, health workforce and the role
of the private sector. Each row has the indicator's label, its value and
its unit, ready for
[`plot.cd_health_system_table()`](plot.cd_health_system_table.md).

## Usage

``` r
generate_health_system_table(metric_data, labels = NULL)
```

## Arguments

- metric_data:

  A `cd_health_system_metric` object for the national level, as returned
  by
  [`calculate_health_system_metrics()`](calculate_health_system_metrics.md)
  with `admin_level = "national"`.

- labels:

  (Optional) A nested list of localized labels for sections, indicators,
  and units (elements `section`, `indicator` and `unit`). English labels
  are used for whatever it does not set.

## Value

A tibble of class `cd_health_system_table` with one row per indicator
and the columns `section`, `indicator`, `value` and `unit` (`NA` where
the indicator has no unit).

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
metrics <- calculate_health_system_metrics(data, admin_level = "national")

generate_health_system_table(metrics)
#> # A tibble: 8 × 4
#>   section                indicator                                   value unit 
#>   <chr>                  <chr>                                       <dbl> <chr>
#> 1 Health infrastructure  Health facility density                      1.72 per …
#> 2 Health infrastructure  Share of facilities that are hospitals      99.5  %    
#> 3 Health infrastructure  Hospital density                            17.1  per …
#> 4 Health infrastructure  Inpatient bed density                       10.6  per …
#> 5 Health workforce       Health workforce density                     7.92 per …
#> 6 Health workforce       Skills mix ratio nurse-midwives per physic… 10.7  NA   
#> 7 Role of private sector Share of Private facilities                 35.9  %    
#> 8 Role of private sector Share of NGO facilities                     14.2  %    

# labels in another language: what is not given stays in English
generate_health_system_table(metrics, labels = list(section = list(workforce = "Personnel de sante")))
#> # A tibble: 8 × 4
#>   section                indicator                                   value unit 
#>   <chr>                  <chr>                                       <dbl> <chr>
#> 1 Health infrastructure  Health facility density                      1.72 per …
#> 2 Health infrastructure  Share of facilities that are hospitals      99.5  %    
#> 3 Health infrastructure  Hospital density                            17.1  per …
#> 4 Health infrastructure  Inpatient bed density                       10.6  per …
#> 5 Personnel de sante     Health workforce density                     7.92 per …
#> 6 Personnel de sante     Skills mix ratio nurse-midwives per physic… 10.7  NA   
#> 7 Role of private sector Share of Private facilities                 35.9  %    
#> 8 Role of private sector Share of NGO facilities                     14.2  %    
```
