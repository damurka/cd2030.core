# Read column names with the data dictionary

Splits each name into its parts ([`cd_dictionary()`](cd_dictionary.md))
and says in plain words what the column holds – e.g.
`cov_penta3_penta1derived`: "Coverage of Pentavalent 3 (%), denominator:
Penta1 population growth". A name it cannot read gets type `"unknown"`
and no description: it never guesses.

## Usage

``` r
cd_describe_columns(names)
```

## Arguments

- names:

  Column names.

## Value

A data frame, one row per name: `column`, `type` (count, coverage,
population, population_growth, survey, survey_upper, survey_lower,
reporting_rate, fixed, unknown), `indicator`, `denominator`,
`population` (the parts' ids, or `NA`) and `description`.

## Examples

``` r
cd_describe_columns(c("cov_penta3_penta1derived", "totinftpenta_anc1", "r_penta1",
                      "vacc_rr", "year", "xyz"))
#>                     column           type indicator   denominator   population
#> 1 cov_penta3_penta1derived       coverage    penta3 penta1derived         <NA>
#> 2        totinftpenta_anc1     population      <NA>          anc1 totinftpenta
#> 3                 r_penta1         survey    penta1          <NA>         <NA>
#> 4                  vacc_rr reporting_rate      <NA>          <NA>         <NA>
#> 5                     year          fixed      <NA>          <NA>         <NA>
#> 6                      xyz        unknown      <NA>          <NA>         <NA>
#>                                                                                 description
#> 1      Coverage of Pentavalent 3 (%), denominator: Penta1 population growth (penta1derived)
#> 2 Infants eligible for Penta (thousands) estimated with the ANC1-derived denominator (anc1)
#> 3                                                      Survey coverage of Pentavalent 1 (%)
#> 4                              Reporting rate, vaccination (% of expected reports received)
#> 5                                                                                 The year.
#> 6                                                                                      <NA>
```
