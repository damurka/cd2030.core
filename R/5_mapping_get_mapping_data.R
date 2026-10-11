#' Get mapping data for subnational coverage analysis
#'
#' Merges coverage data with a country's shapefile to enable spatial visualization
#' of health indicators. It joins subnational (admin level 1) indicator coverage
#' that has already been calculated with the geographic features of each unit.
#'
#' @param .data A `cd_population` object (for example the output of
#'        [calculate_indicator_coverage()]) calculated at `admin_level = "adminlevel_1"`.
#'        Must include metadata attributes `iso3` (ISO3 country code) and `admin_level`.
#' @param subnational_map Optional. A data frame to join with the shapefile to add metadata.
#'
#' @return A `tibble` of class `"cd_mapping"` that combines the input data with shapefile geometries.
#'
#' @examples
#' \dontrun{
#' coverage <- calculate_indicator_coverage(data, admin_level = "adminlevel_1")
#' get_mapping_data(coverage)
#' }
#'
#' @export
get_mapping_data <- function(.data,
                             subnational_map = NULL) {
  NAME_1 = NULL

  check_cd_population(.data)

  iso <- attr_or_abort(.data, "iso3")
  admin_level <- attr_or_abort(.data, 'admin_level')
  if (admin_level != 'adminlevel_1') {
    cd_abort(c('x' = 'Only admin 1 data is supported currently.'))
  }

  shapefile <- get_country_shapefile(iso, "admin_level_1")

  shapefile <- if (is.null(subnational_map)) {
    shapefile %>%
      mutate(adminlevel_1 = NAME_1)
  } else {
    shapefile %>%
      left_join(subnational_map, by = "NAME_1") %>%
      rename(adminlevel_1 = admin_level_1)
  }

  merged_data <- .data %>%
    left_join(shapefile, by = join_by(adminlevel_1))

  new_tibble(
    merged_data,
    class = "cd_mapping",
    admin_level = admin_level
  )
}

#' Select one indicator's mapping data
#'
#' Extracts and filters indicator coverage data by year, denominator type, and
#' color palette for visualization.
#'
#' @param .data A `cd_mapping` object returned by `get_mapping_data()`.
#' @param indicator Character. Indicator name (e.g., `"anc4"`, `"penta1"`).
#' @param denominator Character. One of: `"dhis2"`, `"anc1"`, `"penta1"`, `"penta1derived"`, `"anc1derived"`.
#' @param palette Character. Color palette for mapping.
#'        One of: `"Reds"`, `"Blues"`, `"Greens"`, `"Purples"`, `"YlGnBu"`.
#' @param plot_year Optional integer or vector of years to filter.
#'
#' @return A `tibble` of class `"cd_mapping_filtered"`.
#'
#' @examples
#' \dontrun{
#' filtered <- select_mapping_data(
#'   data, indicator = "anc4", denominator = "anc1", palette = "Blues", plot_year = 2021
#' )
#' }
#'
#' @export
select_mapping_data <- function(.data,
                                indicator,
                                denominator = c("dhis2", "anc1", "penta1", "penta1derived", "anc1derived"),
                                palette = c("Reds", "Blues", "Greens", "Purples", "YlGnBu"),
                                plot_year = NULL) {
  check_cd_mapping(.data)

  indicator <- arg_match(indicator, get_analysis_indicators())
  denominator <- arg_match(denominator)
  palette <- arg_match(palette)

  column <- paste0("cov_", indicator, "_", denominator)
  data <- .data %>%
    filter(if (is.null(plot_year)) TRUE else year %in% plot_year) %>%
    select(any_of(c('adminlevel_1', 'district', 'year', column)), starts_with('geom')) %>%
    rename_with(~ 'geometry', starts_with('geom'))

  if (!column %in% colnames(data)) {
    cd_abort(c("x" = "{.field {column}} not in the data"))
  }

  new_tibble(
    data,
    class = 'cd_mapping_filtered',
    indicator = indicator,
    column = column,
    palette = palette
  )
}

