# The table a CacheConnection member gives

Reads an active binding, or calls a method with `args` (arguments it
doesn't take are left out), and returns the result as a plain data frame
(a map's geometry dropped).

## Usage

``` r
cd_member_data(cache, member, args = list())
```

## Arguments

- cache:

  A `CacheConnection`.

- member:

  A member name, one of
  [`cd_chartable_members()`](cd_chartable_members.md).

- args:

  A named list of arguments for a method.

## Value

A data frame.
