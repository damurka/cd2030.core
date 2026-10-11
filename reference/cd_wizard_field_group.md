# Describe one group of fields of the National Rates step

Puts fields under one heading for an app's wizard configuration. The
National Rates step shows each group as a titled block of number fields,
in the order given (see [`cd_wizard_config()`](cd_wizard_config.md)).

## Usage

``` r
cd_wizard_field_group(title_key, subtitle_key, ...)
```

## Arguments

- title_key:

  The translation key of the group's title, a string.

- subtitle_key:

  The translation key of the group's subtitle, a string.

- ...:

  The fields of the group, in display order. Each argument is one field
  (from [`cd_wizard_survey_field()`](cd_wizard_survey_field.md) or
  [`cd_wizard_rate_field()`](cd_wizard_survey_field.md)) or a list of
  fields (such as
  [`cd_wizard_national_rate_fields()`](cd_wizard_national_rate_fields.md)),
  whose fields are added one by one.

## Value

A list with elements `title_key`, `subtitle_key` and `fields` (a flat
list of the fields).

## Examples

``` r
group <- cd_wizard_field_group("title_upload_group_immunization", "sub_upload_group_immunization",
  cd_wizard_survey_field("penta3_prop", "penta3", "title_upload_penta3_survey"),
  cd_wizard_survey_field("measles1_prop", "measles1", "title_upload_measles1_survey")
)
vapply(group$fields, function(f) f$key, character(1))
#> [1] "penta3"   "measles1"

# a list of fields is added field by field
group <- cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
  cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
  cd_wizard_national_rate_fields()
)
length(group$fields)
#> [1] 6
```
