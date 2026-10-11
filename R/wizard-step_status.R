# The steps of the Load Data wizard and their state. The step tests are plain functions of a
# dataset (the value of cache(), not the reactive), so they can be called from anywhere. The only
# input that differs between apps is cd_wizard_config() (wizard-config.R).

#' Tests of whether a Load Data wizard step is complete
#'
#' Each function looks at a dataset and says whether one step of the Load Data wizard is done.
#' The wizard uses them, through [wizard_step_defs] and [compute_step_states()], to decide which
#' steps are open and when Continue is enabled. `step_shapefile_touched()` is not a completion
#' test: it says whether the user has done anything on the Shapefile step, which decides whether
#' that step's button reads "Skip" or "Continue".
#'
#' @details
#' The survey files, the reference estimates and the shapefile have built-in data for the
#' dataset's country, so reading them from the dataset never gives `NULL`. The tests for those
#' steps therefore use `cd$is_default()`, which says whether the user has uploaded something.
#' The two name mappings have no built-in data, so their tests check for `NULL`: a mapping
#' exists only after the user has saved the matching dialog at least once.
#'
#' @param cd The dataset, a [CacheConnection] object (the value of `cache()`, not the reactive),
#'   or `NULL` when no dataset is loaded.
#' @return `TRUE` or `FALSE`. Every function returns `FALSE` for a `NULL` dataset, except
#'   `step_shapefile_complete()`, which returns `TRUE`. Otherwise each returns `TRUE` when:
#'   * `step_upload_complete()`: the dataset holds unmerged sheets (`cd$wizard_parts`) or merged
#'     data with at least one row (`cd$countdown_data`).
#'   * `step_quality_complete()`: the upload is complete and every check of severity
#'     `"blocking"` in [run_all_quality_checks()] has passed.
#'   * `step_national_rates_complete()`: every national rate named by
#'     [national_rates_required_fields()] and every survey estimate named by
#'     [survey_estimates_required_fields()] has a value, and `cd$survey_year` is set.
#'   * `step_survey_files_complete()`: the user has uploaded all five survey files
#'     ([survey_fields]).
#'   * `step_shapefile_complete()`: the built-in shapefile is in use, or the user has uploaded
#'     one and `cd$shapefile_name_field` is set.
#'   * `step_shapefile_touched()`: the user has uploaded a shapefile.
#'   * `step_survey_mapping_complete()`: a survey name mapping is saved (`cd$survey_mapping`).
#'   * `step_map_mapping_complete()`: a shapefile name mapping is saved (`cd$map_mapping`).
#' @examples
#' old <- options(cd2030.wizard = list(national_rates_groups = list(
#'   cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
#'     cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
#'     cd_wizard_national_rate_fields()
#'   )
#' )))
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#'
#' step_upload_complete(cache)
#' step_quality_complete(cache)
#' step_national_rates_complete(cache)
#' step_survey_files_complete(cache)
#' step_shapefile_complete(cache)
#' step_shapefile_touched(cache)
#' step_survey_mapping_complete(cache)
#' step_map_mapping_complete(cache)
#'
#' # no dataset loaded
#' step_upload_complete(NULL)
#'
#' options(old)
#' @concept Countdown app wizard
#' @export
step_upload_complete <- function(cd) {
  # wizard_parts counts too: a newly loaded Excel file only has its unmerged sheets until
  # Finish, and countdown_data stays NULL for the whole walkthrough.
  if (is.null(cd)) return(FALSE)
  (!is.null(cd$wizard_parts)) || (!is.null(cd$countdown_data) && nrow(cd$countdown_data) > 0)
}

#' @rdname step_upload_complete
#' @export
step_quality_complete <- function(cd) {
  # The dataset is loaded without validation (wizard-upload_box.R), so this is where the
  # blocking data quality checks stop the wizard.
  if (!step_upload_complete(cd)) return(FALSE)
  results <- run_all_quality_checks(cd)
  all(vapply(results, function(r) !identical(r$severity, "blocking") || isTRUE(r$ok), logical(1)))
}

