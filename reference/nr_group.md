# A titled group of fields in the wizard's forms

Lays out fields in a grid under a title and a subtitle. The National
Rates step uses it for each group of fields, and the Upload Data step
for its reference-data upload zones.

## Usage

``` r
nr_group(i18n, titleKey, subtitleKey, ..., cols = 4)
```

## Arguments

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- titleKey:

  The translation key of the group's title, a string.

- subtitleKey:

  The translation key of the group's subtitle, a string.

- ...:

  The fields of the group, as Shiny tags (for example from
  [`nr_field()`](nr_field.md)), in display order.

- cols:

  The number of columns of the grid, a whole number. The default is 4.

## Value

The group as Shiny tags.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a module's ui, where ns <- NS(id)
nr_group(i18n, "title_upload_group_survey_ref", "sub_upload_group_survey_ref",
  nr_field(ns, i18n, "survey_year", "title_upload_recent_survey_year", 2015, 2030, 1, NULL),
  uiOutput(ns("survey_start_ui"))
)

# two columns in place of four
nr_group(i18n, "title_upload_group_immunization", "sub_upload_group_immunization",
  nr_field(ns, i18n, "penta3_prop", "title_upload_penta3_survey", 0, 100, 1, "hint_upload_percent"),
  nr_field(ns, i18n, "bcg_prop", "title_upload_bcg_survey", 0, 100, 1, "hint_upload_percent"),
  cols = 2
)
} # }
```
