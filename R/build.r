#' Build a complete pkgdown website
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
#' [clean_site()] first to clean up orphan files.
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
#' Supplying this will:
#' * Allow other pkgdown sites to link to your site when needed,
#'   rather than using generic links to <https://rdrr.io>.
#' * Generate a `sitemap.xml`, increasing the searchability of your site.
#' * Automatically generate a `CNAME` when
#'   [deploying to github][deploy_site_github].
#'
#' ```yaml
#' url: http://pkgdown.r-lib.org
#' ```
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
#'     html: <img src="https://www.tidyverse.org/rstudio-logo.svg" height="24" />
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
#'   mode: devel
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
#' * `0.0.0.9000` (`0.0.0.*`): unreleased
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
#'
#' By default, the top navigation bar (the "navbar") will contain links to:
#'
#' * The home page, with a "home" icon.
#' * "Get Started", if you have an article with the same name as the package
#'   (e.g., `vignettes/pkgdown.Rmd`).
#' * Reference
#' * Articles (i.e., vignettes, if present).
#' * News (if present).
#' * A "github" icon with a link to your
#'   github repo (if listed in the `DESCRIPTION` url field).
#'
#' You can override these defaults with the  `navbar` field. It has two primary
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
#' syntax as [RMarkdown](http://rmarkdown.rstudio.com/rmarkdown_websites.html#site_navigation).
#' The following YAML snippet illustrates some of the most important features.
#'
#' ```
#' navbar:
#'   components:
#'     home: ~
#'     articles:
#'      text: Articles
#'      menu:
#'      - text: Category A
#'      - text: Title A1
#'        href: articles/a1.html
#'      - text: Title A2
#'        href: articles/a2.html
#'      - text: -------
#'      - text: "Category B"
#'      - text: Title B1
#'        menu:
#'        - text "Sub-category B11"
#'          href: articles/b11.html
#'      twitter:
#'        icon: "fab fa-twitter fa-lg"
#'        href: http://twitter.com/hadleywickham
#' ```
#'
#' Components can contain sub-`menu`s with headings (indicated by missing
#' `href`) and separators (indicated by a bunch of `-`). You can also use `icon`s
#' from [fontawesome](https://fontawesome.com/icons?d=gallery).
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
#' You also need to add a `url:` field, see above.
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
#' <https://gallery.shinyapps.io/117-shinythemes/>:
#'
#' Optionally provide the `ganalytics` template parameter to enable
#' [Google Analytics](https://www.google.com/analytics/). It should
#' correspond to your
#' [tracking id](https://support.google.com/analytics/answer/1032385).
#'
#' When enabling Google Analytics, be aware of the type and amount of
#' user information that you are collecting. You may wish to limit the
#' extent of data collection or to add a privacy disclosure to your
#' site, in keeping with current laws and regulations.
#'
#' ```
#' template:
#'   params:
#'     ganalytics: UA-000000-01
#' ```
#'
#' Suppress indexing of your pages by web robots by setting `noindex:
#' true`:
#'
#' ```
#' template:
#'   params:
#'     noindex: true
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
#' @section YAML config - repo:
#' pkgdown automatically generates links to the source repository in a few
#' places
#'
#' * Articles and documentation topics are linked back to the
#'   underlying source file.
#'
#' * The NEWS automatically links issue numbers and user names.
#'
#' * The homepage provides a link to  "Browse source code"
#'
#' pkgdown automatically figures out the necessary URLs if you link to a GitHub
#' or GitLab repo in your `BugReports` or `URL` field. Otherwise, you can
#' supply your own in the `repo` component:
#'
#' ```yaml
#' repo:
#'   url:
#'     home: https://github.com/r-lib/pkgdown/
#'     source: https://github.com/r-lib/pkgdown/blob/master/
#'     issue: https://github.com/r-lib/pkgdown/issues/
#'     user: https://github.com/
#' ```
#'
#' * `home`: path to package home on source code repository.
#' * `source:`: path to source of individual file in master branch.
#' * `issue`: path to individual issue.
#' * `user`: path to user.
#'
#' The varying components (e.g. path, issue number, user name) are pasted on
#' the end of these URLs so they should have trailing `/`s.
#'
#' @section Options:
#' Users with limited internet connectivity can disable CRAN checks by setting
#' `options(pkgdown.internet = FALSE)`. This will also disable some features
#' from pkgdown that requires an internet connectivity. However, if it is used
#' to build docs for a package that requires internet connectivity in examples
#' or vignettes, this connection is required as this option won't apply on them.
#'
#' Users can set a timeout for `build_site(new_process = TRUE)` with
#' `options(pkgdown.timeout = Inf)`, which is useful to prevent stalled builds from
#' hanging in cron jobs.
#'
#' @inheritParams build_articles
#' @inheritParams build_reference
#' @param lazy If `TRUE`, will only rebuild articles and reference pages
#'   if the source is newer than the destination.
#' @param devel Use development or deployment process?
#'
#'   If `TRUE`, uses lighter-weight process suitable for rapid
#'   iteration; it will run examples and vignettes in the current process,
#'   and will load code with `pkgload::load_all()`.
#'
#'   If `FALSE`, will first install the package to a temporary library,
#'   and will run all examples and vignettes in a new process.
#'
#'   `build_site()` defaults to `devel = FALSE` so that you get high fidelity
#'   outputs when you building the complete site; `build_reference()`,
#'   `build_home()` and friends default to `devel = TRUE` so that you can
#'   rapidly iterate during development.
#' @param new_process If `TRUE`, will run `build_site()` in a separate process.
#'   This enhances reproducibility by ensuring nothing that you have loaded
#'   in the current process affects the build process.
#' @param install If `TRUE`, will install the package in a temporary library
#'   so it is available for vignettes.
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
                       lazy = FALSE,
                       override = list(),
                       preview = NA,
                       devel = FALSE,
                       new_process = !devel,
                       install = !devel,
                       document = "DEPRECATED") {
  pkg <- as_pkgdown(pkg, override = override)

  if (!missing(document)) {
    warning("`document` is deprecated. Please use `devel` instead.", call. = FALSE)
    devel <- document
  }

  if (install) {
    withr::local_temp_libpaths()
    rule("Installing package into temporary library")
    utils::install.packages(pkg$src_path, repos = NULL, type = "source", quiet = TRUE)
  }

  if (new_process) {
    build_site_external(
      pkg = pkg,
      examples = examples,
      run_dont_run = run_dont_run,
      seed = seed,
      lazy = lazy,
      override = override,
      preview = preview,
      devel = devel
    )
  } else {
    build_site_local(
      pkg = pkg,
      examples = examples,
      run_dont_run = run_dont_run,
      seed = seed,
      lazy = lazy,
      override = override,
      preview = preview,
      devel = devel
    )
  }
}

