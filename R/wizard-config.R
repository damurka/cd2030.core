#' The app's Load Data wizard configuration
#'
#' Returns what an app has set for its own part of the Load Data wizard. The wizard is the same
#' for every indicator group except for two things, which an app describes once with
#' `options(cd2030.wizard = list(...))` before the wizard is used: the fields of the National
#' Rates step and which reference-data upload zones the Upload Data step shows. The indicator
#' group is not part of this configuration (see [cd_wizard_indicator_group()]).
#'
#' @details
#' An app sets the option like this:
#'
#' ```r
#' options(cd2030.wizard = list(
#'   national_rates_groups = list(cd_wizard_field_group(...), ...),
#'   reference_uploads     = c("un_estimates", "wuenic_estimates", "un_mortality_estimates")
#' ))
#' ```
#'
#' * `national_rates_groups` (required): the groups of fields of the National Rates step, in
#'   display order. Each element is made with [cd_wizard_field_group()], and each field in it
#'   with [cd_wizard_survey_field()] (a survey coverage estimate, in percent) or
#'   [cd_wizard_rate_field()] (a national rate, as a proportion). The wizard takes from these
#'   the inputs it shows, what it saves to and reads back from the dataset, and which values
#'   the step needs before it counts as complete: every field listed is required.
#' * `reference_uploads` (optional): which reference-data zones the Upload Data step shows, any
#'   of `"un_estimates"`, `"wuenic_estimates"` and `"un_mortality_estimates"`. The default is all
#'   three.
#'
#' @return The value of `getOption("cd2030.wizard")`, a list, with `reference_uploads` filled in
#'   with its default when the app did not set it. The function stops with an error when the
#'   option, or its `national_rates_groups` element, is not set.
#' @examples
#' old <- options(cd2030.wizard = list(
#'   national_rates_groups = list(
#'     cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
#'       cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
#'       cd_wizard_national_rate_fields()
#'     )
#'   ),
#'   reference_uploads = c("un_estimates", "wuenic_estimates")
#' ))
#'
#' cfg <- cd_wizard_config()
#' cfg$reference_uploads
#' length(cfg$national_rates_groups[[1]]$fields)
#'
#' options(old)
#' @concept Countdown app wizard
#' @export
cd_wizard_config <- function() {
  cfg <- getOption("cd2030.wizard")
  if (is.null(cfg) || is.null(cfg$national_rates_groups)) {
    stop("options(cd2030.wizard = list(national_rates_groups = ...)) must be set before the Load Data wizard is used.", call. = FALSE)
  }
  cfg$reference_uploads <- cfg$reference_uploads %||% c("un_estimates", "wuenic_estimates", "un_mortality_estimates")
  cfg
}

#' The indicator group the running app is for
#'
#' Returns the indicator group of the app, from `options(cd2030.app_group = ...)`. When that
#' option is not set it falls back to `getOption("cd2030.selected_group")`. The wizard uses it
#' to build a dataset for the app's group and to name the dataset's saved copy.
#'
#' @return The indicator group, as the app set it (a string such as `"rmncah"` or `"vaccine"`).
#'   The function stops with an error when neither option is set.
#' @examples
#' old <- options(cd2030.app_group = "rmncah")
#' cd_wizard_indicator_group()
#' options(old)
#' @concept Countdown app wizard
#' @export
cd_wizard_indicator_group <- function() {
  # The app's own option comes first: the session-wide selected group changes when a dataset
  # built for another group is loaded, so it cannot say which group this app is for.
  group <- getOption("cd2030.app_group") %||% getOption("cd2030.selected_group")
  if (is.null(group)) stop("options(cd2030.app_group = ...) must be set before the Load Data wizard is used.", call. = FALSE)
  group
}

