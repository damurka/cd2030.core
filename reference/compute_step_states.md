# Work out the state of every Load Data wizard step

Applies the step definitions to a dataset and returns, for each step,
whether it is complete, locked, required and how it should show in the
wizard's row of steps. The wizard's row of steps, its footer and the
summary page all read this result.

## Usage

``` r
compute_step_states(
  cd,
  current,
  requires_walkthrough = TRUE,
  step_defs = wizard_step_defs,
  acknowledged = character(0)
)
```

## Arguments

- cd:

  The dataset, a [CacheConnection](CacheConnection.md) object (the value
  of `cache()`, not the reactive), or `NULL` when no dataset is loaded.

- current:

  The key of the step the user is on, a string, or `NULL` when there is
  none.

- requires_walkthrough:

  `TRUE` (the default) when the steps must be gone through in order, as
  for a newly loaded Excel or Stata file. `FALSE` for a finished
  dataset, which locks nothing.

- step_defs:

  The steps, a list with the structure of
  [wizard_step_defs](wizard_step_defs.md), which is the default. A step
  may also have a `required_fn`, a function of the dataset that is used
  in place of its `required` value.

- acknowledged:

  The keys of the steps the user has moved on from with Continue or
  Skip, a character vector.

## Value

A list with one element per step, in the order of `step_defs`. Each
element is a list with:

- `key`, `title_key`: copied from the step's definition.

- `status`: `"locked"`, `"current"`, `"complete"` or `"available"` (see
  Details).

- `complete`: `TRUE` when the step's `complete_fn` returns `TRUE` for
  `cd`.

- `touched`: the result of the step's `touched_fn`, or the same as
  `complete` when the step has none.

- `locked`: `TRUE` when the user may not open the step yet.

- `relevant`: the result of the step's `relevant_fn`, or `TRUE` when the
  step has none.

- `required`: `TRUE` when the step must be complete before the user can
  go on.

## Details

On a walkthrough (`requires_walkthrough = TRUE`) a step is locked when
the step before it is not in `acknowledged`, or when any earlier
required step is incomplete. Without a walkthrough nothing is locked.

`status` is only for display. It is `"locked"` for a locked step,
otherwise `"current"` for the step named by `current`, otherwise
`"complete"` when the step is complete, touched and in `acknowledged`,
and otherwise `"available"`. To know whether a step's data is done, read
`complete`, not `status`: the current step never has the status
`"complete"`.

## Examples

``` r
old <- options(cd2030.wizard = list(national_rates_groups = list(
  cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
    cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
    cd_wizard_national_rate_fields()
  )
)))
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

# on a walkthrough, with the first two steps passed
states <- compute_step_states(cache,
  current = "survey_files", acknowledged = c("upload", "quality")
)
vapply(states, function(s) s$status, character(1))
#> [1] "complete" "complete" "current"  "locked"   "locked"   "locked"   "locked"  

# a finished dataset: nothing is locked
states <- compute_step_states(cache, current = NULL, requires_walkthrough = FALSE)
vapply(states, function(s) s$complete, logical(1))
#> [1]  TRUE  TRUE FALSE FALSE  TRUE FALSE FALSE

options(old)
```
