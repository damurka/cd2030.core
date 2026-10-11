# The R command that installs the Bayesian model's packages

For R outside DataSuite.

## Usage

``` r
cd_bayes_install_command(packages = cd_bayes_packages_missing())
```

## Arguments

- packages:

  The packages to install, by default the missing ones.

## Value

The command, as a string.

## Examples

``` r
cd_bayes_install_command(c("bayescoveragemodel", "bayescoveragedeploy"))
#> [1] "install.packages(c(\"bayescoveragemodel\", \"bayescoveragedeploy\"), repos = c(\"https://alkemalab.r-universe.dev\", \"https://cloud.r-project.org\"))"

# only what is missing
missing <- cd_bayes_packages_missing()
if (length(missing) > 0) cd_bayes_install_command(missing)
```