#' File name of a dataset's saved copy
#'
#' Builds the name of the `.rds` file a finished dataset is saved to: `<stem>_<group>.rds`, for
#' example `Benin_rmncah.rds` or `Benin_vaccine.rds`. One source file can be loaded by more than
#' one app, and the group in the name keeps each app's finished copy apart.
#'
#' @param stem The name of the source file without its extension, a string.
#' @return The file name (not a full path), a string. The group is the one
#'   [cd_wizard_indicator_group()] returns.
#' @examples
#' old <- options(cd2030.app_group = "rmncah")
#' cd_saved_copy_name("Kenya")
#' cd_saved_copy_name(tools::file_path_sans_ext(basename("C:/data/Kenya_2024.xlsx")))
#' options(old)
#' @concept Countdown app wizard
#' @export
cd_saved_copy_name <- function(stem) paste0(stem, "_", cd_wizard_indicator_group(), ".rds")

#' Check that a loaded dataset belongs to the app's indicator group
#'
#' Sets the package's selected indicator group back to the app's group (with
#' `set_selected_group()`), then stops with an error when the dataset was built for a different
#' group. The group a dataset was built for is the `indicator_group` attribute of its
#' `countdown_data`. A dataset without that attribute, or a `NULL` dataset, passes.
#'
#' @param cache The dataset, a [CacheConnection] object (not a reactive), or `NULL`.
#' @return `TRUE`, invisibly. The function stops with an error when the dataset was built for
#'   another indicator group.
#' @examples
#' old <- options(cd2030.app_group = "rmncah")
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cd_wizard_check_group(cache)
#'
#' # no dataset passes too
#' cd_wizard_check_group(NULL)
#' options(old)
#' @concept Countdown app wizard
#' @export
cd_wizard_check_group <- function(cache) {
  app_group <- cd_wizard_indicator_group()
  built_for <- if (!is.null(cache)) attr(cache$countdown_data, "indicator_group") else NULL
  set_selected_group(app_group)
  if (!is.null(built_for) && !identical(built_for, app_group)) {
    stop(sprintf("This dataset was built for the '%s' indicator group, but this app is for '%s'.", built_for, app_group), call. = FALSE)
  }
  invisible(TRUE)
}

#' Describe one field of the National Rates step
#'
#' Each function describes one number field for an app's wizard configuration (see
#' [cd_wizard_config()]). `cd_wizard_survey_field()` describes a survey coverage estimate, entered
#' in percent (0 to 100, in steps of 1) and saved in the dataset's `survey_estimates`.
#' `cd_wizard_rate_field()` describes a national rate, entered as a proportion (0 to 0.05, in
#' steps of 0.001) and saved in the dataset's `national_estimates`. Pass the results to
#' [cd_wizard_field_group()].
#'
#' @param id The input id of the field, a string.
#' @param key The name of the value in the dataset, a string: an element of `survey_estimates`
#'   for a survey field (for example `"anc4"`), or of `national_estimates` for a rate field
#'   (`"nmr"`, `"pnmr"`, `"sbr"`, `"twin_rate"` or `"preg_loss"`).
#' @param label_key The translation key of the field's label, a string.
#' @return A list that describes the field, with elements `kind` (`"survey"` or `"rate"`), `id`,
#'   `key`, `label_key`, `min`, `max`, `step` and `hint` (the translation key of the hint under
#'   the field).
#' @examples
#' str(cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"))
#' str(cd_wizard_rate_field("stillbirth_rate", "sbr", "title_upload_stillbirth"))
#' @concept Countdown app wizard
#' @export
cd_wizard_survey_field <- function(id, key, label_key) {
  list(kind = "survey", id = id, key = key, label_key = label_key, min = 0, max = 100, step = 1, hint = "hint_upload_percent")
}

#' @rdname cd_wizard_survey_field
#' @export
cd_wizard_rate_field <- function(id, key, label_key) {
  list(kind = "rate", id = id, key = key, label_key = label_key, min = 0, max = 0.05, step = 0.001, hint = "hint_upload_proportion")
}

