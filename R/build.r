#' Build staticdocs website
#'
#' \code{build_site} calls \code{\link{init_site}()},
#' \code{\link{build_site}()},
#' \code{\link{build_home}()}, and
#' \code{\link{build_reference}}.
#' See the individual documentation for how the code works.
#'
#' By default, staticdocs will use predefined templates and assets. If you
#' want to override, you can set the \code{asset_path} and \code{template_path}
#' at the top-level of \code{staticdocs.yml}.
#'
#' @inheritParams build_articles
#' @inheritParams build_reference
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
                       mathjax = TRUE,
                       launch = interactive(),
                       seed = 1014
                       ) {
  set.seed(seed)

  pkg <- as_staticdocs(pkg)
  init_site(path, pkg$meta$assets_path)

  build_home(pkg, path = path)
  build_reference(pkg,
    examples = TRUE,
    run_dont_run = TRUE,
    mathjax = TRUE,
    path = file.path(path, "reference"),
    depth = 1L
  )
  build_articles(pkg, path = file.path(path, "articles"), depth = 1L)
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