#' The values the National Rates step requires
#'
#' Return the names of the values that must be set before the National Rates step counts as
#' complete: every field of the app's wizard configuration ([cd_wizard_config()]).
#' `national_rates_required_fields()` gives the national rates, which are elements of the
#' dataset's `national_estimates`. `survey_estimates_required_fields()` gives the survey coverage
#' estimates, which are elements of the dataset's `survey_estimates`. They are functions because
#' the list differs between apps and is read from the configuration when called.
#'
#' @return A character vector of names, in display order: the `key` of every `"rate"` field for
#'   `national_rates_required_fields()`, and of every `"survey"` field for
#'   `survey_estimates_required_fields()`.
#' @examples
#' old <- options(cd2030.wizard = list(national_rates_groups = list(
#'   cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
#'     cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
#'     cd_wizard_survey_field("ideliv_prop", "instlivebirths", "title_upload_ideliv_survey"),
#'     cd_wizard_national_rate_fields()
#'   )
#' )))
#'
#' national_rates_required_fields()
#' survey_estimates_required_fields()
#'
#' options(old)
#' @seealso [step_national_rates_complete()], which uses both.
#' @concept Countdown app wizard
#' @export
national_rates_required_fields <- function() vapply(wizard_fields("rate"), function(f) f$key, character(1))
#' @rdname national_rates_required_fields
#' @export
survey_estimates_required_fields <- function() vapply(wizard_fields("survey"), function(f) f$key, character(1))

#' @rdname step_upload_complete
#' @export
step_national_rates_complete <- function(cd) {
  # Every rate is checked, also twin_rate and preg_loss, which start with a default value: the
  # user can empty them in the form, and they are then NA.
  if (is.null(cd)) return(FALSE)
  all(!is.na(unlist(cd$national_estimates[national_rates_required_fields()]))) &&
    all(!is.na(cd$survey_estimates[survey_estimates_required_fields()])) &&
    !is.null(cd$survey_year)
}

#' The dataset fields of the five survey files
#'
#' The names of the dataset fields the Survey Files step fills, one per survey file. Each has
#' built-in data for the dataset's country, so `cache()$is_default(field)` is the way to tell
#' whether the user has uploaded a file for it.
#'
#' @format A character vector of five field names: `"national_survey"`, `"regional_survey"`,
#'   `"wiq_survey"` (wealth index quintiles), `"area_survey"` and `"education_survey"`.
#' @examples
#' survey_fields
#'
#' # which survey files the user has uploaded
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' vapply(survey_fields, function(f) !cache$is_default(f), logical(1))
#' @concept Countdown app wizard
#' @export
survey_fields <- c("national_survey", "regional_survey", "wiq_survey", "area_survey", "education_survey")

#' @rdname step_upload_complete
#' @export
step_survey_files_complete <- function(cd) {
  if (is.null(cd)) return(FALSE)
  all(vapply(survey_fields, function(f) !isTRUE(cd$is_default(f)), logical(1)))
}

#' @rdname step_upload_complete
#' @export
step_shapefile_complete <- function(cd) {
  # A usable shapefile always exists (the built-in one), so this step only reads as incomplete
  # for an uploaded shapefile whose admin level 1 name column is not chosen.
  if (is.null(cd) || isTRUE(cd$is_default("shapefile"))) return(TRUE)
  !is.null(cd$shapefile_name_field)
}

#' @rdname step_upload_complete
#' @export
step_shapefile_touched <- function(cd) !is.null(cd) && !isTRUE(cd$is_default("shapefile"))

#' @rdname step_upload_complete
#' @export
step_survey_mapping_complete <- function(cd) !is.null(cd) && !is.null(cd$survey_mapping)
#' @rdname step_upload_complete
#' @export
step_map_mapping_complete <- function(cd) !is.null(cd) && !is.null(cd$map_mapping)

