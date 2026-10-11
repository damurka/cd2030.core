# Generate a key for each admin level 1 unit

Gives each distinct admin level 1 name a short key, so that the same
unit can be identified in several tables (for example the dataset, the
survey mapping and the map mapping). Generate the keys once from the
dataset's names, then join them to the other tables by name.

## Usage

``` r
generate_admin1_keys(admin1_names)
```

## Arguments

- admin1_names:

  A character vector of admin level 1 names, usually the `adminlevel_1`
  column of the dataset.

## Value

A tibble with one row per distinct name, sorted by name, and columns
`adminlevel_1` (the name) and `admin1_key` (the key: `"A1-001"`,
`"A1-002"` and so on).

## Details

The keys are arbitrary: the distinct names are sorted and numbered in
that order. They are not standard codes, and they are not stable between
datasets. A dataset with a different set of names can give a different
key to the same unit. Missing names get no key.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
generate_admin1_keys(data$adminlevel_1)
#> # A tibble: 8 × 2
#>   adminlevel_1  admin1_key
#>   <chr>         <chr>     
#> 1 Central       A1-001    
#> 2 Coast         A1-002    
#> 3 Eastern       A1-003    
#> 4 Nairobi       A1-004    
#> 5 North Eastern A1-005    
#> 6 Nyanza        A1-006    
#> 7 Rift Valley   A1-007    
#> 8 Western       A1-008    

# Repeated and missing names get no key of their own
generate_admin1_keys(c("Western", "Coast", "Western", NA))
#> # A tibble: 2 × 2
#>   adminlevel_1 admin1_key
#>   <chr>        <chr>     
#> 1 Coast        A1-001    
#> 2 Western      A1-002    
```
