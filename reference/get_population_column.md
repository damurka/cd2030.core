# Get the population column for an indicator and denominator

Names the column that holds the target population of an indicator for a
denominator option. The name is the indicator's target population
followed by the denominator, for example `"totinftpenta_penta1"` for
`penta3` with the `penta1` denominator.

## Usage

``` r
get_population_column(indicator, denominator)
```

## Arguments

- indicator:

  Character scalar. Indicator name (e.g., 'penta1', 'measles1')

- denominator:

  Character scalar. The denominator for the indicator: one of `"dhis2"`,
  `"anc1"`, `"penta1"`, `"penta1derived"` or `"anc1derived"`.

## Value

A string naming the corresponding population column, or `NA` when the
indicator has no target population defined.

## Examples

``` r
get_population_column("penta3", "penta1")
#> [1] "totinftpenta_penta1"
get_population_column("anc4", "dhis2")
#> [1] "totpreg_dhis2"

# births are total births with the DHIS2 denominator, live births with the others
get_population_column("bcg", "dhis2")
#> [1] "totbirths_dhis2"
get_population_column("bcg", "anc1")
#> [1] "totlbirths_anc1"
```