#' The steps of the Load Data wizard
#'
#' The definition of the wizard's seven steps, in the order the user goes through them: Upload
#' Data, Data Quality, Survey Files, National Rates, Shapefile, Map Survey Files and Map
#' Shapefile Names. [compute_step_states()] turns it into the state of each step for a dataset.
#' Survey Files and Shapefile are optional; the other five are required.
#'
#' @details
#' Survey Files comes before National Rates because an uploaded national survey fills in most
#' of the National Rates fields; the user then only has to check them.
#'
#' @format A list of seven lists, one per step. Each has:
#' * `key`: the step's key, a string: `"upload"`, `"quality"`, `"survey_files"`,
#'   `"national_rates"`, `"shapefile"`, `"survey_mapping"` or `"map_mapping"`.
#' * `title_key`: the translation key of the step's title.
#' * `required`: `TRUE` when the step must be complete before the user can go on.
#' * `complete_fn`: a function of the dataset that returns `TRUE` when the step is complete
#'   (see [step_upload_complete()]).
#' * `touched_fn` (the Shapefile step only): a function of the dataset that returns `TRUE` when
#'   the user has done something on the step.
#' * `relevant_fn` (the two mapping steps only): a function of the dataset whose result
#'   [compute_step_states()] reports as `relevant`.
#' @examples
#' vapply(wizard_step_defs, function(s) s$key, character(1))
#' vapply(wizard_step_defs, function(s) s$required, logical(1))
#'
#' # test one step on a dataset
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' wizard_step_defs[[1]]$complete_fn(cache)
#' @concept Countdown app wizard
#' @export
wizard_step_defs <- list(
  list(key = "upload", title_key = "step_upload_title", required = TRUE, complete_fn = step_upload_complete),
  list(key = "quality", title_key = "step_quality_title", required = TRUE, complete_fn = step_quality_complete),
  list(key = "survey_files", title_key = "step_survey_files_title", required = FALSE, complete_fn = step_survey_files_complete),
  list(key = "national_rates", title_key = "step_national_rates_title", required = TRUE, complete_fn = step_national_rates_complete),
  list(key = "shapefile", title_key = "step_shapefile_title", required = FALSE, complete_fn = step_shapefile_complete, touched_fn = step_shapefile_touched),
  list(key = "survey_mapping", title_key = "step_survey_mapping_title", required = TRUE, complete_fn = step_survey_mapping_complete, relevant_fn = step_survey_files_complete),
  list(key = "map_mapping", title_key = "step_map_mapping_title", required = TRUE, complete_fn = step_map_mapping_complete, relevant_fn = step_shapefile_complete)
)

