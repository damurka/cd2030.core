# Read a user-uploaded shapefile folder

Takes the same `name`/`datapath` shape a Shiny multi-file/folder
`fileInput()` already produces (`apps/rmncah`'s
`cdDirectoryUpload()`/`input$directory_select`) – Shiny scatters each
uploaded file into its own randomly-named temp subdirectory, but
[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)
needs a shapefile's `.shp`/`.dbf`/`.shx`/`.prj` parts physically
colocated with their original basenames, so this reassembles them into
one fresh temp directory first.

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
Column names are exactly as uploaded – no forced rename to `NAME_1`,
since a real shapefile won't necessarily use that name (see
[`check_shapefile_admin_names()`](check_shapefile_admin_names.md)'s own
`name_field` parameter).
