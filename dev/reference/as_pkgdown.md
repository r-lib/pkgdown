# Generate pkgdown data structure

You will generally not need to use this unless you need a custom site
design and you're writing your own equivalent of
[`build_site()`](https://pkgdown.r-lib.org/dev/reference/build_site.md).

## Usage

``` r
as_pkgdown(pkg = ".", override = list())
```

## Arguments

- pkg:

  Path to package.

- override:

  An optional named list used to temporarily override values in
  `_pkgdown.yml`
