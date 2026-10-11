# Start the background workers that fit the Bayesian models

Sets the R session's `future` plan to `multisession`, so that the
Bayesian page fits its models in other R processes and the app stays
usable meanwhile. It changes the plan only while the plan is the default
(`sequential`): a session that already has a plan of its own keeps it,
and a second call does nothing. There is one worker by default, so a fit
asked for while another runs waits its turn.
`options(cd2030.bayes_workers = )` sets another number (at least one is
always used).

## Usage

``` r
cd_start_bayes_workers()
```

## Value

The session's `future` plan, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
cd_start_bayes_workers()
future::nbrOfWorkers()

# two fits at a time: set the option before the first call
options(cd2030.bayes_workers = 2)
cd_start_bayes_workers()
} # }
```