#' Work out the state of every Load Data wizard step
#'
#' Applies the step definitions to a dataset and returns, for each step, whether it is complete,
#' locked, required and how it should show in the wizard's row of steps. The wizard's row of
#' steps, its footer and the summary page all read this result.
#'
#' @details
#' On a walkthrough (`requires_walkthrough = TRUE`) a step is locked when the step before it is
#' not in `acknowledged`, or when any earlier required step is incomplete. Without a walkthrough
#' nothing is locked.
#'
#' `status` is only for display. It is `"locked"` for a locked step, otherwise `"current"` for
#' the step named by `current`, otherwise `"complete"` when the step is complete, touched and in
#' `acknowledged`, and otherwise `"available"`. To know whether a step's data is done, read
#' `complete`, not `status`: the current step never has the status `"complete"`.
#'
#' @param cd The dataset, a [CacheConnection] object (the value of `cache()`, not the reactive),
#'   or `NULL` when no dataset is loaded.
#' @param current The key of the step the user is on, a string, or `NULL` when there is none.
#' @param requires_walkthrough `TRUE` (the default) when the steps must be gone through in
#'   order, as for a newly loaded Excel or Stata file. `FALSE` for a finished dataset, which
#'   locks nothing.
#' @param step_defs The steps, a list with the structure of [wizard_step_defs], which is the
#'   default. A step may also have a `required_fn`, a function of the dataset that is used in
#'   place of its `required` value.
#' @param acknowledged The keys of the steps the user has moved on from with Continue or Skip, a
#'   character vector.
#' @return A list with one element per step, in the order of `step_defs`. Each element is a list
#'   with:
#'   * `key`, `title_key`: copied from the step's definition.
#'   * `status`: `"locked"`, `"current"`, `"complete"` or `"available"` (see Details).
#'   * `complete`: `TRUE` when the step's `complete_fn` returns `TRUE` for `cd`.
#'   * `touched`: the result of the step's `touched_fn`, or the same as `complete` when the
#'     step has none.
#'   * `locked`: `TRUE` when the user may not open the step yet.
#'   * `relevant`: the result of the step's `relevant_fn`, or `TRUE` when the step has none.
#'   * `required`: `TRUE` when the step must be complete before the user can go on.
#' @examples
#' old <- options(cd2030.wizard = list(national_rates_groups = list(
#'   cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
#'     cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
#'     cd_wizard_national_rate_fields()
#'   )
#' )))
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#'
#' # on a walkthrough, with the first two steps passed
#' states <- compute_step_states(cache,
#'   current = "survey_files", acknowledged = c("upload", "quality")
#' )
#' vapply(states, function(s) s$status, character(1))
#'
#' # a finished dataset: nothing is locked
#' states <- compute_step_states(cache, current = NULL, requires_walkthrough = FALSE)
#' vapply(states, function(s) s$complete, logical(1))
#'
#' options(old)
#' @concept Countdown app wizard
#' @export
compute_step_states <- function(cd, current, requires_walkthrough = TRUE, step_defs = wizard_step_defs, acknowledged = character(0)) {
  # `acknowledged` only affects what is shown (`status`) and what is locked. `complete` is
  # always the real state of the data, so callers that enable Continue must read `complete`.
  blocked <- FALSE
  lapply(seq_along(step_defs), function(i) {
    def <- step_defs[[i]]
    complete <- isTRUE(def$complete_fn(cd))
    # touched: has the user actually DONE anything here, as opposed to merely "nothing blocks progression"
    # (complete). Only shapefile needs its own touched_fn today (step_shapefile_touched, above) -- every
    # other step's complete_fn is already "did the user provide this" with no default-counts-as-done
    # wrinkle, so falling back to `complete` is correct for them without needing a touched_fn of their own.
    touched <- if (!is.null(def$touched_fn)) isTRUE(def$touched_fn(cd)) else complete
    required <- if (!is.null(def$required_fn)) isTRUE(def$required_fn(cd)) else isTRUE(def$required)
    # On a fresh walkthrough a step opens only once the user has moved on from the one before it (Continue or
    # Skip) -- not merely because that step's data happens to be complete -- so the rail can't be used to jump
    # ahead of the walkthrough. Editing a finished dataset is not a walkthrough: nothing is locked.
    locked <- if (!requires_walkthrough) FALSE else blocked || (i > 1 && !(step_defs[[i - 1]]$key %in% acknowledged))
    if (requires_walkthrough && required && !complete) blocked <<- TRUE
    relevant <- if (!is.null(def$relevant_fn)) isTRUE(def$relevant_fn(cd)) else TRUE
    # status: DISPLAY only (what the rail's icon shows) -- "current" wins over "complete" there so the step
    # you're actively looking at doesn't switch to a checkmark out from under you, and a complete-but-not-yet-
    # acknowledged step shows as merely "available" rather than already done (see this function's own
    # `acknowledged` param comment above). complete: the actual, always-accurate "is this step's data done"
    # boolean, independent of whether it's also the current step or has been visited -- callers that need to
    # know completion (the footer's can_advance, in particular) must use THIS field, never infer it from
    # status. Confirmed live bug otherwise: viewing a step you'd just finished (still "current") made its own
    # Continue button permanently read as disabled, since identical(status, "complete") is never true for the
    # step you're actually on.
    #
    # `touched`, NOT `complete`, gates the checkmark here -- explicit user report: Shapefile showed a
    # checkmark ("completed shading") having never been uploaded, purely because it was `complete` (a usable
    # default shapefile always exists) and acknowledged (the user had passed it going forward). `complete`
    # alone can't tell "the user genuinely did this" apart from "there was nothing to do" for any step that
    # has its own touched_fn (only Shapefile today) -- exactly the same distinction the footer's Skip/Continue
    # label already uses `touched` for, just never applied to the rail's own icon until now. No behavior
    # change for every other step, where touched falls back to complete.
    status <- if (locked) {
      "locked"
    } else if (identical(def$key, current)) {
      "current"
    } else if (touched && complete && def$key %in% acknowledged) {
      "complete"
    } else {
      "available"
    }
    list(key = def$key, title_key = def$title_key, status = status, complete = complete, touched = touched, locked = locked, relevant = relevant, required = required)
  })
}
