#' Retrieve an attribute or abort with error
#'
#' Safely retrieves a named attribute from an object. If the attribute is missing,
#' raises an error with a clear message. Intended for internal use to enforce
#' required metadata on structured objects.
#'
#' @param .data An object to inspect.
#' @param attr_name A string. The name of the attribute to retrieve.
#'
#' @return The value of the specified attribute.
#'
#' @examples
#' obj <- structure(list(a = 1), my_attr = "value")
#' cd2030.core:::attr_or_abort(obj, "my_attr")
#' #> "value"
#'
#' # cd2030.core:::attr_or_abort(obj, "missing") would throw an error
#'
#' @keywords internal
attr_or_abort <- function(.data, attr_name) {
  value <- attr(.data, attr_name)
  if (is.null(value)) {
    cd_abort(c("x" = "Missing attribute: {attr_name}"))
  }
  value
}

#' Retrieve attribute or return NULL if missing
#'
#' A safe variant of `attr_or_abort()` that returns `NULL` instead of throwing an error
#' when the specified attribute does not exist.
#'
#' @inheritParams attr_or_abort
#'
#' @return The value of the specified attribute, or `NULL` if not present.
#'
#' @examples
#' obj <- structure(list(a = 1), my_attr = "value")
#' cd2030.core:::attr_or_null(obj, "my_attr")
#' #> "value"
#'
#' cd2030.core:::attr_or_null(obj, "missing")
#' #> NULL
#'
#' @keywords internal
attr_or_null <- function(.data, attr_name) {
  tryCatch(attr_or_abort(.data, attr_name), error = function(e) NULL)
}

#' Get country name
#'
#' Reads the name of the country a Countdown dataset is for. The name is stored with the data when
#' it is loaded.
#'
#' @param .data A `cd_data` object
#'
#' @return The country name as a character string
#'
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' data <- load_data(path)
#'
#' get_country_name(data)
#'
#' @export
get_country_name <- function(.data) {
  check_cd_data(.data)
  local_data_group(.data)
  attr_or_abort(.data, "country")
}

#' Get country ISO3 code
#'
#' Reads the ISO3 code of the country a Countdown dataset is for. The code is stored with the data
#' when it is loaded.
#'
#' @param .data A `cd_data` object
#'
#' @return The ISO3 country code as a character string
#'
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' data <- load_data(path)
#'
#' get_country_iso3(data)
#'
#' @export
get_country_iso3 <- function(.data) {
  check_cd_data(.data)
  local_data_group(.data)
  attr_or_abort(.data, "iso3")
}

#' Detemine if an indicator is maternal indicator
#'
#' Default grouping of indicators used in CD2030 coverage framework
#'
#' @param indicator Character. Indicator name(s) to check, for example
#'   `"anc1"`. Always `FALSE` unless the selected group is `"rmncah"`.
#'
#' @return TRUE if and indicator is maternal
#'
#' @examples
#' is_maternal_indicator("anc4")
#' is_maternal_indicator(c("anc4", "ideliv", "penta3"))
#'
#' @export
is_maternal_indicator <- function(indicator) {
  group <- get_selected_group()
  if (group == 'rmncah') {
    groups <- get_indicator_groups()
    indicator %in% c(groups$anc, groups$idelv)
  } else {
    return(FALSE)
  }
}

# small helper
`%||%` <- function(x, y) if (is.null(x)) y else x

