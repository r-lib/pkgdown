# Build news section

A `NEWS.md` will be broken up into versions using level one (`#`) or
level two headings (`##`) that (partially) match one of the following
forms (ignoring case):

- `{package name} 1.3.0`

- `{package name} v1.3.0`

- `Version 1.3.0`

- `Changes in 1.3.0`

- `Changes in v1.3.0`

## Usage

``` r
build_news(pkg = ".", override = list(), preview = FALSE)
```

## Arguments

- pkg:

  Path to package.

- override:

  An optional named list used to temporarily override values in
  `_pkgdown.yml`

- preview:

  If `TRUE`, or `is.na(preview) && interactive()`, will preview freshly
  generated section in browser.

## Details

A [common structure](https://style.tidyverse.org/news.html) for news
files is to use a top level heading for each release, and use a second
level heading to break up individual bullets into sections.

    # foofy 1.0.0

    ## Major changes

    * Can now work with all grooveable grobbles!

    ## Minor improvements and bug fixes

    * Printing scrobbles no longer errors (@githubusername, #100)

    * Wibbles are now 55% less jibbly (#200)

Issues and contributors will be automatically linked to the
corresponding pages on GitHub if the GitHub repo can be discovered from
the `DESCRIPTION` (typically from a `URL` entry containing `github.com`)

If a version is available on CRAN, the release date will automatically
be added to the heading (see below for how to suppress); if not
available on CRAN, "Unreleased" will be added.

## YAML config

To automatically link to release announcements, include a `releases`
section.

    news:
     releases:
     - text: "usethis 1.3.0"
       href: https://www.tidyverse.org/articles/2018/02/usethis-1-3-0/
     - text: "usethis 1.0.0 (and 1.1.0)"
       href: https://www.tidyverse.org/articles/2017/11/usethis-1.0.0/

Control whether news is present on one page or multiple pages with the
`one_page` field. The default is `true`.

    news:
      one_page: false

Suppress the default addition of CRAN release dates with:

    news:
      cran_dates: false

## See also

[Tidyverse style for News](https://style.tidyverse.org/news.html)

Other site components:
[`build_articles()`](https://pkgdown.r-lib.org/dev/reference/build_articles.md),
[`build_home()`](https://pkgdown.r-lib.org/dev/reference/build_home.md),
[`build_llm_docs()`](https://pkgdown.r-lib.org/dev/reference/build_llm_docs.md),
[`build_reference()`](https://pkgdown.r-lib.org/dev/reference/build_reference.md),
[`build_tutorials()`](https://pkgdown.r-lib.org/dev/reference/build_tutorials.md)
