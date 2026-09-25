# Print Notes for a Specific Page and Object

This function retrieves notes from the cache for a given `page_id` and
`object_id`, filters them for those marked as `include_in_report`, and
prints them to the console. If no notes are found, it prompts the user
to enter notes for the given `page_id` and `object_id`, optionally
including additional parameters.

## Usage

``` r
print_notes(cache, page_id, object_id = NULL, parameters = NULL)
```

## Arguments

- cache:

  An object (e.g., of class `CacheConnection`) that manages cached data,
  including notes.

- page_id:

  A character string specifying the page identifier for which to
  retrieve notes.

- object_id:

  An optional character string specifying the object identifier within
  the page. Defaults to `NULL`.

- parameters:

  An optional named list of additional parameters to filter or describe
  the notes.

## Value

None. The function is used for its side effects (printing notes or
prompting the user).
