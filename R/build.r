#' Build complete static documentation for a package.
#'
#' \code{build_site} calls \code{\link{init_site}()},
#' \code{\link{build_site}()},
#' \code{\link{build_home}()}, and
#' \code{\link{build_reference}}.
#' See the individual documentation for how the code works.
#'
#' @inheritParams build_articles
#' @param run_dont_run Run examples that are surrounded in \\dontrun?
#' @param examples Run examples?
#' @param templates_path Path in which to look for templates. If this doesn't
#'   exist will look next in \code{pkg/inst/staticdocs/templates}, then
#'   in staticdocs itself.
#' @param mathjax Use mathjax to render math symbols?
#' @param seed Seed used to initialize so that random examples are
#'   reproducible.
#' @param launch If \code{TRUE}, will open freshly generated site in web
#'   browser.
#' @inheritParams init_site
#' @export
#' @import stringr
#' @examples
#' \dontrun{
#' build_site()
#' }
build_site <- function(pkg = ".",
                       path = "docs",
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
  init_site(path, assets_path)

  build_home(pkg, path = path)
  build_reference(pkg, path = file.path(path, "reference"))
  build_articles(pkg, path = file.path(path, "articles"))
  # build_news(pkg)

  if (launch) {
    rule("Launching site")
    servr::httd(path)
  }
  invisible(TRUE)
}

#' Initialise the site
#'
#' Creates directory and copies assets.
#'
#' @param assets_path Path in which to look for assets files. If
#'   this doesn't exist, will use files built into staticdocs.
#' @inheritParams build_articles
#' @export
init_site <- function(path, assets_path = NULL) {
  rule("Initialising site")

  mkdir(path)
  if (is.null(assets_path) || !file.exists(assets_path)) {
    assets_path <- file.path(inst_path(), "assets")
  }

  assets <- dir(assets_path, full.names = TRUE)
  for (asset in assets) {
    message("Copying '", asset, "'")
    file.copy(asset, path, recursive = TRUE)
  }
}
