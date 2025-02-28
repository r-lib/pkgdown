#' Build home section
#'
#' @description
#' `build_home()` function generates pages at the top-level of the site
#' including:
#'
#' * The home page
#' * HTML files from any `.md` files in `./` or `.github/`.
#' * The authors page (from `DESCRIPTION`)
#' * The citation page (from `inst/CITATION`, if present).
#' * The license page
#' * A default 404 page if `.github/404.md` is not found.
#'
#' `build_home_index()` rebuilds just the index page; it's useful for rapidly
#' iterating when experimenting with site styles.
#'
#' # Home page
#'
#' The main content of the home page (`index.html`) is generated from
#' `pkgdown/index.md`, `index.md`, or `README.md`, in that order.
#' Most packages will use `README.md` because that's also displayed by GitHub
#' and CRAN. Use `index.md` if you want your package website to look
#' different to your README, and use `pkgdown/index.md` if you don't want that
#' file to live in your package root directory.
#'
#' If you use `index.Rmd` or `README.Rmd` it's your responsibility to knit
#' the document to create the corresponding `.md`. pkgdown does not do this
#' for you because it only touches files in the `doc/` directory.
#'
#' Extra markdown files in the base directory (e.g. `ROADMAP.md`) or in
#' `.github/` (e.g. `CODE_OF_CONDUCT.md`) are copied by `build_home()` to `docs/` and converted to HTML.
#'
#' The home page also features a sidebar with information extracted from the
#' package. You can tweak it via the configuration file, to help make the home
#' page an as informative as possible landing page.
#'
#' ## Images and figures
#'
#' If you want to include images in your `README.md`, they must be stored
#' somewhere in the package so that they can be displayed on the CRAN website.
#' The best place to put them is `man/figures`. If you are generating figures
#' with R Markdown, make sure you set up `fig.path` as followed:
#'
#' ``` r
#' knitr::opts_chunk$set(
#'   fig.path = "man/figures/"
#' )
#' ```
#'
#' This should usually go in a chunk with `include = FALSE`.
#'
#' ```` markdown
#' ```{r chunk-name, include=FALSE}`r ''`
#' knitr::opts_chunk$set(
#'   fig.path = "man/figures/"
#' )
#' ```
#' ````
#'
#' ## Package logo
#'
#' If you have a package logo, you can include it at the top of your README
#' in a level-one heading:
#'
#' ``` markdown
#' # pkgdown <img src="man/figures/logo.png" align="right" />
#' ```
#'
#' [init_site()] will also automatically create a favicon set from your package logo.
#'
#' ## YAML config - title and description
#'
#' By default, the page title and description are extracted automatically from
#' the `Title` and `Description` fields `DESCRIPTION` (stripping single quotes
#' off quoted words). CRAN ensures that these fields don't contain phrases
#' like "R package" because that's obvious on CRAN. To make your package more
#' findable on search engines, it's good practice to override the `title` and
#' `description`, thinking about what people might search for:
#'
#' ```yaml
#' home:
#'   title: An R package for pool-noodle discovery
#'   description: >
#'     Do you love R? Do you love pool-noodles? If so, you might enjoy
#'     using this package to automatically discover and add pool-noodles
#'     to your growing collection.
#' ```
#'
#' (Note the use of YAML's `>` i.e. "YAML pipes"; this is a convenient way of
#' writing paragraphs of text.)
#'
#' ## Dev badges
#'
#' pkgdown identifies badges in three ways:
#'
#' -   Any image-containing links between `<!-- badges: start -->` and
#'     `<!-- badges: end -->`, as e.g. created by `usethis::use_readme_md()`
#'     or `usethis::use_readme_rmd()`. There should always be an empty line after
#'     the `<!-- badges: end -->` line. If you divide badges into paragraphs,
#'     make sure to add an empty line before the `<!-- badges: end -->` line.
#'
#' -   Any image-containing links within `<div id="badges"></div>`.
#'
#' -   Within the first paragraph, if it only contains image-containing links.
#'
#' Identified badges are **removed** from the _main content_.
#' They are shown or not in the _sidebar_ depending on the development mode and
#' sidebar customization, see the sidebar section.
#'
#' # Authors
#'
#' By default, pkgdown will display author information in three places:
#'
#' * the sidebar,
#' * the left part side of the footer,
#' * the author page.
#'
#' This documentation describes how to customise the overall author display.
#' See `?build_home` and `?build_site` for details about changing the location
#' of the authors information within the home sidebar and the site footer.
#'
#' ## Authors ORCID, ROR and bio
#'
#' Author ORCID identification numbers in the `DESCRIPTION` are linked using
#' the ORCID logo,
#' author ROR identification numbers are linked using the ROR logo:
#'
#' ```r
#' Authors@R: c(
#'     person("Hadley", "Wickham", , "hadley@rstudio.com", role = c("aut", "cre"),
#'       comment = c(ORCID = "0000-0003-4757-117X")
#'     ),
#'     person("Jay", "Hesselberth", role = "aut",
#'       comment = c(ORCID = "0000-0002-6299-179X")
#'     ),
#'    person("Posit Software, PBC", role = c("cph", "fnd"),
#'           comment = c(ROR = "03wc8by49"))
#'   )
#' ```
#'
#' If you want to add more details about authors or their involvement with the
#' package, you can use the comment field, which will be rendered on the
#' authors page.
#'
#' ```r
#' Authors@R: c(
#'     person("Hadley", "Wickham", , "hadley@rstudio.com", role = c("aut", "cre"),
#'       comment = c(ORCID = "0000-0003-4757-117X", "Indenter-in-chief")
#'     ),
#'     person("Jay", "Hesselberth", role = "aut",
#'       comment = c(ORCID = "0000-0002-6299-179X")
#'     )
#'   )
#' ```
#'
#' ## Additional control via YAML
#'
#' You can control additional aspects of the authors display via the `authors`
#' YAML field:
#'
#' * display of each author in the footer, sidebar and authors page,
#' * which authors (by role) are displayed in the sidebar and footer,
#' * text before authors in the footer,
#' * text before and after authors in the sidebar,
#' * text before and after authors on the authors page.
#'
#' You can modify how each author's name is displayed by adding a subsection
#' for `authors`. Each entry in `authors` should be named the author's name
#' (matching `DESCRIPTION`) and can contain `href` and/or `html` fields:
#'
#' * If `href` is provided, the author's name will be linked to this URL.
#' * If `html` is provided, it will be shown instead of the author's name.
#'   This is particularly useful if you want to display the logo of a corporate
#'   sponsor. Use an absolute URL to an image, not a relative link. Use an empty
#'   alternative text rather than no alternative text so a screen-reader would
#' skip over it.
#'
#' ```yaml
#' authors:
#'   firstname lastname:
#'     href: "http://name-website.com"
#'     html: "<img src='https://website.com/name-picture.png' width=72 alt=''>"
#' ```
#'
#'
#' By default, the "developers" list shown in the sidebar and footer is
#' populated by the maintainer ("cre"), authors ("aut"), and funder ("fnd")
#' from the `DESCRIPTION`. You could choose other roles for filtering.
#' With the configuration below:
#'
#' * only the maintainer and funder(s) appear in the footer, after the text
#'   "Crafted by",
#' * all authors and contributors appear in the sidebar,
#' * the authors list on the sidebar is preceded and followed by some text,
#' * the authors list on the authors page is preceded and followed by some text.
#'
#'
#' ```yaml
#' authors:
#'   footer:
#'     roles: [cre, fnd]
#'     text: "Crafted by"
#'   sidebar:
#'     roles: [aut, ctb]
#'     before: "So *who* does the work?"
#'     after: "Thanks all!"
#'   before: "This package is proudly brought to you by:"
#'   after: "See the [changelog](news/index.html) for other contributors. :pray:"
#' ```
#'
#' If you want to filter authors based on something else than their roles,
#' consider using a custom sidebar/footer component
#' (see `?build_home`/`?build_site`, respectively).
#'
#' # Sidebar
#'
#' You can customise the homepage sidebar with the `home.sidebar` field.
#' It's made up of two pieces: `structure`, which defines the overall layout,
#' and `components`, which defines what each piece looks like. This organisation
#' makes it easy to mix and match the pkgdown defaults with your own
#' customisations.
#'
#' This is the default structure:
#'
#' ``` yaml
#' home:
#'   sidebar:
#'     structure: [links, license, community, citation, authors, dev]
#' ```
#'
#' These are drawn from seven built-in components:
#'
#' -   `links`: automated links generated from `URL` and `BugReports` fields
#'     from `DESCRIPTION` plus manual links from the `home.links` field:
#'
#'     ``` yaml
#'     home:
#'       links:
#'       - text: Link text
#'         href: https://website.com
#'       - text: Roadmap
#'         href: /roadmap.html
#'     ```
#'
#' -   `license`: Licensing information if `LICENSE`/`LICENCE` or
#'     `LICENSE.md`/`LICENCE.md` files are present.
#'
#' -   `community`: links to to `.github/CONTRIBUTING.md`,
#'     `.github/CODE_OF_CONDUCT.md`, etc.
#'
#' -   `citation`: link to package citation information. Uses either
#'     `inst/CITATION` or, if absent, information from the `DESCRIPTION`.
#'
#' -   `authors`: selected authors from the `DESCRIPTION`.
#'
#' -   `dev`: development status badges extracted from `README.md`/`index.md`.
#'     This is only shown for "development" versions of websites; see
#'     "Development mode" in `?build_site` for details.
#'
#' -   `toc`: a table of contents for the README (not shown by default).
#'
#' You can also add your own components, where `text` is markdown text:
#'
#' ``` yaml
#' home:
#'   sidebar:
#'     structure: [authors, custom, toc, dev]
#'     components:
#'       custom:
#'         title: Funding
#'         text: We are *grateful* for funding!
#' ```
#'
#' Alternatively, you can provide a ready-made sidebar HTML:
#'
#' ``` yaml
#' home:
#'   sidebar:
#'     html: path-to-sidebar.html
#' ```
#'
#' Or completely remove it:
#'
#' ``` yaml
#' home:
#'   sidebar: FALSE
#' ```
#' @inheritParams build_articles
#' @family site components
#' @export
#' @order 1
build_home <- function(pkg = ".",
                       override = list(),
                       preview = FALSE,
                       quiet = TRUE) {

  pkg <- section_init(pkg, override = override)
  check_bool(quiet)

  cli::cli_rule("Building home")

  build_citation_authors(pkg)

  build_home_md(pkg)
  build_home_license(pkg)
  build_home_index(pkg, quiet = quiet)

  if (!pkg$development$in_dev) {
    build_404(pkg)
  }


  preview_site(pkg, "/", preview = preview)
}
