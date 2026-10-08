# Notebook data: a folder's Countdown datasets for DataSuite's notebooks

What DataSuite's notebooks call (an app's `notebookData`): the datasets
of a folder – each app's saved `.rds` next to its Excel file, and its
workspace – by name, in R, Python and Stata. Never writes to an `.xlsx`
or an `.rds`; only the workspace's `data/` folder.

## Usage

``` r
notebook_data(
  action = c("list", "prepare", "attach", "describe"),
  folder,
  workspace = NULL,
  datasets = NULL,
  force = FALSE,
  period = 60,
  tables = NULL
)
```

## Arguments

- action:

  `"list"` (the datasets and their tables, from the file names alone),
  `"prepare"` (Stata files of the tables of `datasets`, for Python and
  Stata, made or remade when their `.rds` changed) or `"attach"` (in a
  notebook's R session: the tables by name, and `ds_list()`, `ds_use()`,
  `ds_save()`, `ds_reload()`) or `"describe"` (the own dataset's tables
  with their columns and what each column holds, for an assistant
  writing code; read from the `.rds`, which is not changed).

- folder:

  The folder holding the Excel files, the `.rds` files and their
  workspaces.

- workspace:

  The notebook's workspace (`<stem>.shiny-workspace`): its `.rds` is the
  notebook's own dataset.

- datasets:

  For `"prepare"`: the datasets (their `.rds` file names without `.rds`,
  or `"ref"`) to prepare; the workspace's own is always included.

- force:

  For `"prepare"`: check the `.rds` files now, not only when the last
  check is older than `period`.

- period:

  Seconds between checks of an `.rds` for changes (default 60).

- tables:

  For `"prepare"`: the tables to write (names from `"list"`); the usual
  ones when `NULL`. Tables already written are kept, and written again
  once their `.rds` has changed. For `"describe"`: the tables to
  describe; the usual ones when `NULL`.

## Value

For `"list"`, `"prepare"` and `"describe"`, a list (DataSuite reads it
as JSON); for `"attach"`, invisibly the names attached.
