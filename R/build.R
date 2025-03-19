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
#' * [build_redirects()]
#'
#' See the documentation for the each function to learn how to control
#' that aspect of the site. This page documents options that affect the
#' whole site.
#'
#' # General config
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
#'    [deploying to github][build_site_github_pages()], generate the metadata needed
#'    rich social "media cards" (`vignette("metadata")`), and more.
#'
#' *  `title` overrides the default site title, which is the package name.
#'    It's used in the page title and default navbar.
#'
#' # Navbar and footer
#'
#' The `navbar` and `footer` fields control the appearance of the navbar
#' footer which appear on every page. Learn more about these fields in
#' `vignette("customise")`.
#'
#' # Development mode
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
#' The development `mode` of a site controls where the built site is placed
#' and how it is styled (i.e. the colour of the package version in the
#' navbar, the version tooltip), and whether or not the site is indexed by
#' search engines. There are four possible modes:
#'
#' * **automatic** (`mode: auto`): determines the mode based on the version:
#'
#'   * `0.0.0.9000` (`0.0.0.*`): unreleased.
#'   * four version components: development.
#'   * everything else -> release.
#'
#' * **release** (`mode: release`), the default. Site is written to `docs/`
#'   and styled like a released package, even if the content is for an
#'   unreleased or development version. Version in navbar gets the default
#'   colouring. Development badges are not shown in the sidebar
#'   (see `?build_home`).
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
#' Use `mode: auto` if you want both a released and a dev site, and
#' `mode: release` if you just want a single site. It is very rare that you
#' will need either devel or unreleased modes.
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
#' # Template
#' The `template` field is mostly used to control the appearance of the site.
#' See `vignette("customise")` for details. But it's also used to control
#'
#' ## Other aspects
#'
#' There are a few other `template` fields that control other aspects of the
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
#' ## Analytics
#'
#' To capture usage of your site with a web analytics tool, you can make
#' use of the `includes` field to add the special HTML they need. This HTML
#' is typically placed `in_header` (actually in the `<head>`), `before_body`,
#' or `after_body`.
#' You can learn more about how includes work in pkgdown at
#' <https://pkgdown.r-lib.org/articles/customise.html#additional-html-and-files>.
#'
#' I include a few examples of popular analytics platforms below, but we
#' recommend getting the HTML directly from the tool:
#'
#' *   [plausible.io](https://plausible.io):
#'
#'     ```yaml
#'     template:
#'       includes:
#'         in_header: |
#'           <script defer data-domain="{YOUR DOMAIN}" src="https://plausible.io/js/plausible.js"></script>
#'     ```
#'
#' *   [Google analytics](https://analytics.google.com/analytics/web/):
#'
#'     ```yaml
#'     template:
#'       includes:
#'         in_header: |
#'            <!-- Global site tag (gtag.js) - Google Analytics -->
#'            <script async src="https://www.googletagmanager.com/gtag/js?id={YOUR MEASUREMENT ID}" ></script>
#'            <script>
#'              window.dataLayer = window.dataLayer || [];
#'              function gtag(){dataLayer.push(arguments);}
#'              gtag('js', new Date());
#'
#'              gtag('config', '{YOUR MEASUREMENT ID}');
#'            </script>
#'            <!-- Google tag (gtag.js) -->
#'     ```
#' *   [GoatCounter](https://www.goatcounter.com):
#'
#'     ```yaml
#'     template:
#'       includes:
#'         after_body: >
#'           <script data-goatcounter="https://{YOUR CODE}.goatcounter.com/count" data-goatcounter-settings="{YOUR SETTINGS}" async src="https://gc.zgo.at/count.js"></script>
#'     ```
#'
#' # Source repository
#'
#' Use the `repo` field to override pkgdown's automatically discovery
#' of your source repository. This is used in the navbar, on the homepage,
#' in articles and reference topics, and in the changelog (to link to issue
#' numbers and user names). pkgdown can automatically figure out the necessary
#' URLs if you link to a GitHub, GitLab or Codeberg repo in your `BugReports`
#' or `URL` field.
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
#' * `source`: path to source of individual file in default branch
#'   (more on that below).
#' * `issue`: path to individual issue.
#' * `user`: path to user.
#'
#' The varying components (e.g. path, issue number, user name) are pasted on
#' the end of these URLs so they should have trailing `/`s.
#'
#' When creating the link to a package source, we have to link to a specific
#' branch. The default behaviour is to use current branch when in GitHub
#' actions and `HEAD` otherwise. You can overide this default with
#' `repo.branch`:
#'
#' ```yaml
#' repo:
#'   branch: devel
#' ```
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
#' # Deployment (`deploy`)
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
build_site <- function(
  pkg = ".",
  examples = TRUE,
  run_dont_run = FALSE,
  seed = 1014L,
  lazy = FALSE,
  override = list(),
  preview = NA,
  devel = FALSE,
  new_process = !devel,
  install = !devel
) {
  pkg <- as_pkgdown(pkg, override = override)
  check_bool(devel)
  check_bool(new_process)
  check_bool(install)

  if (install) {
    withr::local_temp_libpaths()
    cli::cli_rule(
      "Installing package {.pkg {pkg$package}} into temporary library"
    )
    # Keep source, so that e.g. pillar can show the source code
    # of its functions in its articles
    withr::with_options(
      list(keep.source.pkgs = TRUE, keep.parse.data.pkgs = TRUE),
      utils::install.packages(
        pkg$src_path,
        repos = NULL,
        type = "source",
        quiet = TRUE
      )
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

build_site_external <- function(
  pkg = ".",
  examples = TRUE,
  run_dont_run = FALSE,
  seed = 1014L,
  lazy = FALSE,
  override = list(),
  preview = NA,
  devel = TRUE
) {
  pkg <- as_pkgdown(pkg, override = override)
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
    hyperlinks = cli::ansi_has_hyperlink_support()
  )
  callr::r(
    function(..., cli_colors, hyperlinks) {
      options(
        cli.num_colors = cli_colors,
        cli.hyperlink = hyperlinks,
        cli.hyperlink_run = hyperlinks
      )
      pkgdown::build_site(...)
    },
    args = args,
    show = TRUE
  )

  cli::cli_rule(
    "Finished building pkgdown site for package {.pkg {pkg$package}}"
  )

  preview_site(pkg, preview = preview)
  invisible()
}

build_site_local <- function(
  pkg = ".",
  examples = TRUE,
  run_dont_run = FALSE,
  seed = 1014L,
  lazy = FALSE,
  override = list(),
  preview = NA,
  devel = TRUE
) {
  pkg <- section_init(pkg, override = override)

  cli::cli_rule("Building pkgdown site for package {.pkg {pkg$package}}")
  cli::cli_inform("Reading from: {src_path(path_abs(pkg$src_path))}")
  cli::cli_inform("Writing to:   {dst_path(path_abs(pkg$dst_path))}")

  pkgdown_sitrep(pkg)

  if (!lazy) {
    # Only force init_site() if `!lazy`
    # if site is not initialized, it will be in build_home()
    init_site(pkg, override)
  }

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

  check_built_site(pkg)

  cli::cli_rule(
    "Finished building pkgdown site for package {.pkg {pkg$package}}"
  )
  preview_site(pkg, preview = preview)
}
