# Table cell showing a rate with its status

Draws one cell of a table of rates, such as reporting rates: a small
coloured shape that says how good the rate is, followed by the rate
rounded to a whole number. The shape differs with the status as well as
the colour, so the status never depends on colour alone. Use it as the
`cell` of a
[`reactable::colDef()`](https://glin.github.io/reactable/reference/colDef.html),
for example in the `columns` of [`cd_table_server()`](cd_table_ui.md).

## Usage

``` r
cd_rate_status_cell(value)
```

## Arguments

- value:

  The rate, a single number on a scale of 0 to 100. `NULL` or `NA` gives
  an empty cell.

## Value

The cell as a Shiny tag (a `span` holding the shape and the number), or
`""` when `value` is `NULL` or `NA`.

## Details

The status has fixed limits: a red triangle below 70, an amber diamond
from 70 to below 90, and a green circle from 90.

## Examples

``` r
cd_rate_status_cell(64.2)
#> <span class="cd-status-cell">
#>   <svg width="10" height="10" viewBox="0 0 10 10" aria-hidden="true">
#>     <path d="M5 9.5L9.5 1.5h-9z" fill="#c0392b"></path>
#>   </svg>
#>   64.2
#> </span>
cd_rate_status_cell(95)
#> <span class="cd-status-cell">
#>   <svg width="10" height="10" viewBox="0 0 10 10" aria-hidden="true">
#>     <circle cx="5" cy="5" r="4.5" fill="#1b7f5a"></circle>
#>   </svg>
#>   95.0
#> </span>
cd_rate_status_cell(NA)
#> [1] ""

# as the cell of a table column
reactable::colDef(cell = cd_rate_status_cell)
#> $cell
#> function (value) 
#> {
#>     if (is.null(value) || is.na(value)) 
#>         return("")
#>     shape <- if (value < 70) {
#>         tags$path(d = "M5 9.5L9.5 1.5h-9z", fill = "#c0392b")
#>     }
#>     else if (value < 90) {
#>         tags$path(d = "M5 .5L9.5 5 5 9.5.5 5z", fill = "#b57f0c")
#>     }
#>     else {
#>         tags$circle(cx = "5", cy = "5", r = "4.5", fill = "#1b7f5a")
#>     }
#>     span(class = "cd-status-cell", tags$svg(width = "10", height = "10", 
#>         viewBox = "0 0 10 10", `aria-hidden` = "true", shape), 
#>         .cd_table_number(value, "rate"))
#> }
#> <bytecode: 0x5628efa333b8>
#> <environment: namespace:cd2030.core>
#> 
#> attr(,"class")
#> [1] "colDef"
```
