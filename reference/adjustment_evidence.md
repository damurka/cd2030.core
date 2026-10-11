# What the data quality checks found, for the Data Adjustment page

The numbers the Data Adjustment page shows beside its settings, from the
same computations as the check pages (Reporting rate, Outlier detection,
Data completeness): each indicator group's national reporting rate in
`year` and how many districts report below `threshold`; each indicator's
outlier months (more than 5 x MAD from the district's median) and empty
months; each region's and district's lowest group reporting rate in
`year`.

## Usage

``` r
adjustment_evidence(
  .data,
  threshold = .cd_method$data_quality$reporting_threshold,
  year = NULL
)
```

## Arguments

- .data:

  A `cd_data` tibble (the data before adjustment, its removed years
  already left out).

- threshold:

  Numeric. The performance threshold (in percent) of the Reporting rate
  page.

- year:

  The year of the reporting rates (by default the latest).

## Value

A list: `year`, `threshold`, `groups` (named by group: `rr`, `below`),
`indicators` (named by indicator: `outliers`, `missing`, months),
`areas` (a list of
`list(region, rr, districts = list(list(name, rr)))`).

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
evidence <- adjustment_evidence(data)
str(evidence$groups$opd)
#> List of 2
#>  $ rr   : num 97
#>  $ below: int 4
str(evidence$indicators$penta3)
#> List of 2
#>  $ outliers: int 29
#>  $ missing : int 0

# Against a stricter threshold, for an earlier year
adjustment_evidence(data, threshold = 95, year = 2021)$groups$opd
#> $rr
#> [1] 96
#> 
#> $below
#> [1] 12
#> 
```
