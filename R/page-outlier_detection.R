#' Outlier detection page
#'
#' The data quality page on extreme values in the monthly data. Its first card has three tabs for
#' the chosen indicator: a heat map of the outlier summary by admin level 1 area or district, a bar
#' chart by indicator and a bar chart by area. Below it are a table of the districts and months
#' flagged as outliers in the year picked on the table (the reported value with its median and
#' median absolute deviation), and a trend chart of those outliers for one region and that year. The
#' filters are the indicator and the admin level with its region. The trend chart has its own region
#' filter, which follows the page's region.
#'
#' The page reads `outliers_admin1`, `outliers_district` and `list_outlier_units` from the dataset,
#' and calls its `calculate_outliers_summary()` when a region is chosen. The heat map's Excel
#' download also writes `outliers_national` and `district_outliers_summary`.
#'
#' @param id The module's id. A page's id is also its entry in the app's page registry.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return `outlier_detection_ui()` returns the page's UI as Shiny tags.
#'   `outlier_detection_server()` is called for its side effects.
#'
#' @examples
#' \dontrun{
#' # the page's entry in an app's page registry
#' cd_page_def(
#'   id = "outlier_detection",
#'   ui = outlier_detection_ui,
#'   server = outlier_detection_server,
#'   title = "title_outlier_main",
#'   section = "lbl_nav_section_quality",
#'   subtitle = "sub_outlier_main"
#' )
#' }
#'
#' @concept Countdown app pages
#' @export
outlier_detection_ui <- function(id, i18n) {
  ns <- NS(id)

  cd_page_ui(id, i18n,
    filters = cd_filter_bar(
      cd_indicator_ui(ns("indicator"), i18n, tooltip = "tt_outlier_indicator"),
      cd_admin_level_ui(ns("admin_level"), i18n)
    ),
    cd_chart_card(
      title = i18n$t("title_outlier_indicators"),
      icon = "chart-line",
      chart_toolbar = uiOutput(ns("outlier_toolbar")),
      i18n = i18n,
      width = 12,
      tabs = uiOutput(ns("outlier_tabs")),
      cd_tab_panes(ns("indicator_tabs"), list(
        heat_map = cd_plot_ui(ns("outlier_heatmap"), toolbar_inline = TRUE),
        indicator_bar = cd_plot_ui(ns("outlier_bargraph"), toolbar_inline = TRUE),
        region_bar = cd_plot_ui(ns("outlier_region_bargraph"), toolbar_inline = TRUE)
      ))
    ),
    cd_card_row(
      cd_table_ui(ns("district_outlier_summary"), i18n, "title_outlier_district"),
      cd_chart_card(
        title = i18n$t("title_outlier_district_trends"),
        chart_toolbar = cd_plot_toolbar_ui(ns("outlier_district_trend")),
        i18n = i18n,
        status = "success",
        collapsible = TRUE,
        div(
          class = "cd-stack",
          cd_admin_level_ui(ns("region_trend"), i18n, show_admin_level = FALSE),
          cd_plot_ui(ns("outlier_district_trend"), toolbar_inline = TRUE)
        )
      )
    )
  )
}

