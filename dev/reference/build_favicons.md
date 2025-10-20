# Initialise favicons from package logo

This function auto-detects the location of your package logo (with the
name `logo.svg` (recommended format) or `logo.png`, created with
[`usethis::use_logo()`](https://usethis.r-lib.org/reference/use_logo.html))
and runs it through the <https://realfavicongenerator.net> API to build
a complete set of favicons with different sizes, as needed for modern
web usage.

You only need to run the function once. The favicon set will be stored
in `pkgdown/favicon` and copied by
[`init_site()`](https://pkgdown.r-lib.org/dev/reference/init_site.md) to
the relevant location when the website is rebuilt.

Once complete, you should add `pkgdown/` to `.Rbuildignore ` to avoid a
NOTE during package checking.
([`usethis::use_logo()`](https://usethis.r-lib.org/reference/use_logo.html)
does this for you!)

## Usage

``` r
build_favicons(pkg = ".", overwrite = FALSE)
```

## Arguments

- pkg:

  Path to package.

- overwrite:

  If `TRUE`, re-create favicons from package logo.
