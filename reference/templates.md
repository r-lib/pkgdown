# Generate YAML templates

Use these function to generate the default YAML that pkgdown uses for
the different parts of `_pkgdown.yml`. This are useful starting points
if you want to customise your site.

## Usage

``` r
template_navbar(path = ".")

template_reference(path = ".")

template_articles(path = ".")
```

## Arguments

- path:

  Path to package root

## Examples

``` r
if (FALSE) { # \dontrun{
pkgdown::template_navbar()
} # }

if (FALSE) { # \dontrun{
pkgdown::template_reference()
} # }

if (FALSE) { # \dontrun{
pkgdown::template_articles()
} # }
```
