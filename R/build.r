#' Build pkgdown website
#'
#' @description
#' `build_site()` is a convenient wrapper around six functions:
#'
#' * [init_site()]
#' * [build_home()]
#' * [build_reference()]
#' * [build_articles()]
#' * [build_tutorials()]
#' * [build_news()]
#'
#' See the documentation for the each function to learn how to control
#' that aspect of the site.
#'
#' Note if names of generated files were changed, you will need to use
#' [clean_site] first to clean up orphan files.
#'
#' @section YAML config:
#' There are four top-level YAML settings that affect the entire site:
#' `destination`, `url`, `title`, `template`, and `navbar`.
#'
#' `destination` controls where the site will be generated. It defaults to
#' `docs/` (for GitHub pages), but you can override if desired. Relative
#' paths will be taken relative to the package root.
#'
#' `url` optionally specifies the url where the site will be published.
#' If you supply this, other pkgdown sites will link to your site when needed,
#' rather than using generic links to \url{rdocumentation.org}.
#'
#' `title` overrides the default site title, which is the package name.
#' It's used in the page title and default navbar.
#'
#' You can also provided information to override the default display of
#' the authors. Provided a list named with the name of each author,
#' including `href` to add a link, or `html` to override the
#' text:
#'
#' ```
#' authors:
#'   Hadley Wickham:
#'     href: http://hadley.nz
#'   RStudio:
#'     href: https://www.rstudio.com
#'     html: <img src="http://tidyverse.org/rstudio-logo.svg" height="24" />
#' ```
#'
#' @section Development mode:
#' The development mode of a site controls four main things:
#'
#' * Where the site is built.
#' * The colour of the package version in the navbar.
#' * The optional tooltip associated with the version.
#' * The indexing of the site by search engines.
#'
#' There are currently three possible development modes:
#'
#' * **release**: site written to `docs/`, the version gets the default
#'   colouring, and no message.
#'
#' * **development**: written to `docs/dev/`, the version gets a danger label,
#'   and message stating these are docs for an in-development version of the
#'   package. The `noindex` meta tag is used to ensure that these packages are
#'   not indexed by search engines.
#'
#' * **unreleased**: the package is written to `docs/`, the version gets a "danger"
#'   label, and the message indicates the package is not yet on CRAN.
#'
#' The default development mode is "release". You can override it by adding a
#' new `development` field to `_pkgdown.yml`, e.g.
#'
#' ```
#' development:
#'   mode: development
#' ```
#'
#' You can also have pkgdown automatically detect the mode with:
#'
#' ```
#' development:
#'   mode: auto
#' ```
#'
#' The mode will be automatically determined based on the version number:
#'
#' * `0.0.0.9000`: unreleased
#' * four version components: development
#' * everything else -> release
#'
#' There are three other options that you can control:
#'
#' ```
#' development:
#'   destination: dev
#'   version_label: danger
#'   version_tooltip: "Custom message here"
#' ```
#'
#' `destination` allows you to override the default subdirectory used for the
#' development site; it defaults to `dev/`. `version_label` allows you to
#' override the style used for development (and unreleased) versions of the
#' package. It defaults to "danger", but you can set to "default", "info", or
#' "warning" instead. (The precise colours are determined by your bootstrap
#' theme, but become progressively more eye catching as you go from default
#' to danger). Finally, you can choose to override the default tooltip with
#' `version_tooltip`.
#'
#' @section YAML config - navbar:
#' `navbar` controls the navbar at the top of the page. It has two primary
#' components: `structure` and `components`. These components interact in
#' a somewhat complicated way, but the complexity allows you to make minor
#' tweaks to part of the navbar while relying on pkgdown to automatically
#' generate the rest.
#'
#' The `structure` defines the layout of the navbar, i.e. the order
#' of the components, and whether they're right aligned or left aligned.
#' You can use this component to change the order of the default components,
#' and to add your own components.
#'
#' ```
#' navbar:
#'   structure:
#'     left:  [home, intro, reference, articles, tutorials, news]
#'     right: [github]
#' ````
#'
#' The `components` describes the appearance of each element in the navbar.
#' It uses the same
#' syntax as \href{http://rmarkdown.rstudio.com/rmarkdown_websites.html#site_navigation}{RMarkdown}.
#' The following YAML snippet illustrates some of the most important features.
#'
#' ```
#' components:
#'   home: ~
#'   articles:
#'     text: Articles
#'     menu:
#'     - text: Category A
#'     - text: Title A1
#'       href: articles/a1.html
#'     - text: Title A2
#'       href: articles/a2.html
#'     - text: -------
#'     - text: "Category B"
#'     - text: Title B1
#'       href: articles/b1.html
#'    twitter:
#'      icon: fa-lg fa-twitter
#'      href: http://twitter.com/hadleywickham
#' ```
#'
#' Components can contain sub-`menu`s with headings (indicated by missing
#' `href`) and separators (indiciated by a bunch of `-`). You can use `icon`s
#' from fontawesome: see a full list <http://fontawesome.io/icons/>.
#'
#' This yaml would override the default "articles" component, eliminate
#' the "home" component, and add a new "twitter" component. Unless you
#' explicitly mention new components in the `structure` they'll be added
#' to the far right of the left menu.
#'
#' @section YAML config - search:
#' You can use [docsearch](https://community.algolia.com/docsearch/) by algolia
#' to add search to your site.
#'
#' ```
#' template:
#'   params:
#'     docsearch:
#'       api_key: API_KEY
#'       index_name: INDEX_NAME
#' ```
#'
#' You also need to add a `url:` field to `_pkgdown.yml` that specifies the
#' location of your documentation on the web. For pkgdown, the URL field is:
#'
#' ```yaml
#' url: http://pkgdown.r-lib.org
#' ```
#'
#' See `vignette("pkgdown")` for details.
#'
#' @section YAML config - template:
#' You can get complete control over the appearance of the site using the
#' `template` component. There are two components to the template:
#' the HTML templates used to layout each page, and the css/js assets
#' used to render the page in the browser.
#'
#' The easiest way to tweak the default style is to use a bootswatch template,
#' by passing on the `bootswatch` template parameter to the built-in
#' template:
#'
#' ```
#' template:
#'   params:
#'     bootswatch: cerulean
#' ```
#'
#' See a complete list of themes and preview how they look at
#' \url{https://gallery.shinyapps.io/117-shinythemes/}:
#'
#' Optionally provide the `ganalytics` template parameter to enable
#' [Google Analytics](https://www.google.com/analytics/). It should
#' correspond to your
#' [tracking id](https://support.google.com/analytics/answer/1032385).
#'
#' ```
#' template:
#'   params:
#'     ganalytics: UA-000000-01
#' ```
#'
#' You can also override the default templates and provide additional
#' assets. You can do so by either storing in a `package` with
#' directories `inst/pkgdown/assets` and `inst/pkgdown/templates`,
#' or by supplying `path` and `asset_path`. To suppress inclusion
#' of the default assets, set `default_assets` to false.
#'
#' ```
#' template:
#'   package: mycustompackage
#'
#' # OR:
#'
#' template:
#'   path: path/to/templates
#'   assets: path/to/assets
#'   default_assets: false
#' ```
#'
#' These settings are currently recommended for advanced users only. There
#' is little documentation, and you'll need to read the existing source
#' for pkgdown templates to ensure that you use the correct components.
#'
#' @inheritParams build_articles
#' @inheritParams build_reference
#' @param lazy If `TRUE`, will only rebuild articles and reference pages
#'   if the source is newer than the destination.
#' @export
#' @examples
#' \dontrun{
#' build_site()
#'
#' build_site(override = list(destination = tempdir()))
#' }
build_site <- function(pkg = ".",
                       examples = TRUE,
                       run_dont_run = FALSE,
                       seed = 1014,
                       mathjax = TRUE,
                       lazy = FALSE,
                       override = list(),
                       preview = NA
                       ) {

  pkg <- section_init(pkg, depth = 0, override = override)

  rule("Building pkgdown site", line = 2)
  cat_line("Reading from: ", src_path(path_abs(pkg$src_path)))
  cat_line("Writing to:   ", dst_path(path_abs(pkg$dst_path)))

  init_site(pkg)

  build_home(pkg, override = override, preview = FALSE)
  build_reference(pkg,
    lazy = lazy,
    examples = examples,
    run_dont_run = run_dont_run,
    mathjax = mathjax,
    seed = seed,
    override = override,
    preview = FALSE
  )
  build_articles(pkg, lazy = lazy, override = override, preview = FALSE)
  build_tutorials(pkg, override = override, preview = FALSE)
  build_news(pkg, override = override, preview = FALSE)

  preview_site(pkg, preview = preview)
  rule("DONE", line = 2)
}

build_site_rstudio <- function(pkg = ".") {
  devtools::document()
  callr::r(
    function(...) pkgdown::build_site(...),
    args = list(pkg = pkg),
    show = TRUE
  )
  preview_site(pkg)
  invisible()
}
