# Initialise site infrastructure

`init_site()`:

- creates the output directory (`docs/`),

- generates a machine readable description of the site, used for
  autolinking,

- copies CSS/JS assets and extra files, and

- runs
  [`build_favicons()`](https://pkgdown.r-lib.org/dev/reference/build_favicons.md),
  if needed.

Typically, you will not need to call this function directly, as all
`build_*()` functions will run `init_site()` if needed.

The only good reasons to call `init_site()` directly are the following:

- If you add or modify a package logo.

- If you add or modify `pkgdown/extra.scss`.

- If you modify `template.bslib` variables in `_pkgdown.yml`.

See
[`vignette("customise")`](https://pkgdown.r-lib.org/dev/articles/customise.md)
for the various ways you can customise the display of your site.

## Usage

``` r
init_site(pkg = ".", override = list())
```

## Arguments

- pkg:

  Path to package.

- override:

  An optional named list used to temporarily override values in
  `_pkgdown.yml`

## Build-ignored files

We recommend using
[`usethis::use_pkgdown_github_pages()`](https://usethis.r-lib.org/reference/use_pkgdown.html)
to build-ignore `docs/` and `_pkgdown.yml`. If use another directory, or
create the site manually, you'll need to add them to `.Rbuildignore`
yourself. A `NOTE` about an unexpected file during `R CMD CHECK` is an
indication you have not correctly ignored these files.
