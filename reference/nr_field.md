# One number field of the wizard's forms

Builds one labelled number field with the interface kit's
`cd_field_number()`. The field checks what is typed against `min` and
`max`, shows an error under the field for a value out of range, and
sends only a valid value to the server. A required field that is empty
shows a "not set" warning. A field whose hint is `"hint_upload_percent"`
shows a "%" unit at its end.

## Usage

``` r
nr_field(ns, i18n, inputId, labelKey, min, max, step, hintKey, required = TRUE)
```

## Arguments

- ns:

  The namespace function of the module the field belongs to (from
  `NS(id)` or `session$ns`).

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- inputId:

  The input id of the field, without the namespace, a string.

- labelKey:

  The translation key of the field's label, a string.

- min, max:

  The smallest and largest value the field accepts, numbers.

- step:

  The amount one step of the field changes the value by, a number.

- hintKey:

  The translation key of the hint under the field, a string, or `NULL`
  for no hint.

- required:

  `TRUE` (the default) when the field must have a value; an empty
  required field shows the "not set" warning.

## Value

The field as Shiny tags.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a module's ui, where ns <- NS(id)
nr_field(ns, i18n, "anc4_prop", "title_upload_anc4_survey", 0, 100, 1, "hint_upload_percent")

# a field without a hint, which may be left empty
nr_field(ns, i18n, "survey_year", "title_upload_recent_survey_year", 2015, 2030, 1, NULL,
  required = FALSE
)

# from a field description of the app's wizard configuration
f <- cd_wizard_rate_field("stillbirth_rate", "sbr", "title_upload_stillbirth")
nr_field(ns, i18n, f$id, f$label_key, f$min, f$max, f$step, f$hint)
} # }
```
