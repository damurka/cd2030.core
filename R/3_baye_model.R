#' Generate Bayesian coverage model object
#'
#' Fits a Bayesian coverage model for one indicator, combining the survey estimates and the routine
#' (DHIS2) coverage in `coverage_data` with the yearly data quality score in `overall_score`. The
#' model is national or sub-national (admin level 1), following the admin level of `coverage_data`.
#'
#' @param coverage_data Survey data frame of class 'cd_coverage'.
#' @param overall_score DHIS2 data frame of class 'cd_overall_score'.
#' @param indicator Indicator character code (e.g., 'anc4', 'penta3').
#' @param denominator The denominator type to use from DHIS2 (e.g., 'penta1', 'dhis2').
#' @param keep_samples Whether the model keeps the sampler's draws and the compiled Stan model (`samples`,
#'   `stan_model`). Default `FALSE`: the charts and [bayes_model_estimates()] read the summary of the draws, which is
#'   kept either way, and a model without the draws is much smaller (tens to hundreds of KB
#'   instead of tens of MB), so it is quicker to save and to pass between processes.
#'
#' @return An object of class `cd_bayes_model`: the fitted model returned by
#'   `bayescoveragedeploy::fit_local_model()` (a list, with its `posteriors` summary), without `samples` and
#'   `stan_model` unless `keep_samples = TRUE`. It carries the attributes `indicator`, `model_indicator` (the
#'   name the model uses for the indicator), `iso` and `is_national`.
#'
#' @examples
#' \dontrun{
#' # needs the Bayesian model packages (see cd_bayes_packages_missing()); a fit takes minutes
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' cache <- load_cache_data(path)
#' cache$set_national_estimates(list(sbr = 0.02))
#' cache$adjust_data()
#'
#' model <- generate_bayes_model(
#'   coverage_data = cache$calculate_coverage("national"),
#'   overall_score = cache$overall_score,
#'   indicator = "penta3",
#'   denominator = "penta1"
#' )
#' bayes_model_estimates(model)
#' plot(model)
#' }
#'
#' @export
generate_bayes_model <- function(coverage_data,
                                 overall_score,
                                 indicator = c('anc4', 'anc_1trimester', 'ideliv', 'measles1', 'penta3'), 
                                 denominator = c('anc1', 'dhis2', 'penta1', 'penta1derived', 'anc1derived'),
                                 keep_samples = FALSE) {
  # keep_samples = FALSE: with the draws a model is 13 MB to 41 MB (30 KB to 170 KB without), and a model that
  # size, sent back from the worker and written to the dataset's file on every change, holds the app up for seconds.

  # Validate inputs
  check_cd_coverage(coverage_data)
  check_cd_class(overall_score, 'cd_overall_score')

  indicator <- arg_match(indicator)
  denominator <- arg_match(denominator)

  # Map the routine indicator name to the model's expected survey name
  model_indicator <- switch(
    indicator,
    'anc4'           = 'anc4',
    'anc_1trimester' = 'anc1trimester',
    'ideliv' = 'ideliv',
    'measles1'       = 'vmsl',
    'penta3'         = 'vdpt',
    indicator # fallback
  )

  admin_level <- attr_or_abort(coverage_data, 'admin_level')
  is_national <- admin_level == 'national'
  
  # Extract the ISO dynamically from the data
  iso_val <- attr_or_abort(coverage_data, 'iso3')
  
  # Construct the column names dynamically based on the ROUTINE indicator name
  # Institutional deliveries are named in more than one way: a survey table and a coverage table hold them as
  # `instdeliveries` or `instlivebirths` (the built-in surveys have r_instlivebirths, the coverage tables
  # cov_instdeliveries_* and cov_instlivebirths_*), and none has `ideliv`, so that tab's fit stopped with
  # "object 'r_ideliv' not found". The first name the data has is used.
  data_name <- function(prefix, suffix = "") {
    names_to_try <- if (indicator == "ideliv") c("ideliv", "instdeliveries", "instlivebirths") else indicator
    columns <- paste0(prefix, names_to_try, suffix)
    found <- columns[columns %in% names(coverage_data)]
    if (length(found)) found[[1]] else columns[[1]]
  }
  r_col   <- data_name("r_")
  se_col  <- sub("^r_", "se_", r_col)
  cov_col <- data_name("cov_", paste0("_", denominator))
  
  # ---------------------------------------------------------
  # 1. Prepare Survey Data 
  # ---------------------------------------------------------
  baye_dt <- coverage_data %>%  
    filter(!is.na(!!sym(r_col))) %>% 
    mutate(
      indic = model_indicator,  
      r = !!sym(r_col) / 100, 
      se = !!sym(se_col) / 100
    )
    
  # Conditionally select columns (ISO must ALWAYS be present for the survey data)
  if (is_national) {
    baye_dt <- baye_dt %>% 
      select(country, iso, year, source, r, se, indic)
  } else {
    baye_dt <- baye_dt %>% 
      # Keep 'iso' so process_data() can join regions_dat
      select(iso, admin1 = adminlevel_1, year, source, r, se, indic) 
  }

  # Pass processed columns to AlkemaLab data processor
  baye_dt <- baye_dt %>% 
    bayescoveragemodel::process_data(
      regions_dat = bayescoveragemodel::regions_all,
      indicator = model_indicator,
      verbose = FALSE
    )

  # ---------------------------------------------------------
  # 2. Prepare DQA Data
  # ---------------------------------------------------------
  dqa <- overall_score %>% 
    filter(no == '4') %>% 
    pivot_longer(cols = is.numeric, names_to = 'year', values_to = 'countdownmean') %>% 
    select(year, countdownmean) %>% 
    mutate(year = as.integer(year))

  # ---------------------------------------------------------
  # 3. Prepare Routine Data 
  # ---------------------------------------------------------
  routine_dt <- coverage_data %>% 
    filter(!is.na(!!sym(cov_col))) %>% 
    mutate(
      indicator_name = model_indicator,
      routine_value = !!sym(cov_col) / 100
    ) 
    
  # Conditionally select columns (ISO must be DROPPED for subnational routine data)
  if (is_national) {
    routine_dt <- routine_dt %>% 
      select(iso, year, indicator_name, routine_value)
  } else {
    routine_dt <- routine_dt %>% 
      # Omit 'iso' so fit_local_model() does not throw an error
      select(admin1 = adminlevel_1, year, indicator_name, routine_value)
  }

  # Join DQA scores
  routine_dt <- routine_dt %>% 
    left_join(dqa, by = join_by(year))

  # ---------------------------------------------------------
  # 4. Fit Model
  # ---------------------------------------------------------
  local_model <- bayescoveragedeploy::fit_local_model(
    survey_df = baye_dt,
    subnational = !is_national,
    indicator = model_indicator, 
    iso_select = iso_val,
    routine_df = routine_dt,
    iter_sampling = 300,
    iter_warmup = 150,
    adapt_delta = 0.95,
    max_treedepth = 14
  )

  # ---------------------------------------------------------
  # 5. Return object safely
  # ---------------------------------------------------------
  if (!isTRUE(keep_samples)) {
    local_model <- slim_bayes_model(local_model)
  }
  class(local_model) <- c('cd_bayes_model', class(local_model))
  
  attr(local_model, "indicator") <- indicator 
  attr(local_model, "model_indicator") <- model_indicator
  attr(local_model, "iso") <- iso_val
  attr(local_model, "is_national") <- is_national
  
  return(local_model)
}