build_site_external <- function(pkg = ".",
                                examples = TRUE,
                                run_dont_run = FALSE,
                                seed = 1014,
                                lazy = FALSE,
                                override = list(),
                                preview = NA,
                                devel = TRUE) {
  args <- list(
    pkg = pkg,
    examples = examples,
    run_dont_run = run_dont_run,
    seed = seed,
    lazy = lazy,
    override = override,
    install = FALSE,
    preview = FALSE,
    new_process = FALSE,
    devel = devel,
    crayon_enabled = crayon::has_color(),
    crayon_colors = crayon::num_colors(),
    pkgdown_internet = has_internet()
  )
  callr::r(
    function(..., crayon_enabled, crayon_colors, pkgdown_internet) {
      options(
        crayon.enabled = crayon_enabled,
        crayon.colors = crayon_colors,
        pkgdown.internet = pkgdown_internet
      )
      pkgdown::build_site(...)
    },
    args = args,
    show = TRUE,
    timeout = getOption('pkgdown.timeout', Inf)
  )

  preview_site(pkg, preview = preview)
  invisible()
}

build_site_local <- function(pkg = ".",
                       examples = TRUE,
                       run_dont_run = FALSE,
                       seed = 1014,
                       lazy = FALSE,
                       override = list(),
                       preview = NA,
                       devel = TRUE
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
    seed = seed,
    override = override,
    preview = FALSE,
    devel = devel
  )
  build_articles(pkg, lazy = lazy, override = override, preview = FALSE)
  build_tutorials(pkg, override = override, preview = FALSE)
  build_news(pkg, override = override, preview = FALSE)

  rule("DONE", line = 2)
  preview_site(pkg, preview = preview)
}
