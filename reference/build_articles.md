# Build articles section

`build_articles()` renders each R Markdown file underneath `vignettes/`
and saves it to `articles/`. There are two exceptions:

- Files that start with `_` (e.g., `_index.Rmd`) are ignored, enabling
  the use of child documents.

- Files in `vignettes/tutorials` are handled by
  [`build_tutorials()`](https://pkgdown.r-lib.org/reference/build_tutorials.md)

Vignettes are rendered using a special document format that reconciles
[`rmarkdown::html_document()`](https://pkgs.rstudio.com/rmarkdown/reference/html_document.html)
with the pkgdown template. This means articles behave slightly
differently to vignettes, particularly with respect to external files,
and custom output formats. See below for more details.

Note that when you run `build_articles()` directly (outside of
[`build_site()`](https://pkgdown.r-lib.org/reference/build_site.md))
vignettes will use the currently installed version of the package, not
the current source version. This makes iteration quicker when you are
primarily working on the text of an article.

## Usage

``` r
build_articles(
  pkg = ".",
  quiet = TRUE,
  lazy = TRUE,
  seed = 1014L,
  override = list(),
  preview = FALSE
)

build_article(
  name,
  pkg = ".",
  lazy = FALSE,
  seed = 1014L,
  new_process = TRUE,
  pandoc_args = character(),
  override = list(),
  quiet = TRUE
)

build_articles_index(pkg = ".", override = list())
```

## Arguments

- pkg:

  Path to package.

- quiet:

  Set to `FALSE` to display output of knitr and pandoc. This is useful
  when debugging.

- lazy:

  If `TRUE`, will only re-build article if input file has been modified
  more recently than the output file.

- seed:

  Seed used to initialize random number generation in order to make
  article output reproducible. An integer scalar or `NULL` for no seed.

- override:

  An optional named list used to temporarily override values in
  `_pkgdown.yml`

- preview:

  If `TRUE`, or `is.na(preview) && interactive()`, will preview freshly
  generated section in browser.

- name:

  Name of article to render. This should be either a path relative to
  `vignettes/` *without extension*, or `index` or `README`.

- new_process:

  Build the article in a clean R process? The default, `TRUE`, ensures
  that every article is build in a fresh environment, but you may want
  to set it to `FALSE` to make debugging easier.

- pandoc_args:

  Pass additional arguments to pandoc. Used for testing.

## Index and navbar

You can control the articles index and navbar with a `articles` field in
your `_pkgdown.yml`. If you use it, pkgdown will check that all articles
are included, and will error if you have missed any.

The `articles` field defines a list of sections, each of which can
contain four fields:

- `title` (required): title of section, which appears as a heading on
  the articles index.

- `desc` (optional): An optional markdown description displayed
  underneath the section title.

- `navbar` (optional): A couple of words used to label this section in
  the navbar. If omitted, this section of vignettes will not appear in
  the navbar.

- `contents` (required): a list of article names to include in the
  section. This can either be names of individual vignettes or a call to
  `starts_with()`. The name of a vignette includes its path under
  `vignettes` without extension so that the name of the vignette found
  at `vignettes/pizza/slice.Rmd` is `pizza/slice`.

The title and description of individual vignettes displayed on the index
comes from `title` and `description` fields of the YAML header in the
Rmds.

For example, this yaml might be used for some version of dplyr:

    articles:
    - title: Main verbs
      navbar: ~
      contents:
      - one-table
      - two-table
      - rowwise
      - colwise

    - title: Developer
      desc: Vignettes aimed at package developers
      contents:
      - programming
      - packages

Note the use of the `navbar` fields. `navbar: ~` means that the "Main
verbs" will appear in the navbar without a heading; the absence of the
`navbar` field in the developer vignettes means that they will only be
accessible via the articles index.

The navbar will include a link to the articles index if one or more
vignettes are not available through the navbar. If some vignettes appear
in the navbar drop-down list and others do not, the list will
automatically include a "More ..." link at the bottom; if no vignettes
appear in the the navbar, it will link directly to the articles index
instead of providing a drop-down.

### Get started

Note that a vignette with the same name as the package (e.g.,
`vignettes/pkgdown.Rmd` or `vignettes/articles/pkgdown.Rmd`)
automatically becomes a top-level "Get started" link, and will not
appear in the articles drop-down.

(If your package name includes a `.`, e.g. `pack.down`, use a `-` in the
vignette name, e.g. `pack-down.Rmd`.)

### Missing articles

pkgdown will warn if there are (non-internal) articles that aren't
listed in the articles index. You can suppress such warnings by listing
the affected articles in a section with `title: internal` (case
sensitive); this section will not be displayed on the index page.

### External articles

You can link to arbitrary additional articles by adding an
`external-articles` entry to `_pkgdown.yml`. It should contain an array
of objects with fields `name`, `title`, `href`, and `description`.

    external-articles:
    - name: subsampling
      title: Subsampling for Class Imbalances
      description: Improve model performance in imbalanced data sets through undersampling or oversampling.
      href: https://www.tidymodels.org/learn/models/sub-sampling/

If you've defined a custom articles index, you'll need to include the
name in one of the `contents` fields.

## External files

pkgdown differs from base R in its handling of external files. When
building vignettes, R assumes that vignettes are self-contained (a
reasonable assumption when most vignettes were PDFs) and only copies
files explicitly listed in `.install_extras`. pkgdown takes a different
approach based on
[`rmarkdown::find_external_resources()`](https://pkgs.rstudio.com/rmarkdown/reference/find_external_resources.html),
and it will also copy any images that you link to. If for some reason
the automatic detection doesn't work, you will need to add a
`resource_files` field to the yaml metadata, e.g.:

    ---
    title: My Document
    resource_files:
      - data/mydata.csv
      - images/figure.png
    ---

Note that you can not use the `fig.path` to change the output directory
of generated figures as its default value is a strong assumption of
rmarkdown.

## Embedding Shiny apps

If you would like to embed a Shiny app into an article, the app will
have to be hosted independently, (e.g. <https://www.shinyapps.io>).
Then, you can embed the app into your article using an `<iframe>`, e.g.
`<iframe src = "https://gallery.shinyapps.io/083-front-page" class="shiny-app">`.

See <https://github.com/r-lib/pkgdown/issues/838#issuecomment-430473856>
for some hints on how to customise the appearance with CSS.

## Output formats

By default, pkgdown builds all articles using the
[`rmarkdown::html_document()`](https://pkgs.rstudio.com/rmarkdown/reference/html_document.html)
`output` format, ignoring whatever is set in your YAML metadata. This is
necessary because pkgdown has to integrate the HTML/CSS/JS from the
vignette with the HTML/CSS/JS from rest of the site. Because of the
challenges of combining two sources of HTML/CSS/JS, there is limited
support for other output formats and you have to opt-in by setting the
`as_is` field in your `.Rmd` metadata:

    pkgdown:
      as_is: true

If the output format produces a PDF, you'll also need to specify the
`extension` field:

    pkgdown:
      as_is: true
      extension: pdf

To work with pkgdown, the output format must accept `template`, `theme`,
and `self_contained` arguments, and must work without any additional CSS
or JSS files. Note that if you use
[`_output.yml`](https://bookdown.org/yihui/rmarkdown/html-document.html#shared-options)
or
[`_site.yml`](https://rmarkdown.rstudio.com/docs/reference/render_site.html)
you'll still need to add `as_is: true` to each individual vignette.

Additionally, htmlwidgets do not work when `as_is: true`.

## Suppressing vignettes

If you want
[articles](https://r-pkgs.org/vignettes.html#sec-vignettes-article) that
are not vignettes, use
[`usethis::use_article()`](https://usethis.r-lib.org/reference/use_vignette.html)
to create it. An articles link will be automatically added to the
default navbar if the vignettes directory is present: if you do not want
this, you will need to customise the navbar. See
[`build_site()`](https://pkgdown.r-lib.org/reference/build_site.md)
details.

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
[`build_home()`](https://pkgdown.r-lib.org/reference/build_home.md),
[`build_llm_docs()`](https://pkgdown.r-lib.org/reference/build_llm_docs.md),
[`build_news()`](https://pkgdown.r-lib.org/reference/build_news.md),
[`build_reference()`](https://pkgdown.r-lib.org/reference/build_reference.md),
[`build_tutorials()`](https://pkgdown.r-lib.org/reference/build_tutorials.md)
