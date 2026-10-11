# Generate coverage data for continuum of care

Processes and shapes raw coverage data into a clean, long format
optimized for continuum-of-care plotting. It dynamically builds regex
patterns based on the spatial level and data type to extract relevant
columns:

- **National**: Extracts Facility, Survey, and WUENIC data.

- **Subnational**: Extracts Facility data only.

The function automatically filters for the absolute latest available
data point per indicator-source combination and converts the `indicator`
column into an ordered factor representing the lifecycle stages to
ensure plots are always ordered correctly.

## Usage

``` r
generate_coverage_data(
  .data,
  type = c("maternal", "child"),
  denominator = c("dhis2", "anc1", "penta1", "penta1derived", "anc1derived")
)
```

## Arguments

- .data:

  A data frame/tibble originating from
  [`calculate_coverage()`](calculate_coverage.md). Must contain an
  `admin_level` attribute.

- type:

  Character. Specifies whether to extract 'maternal' or 'child'
  indicators.

- denominator:

  Character. The denominator to use for the specified indicator type.
  Options include "dhis2", "anc1", "penta1", "penta1derived", or
  "anc1derived".

## Value

A tibble of class `cd_coverage_selected` containing the latest coverage
values, categorized sources, and ordered indicators. Retains
`admin_level` and `admin_col` attributes for downstream plotting.

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
coverage <- cache$calculate_coverage("national")

generate_coverage_data(coverage, type = "maternal", denominator = "anc1")
#> # A tibble: 11 × 5
#>     year name                    value source   indicator     
#>    <dbl> <chr>                   <dbl> <fct>    <fct>         
#>  1  2022 r_anc1                   98.0 survey   anc1          
#>  2  2022 r_anc_1trimester         28.6 survey   anc_1trimester
#>  3  2022 r_anc4                   66.0 survey   anc4          
#>  4  2022 r_instlivebirths         88.1 survey   instlivebirths
#>  5  2022 r_pnc48h                 78.4 survey   pnc48h        
#>  6  2023 cov_anc1_anc1            98   facility anc1          
#>  7  2023 cov_instlivebirths_anc1  81.9 facility instlivebirths
#>  8  2023 cov_ideliv_anc1          83.0 facility ideliv        
#>  9  2023 cov_anc_1trimester_anc1   0   facility anc_1trimester
#> 10  2023 cov_anc4_anc1            59.9 facility anc4          
#> 11  2023 cov_pnc48h_anc1          24.9 facility pnc48h        
generate_coverage_data(coverage, type = "child", denominator = "penta1")
#> # A tibble: 15 × 5
#>     year name                value source   indicator
#>    <dbl> <chr>               <dbl> <fct>    <fct>    
#>  1  2022 r_penta3            89.2  survey   penta3   
#>  2  2022 r_penta1            97.1  survey   penta1   
#>  3  2022 r_bcg               96.9  survey   bcg      
#>  4  2022 r_measles1          89.0  survey   measles1 
#>  5  2023 cov_bcg_penta1      53.7  facility bcg      
#>  6  2023 cov_penta1_penta1   97.1  facility penta1   
#>  7  2023 cov_penta3_penta1   93.6  facility penta3   
#>  8  2023 cov_measles1_penta1 95.1  facility measles1 
#>  9  2023 cov_measles2_penta1  2.82 facility measles2 
#> 10  2023 cov_bcg_wuenic      90    wuenic   bcg      
#> 11  2023 cov_measles1_wuenic 91    wuenic   measles1 
#> 12  2023 cov_measles2_wuenic 76    wuenic   measles2 
#> 13  2023 cov_penta1_wuenic   97    wuenic   penta1   
#> 14  2023 cov_penta3_wuenic   93    wuenic   penta3   
#> 15  2022 r_measles2          30.8  survey   measles2 
```
