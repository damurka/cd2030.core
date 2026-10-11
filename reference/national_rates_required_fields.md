# The values the National Rates step requires

Return the names of the values that must be set before the National
Rates step counts as complete: every field of the app's wizard
configuration ([`cd_wizard_config()`](cd_wizard_config.md)).
`national_rates_required_fields()` gives the national rates, which are
elements of the dataset's `national_estimates`.
`survey_estimates_required_fields()` gives the survey coverage
estimates, which are elements of the dataset's `survey_estimates`. They
are functions because the list differs between apps and is read from the
configuration when called.

## Usage

``` r
national_rates_required_fields()

survey_estimates_required_fields()
```

## Value

A character vector of names, in display order: the `key` of every
`"rate"` field for `national_rates_required_fields()`, and of every
`"survey"` field for `survey_estimates_required_fields()`.

## See also

[`step_national_rates_complete()`](step_upload_complete.md), which uses
both.

## Examples

``` r
old <- options(cd2030.wizard = list(national_rates_groups = list(
  cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
    cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
    cd_wizard_survey_field("ideliv_prop", "instlivebirths", "title_upload_ideliv_survey"),
    cd_wizard_national_rate_fields()
  )
)))

national_rates_required_fields()
#> [1] "preg_loss" "twin_rate" "sbr"       "nmr"       "pnmr"     
survey_estimates_required_fields()
#> [1] "anc4"           "instlivebirths"

options(old)
```
