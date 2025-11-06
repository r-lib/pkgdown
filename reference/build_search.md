# Build search index

Generate a JSON search index from the built site. This is used by
[fuse.js](https://www.fusejs.io/) to provide a javascript powered search
for BS5 powered pkgdown sites.

NB: `build_search()` is called automatically by
[`build_site()`](https://pkgdown.r-lib.org/reference/build_site.md); you
don't need call it yourself. This page documents how it works and its
customisation options.

## Usage

``` r
build_search(pkg = ".", override = list())
```

## Arguments

- pkg:

  Path to package.

- override:

  An optional named list used to temporarily override values in
  `_pkgdown.yml`

## YAML config

You can exclude some paths from the search index using `search.exclude`.
Below we exclude the changelog from the search index:

    search:
      exclude: ['news/index.html']

## Debugging and local testing

Locally (as opposed to on GitHub Pages or Netlify for instance), search
won't work if you simply use pkgdown preview of the static files. You
can use `servr::httw("docs")` instead.

If search is not working, run
[`pkgdown::pkgdown_sitrep()`](https://pkgdown.r-lib.org/reference/check_pkgdown.md)
to eliminate common issues such as the absence of URL in the pkgdown
configuration file of your package.
