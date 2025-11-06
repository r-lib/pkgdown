# Clean site

Delete all files in `docs/` (except for `CNAME`).

Delete all files in the pkgdown cache directory.

## Usage

``` r
clean_site(pkg = ".", quiet = FALSE, force = FALSE)

clean_cache(pkg = ".", quiet = FALSE)
```

## Arguments

- pkg:

  Path to package.

- quiet:

  If `TRUE`, suppresses a message.

- force:

  If `TRUE`, delete contents of `docs` even if it is not a pkgdown site.