#' A Bayesian model without the sampler's draws and the compiled Stan model
#'
#' What makes a fitted model large (`samples`, `stan_model`) and no chart or table reads: see
#' [generate_bayes_model()]'s `keep_samples`. A model that has neither is returned as it is.
#'
#' @param model A fitted model.
#' @return The model without them, its class and attributes kept.
#' @examples
#' # a stand-in for a model fitted with keep_samples = TRUE
#' model <- structure(
#'   list(posteriors = list(), samples = matrix(0, 1000, 50), stan_model = "the compiled model"),
#'   class = c("cd_bayes_model", "list"),
#'   indicator = "penta3"
#' )
#' slim <- slim_bayes_model(model)
#' names(slim)
#' attr(slim, "indicator")
#' object.size(slim) < object.size(model)
#' @export
slim_bayes_model <- function(model) {
  heavy <- intersect(c("samples", "stan_model"), names(model))
  if (!is.list(model) || !length(heavy)) {
    return(model)
  }
  kept <- attributes(model)
  slim <- unclass(model)[setdiff(names(model), heavy)]
  kept$names <- names(slim)
  attributes(slim) <- kept
  slim
}

#' A Bayesian model's estimates as a table
#'
#' The fitted coverage by year (2010 to 2030), in percent like the other coverage tables: the median with its 95%
#' and 80% intervals. A sub-national model gives a row per region and year.
#'
#' @param model A model from [generate_bayes_model()].
#' @return A tibble: `indicator`, `adminlevel_1` (a sub-national model only), `year`, `estimate`, `lower` and
#'   `upper` (95%), `lower_80` and `upper_80`.
#' @examples
#' \dontrun{
#' # `cache` is a dataset with adjusted data; fitting needs the Bayesian model packages
#' model <- cache$get_bayes_model("national", "penta3")
#' estimates <- bayes_model_estimates(model)
#' estimates[estimates$year >= 2020, c("year", "estimate", "lower", "upper")]
#'
#' # a sub-national model has a row per region and year
#' regions <- bayes_model_estimates(cache$get_bayes_model("adminlevel_1", "penta3"))
#' regions[regions$year == 2023, ]
#' }
#' @export
bayes_model_estimates <- function(model) {
  check_cd_class(model, "cd_bayes_model")
  temporal <- model$posteriors$temporal
  quantiles <- c(estimate = "50%", lower = "2.5%", upper = "97.5%", lower_80 = "10%", upper_80 = "90%")
  if (!is.data.frame(temporal) || !all(c("year", quantiles) %in% names(temporal))) {
    cd_abort(c("x" = "The model has no estimates by year."))
  }
  out <- tibble::tibble(indicator = attr_or_abort(model, "indicator"), year = as.integer(temporal$year))
  for (name in names(quantiles)) {
    out[[name]] <- temporal[[quantiles[[name]]]] * 100
  }
  if ("admin1" %in% names(temporal)) {
    out <- tibble::add_column(out, adminlevel_1 = as.character(temporal$admin1), .after = "indicator")
  }
  dplyr::arrange(out, dplyr::across(dplyr::any_of(c("adminlevel_1", "year"))))
}

