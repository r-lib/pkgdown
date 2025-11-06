# Test case: long-lines

The example results should have the copy button correctly placed when
scrollings

## See also

Other tests: [`index`](https://pkgdown.r-lib.org/reference/index.md),
[`test-crayon`](https://pkgdown.r-lib.org/reference/test-crayon.md),
[`test-dont`](https://pkgdown.r-lib.org/reference/test-dont.md),
[`test-figures`](https://pkgdown.r-lib.org/reference/test-figures.md),
[`test-links`](https://pkgdown.r-lib.org/reference/test-links.md),
[`test-lists`](https://pkgdown.r-lib.org/reference/test-lists.md),
[`test-math-examples`](https://pkgdown.r-lib.org/reference/test-math-examples.md),
[`test-output-styles`](https://pkgdown.r-lib.org/reference/test-output-styles.md),
[`test-params`](https://pkgdown.r-lib.org/reference/test-params.md),
[`test-sexpr-title`](https://pkgdown.r-lib.org/reference/test-sexpr-title.md),
[`test-tables`](https://pkgdown.r-lib.org/reference/test-tables.md),
[`test-verbatim`](https://pkgdown.r-lib.org/reference/test-verbatim.md)

## Examples

``` r
pkgdown:::ruler()
#> ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
#> 12345678901234567890123456789012345678901234567890123456789012345678901234567890

cat(rep("x ", 100), sep = "")
#> x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
cat(rep("xy", 100), sep = "")
#> xyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxy
cat(rep("x ", 100), sep = "")
#> x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x 
cat(rep("xy", 100), sep = "")
#> xyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxy
```
