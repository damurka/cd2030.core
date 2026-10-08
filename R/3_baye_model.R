#' Generate Bayesian Coverage Model Object
#'
#' @param coverage_data Survey data frame of class 'cd_coverage'.
#' @param overall_score DHIS2 data frame of class 'cd_overall_score'.
#' @param indicator Indicator character code (e.g., 'anc4', 'penta3').
#' @param denominator The denominator type to use from DHIS2 (e.g., 'penta1', 'dhis2').
#' @param keep_samples Whether the model keeps the sampler's draws and the compiled Stan model (`samples`,
#'   `stan_model`). Default `FALSE`: the charts and [bayes_model_estimates()] read the summary of the draws, which is
#'   kept either way, and without the draws a model is some 30 KB (national) to 170 KB (sub-national) where it was
#'   13 MB to 41 MB. A model that size was brought back from the worker that fitted it, kept in the dataset and
#'   written to its file with every later change, each of which held the app up for seconds.
#'
#' @export
generate_bayes_model <- function(coverage_data,
                                 overall_score,
                                 indicator = c('anc4', 'anc_1trimester', 'ideliv', 'measles1', 'penta3'), 
                                 denominator = c('anc1', 'dhis2', 'penta1', 'penta1derived', 'anc1derived'),
                                 keep_samples = FALSE) {
  
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
  r_col   <- paste0("r_", indicator)
  se_col  <- paste0("se_", indicator)
  cov_col <- paste0("cov_", indicator, "_", denominator)
  
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

#' Plot S3 method for Bayesian Coverage Model
#'
#' Leverages the bayescoveragemodel package's internal plotting function
#' and applies the custom Countdown (CD) theme and translated labels.
#'
#' @param x An object of class `cd_bayes_model` returned by `generate_bayes_model()`.
#' @param title (Optional) Custom translated title.
#' @param x_axis (Optional) Custom translated x-axis label.
#' @param y_axis (Optional) Custom translated y-axis label.
#' @param caption (Optional) Custom translated caption.
#' @param region (Optional) Specific region code to plot for subnational data.
#' @param ... Additional arguments.
#'
#' @param options (Optional) A [cd_chart_options()] object: text, legend, fonts and sizes a user changed. Applied last, so it wins over the
#'   arguments above; the plot's own defaults are used for whatever it does not set. Any chart option can also be given by name in `...`.
#' @export
plot.cd_bayes_model <- function(x,
                                title = NULL,
                                x_axis = NULL,
                                y_axis = NULL,
                                caption = NULL,
                                region = NULL,
                                ..., options = NULL) {
  cd_finish_plot(.plot_cd_bayes_model_impl(x, title = title, x_axis = x_axis, y_axis = y_axis, caption = caption, region = region, ...), options, ..., .source = x)
}

.plot_cd_bayes_model_impl <- function(x,
                                title = NULL,
                                x_axis = NULL,
                                y_axis = NULL,
                                caption = NULL,
                                region = NULL,
                                ...) {
  
  # 1. Retrieve attributes stored during the data generation step
  indicator <- attr_or_abort(x, "indicator")
  is_national <- attr_or_abort(x, 'is_national')

  if (is_national && !is.null(region)) {
    cd_abort(c('x' = '{.arg region} must be null for national data'))
  }
  
  # Determine if this is a comparison plot (subnational with no specific region selected)
  is_comparison <- !is_national && is.null(region)
  
  # 2. Setup Smart Defaults for Labels and Axes
  if (is_comparison) {
    # Scenario A: Subnational Comparison Plot
    t_title <- title %||% paste("Subnational Comparison (2025):", toupper(indicator))
    t_x     <- x_axis %||% "Region"
    t_y     <- y_axis %||% "Coverage"
    
  } else if (!is_national && !is.null(region)) {
    # Scenario B: Subnational Trend Plot for a specific region
    t_title <- title %||% paste("Bayesian Coverage Model Estimates:", toupper(indicator), "-", region)
    t_x     <- x_axis %||% "Year"
    t_y     <- y_axis %||% "Coverage"
    
  } else {
    # Scenario C: National Trend Plot
    t_title <- title %||% paste("Bayesian Coverage Model Estimates:", toupper(indicator))
    t_x     <- x_axis %||% "Year"
    t_y     <- y_axis %||% "Coverage"
  }
  
  t_cap <- caption %||% "Source: Survey Data & DHIS2 Routine Data"

  # 3. Call the package's plotting function
  plot_list <- if (!is_comparison) {
    bayescoveragemodel::plot_estimates_local_all(
      results = x,
      indicator_name = t_y,
      use_for_facetting = TRUE,
      region_codes = region
    )
  } else {
    bayescoveragemodel::plot_subnational_comparison(
      results = x,
      model_names = "Bayesian model estimates",
      year_select = 2025
    )
  }

  # 4. Extract the actual ggplot object
  p <- if (!is_comparison) plot_list[[1]] else plot_list

  # 5. Extract Custom Theme Labels
  my_theme <- cd_plot_theme(
    title = t_title,
    x_axis = t_x,
    y_axis = t_y,
    caption = t_cap
  )

  # 6. Apply Labels, Scales, and safely clean up the Legend
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