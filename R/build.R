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
#' that aspect of the site. This page documents options that affect the
#' whole site.
#'
#' @section General config:
#' *  `destination` controls where the site will be generated, defaulting to
#'    `docs/`. Paths are relative to the package root.
#'
#' *  `url` is optional, but strongly recommended.
#'
#'    ```yaml
#'    url: https://pkgdown.r-lib.org
#'    ```
#'
#'    It specifies where the site will be published and is used to allow other
#'    pkgdown sites to link to your site when needed (`vignette("linking")`),
#'    generate a `sitemap.xml`, automatically generate a `CNAME` when
#'    [deploying to github][deploy_site_github], generate the metadata needed
#'    rich social "media cards" (`vignette("metadata")`), and more.
#'
#' *  `title` overrides the default site title, which is the package name.
#'    It's used in the page title and default navbar.
#'
#' @section Development mode:
#' The `development` field allows you to generate different sites for the
#' development and released versions of your package. To use it, you first
#' need to set the development `mode`:
#'
#' ```yaml
#' development:
#'   mode: auto
#' ```
#'
#' ### Setting development mode
#'
#' The development `mode` of a site controls where the site is built,
#' the colour of the package version in the navbar, the version tooltip,
#' and whether or not the site is indexed by search engines. There are
#' four possible modes:
#'
#' * **automatic** (`mode: auto`): automatically determines the mode based on the
#'   version number:
#'
#'   * `0.0.0.9000` (`0.0.0.*`): unreleased.
#'   * four version components: development.
#'   * everything else -> release.
#'
#' * **release** (`mode: release`), the default. Site is written to `docs/`.
#'   Version in navbar gets the default colouring. Development badges are
#'   not shown in the sidebar (see `?build_home`).
#'
#' * **development** (`mode: devel`). Site is written to `docs/dev/`.
#'   The navbar version gets a "danger" class and a tooltip stating these are
#'   docs for an in-development version of the package. The `noindex` meta tag
#'   is used to ensure that these packages are not indexed by search engines.
#'   Development badges are shown in the sidebar (see `?build_home`).
#'
#' * **unreleased** (`mode: unreleased`). Site is written to `docs/`.
#'   Version in navbar gets the "danger" class, and a message indicating the
#'   package is not yet on CRAN.
#'   Development badges are shown in the sidebar (see `?build_home`).
#'
#' You can override the mode specified in the `_pkgdown.yml` by setting
#' by setting `PKGDOWN_DEV_MODE` to `devel` or `release`.
#'
#' ### Selective HTML
#'
#' You can selectively show HTML only on the devel or release site by adding
#' class `pkgdown-devel` or `pkgdown-release`. This is most easily accessed
#' from `.Rmd` files where you can use pandoc's `<div>` syntax to control
#' where a block of markdown will display. For example, you can use the
#' following markdown in your README to only show GitHub install instructions
#' on the development version of your site:
#'
#' ```md
#' ::: {.pkgdown-devel}
#' You can install the development version of pkgdown from GitHub with:
#' `remotes::install_github("r-lib/pkgdown")`
#' :::
#' ```
#'
#' You can use a similar technique to control where badges are displayed.
#' This markdown show the CRAN status badge on the site for the released
#' package and the GitHub check status for the development package:
#'
#' ```md
#' [![CRAN Status](https://www.r-pkg.org/badges/version/pkgdown)]
#'   (https://cran.r-project.org/package=pkgdown){.pkgdown-release}
#' [![R-CMD-check](https://github.com/r-lib/pkgdown/workflows/R-CMD-check/badge.svg)]
#'   (https://github.com/r-lib/pkgdown/actions){.pkgdown-devel}
#' ```
#'
#' ### Other options
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
#' ## Page layout
#'
#' The `navbar`, `footer`, and `sidebar` fields control the appearance
#' of the navbar, footer, and sidebar respectively. They have many individual
#' options which are documented in the **Layout** section of
#' `vignette("customise")`.
#'
#' @section Search:
#' The `search` field controls the built-in search and is
#' documented in `vignette("search")`.
#'
#' @section Template:
#' The `template` field is mostly used to control the appearance of the site.
#' See `vignette("customise")` for details.
#'
#' There are two other `template` fields that control other aspects of the
#' site:
#'
#' *   `noindex: true` will suppress indexing of your pages by search engines:
#'
#'     ```yaml
#'     template:
#'       params:
#'         noindex: true
#'     ```
#'
#' * `google_site_verification` allows you to verify your site with google:
#'
#'      ```yaml
#'      template:
#'        params:
#'          google_site_verification: _nn6ile-a6x6lctOW
#'      ```
#'
#' *   `trailing_slash_redirect: true` will automatically redirect
#'     `your-package-url.com` to `your-package-url.com/`, using a JS script
#'      added to the `<head>` of the home page. This is useful in certain
#'      redirect scenarios.
#'
#'      ```yaml
#'      template:
#'        trailing_slash_redirect: true
#'      ```
#'
#' @section Analytics:
#'
#' To capture usage of your site with a web analytics platform, you can make
#' use of the `includes` field to add the HTML supplied to you by the platform.
#' Typically these are either placed `after_body` or `in_header`. I include
#' a few examples below, but I highly recommend getting the recommended HTML
#' directly from the platform.
#'
#' *   [GoatCounter](https://www.goatcounter.com):
#'
#'     ```yaml
#'     template:
#'       includes:
#'         after_body: >
#'           <script data-goatcounter="https://{YOUR CODE}.goatcounter.com/count" data-goatcounter-settings="{YOUR SETTINGS}" async src="https://gc.zgo.at/count.js"></script>
#'     ```
#'
#' *   [Google analytics](https://analytics.google.com/analytics/web/):
#'
#'     ```yaml
#'     template:
#'       includes:
#'         in_header: |
#'            <!-- Global site tag (gtag.js) - Google Analytics -->
#'            <script async src="https://www.googletagmanager.com/gtag/js?id={YOUR TRACKING ID}"#' ></script>
#'            <script>
#'              window.dataLayer = window.dataLayer || [];
#'              function gtag(){dataLayer.push(arguments);}
#'              gtag('js', new Date());
#'
#'              gtag('config', '{YOUR TRACKING ID}');
#'            </script>
#'     ```
#'
#' *   [plausible.io](https://plausible.io):
#'
#'     ```yaml
#'     templates:
#'       includes:
#'         in_header: |
#'           <script defer data-domain="{YOUR DOMAIN}" src="https://plausible.io/js/plausible.js"></script>
#'     ```
#'
#' @section Source repository:
#' Use the `repo` field to override pkgdown's automatically discovery
#' of your source repository. This is used in the navbar, on the homepage,
#' in articles and reference topics, and in the changelog (to link to issue
#' numbers and user names). pkgdown can automatically figure out the necessary
#' URLs if you link to a GitHub or GitLab repo in your `BugReports` or `URL`
#' field.
#'
#' Otherwise, you can supply your own in the `repo` field:
#'
#' ```yaml
#' repo:
#'   url:
#'     home: https://github.com/r-lib/pkgdown/
#'     source: https://github.com/r-lib/pkgdown/blob/HEAD/
#'     issue: https://github.com/r-lib/pkgdown/issues/
#'     user: https://github.com/
#' ```
#'
#' * `home`: path to package home on source code repository.
#' * `source:`: path to source of individual file in default branch.
#' * `issue`: path to individual issue.
#' * `user`: path to user.
#'
#' The varying components (e.g. path, issue number, user name) are pasted on
#' the end of these URLs so they should have trailing `/`s.
#'
#' pkgdown can automatically link to Jira issues as well if specify both a
#' custom `issue` URL as well Jira project names to auto-link in
#' `jira_projects`. You can specify as many projects as you would like:
#'
#' ```yaml
#' repo:
#'   jira_projects: [this_project, another_project]
#'   url:
#'     issue: https://jira.organisation.com/jira/browse/
#' ```
#'
#' pkgdown defaults to using the "HEAD" branch for source file URLs. This can
#' be configured to use a specific branch when linking to source files by
#' specifying a branch name:
#'
#' ```yaml
#' repo:
#'   branch: devel
#' ````
#'
#' @section Deployment (`deploy`):
#' There is a single `deploy` field
#'
#' *  `install_metadata` allows you to install package index metadata into
#'    the package itself. Normally this metadata is made available on the
#'    published site; installing it into your package means that it's
#'    available for autolinking even if your website is not reachable at build
#'    time (e.g. because behind a firewall or requires auth).
#'
#'    ```yaml
#'    deploy:
#'      install_metadata: true
#'    ```
#'
#' @section Redirects:
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

  if (document != "DEPRECATED") {
    lifecycle::deprecate_warn(
      "1.4.0",
      "build_site(document)",
      details = "build_site(devel)"
    )
    devel <- document
  }

  if (install) {
    withr::local_temp_libpaths()
    cli::cli_rule("Installing package {.pkg {pkg$package}} into temporary library")
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
    cli_colors = cli::num_ansi_colors(),
    pkgdown_internet = has_internet()
  )
  callr::r(
    function(..., cli_colors, pkgdown_internet) {
      options(
        cli.num_colors = cli_colors,
        crayon.colors = cli_colors, # backward compatibility
        pkgdown.internet = pkgdown_internet
      )
      pkgdown::build_site(...)
    },
    args = args,
    show = TRUE,
    timeout = getOption('pkgdown.timeout', Inf)
  )

  cli::cli_rule("Finished building pkgdown site for package {.pkg {pkg$package}}")

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
                             devel = TRUE) {

  pkg <- section_init(pkg, depth = 0, override = override)

  cli::cli_rule("Building pkgdown site for package {.pkg {pkg$package}}")
  cli::cli_inform("Reading from: {src_path(path_abs(pkg$src_path))}")
  cli::cli_inform("Writing to:   {dst_path(path_abs(pkg$dst_path))}")

  init_site(pkg)

  build_home(pkg, override = override, preview = FALSE)
  build_reference(
    pkg,
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

  cli::cli_rule("Finished building pkgdown site for package {.pkg {pkg$package}}")
  preview_site(pkg, preview = preview)
}