#' Load country shapefile for mapping
#'
#' Loads the admin level 1 boundaries of a country from the shapefiles that come with the package.
#' Ensures geometries are valid and standardized to WGS84 (EPSG:4326).
#'
#' @param country_iso A string with the ISO3 code of the country (e.g., `"KEN"`).
#' @param level A character string specifying the admin level: `"admin_level_1"` (default) or
#'   `"district"`. The package has admin level 1 boundaries only, so both values give the
#'   admin level 1 areas.
#'
#' @return An `sf` object containing valid geometries of the country's admin level 1 areas.
#'
#' @examples
#' shapefile <- get_country_shapefile("KEN", level = "admin_level_1")
#'
#' @export
get_country_shapefile <- function(country_iso, level = c("admin_level_1", "district")) {
  check_required(country_iso)
  level <- arg_match(level)

  shapefile_path <- system.file(file.path("shapefiles", "admin_level_1.gpkg"), package = "cd2030.core")
  check_file_path(shapefile_path)

  sf_data <- sf::st_read(shapefile_path, layer = country_iso, quiet = TRUE)
  validate_shapefile(sf_data)
}

#' Validate geometry and reproject an `sf` object to WGS84 (EPSG:4326)
#'
#' Shared by `get_country_shapefile()` (the package-bundled shapefile) and `read_shapefile_folder()`
#' (a user-uploaded one, Phase 3 of the Load Data wizard redesign, apps/rmncah) -- one place for this
#' so both are held to the same standard.
#'
#' @param sf_data An `sf` object.
#' @return The same object, with valid geometry, reprojected to EPSG:4326.
#' @noRd
validate_shapefile <- function(sf_data) {
  sf_data %>%
    sf::st_make_valid() %>%
    sf::st_transform(4326)
}

#' Read a user-uploaded shapefile folder
#'
#' Reads a shapefile from the files of an uploaded folder, as a Shiny multi-file or folder
#' `fileInput()` gives them: a data frame with each file's original `name` and the `datapath` it
#' was saved to. The `.shp`, `.dbf`, `.shx` and `.prj` files are all required; they are copied
#' under their original names into one temporary directory and read from there. Other files are
#' ignored.
#'
#' @param files_df A data frame with `name` and `datapath` columns, one row per uploaded file.
#' @param call The calling environment, forwarded to `cd_abort()`.
#' @return The uploaded shapefile as a valid `sf` object, reprojected to EPSG:4326. Column names are
#'   exactly as uploaded: the column holding the unit names is not renamed to `NAME_1`.
#' @examples
#' \dontrun{
#' # in a Shiny server, for fileInput("shapefile", "Shapefile", multiple = TRUE) in the page
#' boundaries <- read_shapefile_folder(input$shapefile)
#'
#' # outside Shiny: the parts of a shapefile kept in one folder
#' parts <- list.files("boundaries", full.names = TRUE)
#' boundaries <- read_shapefile_folder(data.frame(name = basename(parts), datapath = parts))
#' names(boundaries)
#' }
#' @export
read_shapefile_folder <- function(files_df, call = caller_env()) {
  # Shiny puts each uploaded file in its own randomly named temp subdirectory, but sf::st_read() needs a shapefile's
  # parts side by side under their original names, so they are copied into one directory first. Columns are not
  # renamed: check_shapefile_admin_names() takes the name column as `name_field`.
  check_required(files_df, call = call)
  required_ext <- c("shp", "dbf", "shx", "prj")

  matched <- files_df[tolower(tools::file_ext(files_df$name)) %in% required_ext, , drop = FALSE]
  missing_ext <- setdiff(required_ext, tolower(tools::file_ext(matched$name)))
  if (length(missing_ext) > 0) {
    cd_abort(
      c("x" = "Shapefile folder is missing required file(s): {.val {paste0('.', missing_ext, collapse = ', ')}}."),
      call = call
    )
  }

  tmp_dir <- tempfile("cd_shapefile_")
  dir.create(tmp_dir)
  purrr::walk2(matched$datapath, matched$name, ~ file.copy(.x, file.path(tmp_dir, .y), overwrite = TRUE))

  shp_name <- matched$name[tolower(tools::file_ext(matched$name)) == "shp"][1]
  sf_data <- tryCatch(
    sf::st_read(file.path(tmp_dir, shp_name), quiet = TRUE),
    error = function(e) {
      cd_abort(c("x" = paste0("Could not read the uploaded shapefile: ", clean_error_message(e))), call = call)
    }
  )

  validate_shapefile(sf_data)
}
