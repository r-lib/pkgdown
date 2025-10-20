# Build tutorials section

learnr tutorials must be hosted elsewhere as they require an R execution
engine. Currently, pkgdown will not build or publish tutorials for you,
but makes it easy to embed (using `<iframe>`s) published tutorials.
Tutorials are automatically discovered from published tutorials in
`inst/tutorials` and `vignettes/tutorials`. Alternatively, you can list
in `_pkgdown.yml` as described below.

## Usage

``` r
build_tutorials(pkg = ".", override = list(), preview = FALSE)
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

## YAML config

To override the default discovery process, you can provide a `tutorials`
section. This should be a list where each element specifies:

- `name`: used for the generated file name

- `title`: used in page heading and in navbar

- `url`: which will be embedded in an iframe

- `source`: optional, but if present will be linked to

    tutorials:
    - name: 00-setup
      title: Setting up R
      url: https://jjallaire.shinyapps.io/learnr-tutorial-00-setup/
    - name: 01-data-basics
      title: Data basics
      url: https://jjallaire.shinyapps.io/learnr-tutorial-01-data-basics/

## See also

Other site components:
[`build_articles()`](https://pkgdown.r-lib.org/dev/reference/build_articles.md),
[`build_home()`](https://pkgdown.r-lib.org/dev/reference/build_home.md),
[`build_llm_docs()`](https://pkgdown.r-lib.org/dev/reference/build_llm_docs.md),
[`build_news()`](https://pkgdown.r-lib.org/dev/reference/build_news.md),
[`build_reference()`](https://pkgdown.r-lib.org/dev/reference/build_reference.md)
