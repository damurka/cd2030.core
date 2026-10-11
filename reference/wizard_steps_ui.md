# The Load Data wizard: its steps, navigation and Finish

The frame of the Load Data wizard. It shows the row of steps, the page
of the current step, and a footer with Back and Continue buttons, and it
decides which step the user may open
([`compute_step_states()`](compute_step_states.md)). A newly loaded
Excel or Stata file is walked through step by step: a step opens once
the user has moved on from the one before it, and a required step must
be complete before Continue is enabled. An optional step the user has
not touched offers "Skip" in place of "Continue". The last step's button
is Finish. A saved dataset (`.rds`) skips the walkthrough and opens on
the summary page ([`wizard_landing_ui()`](wizard_landing_ui.md)), from
which any step can be opened for editing.

## Usage

``` r
wizard_steps_ui(id)

wizard_steps_server(
  id,
  i18n,
  cache,
  requires_walkthrough,
  panels,
  source_path,
  active,
  step_defs = wizard_step_defs
)
```

## Arguments

- id:

  The module's id.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md), or `NULL` when no dataset is
  loaded.

- requires_walkthrough:

  A reactive that returns `TRUE` when the loaded file must be walked
  through step by step (an Excel or Stata file) and `FALSE` when it is a
  saved dataset (`.rds`). [`upload_box_server()`](upload_box_ui.md)
  returns it.

- panels:

  The pages of the steps: a list with one element per step of
  `step_defs`. Each element is a list with `key` (the step's key) and
  `ui` (the step's page, as Shiny tags).

- source_path:

  A reactive that returns the path Finish saves the dataset next to, a
  string, or `NULL`. [`upload_box_server()`](upload_box_ui.md) returns
  it.

- active:

  A reactive that returns `TRUE` while the Load Data screen is the page
  shown.

- step_defs:

  The wizard's steps, a list with the structure of
  [wizard_step_defs](wizard_step_defs.md), which is the default.

## Value

`wizard_steps_ui()` returns the UI as Shiny tags: the placeholder the
server fills with the wizard or the summary page.
`wizard_steps_server()` returns a list with two elements:

- `edit_mode`: a reactive that is `TRUE` when a finished dataset is
  being edited;

- `current_step`: a reactive value that holds the key of the current
  step.

## Details

**Finish.** On a dataset whose sheets are not merged yet
(`cache()$wizard_parts`), and whose blocking quality checks pass,
Finish:

- merges the sheets with
  [`merge_and_standardize()`](merge_and_standardize.md) for the app's
  indicator group, adds a key per admin level 1 area, and saves the
  result with `cache()$set_countdown_data()`;

- adds the same keys to the saved survey and shapefile name mappings
  (`cache()$set_survey_mapping()`, `cache()$set_map_mapping()`);

- marks the dataset as finished with
  `cache()$set_quality_confirmed(TRUE)`;

- sets where the dataset is saved, with `cache()$set_cache_path()`: the
  folder of `source_path()` and the name
  [`cd_saved_copy_name()`](cd_saved_copy_name.md) gives;

- keeps the quality check results with
  `cache()$set_wizard_quality_results()`, then removes the unmerged
  sheets with `cache()$clear_wizard_parts()`.

When the merge fails, an error notification shows and the wizard stays
on the last step. Otherwise the wizard shows the summary page. A dataset
that has no unmerged sheets (one loaded from a Stata file) is merged
already: Finish marks it finished and sets where it is saved, the same
way.

**Editing.** A dataset that is finished (loaded from a saved copy, or
`cache()$quality_confirmed` is `TRUE`) is in edit mode. The footer then
has a button back to the summary page and a button that opens the
Reporting Rate page (`"reporting_rate"`). Coming back to the Load Data
screen from another page shows the summary page again when
`cache()$quality_confirmed` is `TRUE`.

## Examples

``` r
if (FALSE) { # \dontrun{
# in the ui of the Load Data screen
wizard_steps_ui(ns("wizard"))

# in its server: one page per step of wizard_step_defs, built with the screen's own ns()
upload <- upload_box_server("upload_box", i18n, cdsuite_file = NA_character_)
panels <- list(
  list(key = "upload", ui = upload_box_ui(ns("upload_box"), i18n)),
  list(key = "quality", ui = data_quality_ui(ns("data_quality"), i18n)),
  list(key = "survey_files", ui = survey_upload_ui(ns("survey_upload"), i18n)),
  list(key = "national_rates", ui = national_rates_ui(ns("national_rates"), i18n)),
  list(key = "shapefile", ui = shapefile_step_ui(ns("shapefile_step"), i18n)),
  list(key = "survey_mapping", ui = map_survey_ui(ns("map_survey"), i18n)),
  list(key = "map_mapping", ui = map_shapefile_ui(ns("map_shapefile"), i18n))
)
wizard <- wizard_steps_server(
  "wizard", i18n = i18n, cache = upload$cache,
  requires_walkthrough = upload$requires_walkthrough, panels = panels,
  source_path = upload$source_path, active = active
)
observe(message("On step ", wizard$current_step()))
} # }
```