#' Describe one group of fields of the National Rates step
#'
#' Puts fields under one heading for an app's wizard configuration. The National Rates step shows
#' each group as a titled block of number fields, in the order given (see [cd_wizard_config()]).
#'
#' @param title_key The translation key of the group's title, a string.
#' @param subtitle_key The translation key of the group's subtitle, a string.
#' @param ... The fields of the group, in display order. Each argument is one field (from
#'   [cd_wizard_survey_field()] or [cd_wizard_rate_field()]) or a list of fields (such as
#'   [cd_wizard_national_rate_fields()]), whose fields are added one by one.
#' @return A list with elements `title_key`, `subtitle_key` and `fields` (a flat list of the
#'   fields).
#' @examples
#' group <- cd_wizard_field_group("title_upload_group_immunization", "sub_upload_group_immunization",
#'   cd_wizard_survey_field("penta3_prop", "penta3", "title_upload_penta3_survey"),
#'   cd_wizard_survey_field("measles1_prop", "measles1", "title_upload_measles1_survey")
#' )
#' vapply(group$fields, function(f) f$key, character(1))
#'
#' # a list of fields is added field by field
#' group <- cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
#'   cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
#'   cd_wizard_national_rate_fields()
#' )
#' length(group$fields)
#' @concept Countdown app wizard
#' @export
cd_wizard_field_group <- function(title_key, subtitle_key, ...) {
  fields <- list()
  for (item in list(...)) {
    fields <- if (!is.null(item$kind)) c(fields, list(item)) else c(fields, item)
  }
  list(title_key = title_key, subtitle_key = subtitle_key, fields = fields)
}

#' The five national rate fields every indicator group needs
#'
#' Returns the descriptions of the national rate fields that every app's National Rates step
#' has: pregnancy loss, twin rate, stillbirth rate, neonatal mortality rate and post-neonatal
#' mortality rate. Apps share this list so that their input ids, dataset keys and labels stay
#' the same. Pass it to [cd_wizard_field_group()].
#'
#' @return A list of five field descriptions, each made with [cd_wizard_rate_field()], for the
#'   `national_estimates` keys `preg_loss`, `twin_rate`, `sbr`, `nmr` and `pnmr`.
#' @examples
#' fields <- cd_wizard_national_rate_fields()
#' vapply(fields, function(f) f$key, character(1))
#' vapply(fields, function(f) f$id, character(1))
#' @concept Countdown app wizard
#' @export
cd_wizard_national_rate_fields <- function() {
  list(
    cd_wizard_rate_field("pregnancy_loss", "preg_loss", "title_upload_preg_loss"),
    cd_wizard_rate_field("twin_rate", "twin_rate", "title_upload_twin_rate"),
    cd_wizard_rate_field("stillbirth_rate", "sbr", "title_upload_stillbirth"),
    cd_wizard_rate_field("neonatal_mortality_rate", "nmr", "title_upload_nmr"),
    cd_wizard_rate_field("post_neonatal_mortality_rate", "pnmr", "title_upload_pnmr")
  )
}

#' The National Rates fields of one kind
#'
#' Returns every field of one kind from the app's wizard configuration
#' (`cd_wizard_config()$national_rates_groups`), across all groups, in display order.
#'
#' @param kind The kind of field to return: `"survey"` (survey coverage estimates) or `"rate"`
#'   (national rates).
#' @return A list of field descriptions, as made by [cd_wizard_survey_field()] or
#'   [cd_wizard_rate_field()]. The list is empty when the configuration has no field of that
#'   kind.
#' @examples
#' old <- options(cd2030.wizard = list(national_rates_groups = list(
#'   cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
#'     cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
#'     cd_wizard_national_rate_fields()
#'   )
#' )))
#'
#' vapply(wizard_fields("survey"), function(f) f$id, character(1))
#' vapply(wizard_fields("rate"), function(f) f$id, character(1))
#'
#' options(old)
#' @concept Countdown app wizard
#' @export
wizard_fields <- function(kind) {
  fields <- unlist(lapply(cd_wizard_config()$national_rates_groups, function(g) g$fields), recursive = FALSE)
  Filter(function(f) identical(f$kind, kind), fields)
}
