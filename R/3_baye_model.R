#' Generate Bayesian Coverage Model Object
#'
#' @param coverage_data Survey data frame of class 'cd_coverage'.
#' @param overall_score DHIS2 data frame of class 'cd_overall_score'.
#' @param indicator Indicator character code (e.g., 'anc4', 'penta3').
#' @param denominator The denominator type to use from DHIS2 (e.g., 'penta1', 'dhis2').
#'
#' @export
generate_bayes_model <- function(coverage_data,
                                 overall_score,
                                 indicator = c('anc4', 'anc_1trimester', 'ideliv', 'measles1', 'penta3'), 
                                 denominator = c('anc1', 'dhis2', 'penta1', 'penta1derived', 'anc1derived')) {
  
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

  print(glimpse(baye_dt))
  print(glimpse(routine_dt))

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
  class(local_model) <- c('cd_bayes_model', class(local_model))
  
  attr(local_model, "indicator") <- indicator 
  attr(local_model, "model_indicator") <- model_indicator
  attr(local_model, "iso") <- iso_val
  attr(local_model, "is_national") <- is_national
  
  return(local_model)
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
#' @export
plot.cd_bayes_model <- function(x,
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