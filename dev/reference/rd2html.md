# Translate an Rd string to its HTML output

Translate an Rd string to its HTML output

## Usage

``` r
rd2html(x, fragment = TRUE, ...)
```

## Arguments

- x:

  Rd string. Backslashes must be double-escaped ("\\").

- fragment:

  logical indicating whether this represents a complete Rd file

- ...:

  additional arguments for as_html

## Examples

``` r
rd2html("a\n%b\nc")
#> [1] "a"           "<!-- %b -->" "c"          

rd2html("a & b")
#> [1] "a &amp; b"

rd2html("\\strong{\\emph{x}}")
#> [1] "<strong><em>x</em></strong>"
```
