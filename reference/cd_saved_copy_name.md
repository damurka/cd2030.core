# File name of a dataset's saved copy

Builds the name of the `.rds` file a finished dataset is saved to:
`<stem>_<group>.rds`, for example `Benin_rmncah.rds` or
`Benin_vaccine.rds`. One source file can be loaded by more than one app,
and the group in the name keeps each app's finished copy apart.

## Usage

``` r
cd_saved_copy_name(stem)
```

## Arguments

- stem:

  The name of the source file without its extension, a string.

## Value

The file name (not a full path), a string. The group is the one
[`cd_wizard_indicator_group()`](cd_wizard_indicator_group.md) returns.

## Examples

``` r
old <- options(cd2030.app_group = "rmncah")
cd_saved_copy_name("Kenya")
#> [1] "Kenya_rmncah.rds"
cd_saved_copy_name(tools::file_path_sans_ext(basename("C:/data/Kenya_2024.xlsx")))
#> [1] "Kenya_2024_rmncah.rds"
options(old)
```
