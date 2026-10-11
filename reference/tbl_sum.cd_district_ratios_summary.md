# Summary for `cd_district_ratios_summary` Object

Provides a customized summary for a `cd_district_ratios_summary` object,
which includes the percentage of districts meeting the adequacy criteria
(e.g., ratios within the range of 1.0 to 1.5) across specified indicator
pairs by year. This summary aids in monitoring health indicator
alignment at a district level over time.

## Usage

``` r
# S3 method for class 'cd_district_ratios_summary'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_district_ratios_summary` object, typically created by the
  `calculate_district_ratios_summary` function, containing adequacy
  checks for district-level indicator ratios by year.

- ...:

  Additional arguments to support S3 method compatibility.

## Value

A character vector providing a descriptive title indicating the
percentage of districts with indicator ratios that meet adequacy
criteria, aiding in data quality interpretation.

## Examples

``` r
data <- load_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
ratios <- calculate_ratios_and_adequacy(data)

# the summary is the header printed above the table
calculate_district_ratios_summary(ratios)
#> # Table 3c.d: Percentage of Districts with Adequate Ratios (between 1.0 and
#> #   1.5)
#> # A tibble:   5 × 6
#>    year     anc1  penta1  penta3 % district with anc1/p…¹ % district with pent…²
#>   <int>    <dbl>   <dbl>   <dbl>                    <dbl>                  <dbl>
#> 1  2019 1429512  1359967 1293250                     70.2                   93.6
#> 2  2020 1465266  1323091 1266781                     95.7                   89.4
#> 3  2021 1547683. 1411557 1332230                     91.5                   97.9
#> 4  2022 1479978. 1387864 1340620                     87.2                   87.2
#> 5  2023 1500341  1410586 1355282                     85.1                   93.6
#> # ℹ abbreviated names: ¹​`% district with anc1/penta1 in expected ranged`,
#> #   ²​`% district with penta1/penta3 in expected ranged`
```
