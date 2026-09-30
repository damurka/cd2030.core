# Merge and standardize an already-`load_excel_parts()`-ed set of sheets

The back half of what used to be `.load_excel_data()`: the Tier A
structural checks (admin columns present, exactly one country),
`merge_data()` + `standardize_data()`, then
[`new_countdown()`](new_countdown.md) for group resolution and the Tier
B quality gate. Kept as a fail-fast backstop even for a caller (the Load
Data wizard) that already ran these same Tier A checks non-abortingly,
earlier, against the same `parts` – the same defense-in-depth every
other blocking check in this pipeline already has between its
wizard-facing non-aborting form and its abort-on-call one.

## Usage

``` r
merge_and_standardize(
  parts_result,
  indicator_group = c("auto", "vaccine", "rmncah", "custom"),
  profile = NULL,
  profile_name = NULL,
  validate = TRUE
)
```

## Arguments

- parts_result:

  The list returned by [`load_excel_parts()`](load_excel_parts.md).
  Exported (not `@noRd`) because the Load Data wizard's own Finish
  action (`apps/rmncah/ui/wizard_panels.R`) calls this directly, across
  the package boundary, once
  [`step_quality_complete()`](countdown-pages.md) is satisfied – it's
  not purely an internal implementation detail of `.load_excel_data()`
  any more.

- indicator_group:

  One of `"auto"`, `"vaccine"`, `"rmncah"`, `"custom"`. Default
  `"auto"`.

- profile:

  Optional. Either a **name** (string) of an existing group, or a
  **definition** to register inline before loading:

  - explicit form:
    `list(name = "rmncah", value = list(hiv = c("hiv_test","pmtct1")))`

  - compact form:
    `list(hiv_profile = list(testing = c("hiv_test"), care = c("art_new")))`

  For `"custom"`, the profile must resolve to **one** concrete name.

- profile_name:

  Optional. The resolved profile (indicator group) name, used when
  resolving the indicator group (for example with
  `indicator_group = "custom"`). Default is `NULL`.

- validate:

  Logical. Whether to run Tier B quality checks (district-name
  consistency, missing months, unrecognized months – see
  `R/0_data_quality_checks.R`) as part of loading. Default `TRUE`,
  matching the pipeline's long-standing behavior. `FALSE` lets a file
  with data-quality problems (as opposed to *structural* ones – Tier A,
  e.g. a missing admin column – which always run regardless) load
  anyway, for a caller that wants to run those checks itself later,
  progressively, against the already-loaded data (see
  [`run_all_quality_checks()`](run_all_quality_checks.md)) rather than
  as an upfront hard stop.

## Value

A tibble of class `cd_data`.
