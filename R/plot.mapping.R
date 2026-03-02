#' Plot Subnational Coverage Maps by Indicator
#'
#' Creates a faceted `ggplot2` map showing subnational coverage levels of a health indicator,
#' colored using a gradient palette. Coverage values are drawn from a `cd_mapping_filtered`
#' object, typically filtered for a specific indicator and denominator.
#'
#' @param x A `cd_mapping_filtered` object. Created using [filter_mapping_data()], and must
#'   include spatial geometry and metadata attributes (`indicator`, `palette`, `column`).
#' @param title (Optional) A scalar character string to override the default plot title. Defaults to `NULL`.
#' @param caption (Optional) A scalar character string to override the default plot caption. Defaults to `NULL`.
#' @param legend_title (Optional) A scalar character string to override the default legend title. Defaults to `NULL`.
#' @param ... Additional arguments (currently unused).
#'
#' @return A `ggplot` object visualizing the spatial distribution of the selected indicator by region and year.
#'
#' @examples
#' \dontrun{
#' # Assuming `map_data` is filtered with filter_mapping_data()
#' plot(
#'   map_data,
#'   title = "Penta 1 Coverage by Region",
#'   legend_title = "Coverage (%)",
#'   caption = "Source: DHIS2 2024"
#' )
#' }
#'
#' @seealso [filter_mapping_data()], [get_mapping_data()]
#'
#' @export
plot.cd_mapping_filtered <- function(x, title = NULL, caption = NULL, legend = NULL, ...) {
  year = NULL

  indicator <- attr_or_abort(x, 'indicator')
  palette <- attr_or_abort(x, 'palette')
  column <- attr_or_abort(x, 'column')

  # Validate scalar character inputs for custom labels
  if (!is.null(title) && !is_scalar_character(title)) {
    cd_abort("x" = "{.arg title} must be a scalar character or NULL.")
  }
  if (!is.null(caption) && !is_scalar_character(caption)) {
    cd_abort("x" = "{.arg caption} must be a scalar character or NULL.")
  }
  if (!is.null(legend) && !is_scalar_character(legend)) {
    cd_abort("x" = "{.arg legend} must be a scalar character or NULL.")
  }

  # Setup Default Labels
  indicator_pretty <- str_to_title(indicator)
  default_title <- paste("Distribution of", indicator_pretty, "by Regions")
  default_caption <- "Data Source: DHIS-2 analysis"
  default_legend_title <- "Coverage (%)"

  final_title <- title %||% paste("Distribution of", indicator_pretty, "by Regions")
  final_caption <- caption %||% "Data Source: DHIS-2 analysis"
  final_legend_title <- legend %||% "Coverage (%)"

  x %>%
    st_set_geometry('geometry') %>%
    st_as_sf() %>%
    st_set_crs(4326) %>%
    st_transform(crs = 4326) %>%
    ggplot() +
      geom_sf(aes(fill = !!sym(column))) +
      coord_sf(default_crs = 4326, lims_method = "geometry_bbox") +
      facet_wrap(~ year, scales = "fixed", ncol = 5) +
      scale_fill_gradientn(colors = RColorBrewer::brewer.pal(7, palette)) +
      cd_plot_theme(
        title = final_title,
        legend = final_legend_title,
        caption = final_caption
      ) +
      theme(
        panel.border = element_blank(),
        panel.spacing = unit(1, "lines"),
        legend.text = element_text(size = 10),
        legend.key.width = unit(2, "cm"),
        legend.background = element_blank(),
        legend.title = element_text(size = 11),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        axis.line = element_blank(),
        strip.text = element_text(size = 12, face = "bold"),
        aspect.ratio = 1
      )
}
