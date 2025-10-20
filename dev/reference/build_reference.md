# Build reference section

By default, pkgdown will generate an index that lists all functions in
alphabetical order. To override this, provide a `reference` section in
your `_pkgdown.yml` as described below.

## Usage

``` r
build_reference(
  pkg = ".",
  lazy = TRUE,
  examples = TRUE,
  run_dont_run = FALSE,
  seed = 1014L,
  override = list(),
  preview = FALSE,
  devel = TRUE,
  topics = NULL
)

build_reference_index(pkg = ".", override = list())
```

## Arguments

- pkg:

  Path to package.

- lazy:

  If `TRUE`, only rebuild pages where the `.Rd` is more recent than the
  `.html`. This makes it much easier to rapidly prototype. It is set to
  `FALSE` by
  [`build_site()`](https://pkgdown.r-lib.org/dev/reference/build_site.md).

- examples:

  Run examples?

- run_dont_run:

  Run examples that are surrounded in \dontrun?

- seed:

  Seed used to initialize random number generation in order to make
  article output reproducible. An integer scalar or `NULL` for no seed.

- override:

  An optional named list used to temporarily override values in
  `_pkgdown.yml`

- preview:

  If `TRUE`, or `is.na(preview) && interactive()`, will preview freshly
  generated section in browser.

- devel:

  Determines how code is loaded in order to run examples. If `TRUE` (the
  default), assumes you are in a live development environment, and loads
  source package with
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html).
  If `FALSE`, uses the installed version of the package.

- topics:

  Build only specified topics. If supplied, sets `lazy` and `preview` to
  `FALSE`.

## Reference index

To tweak the index page, add a section called `reference` to
`_pkgdown.yml`. It can contain three different types of element:

- A **title** (`title` + `desc`), which generates an row containing an
  `<h2>` with optional paragraph description.

- A **subtitle** (`subtitle` + `desc`), which generates an row
  containing an `<h3>` with optional paragraph description.

- A **list of topics** (`contents`), which generates one row for each
  topic, with a list of aliases for the topic on the left, and the topic
  title on the right.

(For historical reasons you can include `contents` with a title or
subtitle, but this is no longer recommended).

Most packages will only need to use `title` and `contents` components.
For example, here's a snippet from the YAML that pkgdown uses to
generate its own reference index:

    reference:
    - title: Build
      desc:  Build a complete site or its individual section components.
    - contents:
      - starts_with("build_")
    - title: Templates
    - contents:
      - template_navbar
      - render_page

Bigger packages, e.g. ggplot2, may need an additional layer of structure
in order to clearly organise large number of functions:

    reference:
    - title: Layers
    - subtitle: Geoms
      desc: Geom is short for geometric element
    - contents:
      - starts_with("geom")
    - subtitle: Stats
      desc: Statistical transformations transform data before display.
      contents:
      - starts_with("stat")

`desc` can use markdown, and if you have a long description it's a good
idea to take advantage of the YAML `>` notation:

    desc: >
      This is a very _long_ and **overly** flowery description of a
      single simple function. By using `>`, it's easy to write a description
      that runs over multiple lines.

### Topic matching

`contents` can contain:

- Individual function/topic names.

- Weirdly named functions with doubled quoting, once for YAML and once
  for R, e.g. `` "`+.gg`" ``.

- `starts_with("prefix")` to select all functions with common prefix.

- `ends_with("suffix")` to select all functions with common suffix.

- `matches("regexp")` for more complex regular expressions.

- `has_keyword("x")` to select all topics with keyword "x";
  `has_keyword("datasets")` selects all data documentation.

- `has_concept("blah")` to select all topics with concept "blah". If you
  are using roxygen2, `has_concept()` also matches family tags, because
  roxygen2 converts them to concept tags.

- `lacks_concepts(c("concept1", "concept2"))` to select all topics
  without those concepts. This is useful to capture topics not otherwise
  captured by `has_concepts()`.

- Topics from other installed packages, e.g.
  [`rlang::is_installed()`](https://rlang.r-lib.org/reference/is_installed.html)
  (function name) or
  [`sass::font_face`](https://rstudio.github.io/sass/reference/font_face.html)
  (topic name).

- `has_lifecycle("deprecated")` will select all topics with lifecycle
  deprecated.

All functions (except for `has_keyword()`) automatically exclude
internal topics (i.e. those with `\keyword{internal}`). You can choose
to include with (e.g.) `starts_with("build_", internal = TRUE)`.

Use a leading `-` to remove topics from a section, e.g. `-topic_name`,
`-starts_with("foo")`.

pkgdown will check that all non-internal topics are included on the
reference index page, and error if you have missed any.

### Missing topics

pkgdown will warn if there are (non-internal) topics that not listed in
the reference index. You can suppress these warnings by listing the
topics in section with "title: internal" (case sensitive) which will not
be displayed on the reference index.

### Icons

You can optionally supply an icon for each help topic. To do so, you'll
need a top-level `icons` directory. This should contain `.png` files
that are either 30x30 (for regular display) or 60x60 (if you want retina
display). Icons are matched to topics by aliases.

## Examples

If you need to run extra code before or after all examples are run, you
can create `pkgdown/pre-reference.R` and `pkgdown/post-reference.R`.

## Figures

You can control the default rendering of figures by specifying the
`figures` field in `_pkgdown.yml`. The default settings are equivalent
to:

    figures:
      dev: ragg::agg_png
      dpi: 96
      dev.args: []
      fig.ext: png
      fig.width: 7.2916667
      fig.height: ~
      fig.retina: 2
      fig.asp: 1.618
      bg: NA
      other.parameters: []

Most of these parameters are interpreted similarly to knitr chunk
options. `other.parameters` is a list of parameters that will be
available to custom graphics output devices such as HTML widgets.

## See also

Other site components:
[`build_articles()`](https://pkgdown.r-lib.org/dev/reference/build_articles.md),
[`build_home()`](https://pkgdown.r-lib.org/dev/reference/build_home.md),
[`build_llm_docs()`](https://pkgdown.r-lib.org/dev/reference/build_llm_docs.md),
[`build_news()`](https://pkgdown.r-lib.org/dev/reference/build_news.md),
[`build_tutorials()`](https://pkgdown.r-lib.org/dev/reference/build_tutorials.md)
