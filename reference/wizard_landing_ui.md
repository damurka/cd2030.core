# Summary page of the Load Data wizard

The page the wizard shows in place of its steps once a dataset is
finished: after the user presses Finish, or when a saved dataset
(`.rds`) is loaded. It has a banner that says the dataset is ready, with
a button that opens the Reporting Rate page (`"reporting_rate"`), and
one row per wizard step. Each row gives the step's title, an "optional"
badge when the step is not required, a one-line summary of what the
dataset holds for that step, and an Edit button that opens the step.
Nothing is saved to the dataset here.

## Usage

``` r
wizard_landing_ui(id)

wizard_landing_server(id, cache, step_defs, i18n, on_edit, just_finished)
```

## Arguments

- id:

  The module's id.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- step_defs:

  The wizard's steps, a list with the structure of
  [wizard_step_defs](wizard_step_defs.md). The page shows one row per
  step, in this order.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- on_edit:

  A function of one argument, the key of a step. The page calls it when
  the user presses that step's Edit button; the caller uses it to open
  the step.

- just_finished:

  A reactive that returns `TRUE` when the page shows because the user
  has pressed Finish, and `FALSE` when it shows because a saved dataset
  was loaded. It only changes the banner's subtitle.

## Value

`wizard_landing_ui()` returns the UI as Shiny tags: the placeholders for
the banner and the rows. `wizard_landing_server()` is called for its
side effects and returns nothing useful.

## Details

[`wizard_steps_server()`](wizard_steps_ui.md) shows this page and starts
its server; an app does not normally call either function itself.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a module's server, as wizard_steps_server() uses it
output$body <- renderUI(wizard_landing_ui(ns("landing")))

current_step <- reactiveVal("upload")
wizard_landing_server(
  "landing", cache = cache, step_defs = wizard_step_defs, i18n = i18n,
  on_edit = function(step_key) current_step(step_key),
  just_finished = reactive(FALSE)
)
} # }
```
