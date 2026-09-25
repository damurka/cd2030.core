# Clean and Validate Error Messages

`clean_error_message` processes and cleans error messages to remove
unnecessary details such as ANSI escape codes, CLI-specific bullets,
stack traces, and technical context. It ensures the input is a valid
error object before processing and returns a blank string (`""`) if the
input is not an error.

## Usage

``` r
clean_error_message(error_message)
```

## Arguments

- error_message:

  The input to be processed. This should be an object of class
  `"error"`. Non-error inputs will result in a blank string being
  returned.

## Value

A cleaned, user-friendly error message as a string. Returns an empty
string if the input is not an error object.

## Examples

``` r
# Processing a Valid Error Message
tryCatch(
  {
    stop("Something went wrong.")
  },
  error = function(e) {
    cleaned <- clean_error_message(e)
    cleaned
  }
)
#> [1] "Something went wrong."

# Handling Non-Error Input
cleaned <- clean_error_message("This is not an error object")
cleaned
#> [1] ""
```
