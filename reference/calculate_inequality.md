# Analyze subnational health coverage data with inequality metrics

`calculate_inequality` computes subnational health coverage metrics and
evaluates disparities compared to reference averages (either national or
regional).

## Usage

``` r
calculate_inequality(subnational_data, reference_data)
```

## Arguments

- subnational_data:

  A data frame containing pre-calculated subnational health coverage
  data.

- reference_data:

  A data frame containing pre-calculated reference health coverage data
  (e.g., national data if analyzing `adminlevel_1`, or `adminlevel_1`
  data if analyzing `district`).

## Value

A tibble (`cd_inequality` object) containing:

- Subnational health coverage metrics.

- Population shares.

- MADM, MRDM, and related disparity metrics.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cache$set_national_estimates(list(sbr = 0.02))
cache$adjust_data()

# regions against the national coverage
inequality <- calculate_inequality(
  subnational_data = cache$indicator_coverage_admin1,
  reference_data = cache$indicator_coverage_national
)
select_inequality(inequality, indicator = "instlivebirths", denominator = "dhis2")
#> # A tibble: 40 × 12
#>     year totbirths_dhis2 adminlevel_1 cov_instlivebirths_dhis2   nat    diff
#>    <dbl>           <dbl> <chr>                           <dbl> <dbl>   <dbl>
#>  1  2019              NA Central                          85.7  66.7 19.0   
#>  2  2020              NA Central                          92.1  76.1 16.0   
#>  3  2021              NA Central                          87.5  71.9 15.5   
#>  4  2022              NA Central                          86.2  74.3 11.9   
#>  5  2023              NA Central                         100   100.   0.163 
#>  6  2019              NA Coast                            66.6  66.7  0.0879
#>  7  2020              NA Coast                            73.9  76.1  2.19  
#>  8  2021              NA Coast                            76.8  71.9  4.87  
#>  9  2022              NA Coast                            75.1  74.3  0.801 
#> 10  2023              NA Coast                           100   100.   0.163 
#> # ℹ 30 more rows
#> # ℹ 6 more variables: madm <dbl>, madmpop <dbl>, mrdm <dbl>, mrdmpop <dbl>,
#> #   rd_max <dbl>, popshare <dbl>
```
