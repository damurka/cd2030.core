# Describe one field of the National Rates step

Each function describes one number field for an app's wizard
configuration (see [`cd_wizard_config()`](cd_wizard_config.md)).
`cd_wizard_survey_field()` describes a survey coverage estimate, entered
in percent (0 to 100, in steps of 1) and saved in the dataset's
`survey_estimates`. `cd_wizard_rate_field()` describes a national rate,
entered as a proportion (0 to 0.05, in steps of 0.001) and saved in the
dataset's `national_estimates`. Pass the results to
[`cd_wizard_field_group()`](cd_wizard_field_group.md).

## Usage

``` r
cd_wizard_survey_field(id, key, label_key)

cd_wizard_rate_field(id, key, label_key)
```

## Arguments

- id:

  The input id of the field, a string.

- key:

  The name of the value in the dataset, a string: an element of
  `survey_estimates` for a survey field (for example `"anc4"`), or of
  `national_estimates` for a rate field (`"nmr"`, `"pnmr"`, `"sbr"`,
  `"twin_rate"` or `"preg_loss"`).

- label_key:

  The translation key of the field's label, a string.

## Value

A list that describes the field, with elements `kind` (`"survey"` or
`"rate"`), `id`, `key`, `label_key`, `min`, `max`, `step` and `hint`
(the translation key of the hint under the field).

## Examples

``` r
str(cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"))
#> List of 8
#>  $ kind     : chr "survey"
#>  $ id       : chr "anc4_prop"
#>  $ key      : chr "anc4"
#>  $ label_key: chr "title_upload_anc4_survey"
#>  $ min      : num 0
#>  $ max      : num 100
#>  $ step     : num 1
#>  $ hint     : chr "hint_upload_percent"
str(cd_wizard_rate_field("stillbirth_rate", "sbr", "title_upload_stillbirth"))
#> List of 8
#>  $ kind     : chr "rate"
#>  $ id       : chr "stillbirth_rate"
#>  $ key      : chr "sbr"
#>  $ label_key: chr "title_upload_stillbirth"
#>  $ min      : num 0
#>  $ max      : num 0.05
#>  $ step     : num 0.001
#>  $ hint     : chr "hint_upload_proportion"
```
