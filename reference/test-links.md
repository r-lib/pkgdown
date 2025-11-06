# Test case: links

    jsonlite::minify("{}")
    #> {}

## See also

Other tests: [`index`](https://pkgdown.r-lib.org/reference/index.md),
[`test-crayon`](https://pkgdown.r-lib.org/reference/test-crayon.md),
[`test-dont`](https://pkgdown.r-lib.org/reference/test-dont.md),
[`test-figures`](https://pkgdown.r-lib.org/reference/test-figures.md),
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
jsonlite::minify("{}")
#> {} 

library(jsonlite, warn.conflicts = FALSE)
minify("{}")
#> {} 
```
