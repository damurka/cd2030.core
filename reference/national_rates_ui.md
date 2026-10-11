# National rates step of the Load Data wizard

The user enters the national figures the denominators are calculated
from: the survey coverage estimates (in percent) and national rates (as
proportions) listed in the app's wizard configuration
([`cd_wizard_config()`](cd_wizard_config.md)), the year of the most
recent survey, and the year the surveys start from. The fields show what
the dataset already holds, so values taken from an uploaded national
survey appear filled in; a banner says so when the user has uploaded a
national survey. Each change is saved to the dataset shortly after it is
made. The step counts as complete when every listed field has a value
and the survey year is set (see
[`step_national_rates_complete()`](step_upload_complete.md)).

## Usage

``` r
national_rates_ui(id, i18n)

national_rates_server(id, cache, i18n)
```

## Arguments

- id:

  The module's id.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

## Value

`national_rates_ui()` returns the UI as Shiny tags: a card with the
groups of fields. `national_rates_server()` is called for its side
effects and returns nothing useful.

## Details

What is saved:

- survey coverage estimates, rounded to one decimal place, with
  `cache()$set_survey_estimates()`;

- national rates, rounded to three decimal places, with
  `cache()$set_national_estimates()`;

- the most recent survey year (2015 to 2030) with
  `cache()$set_survey_year()`, or `cache()$clear_survey_year()` when the
  user empties the field;

- the survey start year with `cache()$set_start_survey_year()`. This
  field is a list of `cache()$survey_years` and only shows when the
  dataset has survey years. When the saved start year is not one of
  them, the earliest is saved in its place.

Emptying an estimate or a rate field saves a missing value (`NA`) for
it, which makes the step incomplete again.

## Examples

``` r
if (FALSE) { # \dontrun{
# the app describes the step's fields once, before the wizard is used
options(cd2030.wizard = list(national_rates_groups = list(
  cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
    cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
    cd_wizard_national_rate_fields()
  )
)))

# in the server of the Load Data screen, where `cache` is a reactive holding the dataset:
# the step's page, for wizard_steps_server(), and its server
panel <- list(key = "national_rates", ui = national_rates_ui(ns("national_rates"), i18n))
national_rates_server("national_rates", cache, i18n)
} # }
```
