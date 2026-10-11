# The app's Load Data wizard configuration

Returns what an app has set for its own part of the Load Data wizard.
The wizard is the same for every indicator group except for two things,
which an app describes once with `options(cd2030.wizard = list(...))`
before the wizard is used: the fields of the National Rates step and
which reference-data upload zones the Upload Data step shows. The
indicator group is not part of this configuration (see
[`cd_wizard_indicator_group()`](cd_wizard_indicator_group.md)).

## Usage

``` r
cd_wizard_config()
```

## Value

The value of `getOption("cd2030.wizard")`, a list, with
`reference_uploads` filled in with its default when the app did not set
it. The function stops with an error when the option, or its
`national_rates_groups` element, is not set.

## Details

An app sets the option like this:

    options(cd2030.wizard = list(
      national_rates_groups = list(cd_wizard_field_group(...), ...),
      reference_uploads     = c("un_estimates", "wuenic_estimates", "un_mortality_estimates")
    ))

- `national_rates_groups` (required): the groups of fields of the
  National Rates step, in display order. Each element is made with
  [`cd_wizard_field_group()`](cd_wizard_field_group.md), and each field
  in it with [`cd_wizard_survey_field()`](cd_wizard_survey_field.md) (a
  survey coverage estimate, in percent) or
  [`cd_wizard_rate_field()`](cd_wizard_survey_field.md) (a national
  rate, as a proportion). The wizard takes from these the inputs it
  shows, what it saves to and reads back from the dataset, and which
  values the step needs before it counts as complete: every field listed
  is required.

- `reference_uploads` (optional): which reference-data zones the Upload
  Data step shows, any of `"un_estimates"`, `"wuenic_estimates"` and
  `"un_mortality_estimates"`. The default is all three.

## Examples

``` r
old <- options(cd2030.wizard = list(
  national_rates_groups = list(
    cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
      cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
      cd_wizard_national_rate_fields()
    )
  ),
  reference_uploads = c("un_estimates", "wuenic_estimates")
))

cfg <- cd_wizard_config()
cfg$reference_uploads
#> [1] "un_estimates"     "wuenic_estimates"
length(cfg$national_rates_groups[[1]]$fields)
#> [1] 6

options(old)
```
