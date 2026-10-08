# Ask DataSuite to install the Bayesian model's packages

Inside DataSuite (an app it started), asks it to install them: it shows
the progress in its status bar and then offers to restart the app.
Outside DataSuite it does nothing; install them with
[`cd_bayes_install_command()`](cd_bayes_install_command.md).

## Usage

``` r
cd_request_bayes_packages(packages = cd_bayes_packages_missing())
```

## Arguments

- packages:

  The packages to install, by default the missing ones.

## Value

`TRUE` when DataSuite was asked, invisibly.
