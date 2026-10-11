# The five national rate fields every indicator group needs

Returns the descriptions of the national rate fields that every app's
National Rates step has: pregnancy loss, twin rate, stillbirth rate,
neonatal mortality rate and post-neonatal mortality rate. Apps share
this list so that their input ids, dataset keys and labels stay the
same. Pass it to [`cd_wizard_field_group()`](cd_wizard_field_group.md).

## Usage

``` r
cd_wizard_national_rate_fields()
```

## Value

A list of five field descriptions, each made with
[`cd_wizard_rate_field()`](cd_wizard_survey_field.md), for the
`national_estimates` keys `preg_loss`, `twin_rate`, `sbr`, `nmr` and
`pnmr`.

## Examples

``` r
fields <- cd_wizard_national_rate_fields()
vapply(fields, function(f) f$key, character(1))
#> [1] "preg_loss" "twin_rate" "sbr"       "nmr"       "pnmr"     
vapply(fields, function(f) f$id, character(1))
#> [1] "pregnancy_loss"               "twin_rate"                   
#> [3] "stillbirth_rate"              "neonatal_mortality_rate"     
#> [5] "post_neonatal_mortality_rate"
```
