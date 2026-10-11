# Read a user-uploaded shapefile folder

Reads a shapefile from the files of an uploaded folder, as a Shiny
multi-file or folder `fileInput()` gives them: a data frame with each
file's original `name` and the `datapath` it was saved to. The `.shp`,
`.dbf`, `.shx` and `.prj` files are all required; they are copied under
their original names into one temporary directory and read from there.
Other files are ignored.

## Usage

``` r
read_shapefile_folder(files_df, call = caller_env())
```

## Arguments

- files_df:

  A data frame with `name` and `datapath` columns, one row per uploaded
  file.

- call:

  The calling environment, forwarded to `cd_abort()`.

## Value

The uploaded shapefile as a valid `sf` object, reprojected to EPSG:4326.
Column names are exactly as uploaded: the column holding the unit names
is not renamed to `NAME_1`.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a Shiny server, for fileInput("shapefile", "Shapefile", multiple = TRUE) in the page
boundaries <- read_shapefile_folder(input$shapefile)

# outside Shiny: the parts of a shapefile kept in one folder
parts <- list.files("boundaries", full.names = TRUE)
boundaries <- read_shapefile_folder(data.frame(name = basename(parts), datapath = parts))
names(boundaries)
} # }
```
