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
#' There are five top-level YAML settings that affect the entire site:
#' `destination`, `url`, `title`, `template`, and `navbar`.
#'
#' `destination` controls where the site will be generated. It defaults to
#' `docs/` (for GitHub pages), but you can override if desired. Relative
#' paths will be taken relative to the package root.
#'
#' `url` is optional, but strongly recommended.
#' It specifies where the site will be published and is used to:
#' * Allow other pkgdown sites to link to your site when needed,
#'   rather than using generic links to <https://rdrr.io>.
#'   See `vignette("linking")` for more information.
#' * Generate a `sitemap.xml`, increasing the searchability of your site.
#' * Automatically generate a `CNAME` when
#'   [deploying to github][deploy_site_github].
#' * Generate metadata used by Twitter and the Open Graph protocol
#'   for rich social media cards, see `vignette("metadata")`.
#' * Adds the "external-link" class to external links
#'   for sites using BS4, see `vignette("customise")`.
#'
#' ```yaml
#' url: https://pkgdown.r-lib.org
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
#' ```yaml
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
#' You can override the default development mode by adding a
#' new `development` field to `_pkgdown.yml`, e.g.
#'
#' ```yaml
#' development:
#'   mode: devel
#' ```
#'
#' There are currently four possible modes:
#'
#' * **release** (`mode: release`), the default. Site is written to `docs/`.
#'   Version in navbar gets the default colouring.
#'
#' * **development** (`mode: devel`). Site is written to `docs/dev/`.
#'   Version in navbar gets the "danger" class and a message stating these are
#'   docs for an in-development version of the package. The `noindex` meta tag
#'   is used to ensure that these packages are not indexed by search engines.
#'
#' * **unreleased** (`mode: unreleased`). Site is written to `docs/`.
#'   Version in navbar gets the "danger" class, and a message indicating the
#'   package is not yet on CRAN.
#'
#' * **automatic** (`mode: auto`): pkgdown automatically detects the mode
#'   based on the version number:
#'
#'   * `0.0.0.9000` (`0.0.0.*`): unreleased.
#'   * four version components: development.
#'   * everything else -> release.
#'
#' There are three other options that you can control:
#'
#' ```yaml
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
#' ```{r child="man/rmd-fragments/navbar-configuration.Rmd"}
#' ```
#' @section YAML config - search:
#' See `vignette("search")`
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
#' ```yaml
#' template:
#'   bootswatch: cerulean
#' ```
#'
#' See `vignette("customise")` for details.
#'
#' Optionally provide the `ganalytics` template parameter to enable
#' [Google Analytics](https://marketingplatform.google.com/about/analytics/).
#' It should correspond to your
#' [tracking id](https://support.google.com/analytics/answer/1008080).
#'
#' When enabling Google Analytics, be aware of the type and amount of
#' user information that you are collecting. You may wish to limit the
#' extent of data collection or to add a privacy disclosure to your
#' site, in keeping with current laws and regulations.
#'
#' ```yaml
#' template:
#'   params:
#'     ganalytics: UA-000000-01
#' ```
#'
#' Suppress indexing of your pages by web robots by setting `noindex:
#' true`:
#'
#' ```yaml
#' template:
#'   params:
#'     noindex: true
#' ```
#'
#' You can also override the default templates and provide additional
#' assets. You can do so by either storing them in the
#' directories `pkgdown/assets` and `pkgdown/templates`,
#' or by supplying `path` and `asset_path` pointing to alternative folders.
#' To suppress inclusion
#' of the default assets, set `default_assets` to false.
#'
#' ```yaml
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
#' For further information including how to provide templates and assets in
#' a separate package, see `vignette("customise")`c.
#'
#' You can use the `trailing_slash_redirect` to automatically redirect
#' `your-package-url.com` to `your-package-url.com/`, using a JS script
#'  added to the `<head>` of the home page.
#'
#' ```yaml
#' template:
#'   trailing_slash_redirect: true
#' ```
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
#' pkgdown can automatically link to Jira issues as well, but you must specify
#' both a custom `issue` URL as well as your Jira project names to auto-link in
#' `jira_projects`. You can specify as many projects as you would like in a last
#' (in the example below we would link both the `PROJ` and `OTHER` Jira
#' projects):
#'
#' ```yaml
#' repo:
#'   jira_projects: [PROJ, OTHER]
#'   url:
#'     issue: https://jira.organisation.com/jira/browse/
#' ```
#'
#' pkgdown defaults to using the "master" branch for source file URLs. This can
#' be configured to use a specific branch when linking to source files by
#' specifying a branch name:
#'
#' ```yaml
#' repo:
#'   branch: main
#' ````
#'
#' @section YAML config - deploy:
#' `deploy` currently offers a single parameter:
#'
#' *  `install_metadata` allows you to install package index metadata into
#'    the package itself. Normally this metadata is made available on the
#'    published site; installing it into your package means that it's
#'    available for autolinking even if your website is not reachable at build
#'    time (e.g. because it's only behind the firewall or requires auth).
#'
#'    ```yaml
#'    deploy:
#'      install_metadata: true
#'    ```
#' @section YAML config - footer:
#' ```{r child="man/rmd-fragments/footer-configuration.Rmd"}
#' ```
#' @section YAML config - redirects:
#' ```{r child="man/rmd-fragments/redirects-configuration.Rmd"}
#' ```
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
    # Keep source, so that e.g. pillar can show the source code
    # of its functions in its articles
    withr::with_options(
      list(keep.source.pkgs = TRUE, keep.parse.data.pkgs = TRUE),
      utils::install.packages(pkg$src_path, repos = NULL, type = "source", quiet = TRUE)
    )
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

  rule("Building pkgdown site", line = "=")
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
  build_sitemap(pkg)
  build_redirects(pkg, override = override)
  if (pkg$bs_version == 3) {
    build_docsearch_json(pkg)
  } else {
    build_search(pkg, override = override)
  }

  rule("DONE", line = "=")
  preview_site(pkg, preview = preview)
}