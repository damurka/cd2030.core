#' Plot subnational coverage maps by indicator
#'
#' Creates a faceted `ggplot2` map showing subnational coverage levels of a health indicator,
#' colored using a gradient palette. Coverage values are drawn from a `cd_mapping_filtered`
#' object, typically filtered for a specific indicator and denominator.
#'
#' @param x A `cd_mapping_filtered` object. Created using [select_mapping_data()], and must
#'   include spatial geometry and metadata attributes (`indicator`, `palette`, `column`).
#' @inheritParams cd_plot_arguments
#'
#' @return A `ggplot` object visualizing the spatial distribution of the selected indicator by region and year.
#'
#' @examples
#' \dontrun{
#' # Assuming `map_data` is filtered with select_mapping_data()
#' plot(
#'   map_data,
#'   title = "Penta 1 Coverage by Region",
#'   legend = "Coverage (%)",
#'   caption = "Source: DHIS2 2024"
#' )
#' }
#'
#' @seealso [select_mapping_data()], [get_mapping_data()]
#'
#' @export
plot.cd_mapping_filtered <- function(x,
                                     title = NULL,
                                     subtitle = NULL,
                                     caption = NULL,
                                     x_title = NULL,
                                     y_title = NULL,
                                     legend_title = NULL,
                                     ...,
                                     options = NULL) {
  .cd_draw(.plot_cd_mapping_filtered_impl, x, list(), ..., options = options)
}

.plot_cd_mapping_filtered_impl <- function(x, title = NULL, caption = NULL, legend_title = NULL, ...) {
  year = NULL

  indicator <- attr_or_abort(x, 'indicator')
  palette <- attr_or_abort(x, 'palette')
  column <- attr_or_abort(x, 'column')

  # Validate scalar character inputs for custom labels
  if (!is.null(title) && !is_scalar_character(title)) {
    cd_abort(c("x" = "{.arg title} must be a scalar character or NULL."))
  }
  if (!is.null(caption) && !is_scalar_character(caption)) {
    cd_abort(c("x" = "{.arg caption} must be a scalar character or NULL."))
  }
  if (!is.null(legend_title) && !is_scalar_character(legend_title)) {
    cd_abort(c("x" = "{.arg legend_title} must be a scalar character or NULL."))
  }

  # Setup Default Labels
  indicator_pretty <- str_to_title(indicator)
  default_title <- paste("Distribution of", indicator_pretty, "by Regions")
  default_caption <- "Data Source: DHIS-2 analysis"
  default_legend_title <- "Coverage (%)"

  final_title <- title %||% paste("Distribution of", indicator_pretty, "by Regions")
  final_caption <- caption %||% "Data Source: DHIS-2 analysis"
  final_legend_title <- legend_title %||% "Coverage (%)"

  p <- x %>%
    .cd_as_map() %>%
    ggplot() +
      geom_sf(aes(fill = !!sym(column))) +
      coord_sf(default_crs = 4326, lims_method = "geometry_bbox") +
      facet_wrap(~ year, scales = "fixed", ncol = 5) +
      scale_fill_gradientn(colors = RColorBrewer::brewer.pal(7, palette)) +
      cd_plot_theme(
        title = final_title,
        legend_title = final_legend_title,
        caption = final_caption
      ) +
      cd_map_theme() +
      theme(legend.text = element_text(size = 10), legend.key.width = unit(2, "cm"))

  p
}
