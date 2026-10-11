#' Create a theme for messages with bullets
#'
#' @noRd
cd_theme <- function() {
  list(
    span.field = list(
      color = "blue",
      font_weight = "bold"
    ),
    span.fun = list(
      color = "purple",
      font_style = "italic",
      transform = single_quote_if_no_color
    ),
    span.arg = list(
      color = "green",
      font_weight = "bold"
    ),
    span.val = list(
      color = "orange"
    ),
    span.cls = list(
      transform = single_quote_if_no_color,
      color = "red",
      font_weight = "bold"
    ),
    span.pkg = list(
      transform = single_quote_if_no_color,
      color = "cyan",
      font_style = "italic"
    ),
    span.msg = list(
      # transform = single_quote_if_no_color,
      color = "yellow",
      font_weight = "normal"
    ),
    # Customize bullet points appearance
    .bullets = list(
      ".bullet-*" = list(
        "text-exdent" = 2, # Indentation
        before = function(x) paste0(cli::symbol$bullet, " ") # Bullet symbol
      )
    )
  )
}

#' Display information messages
#'
#' Uses `cli_inform` to display information messages with a custom theme.
#'
#' @param message The message to display.
#' @param ... Additional arguments to pass to `cli_inform()`.
#' @param .envir Environment where the message is evaluated.
#' @param call The call environment.
#'
#' @noRd
cd_info <- function(message, ..., .envir = parent.frame(), call = caller_env()) {
  if (is_quiet_mode()) {
    return(invisible())
  }
  cli::cli_div(theme = cd_theme())
  cli::cli_inform(message = message, ..., .envir = .envir, call = call)
}

#' Display error messages and abort execution
#'
#' Uses `cli_abort` to display error messages and stop execution.
#'
#' @param message The error message to display.
#' @param ... Additional arguments to pass to `cli_abort()`.
#' @param .envir Environment where the error is evaluated.
#' @param call The call environment.
#'
#' @noRd
cd_abort <- function(message, ..., class = NULL, .envir = parent.frame(), call = caller_env()) {
  cli::cli_div(theme = cd_theme())
  cli::cli_abort(
    message = message,
    ...,
    class = c(class, "cd2030_error"),
    .envir = .envir,
    call = call
  )
}

#' Display warning messages
#'
#' Uses `cli_warn` to display warning messages with a custom theme.
#'
#' @param message The warning message to display.
#' @param ... Additional arguments to pass to `cli_warn()`.
#' @param .envir Environment where the warning is evaluated.
#' @param call The call environment.
#'
#' @noRd
cd_warn <- function(message, ..., .envir = parent.frame(), call = caller_env()) {
  cli::cli_div(theme = cd_theme())
  cli::cli_warn(message = message, ..., .envir = .envir, call = call)
}

#' Check if the application is in quiet mode
#'
#' Returns `TRUE` if quiet mode is enabled or the application is in testing mode.
#'
#' @return Logical value indicating if quiet mode is active.
#'
#' @noRd
is_quiet_mode <- function() {
  cd_quiet() %|% is_testing()
}

#' Quote text if ANSI colors are not available
#'
#' This function wraps text in quotes if ANSI colors are not supported in the terminal.
#'
#' @param x The text to potentially quote.
#' @param quote The type of quotes to use (default: single quotes).
#' @return Quoted or unquoted text based on ANSI color availability.
#'
#' @noRd
single_quote_if_no_color <- function(x) quote_if_no_color(x, "'")

quote_if_no_color <- function(x, quote = "'") {
  if (cli::num_ansi_colors() > 1) {
    return(x) # Return as-is if colors are available
  } else {
    return(paste0(quote, x, quote)) # Wrap in quotes if no color
  }
}

#' Check if the application is in testing mode
#'
#' Returns `TRUE` if the application is running in a testing environment.
#'
#' @return Logical value indicating if testing mode is active.
#'
#' @noRd
is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

#' Get the quiet mode status for cd2030
#'
#' This function checks if `cd2030` is running in quiet mode.
#'
#' @return Logical value indicating if quiet mode is active.
#'
#' @noRd
cd_quiet <- function() {
  getOption("cd_quiet", default = NA)
}


#' Execute code in quiet mode
#'
#' Temporarily suppress messages by enabling quiet mode within the provided code block.
#'
#' @param code Code to execute quietly
#' @return No return value, called for side effects
#'
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#'
#' # no progress messages while the data loads
#' data <- with_cd_quiet(load_data(path))
#'
#' # quiet until the function returns
#' load_quietly <- function(path) {
#'   local_cd_quiet()
#'   load_data(path)
#' }
#' data <- load_quietly(path)
#'
#' @rdname cd2030-configuration
#' @export
#'
with_cd_quiet <- function(code) {
  withr::with_options(list(cd_quiet = TRUE), code = code)
}

#' Enable quiet mode in a specific scope
#'
#' Temporarily suppress messages within the specified environment.
#'
#' @param env The environment to use for scoping.
#' @return No return value, called for side effects.
#'
#' @rdname cd2030-configuration
#' @export
local_cd_quiet <- function(env = parent.frame()) {
  withr::local_options(list(cd_quiet = TRUE), .local_envir = env)
}
