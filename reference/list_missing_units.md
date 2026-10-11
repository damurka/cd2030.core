# List the districts and months with a missing value

Lists every district and month in which the value of one indicator is
missing. Use it to see where the gaps behind a completeness summary are.

## Usage

``` r
list_missing_units(.data, indicator, region = NULL)
```

## Arguments

- .data:

  A `cd_data` object.

- indicator:

  Character. The indicator to check: one of the indicators of the
  dataset (for example `"penta3"`).

- region:

  Optional name of an `adminlevel_1` region. If supplied, only the
  districts of that region are listed. Default is `NULL`.

## Value

A tibble of class `cd_missing_list` with one row per district and month
where the indicator is missing, and the columns `adminlevel_1`,
`district`, `year` and `month`. The attribute `indicator` holds the
indicator.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
list_missing_units(data, "measles2")
#> # A tibble: 35 × 4
#>    adminlevel_1 district   year month   
#>    <chr>        <chr>     <int> <ord>   
#>  1 Eastern      Embu       2019 August  
#>  2 Eastern      Embu       2020 May     
#>  3 Eastern      Isiolo     2020 July    
#>  4 Eastern      Isiolo     2020 December
#>  5 Rift Valley  Kericho    2020 April   
#>  6 Central      Kirinyaga  2019 November
#>  7 Central      Kirinyaga  2020 January 
#>  8 Central      Kirinyaga  2020 February
#>  9 Central      Kirinyaga  2020 March   
#> 10 Central      Kirinyaga  2020 June    
#> # ℹ 25 more rows

# Within one region
list_missing_units(data, "measles2", region = "Rift Valley")
#> # A tibble: 4 × 4
#>   adminlevel_1 district     year month   
#>   <chr>        <chr>       <int> <ord>   
#> 1 Rift Valley  Kericho      2020 April   
#> 2 Rift Valley  Samburu      2020 May     
#> 3 Rift Valley  Uasin Gishu  2019 December
#> 4 Rift Valley  Uasin Gishu  2020 January 
```
