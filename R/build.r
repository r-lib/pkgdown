#' Build complete static documentation for a package.
#'
#' \code{build_site} calls \code{\link{build_index}()},
#' \code{\link{build_home}()}, and \code{\link{build_reference}}. See
#' the invidual documentation for how the code works.
#'
#' @param pkg path to source version of package.  See
#'   \code{\link[devtools]{as.package}} for details on how paths and package
#'   names are resolved.
#' @param site_path root Directory in which to create documentation.
#' @param run_dont_run Run examples that are surrounded in \\dontrun?
#' @param examples Run examples?
#' @param templates_path Path in which to look for templates. If this doesn't
#'   exist will look next in \code{pkg/inst/staticdocs/templates}, then
#'   in staticdocs itself.
#' @param assets_path Path in which to look for assets files. If
#'   this doesn't exist, will use \code{pkg/inst/staticdocs/assets},
#'   then files built into staticdocs.
#' @param mathjax Use mathjax to render math symbols?
#' @param seed Seed used to initialize so that random examples are
#'   reproducible.
#' @param launch If \code{TRUE}, will open freshly generated site in web
#'   browser.
#' @export
#' @import stringr
#' @importFrom devtools load_all
#' @aliases staticdocs-package build_package
#' @examples
#' \dontrun{
#' build_site()
#' }
build_site <- function(pkg = ".",
                       site_path = "docs",
                       examples = TRUE,
                       run_dont_run = FALSE,
                       templates_path = "inst/staticdocs/templates",
                       assets_path = "inst/staticdocs/assets",
                       mathjax = TRUE,
                       launch = interactive(),
                       seed = 1014
                       ) {

  set.seed(seed)

  options <- list(
    examples = examples,
    run_dont_run = run_dont_run,
    templates_path = templates_path,
    mathjax = mathjax
  )

  pkg <- as_staticdocs(pkg, options)
  init_site(site_path, assets_path)

  # build_navbar(pkg)
  build_home(pkg, path = site_path)
  build_reference(pkg, path = file.path(site_path, "reference"))
  build_articles(pkg, path = file.path(site_path, "articles"))
  # build_news(pkg)

  if (launch) {
    rule("Launching site")
    servr::httd(site_path)
  }
  invisible(TRUE)
}

init_site <- function(path, user_assets) {
  mkdir(path)

  if (file.exists(user_assets)) {
    assets <- user_assets
  } else {
    assets <- file.path(inst_path(), "assets")
  }
  file.copy(dir(assets, full.names = TRUE), path, recursive = TRUE)
}
