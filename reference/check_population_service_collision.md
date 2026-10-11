# Flag district-years where service births equal population births

Finds district-years where the monthly institutional live births
(`instlivebirths`) equal the annual population live births
(`live_births`) in every month. Monthly counts normally vary, so this
pattern suggests that population figures were entered in a service data
sheet.

## Usage

``` r
check_population_service_collision(.data)
```

## Arguments

- .data:

  A data frame. The merged dataset, with `district`, `year`,
  `instlivebirths` and `live_births` columns.

## Value

A tibble with columns `district` and `year`, one row per flagged
district-year. It has no rows if nothing is flagged or if `.data` lacks
`instlivebirths` or `live_births`.

## Details

Only months where both values are present are compared. A district-year
is flagged when it has at least three such months and the two values are
equal in all of them.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
check_population_service_collision(data)
#> # A tibble: 0 × 2
#> # ℹ 2 variables: district <chr>, year <int>

# Annual population births entered as the monthly service figure
copied <- data$district == "Baringo" & data$year == 2023
data$instlivebirths[copied] <- data$live_births[copied]
check_population_service_collision(data)
#> # A tibble: 1 × 2
#>   district  year
#>   <chr>    <int>
#> 1 Baringo   2023
```
