# Build docs for LLMs

`build_llm_docs()` creates an `LLMs.txt` at the root of your site that
contains the contents of your `README.md`, your reference index, and
your articles index. It also creates a `.md` file for every existing
`.html` file in your site. Together, this gives an LLM an overview of
your package and the ability to find out more by following links.

If you don't want these files generated for your site, you can opt-out
by adding the following to your `pkgdown.yml`:

    llm-docs: false

## Usage

``` r
build_llm_docs(pkg = ".")
```

## Arguments

- pkg:

  Path to package.

## See also

Other site components:
[`build_articles()`](https://pkgdown.r-lib.org/dev/reference/build_articles.md),
[`build_home()`](https://pkgdown.r-lib.org/dev/reference/build_home.md),
[`build_news()`](https://pkgdown.r-lib.org/dev/reference/build_news.md),
[`build_reference()`](https://pkgdown.r-lib.org/dev/reference/build_reference.md),
[`build_tutorials()`](https://pkgdown.r-lib.org/dev/reference/build_tutorials.md)
