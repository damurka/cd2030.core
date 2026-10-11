# Give DataSuite's notebooks a folder's Countdown datasets

Lists, prepares, attaches or describes the datasets of a folder for
notebooks in R, Python and Stata. A dataset is the `.rds` file an app
saved next to a country's Excel file, together with its workspace.
DataSuite calls this function for the apps that declare it as their
`notebookData`. It does not write to an `.xlsx` or `.rds` file: it
writes only to the workspace's `data/` folder.

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

  The notebook's workspace folder (`<stem>.shiny-workspace`). The `.rds`
  file with the same stem is the dataset the notebook belongs to.

- datasets:

  For `"prepare"`: the datasets (their `.rds` file names without `.rds`,
  or `"ref"`) to prepare. The dataset of `workspace` is always included.

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

## Examples

``` r
# a folder with a country's Excel file that no app has opened yet
folder <- tempfile("countdown_")
dir.create(folder)
file.copy(system.file("extdata", "kenya.xlsx", package = "cd2030.core"), folder)
#> [1] TRUE

listing <- notebook_data("list", folder = folder)
listing$datasets[[1]]$status
#> [1] "not-loaded"
vapply(listing$ref$tables, function(t) t$name, character(1))
#> [1] "ref_un_estimates" "ref_un_mortality" "ref_wuenic"       "ref_fpet"        
#> [5] "ref_countries"   
unlink(folder, recursive = TRUE)

if (FALSE) { # \dontrun{
# in a notebook of the workspace of kenya_rmncah.rds: its tables by name, and ds_list()
workspace <- file.path("data", "kenya_rmncah.shiny-workspace")
notebook_data("attach", folder = "data", workspace = workspace)
head(adjusted_data)

# for Python and Stata: Stata files of two of its tables in the workspace's data/ folder
notebook_data("prepare", folder = "data", workspace = workspace,
              tables = c("adjusted_data", "national_survey"))
} # }
```