#' Plot S3 method for Bayesian coverage model
#'
#' Leverages the bayescoveragemodel package's internal plotting function
#' and applies the custom Countdown (CD) theme and translated labels.
#'
#' @param x An object of class `cd_bayes_model` returned by `generate_bayes_model()`.
#' @inheritParams cd_plot_arguments
#' @param region (Optional) A region of a sub-national model: its estimates by year are drawn, as a national
#'   model's are. `NULL` compares the regions in one year.
#' @param year (Optional) For a sub-national model. The year the regions are compared in; by default the latest
#'   year the facility data has. With a `region`, the year is marked on its chart.
#' @param national (Optional) For a sub-national model. The country's coverage from the facility data, with the
#'   same denominator: a data frame with `year` and `value` (a proportion), as `cache$bayes_national_routine()`
#'   gives. The comparison draws it as a line and a region's chart as a series.
#' @param legend_labels (Optional) A named list to override the legend's entries, e.g. with translations: `model`,
#'   `routine` (the facility data) and `national`.
#'
#' @return A `ggplot` object with the chart options applied. For a national model, or the `region` of a
#'   sub-national model: the estimated coverage by year. For a sub-national model with no `region`: the regions
#'   compared in `year`, each with its model estimate and interval and its facility-data value.
#' @examples
#' \dontrun{
#' # `cache` is a dataset with adjusted data; fitting needs the Bayesian model packages
#' national <- cache$get_bayes_model("national", "penta3")
#' plot(national)
#' plot(national, title = "Penta3 coverage, Kenya", y_title = "Coverage")
#'
#' # a sub-national model: the regions compared, or the trend of one region
#' regional <- cache$get_bayes_model("adminlevel_1", "penta3")
#' country <- cache$bayes_national_routine("penta3")
#' plot(regional, national = country)
#' plot(regional, year = 2021, national = country)
#' plot(regional, region = "Nairobi", national = country)
#' }
#' @export
plot.cd_bayes_model <- function(x,
                                region = NULL,
                                year = NULL,
                                title = NULL,
                                subtitle = NULL,
                                caption = NULL,
                                x_title = NULL,
                                y_title = NULL,
                                legend_title = NULL,
                                ...,
                                national = NULL,
                                legend_labels = NULL,
                                options = NULL) {
  .cd_draw(.plot_cd_bayes_model_impl, x,
           list(region = region, year = year, national = national, legend_labels = legend_labels), ..., options = options)
}