#' @rdname outlier_detection_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. The page
#'   does no work before that.
#' @export
outlier_detection_server <- function(id, cache, i18n, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns
      indicator <- cd_indicator_server("indicator")
      admin <- cd_admin_level_server("admin_level", cache, i18n, allow_select_all = TRUE, show_district = FALSE)

      # Page-owned tab strip (cd_tab_strip(), content_dashboard.R) + cd_tab_panes() (_shared/R/core (and components/)) to
      # actually switch the content -- same pattern as 1a_checks_reporting_rate.R and cd_tabbed_charts_ui()/
      # cd_tabbed_charts_server() (_shared/R/layout/tab-panels.R), hand-rolled here because this card's 3 tabs aren't a plain
      # indicator list (their labels don't follow tab_panels.R's own paste0("opt_", key) convention) so it
      # doesn't go through that shared component. Tab KEYS (heat_map/indicator_bar/region_bar) intentionally
      # differ from the underlying cd_plot_server() ids (outlier_heatmap/outlier_bargraph/
      # outlier_region_bargraph, unchanged) -- mapped explicitly below rather than relying on them matching
      # like reporting_rate_server() does.
      outlier_current_tab <- reactiveVal("heat_map")

      output$outlier_tabs <- renderUI({
        cd_tab_strip(ns, tabs = c(
          heat_map = i18n$t("opt_heat_map"),
          indicator_bar = i18n$t("title_outlier_indicator_bar"),
          region_bar = i18n$t("title_outlier_region_bar")
        ), active = outlier_current_tab())
      })

      output$outlier_toolbar <- renderUI({
        switch(outlier_current_tab(),
          heat_map = cd_plot_toolbar_ui(ns("outlier_heatmap")),
          indicator_bar = cd_plot_toolbar_ui(ns("outlier_bargraph")),
          region_bar = cd_plot_toolbar_ui(ns("outlier_region_bargraph"))
        )
      })

      outlier_tab_click <- function(key) {
        observeEvent(input[[paste0("tab_", key)]], {
          outlier_current_tab(key)
          cd_update_tab_panes(session, "indicator_tabs", selected = key)
        }, ignoreInit = TRUE)
      }
      outlier_tab_click("heat_map")
      outlier_tab_click("indicator_bar")
      outlier_tab_click("region_bar")

      admin_parts <- cd_admin_parts(admin)
      admin_level <- admin_parts$admin_level
      region <- admin_parts$region

      admin_level_trend <- reactive({
        req(admin_level())
        get_plot_admin_column(admin_level(), region())
      })

      region_admin <- cd_admin_level_server("region_trend", cache, i18n, show_admin_level = FALSE, selected_admin1 = region)
      region_trend <- reactive({
        ra <- region_admin()
        if (is.null(ra)) {
          return(NULL)
        }
        ra$region
      })

      # active(): see coverage_server() in modules/3_national_coverage/coverage.R for why.
      outlier_summary <- reactive({
        req(cache(), active(), admin_level())
        if (admin_level() == "adminlevel_1" && is.null(region())) {
          cache()$outliers_admin1
        } else if (admin_level() == "district" && is.null(region())) {
          cache()$outliers_district
        } else {
          cache()$calculate_outliers_summary(admin_level(), region())
        }
      })

      outlier_districts <- reactive({
        req(cache(), active())
        cache()$list_outlier_units
      })

      cd_plot_server(
        id = "outlier_heatmap",
        about = .cd_about("dq_outliers_units", variant = "heat_map", indicator = indicator, admin_level = admin_level, region = region),
        i18n = i18n,
        plot_data = outlier_summary,
        plot_filename = reactive("outlier_heatmap"),
        plot_fun = function(d) {
          req(indicator())
          indicator <- i18n$t(paste0("opt_", indicator()))
          admin_level <- i18n$t(if (is.null(region()) || !nzchar(region())) paste0("opt_", admin_level()) else "opt_district")
          title <- if (is.null(region()) || !nzchar(region())) "plt_title_outlier_heatmap_all" else "plt_title_outlier_heatmap_one"
          plot(
            d,
            "heat_map",
            indicator(),
            title = str_glue(i18n$t(title)),
            x_title = admin_level,
            y_title = i18n$t("title_global_year"),
            legend_title = i18n$t("lbl_leg_outlier")
          )
        },
        excel_write_fun = function(wb, d) {
          req(cache())

          cd_add_sheet(wb, i18n$t("title_outlier_extreme"), cache()$outliers_national, title = i18n$t("tab_outlier_extreme"))

          # Check if sheet exists; if not, add it
          cd_add_sheet(wb, i18n$t("lbl_sheet_outlier_district"), cache()$district_outliers_summary, title = i18n$t("tab_outlier_district"))
        }
      )

      cd_plot_server(
        id = "outlier_bargraph",
        about = .cd_about("dq_outliers_units", variant = "by_indicator", indicator = indicator, admin_level = admin_level, region = region),
        i18n = i18n,
        plot_data = outlier_summary,
        plot_filename = reactive("outlier_bargraph"),
        plot_fun = function(d) {
          req(indicator())
          plot(
            d,
            "indicator",
            indicator(),
            title = i18n$t("plt_title_outlier_indicator"),
            x_title = i18n$t("title_global_year"),
            y_title = i18n$t("lbl_leg_outlier"),
            legend_title = i18n$t("lbl_leg_outlier")
          )
        }
      )

      cd_plot_server(
        id = "outlier_region_bargraph",
        about = .cd_about("dq_outliers_units", variant = "by_unit", indicator = indicator, admin_level = admin_level, region = region),
        i18n = i18n,
        plot_data = outlier_summary,
        plot_filename = reactive("outlier_region_bargraph"),
        plot_fun = function(d) {
          req(indicator())
          admin_level <- i18n$t(if (is.null(region()) || !nzchar(region())) paste0("opt_", admin_level()) else "opt_district")
          plot(
            d,
            region = region(),
            indicator = indicator(),
            title = str_glue(i18n$t("plt_title_outlier_region")),
            x_title = i18n$t("title_global_year"),
            y_title = i18n$t("lbl_leg_outlier"),
            legend_title = i18n$t("lbl_leg_outlier")
          )
        }
      )
      
      selected_year <- cd_table_server(
        "district_outlier_summary",
        about = .cd_about(NULL, indicator = indicator),
        cache,
        i18n,
        control_type = "year",
        data = outlier_districts,
        data_transform = function(d) {
          outlier_col <- paste0(indicator(), "_outlier5std")
          d %>%
            select(any_of(c("year", "month", "adminlevel_1", "district", indicator(), paste0(indicator(), c("_med", "_mad")), outlier_col))) %>%
            filter(!!sym(outlier_col) == 1) %>%
            select(-!!sym(outlier_col))
        },
        filename = reactive("district_outliers")
      )

      cd_plot_server(
        id = "outlier_district_trend",
        about = .cd_about("dq_outlier_trend", indicator = indicator, year = selected_year),
        i18n = i18n,
        plot_data = outlier_districts,
        plot_filename = reactive(paste0("outlier_district_trend", indicator(), "_",selected_year())),
        plot_fun = function(d) {
          req(indicator(), region_trend(), selected_year())
          indicator_name <- i18n$t(paste0("opt_", indicator()))
          year_val <- selected_year()
          region_name <- region_trend()
          plot(
            d,
            indicator(),
            region = region_trend(),
            year = as.integer(year_val),
            title = str_glue(i18n$t("plt_title_outlier_trend_year")),
            x_title = i18n$t("lbl_axis_x_outlier_trend"),
            y_title = indicator_name,
            legend_title = i18n$t("lbl_leg_outlier_trend"),
            label = c(
              reported = i18n$t("lbl_outlier_series_reported"),
              median   = i18n$t("lbl_outlier_series_median"),
              bounds   = i18n$t("lbl_outlier_series_bounds"),
              outliers = i18n$t("lbl_outlier_series_outliers")
            )
          )
        },
        excel_write_fun = function(wb, d) {
          cd_add_sheet(wb, i18n$t("title_outlier_district_extreme"), d, title = str_glue(i18n$t("title_outlier_district_extreme_year")))
        }
      )

    }
  )
}
