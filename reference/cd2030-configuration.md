# Execute Code in Quiet Mode

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
