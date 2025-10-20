# Test case: preformatted blocks & syntax highlighting

Manual test cases for various ways of embedding code in sections. All
code blocks should have copy and paste button.

## Should be highlighted

Valid R code in `\preformatted{}`:

    mean(a + 1)

R code in `R` block:

    mean(a + 1)

R code in `r` block:

    mean(a + 1)

Yaml

    yaml: [a, 1]

## Shouldn't be highlighted

Non-R code in `\preformatted{}`

    yaml: [a, b, c]

## See also

Other tests:
[`index`](https://pkgdown.r-lib.org/dev/reference/index.md),
[`test-crayon`](https://pkgdown.r-lib.org/dev/reference/test-crayon.md),
[`test-dont`](https://pkgdown.r-lib.org/dev/reference/test-dont.md),
[`test-figures`](https://pkgdown.r-lib.org/dev/reference/test-figures.md),
[`test-links`](https://pkgdown.r-lib.org/dev/reference/test-links.md),
[`test-lists`](https://pkgdown.r-lib.org/dev/reference/test-lists.md),
[`test-long-lines`](https://pkgdown.r-lib.org/dev/reference/test-long-lines.md),
[`test-math-examples`](https://pkgdown.r-lib.org/dev/reference/test-math-examples.md),
[`test-output-styles`](https://pkgdown.r-lib.org/dev/reference/test-output-styles.md),
[`test-params`](https://pkgdown.r-lib.org/dev/reference/test-params.md),
[`test-sexpr-title`](https://pkgdown.r-lib.org/dev/reference/test-sexpr-title.md),
[`test-tables`](https://pkgdown.r-lib.org/dev/reference/test-tables.md)
