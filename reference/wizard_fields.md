# The National Rates fields of one kind

Returns every field of one kind from the app's wizard configuration
(`cd_wizard_config()$national_rates_groups`), across all groups, in
display order.

## Usage

``` r
wizard_fields(kind)
```

## Arguments

- kind:

  The kind of field to return: `"survey"` (survey coverage estimates) or
  `"rate"` (national rates).

## Value

A list of field descriptions, as made by
[`cd_wizard_survey_field()`](cd_wizard_survey_field.md) or
[`cd_wizard_rate_field()`](cd_wizard_survey_field.md). The list is empty
when the configuration has no field of that kind.

## Examples

``` r
old <- options(cd2030.wizard = list(national_rates_groups = list(
  cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
    cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
    cd_wizard_national_rate_fields()
  )
)))

vapply(wizard_fields("survey"), function(f) f$id, character(1))
#> [1] "anc4_prop"
vapply(wizard_fields("rate"), function(f) f$id, character(1))
#> [1] "pregnancy_loss"               "twin_rate"                   
#> [3] "stillbirth_rate"              "neonatal_mortality_rate"     
#> [5] "post_neonatal_mortality_rate"

options(old)
```
