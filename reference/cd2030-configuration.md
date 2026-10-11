# Execute code in quiet mode

Temporarily suppress messages by enabling quiet mode within the provided
code block.

Temporarily suppress messages within the specified environment.

## Usage

``` r
with_cd_quiet(code)

local_cd_quiet(env = parent.frame())
```

## Arguments

- code:

  Code to execute quietly

- env:

  The environment to use for scoping.

## Value

No return value, called for side effects

No return value, called for side effects.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")

# no progress messages while the data loads
data <- with_cd_quiet(load_data(path))

# quiet until the function returns
load_quietly <- function(path) {
  local_cd_quiet()
  load_data(path)
}
data <- load_quietly(path)
```
