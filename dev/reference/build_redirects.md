# Build redirects

If you change the structure of your documentation (by renaming vignettes
or help topics) you can setup redirects from the old content to the new
content. One or several now-absent pages can be redirected to a new page
(or to a new section of a new page). This works by creating a html page
that performs a "meta refresh", which isn't the best way of doing a
redirect but works everywhere that you might deploy your site.

The syntax is the following, with old paths on the left, and new paths
or URLs on the right.

    redirects:
      - ["articles/old-vignette-name.html", "articles/new-vignette-name.html"]
      - ["articles/another-old-vignette-name.html", "articles/new-vignette-name.html"]
      - ["articles/yet-another-old-vignette-name.html", "https://pkgdown.r-lib.org/dev"]

If for some reason you choose to redirect an existing page make sure to
exclude it from the search index, see
[`?build_search`](https://pkgdown.r-lib.org/dev/reference/build_search.md).

## Usage

``` r
build_redirects(pkg = ".", override = list())
```

## Arguments

- pkg:

  Path to package.

- override:

  An optional named list used to temporarily override values in
  `_pkgdown.yml`