#' Get the population column for an indicator and denominator
#'
#' Names the column that holds the target population of an indicator for a denominator option. The
#' name is the indicator's target population followed by the denominator, for example
#' `"totinftpenta_penta1"` for `penta3` with the `penta1` denominator.
#'
#' @param indicator Character scalar. Indicator name (e.g., 'penta1', 'measles1')
#' @param denominator Character scalar. The denominator for the indicator: one of `"dhis2"`,
#'   `"anc1"`, `"penta1"`, `"penta1derived"` or `"anc1derived"`.
#'
#' @return A string naming the corresponding population column, or `NA` when the indicator has no
#'   target population defined.
#'
#' @examples
#' get_population_column("penta3", "penta1")
#' get_population_column("anc4", "dhis2")
#'
#' # births are total births with the DHIS2 denominator, live births with the others
#' get_population_column("bcg", "dhis2")
#' get_population_column("bcg", "anc1")
#'
#' @export
get_population_column <- function(indicator, denominator) {
  indicator <- arg_match(indicator, get_analysis_indicators())
  # denominator <- arg_match(denominator, c("dhis2", "anc1", "penta1", "penta1derived_diff",  "penta1derived", "anc1derived_diff", "anc1derived"))
  denominator <- arg_match(denominator, c("dhis2", "anc1", "penta1",  "penta1derived", "anc1derived"))
  population <- case_match(
    indicator,
    c("anc1", "anc_1trimester", "anc4", "ipt2", "ipt3", "ifa90", "syphilis_test", "hiv_test") ~ "totpreg",
    c("bcg", "instlivebirths", "low_bweight", "pnc48h", "bcg") ~ ifelse(denominator == 'dhis2', 'totbirths', "totlbirths"),
    c("ideliv", 'ideliv', "csection") ~ 'totdeliv',
    c('penta1', 'penta2', 'penta3', 'pcv1', 'pcv2', 'pcv3', 'rota1',
      'rota2', 'ipv1', 'ipv2', 'opv1', 'opv2', 'opv3', 'undervax','dropout_penta13','zerodose','dropout_penta3mcv1','dropout_penta1mcv1') ~ 'totinftpenta',
    c('measles1', 'dropout_measles12') ~ 'totinftmeasles',
    'measles2' ~ 'totmeasles2'
  )
  if (is.na(population)) {
    return(NA_character_)
  }
  return(paste(population, denominator, sep = "_"))
}

#' Determine grouping columns for administrative levels
#'
#' Returns the appropriate grouping column(s) based on the specified administrative level.
#' If a region is specified and `admin_level = "adminlevel_1"`, districts are included to allow
#' further disaggregation within that region.
#'
#' @param admin_level A string. One of `"national"`, `"adminlevel_1"`, or `"district"`.
#' @param region Optional. If provided, must be used only with `admin_level = "adminlevel_1"`.
#' @param show_district Optional. If show_district is true `adminlevel_1` will include `district` column
#'
#' @return A character vector of column names to use in grouping. Returns:
#' - `NULL` for `"national"`
#' - `"adminlevel_1"` or `c("adminlevel_1", "district")` for `"adminlevel_1"`
#' - `c("adminlevel_1", "district")` for `"district"`
#'
#' @examples
#' get_admin_columns("national")
#' #> NULL
#'
#' get_admin_columns("adminlevel_1")
#' #> "adminlevel_1"
#'
#' get_admin_columns("adminlevel_1", region = "Eastern")
#' #> c("adminlevel_1", "district")
#'
#' get_admin_columns("district")
#' #> c("adminlevel_1", "district")
#'
#' @export
get_admin_columns <- function(admin_level, region = NULL, show_district = TRUE) {

  admin_level <- arg_match(admin_level, c("national", "adminlevel_1", "district"))
  if (admin_level != 'adminlevel_1' && !is.null(region)) {
    cd_abort(c('x' = '{.arg region} canonly be used in {.val adminlevel_1}'))
  }

  switch(admin_level,
    national = NULL,
    adminlevel_1 = if (!is.null(region) && show_district) c("adminlevel_1", 'district') else 'adminlevel_1',
    district = c("adminlevel_1", "district")
  )
}

#' Determine the administrative column to use for plotting
#'
#' Returns the appropriate administrative unit column to use on plots based on the selected
#' administrative level and whether a region is specified. Used to decide whether to facet or
#' label plots by district or by adminlevel_1.
#'
#' @param admin_level A string. Either `"adminlevel_1"` or `"district"`.
#' @param region Optional. A region name or `NULL`. If specified, districts will be used for plotting.
#'
#' @return A string: either `"district"` or `"adminlevel_1"`.
#'
#' @examples
#' get_plot_admin_column("adminlevel_1")
#' #> "adminlevel_1"
#'
#' get_plot_admin_column("adminlevel_1", region = "Nairobi")
#' #> "district"
#'
#' get_plot_admin_column("district")
#' #> "district"
#'
#' @export
get_plot_admin_column <- function(admin_level, region = NULL) {
  admin_level <- arg_match(admin_level, c("adminlevel_1", "district"))
  if (admin_level == 'district' || !is.null(region)) {
    'district'
  } else {
    'adminlevel_1'
  }
}