.plot_cd_bayes_model_impl <- function(x,
                                title = NULL,
                                x_title = NULL,
                                y_title = NULL,
                                caption = NULL,
                                region = NULL,
                                year = NULL,
                                national = NULL,
                                legend_labels = NULL,
                                ...) {

  # 1. Retrieve attributes stored during the data generation step
  indicator <- attr_or_abort(x, "indicator")
  is_national <- attr_or_abort(x, 'is_national')

  if (is_national && !is.null(region)) {
    cd_abort(c('x' = '{.arg region} must be null for national data'))
  }
  if (!is.null(national) && !(is.data.frame(national) && all(c("year", "value") %in% names(national)))) {
    cd_abort(c("x" = "{.arg national} must be a data frame with the columns {.field year} and {.field value}."))
  }
  if (!is.null(year) && !(is_scalar_integerish(year) && !is.na(year))) {
    cd_abort(c("x" = "{.arg year} must be one year."))
  }

  labels <- utils::modifyList(
    list(model = "Model estimate (95% interval)", routine = "Facility data", national = "National, facility data"),
    as.list(legend_labels)
  )
  t_cap <- caption %||% "Source: Survey Data & DHIS2 Routine Data"

  # Determine if this is a comparison plot (subnational with no specific region selected)
  is_comparison <- !is_national && is.null(region)

  # ---------------------------------------------------------
  # A. The regions compared in one year: each region's model estimate with its interval, its facility-data
  #    value beside it, and the national facility-data value as a line
  # ---------------------------------------------------------
  if (is_comparison) {
    estimates <- x$posteriors$temporal
    estimates <- estimates[estimates$admin1 != "National", , drop = FALSE]
    routine <- x$dat_routine
    years <- sort(unique(estimates$year))
    # by default the latest year the facility data has (what the model was fitted to), not a year it only projects
    if (is.null(year)) {
      with_data <- intersect(years, routine$year[!is.na(routine$routine_value)])
      year <- if (length(with_data)) max(with_data) else max(years)
    }
    if (!year %in% years) {
      cd_abort(c("x" = "The model has no estimate for {year}.", "i" = "It has {min(years)} to {max(years)}."))
    }

    shown <- estimates[estimates$year == year, , drop = FALSE]
    shown$region <- forcats::fct_reorder(shown$admin1, shown[["50%"]])
    facility <- routine[routine$year == year & !is.na(routine$routine_value), c("admin1", "routine_value"), drop = FALSE]
    facility <- facility[facility$admin1 %in% shown$admin1, , drop = FALSE]
    facility$region <- factor(facility$admin1, levels = levels(shown$region))
    country <- if (is.null(national)) NULL else national[national$year == year & !is.na(national$value), , drop = FALSE]

    upper <- max(1, shown[["97.5%"]], facility$routine_value, country$value, na.rm = TRUE)
    p <- ggplot(shown, aes(y = .data$region)) +
      geom_linerange(aes(xmin = .data[["2.5%"]], xmax = .data[["97.5%"]], colour = labels$model), linewidth = 1.1) +
      geom_point(aes(x = .data[["50%"]], colour = labels$model), size = 3.2)
    if (nrow(facility)) {
      p <- p + geom_point(data = facility, aes(x = .data$routine_value, colour = labels$routine), shape = 18, size = 4)
    }
    if (!is.null(country) && nrow(country)) {
      p <- p +
        geom_vline(data = country, aes(xintercept = .data$value, linetype = labels$national), colour = "grey30", linewidth = 0.6) +
        scale_linetype_manual(values = set_names("dashed", labels$national), name = NULL)
    }
    p <- p +
      scale_colour_manual(values = set_names(c("#D6604D", "grey20"), c(labels$model, labels$routine)),
                          breaks = c(labels$model, if (nrow(facility)) labels$routine), name = NULL) +
      scale_x_continuous(limits = c(0, upper), labels = scales::percent_format(accuracy = 1),
                         expand = expansion(mult = c(0, 0.03))) +
      cd_plot_theme(
        title = title %||% paste0("Model estimates by region, ", year, ": ", toupper(indicator)),
        x_title = x_title %||% "Coverage",
        y_title = y_title %||% "Region",
        caption = t_cap
      ) +
      theme(legend.position = "right", panel.grid.major.y = element_blank())
    return(p)
  }

  # ---------------------------------------------------------
  # B. One series over the years: the country's, or one region's (the same chart)
  # ---------------------------------------------------------
  t_title <- title %||% if (is_national) {
    paste("Bayesian Coverage Model Estimates:", toupper(indicator))
  } else {
    paste("Bayesian Coverage Model Estimates:", toupper(indicator), "-", region)
  }
  t_x <- x_title %||% "Year"
  t_y <- y_title %||% "Coverage"

  if (!is_national && !region %in% x$posteriors$temporal$admin1) {
    cd_abort(c("x" = "The model has no estimate for {.val {region}}."))
  }

  # Call the package's plotting function and take the plot out of its list
  p <- bayescoveragemodel::plot_estimates_local_all(
    results = x,
    indicator_name = t_y,
    use_for_facetting = TRUE,
    region_codes = region
  )[[1]]

  # Extract Custom Theme Labels
  my_theme <- cd_plot_theme(
    title = t_title,
    x_title = t_x,
    y_title = t_y,
    caption = t_cap
  )

  # A region's chart also has the country's facility-data values, to read the region against, and the year chosen
  if (!is_national && !is.null(national)) {
    country <- national[!is.na(national$value) & national$value <= 1, , drop = FALSE]
    if (nrow(country)) {
      last <- country[which.max(country$year), , drop = FALSE]
      p <- p +
        geom_line(data = country, aes(x = .data$year, y = .data$value), inherit.aes = FALSE, linetype = "dashed", colour = "grey30") +
        geom_point(data = country, aes(x = .data$year, y = .data$value), inherit.aes = FALSE, shape = 18, size = 3, colour = "grey30") +
        geom_text(data = last, aes(x = .data$year, y = .data$value, label = labels$national), inherit.aes = FALSE,
                  hjust = 0, nudge_x = 0.3, size = 3.2, colour = "grey30")
    }
  }
  if (!is_national && !is.null(year)) {
    p <- p + geom_vline(xintercept = year, linetype = "dotted", colour = "grey45")
  }

  # Apply Labels, Scales, and safely clean up the Legend
  p +
    # Use my_theme[[1]] to apply ONLY the labels (labs) so we don't break
    # the internal package's complex legend positioning/borders
    my_theme[[1]] +

    # Scale Y axis to percentage
    scale_y_continuous(
      limits = c(0, 1),
      labels = scales::percent_format(accuracy = 1)
    ) +

    # Strip all hardcoded titles from the internal ggnewscale legends
    guides(
      fill = guide_legend(title = NULL),
      color = guide_legend(title = NULL),
      color_new = guide_legend(title = NULL),
      linetype = guide_legend(title = NULL)
    ) +

    theme(
      legend.position = "right",
      # legend.title = element_blank()
    )
}
