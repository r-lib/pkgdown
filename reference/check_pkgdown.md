# Check `_pkgdown.yml`

This pair of functions checks that your `_pkgdown.yml` is valid without
building the whole site. `check_pkgdown()` errors at the first problem;
`pkgdown_sitrep()` reports the status of all checks.

Currently they check that:

- There's a `url` in the pkgdown configuration, which is also recorded
  in the `URL` field of the `DESCRIPTION`.

- All opengraph metadata is valid.

- All reference topics are included in the index.

- All articles/vignettes are included in the index.

## Usage

``` r
check_pkgdown(pkg = ".")

pkgdown_sitrep(pkg = ".")
```

## Arguments

- pkg:

  Path to package.
