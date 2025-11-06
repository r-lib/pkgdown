# Test case: crayon

Test case: crayon

## See also

Other tests: [`index`](https://pkgdown.r-lib.org/reference/index.md),
[`test-dont`](https://pkgdown.r-lib.org/reference/test-dont.md),
[`test-figures`](https://pkgdown.r-lib.org/reference/test-figures.md),
[`test-links`](https://pkgdown.r-lib.org/reference/test-links.md),
[`test-lists`](https://pkgdown.r-lib.org/reference/test-lists.md),
[`test-long-lines`](https://pkgdown.r-lib.org/reference/test-long-lines.md),
[`test-math-examples`](https://pkgdown.r-lib.org/reference/test-math-examples.md),
[`test-output-styles`](https://pkgdown.r-lib.org/reference/test-output-styles.md),
[`test-params`](https://pkgdown.r-lib.org/reference/test-params.md),
[`test-sexpr-title`](https://pkgdown.r-lib.org/reference/test-sexpr-title.md),
[`test-tables`](https://pkgdown.r-lib.org/reference/test-tables.md),
[`test-verbatim`](https://pkgdown.r-lib.org/reference/test-verbatim.md)

## Examples

``` r
cat(cli::col_red("This is red"), "\n")
#> This is red 
cat(cli::col_blue("This is blue"), "\n")
#> This is blue 

message(cli::col_green("This is green"))
#> This is green

warning(cli::style_bold("This is bold"))
#> Warning: This is bold
```
