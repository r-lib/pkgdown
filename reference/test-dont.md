# Test case: don't

Test case: don't

## See also

Other tests: [`index`](https://pkgdown.r-lib.org/reference/index.md),
[`test-crayon`](https://pkgdown.r-lib.org/reference/test-crayon.md),
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
# \dontrun{} --------------------------------------------------------
# always shown; never run

x <- 1
if (FALSE) x <- 2 # \dontrun{}
if (FALSE) { # \dontrun{
  x <- 3
  x <- 4
} # }
x # should be 1
#> [1] 1

# \donttest{} -------------------------------------------------------
# only multiline are shown; always run

x <- 1
x <- 2
# \donttest{
  x <- 3
  x <- 4
# }
x # should be 4
#> [1] 4

# \testonly{} -----------------------------------------------------
# never shown, never run

x <- 1
x # should be 1
#> [1] 1

# \dontshow{} -------------------------------------------------------
# never shown, always run

x <- 1
x # should be 4
#> [1] 4

# @examplesIf ------------------------------------------------------
# If FALSE, wrapped in if; if TRUE, not seen

x <- 1

if (FALSE) {
x <- 2
}
x <- 3
x # should be 3
#> [1] 3
```
