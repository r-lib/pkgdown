#' Build staticdocs website
#'
#' \code{build_site()} is a convenient wrapper around three functions:
#' \itemize{
#'   \item \code{\link{build_articles}()}
#'   \item \code{\link{build_home}()}
#'   \item \code{\link{build_reference}()}
#' }
#' See the documentation for the each function to learn how to control
#' that aspect of the site.
#'
#' @section YAML config:
#'
#' There are four top-level YAML settings that affect the entire site:
#'
#' \describe{
#'   \item{title}{Site title, used in page title and default navbar.}
#'   \item{bootswatch}{Customise the overall theme with a bootswatch
#'     theme. You can see a complete list and how they'll affect your
#'     site at \url{https://gallery.shinyapps.io/117-shinythemes/}.}
#'  \item{assets_path}{Path to directory of additional assets to be
#'    copied into root directory of site. Use this when you want complete
#'    control over the visual design of the site. Recommended for advanced
#'    users only.}
#'  \item{template_path}{Path to directory of templates. Override the
#'    default (the templates built-in to staticdocs) to completely
#'    control the display of your site. Recommended for advanced users
#'    only.}
#' }
#' @inheritParams build_articles
#' @inheritParams build_reference
#' @param preview If \code{TRUE}, will preview freshly generated site in
#'    RStudio
#' @export
#' @examples
#' \dontrun{
#' build_site()
#' }
build_site <- function(pkg = ".",
                       path = "docs",
                       examples = TRUE,
                       run_dont_run = FALSE,
                       mathjax = TRUE,
                       preview = interactive(),
                       seed = 1014
                       ) {

  pkg <- as_staticdocs(pkg)
  init_site(path, pkg$meta$assets_path)

  build_home(pkg, path = path)
  build_reference(pkg,
    examples = TRUE,
    run_dont_run = TRUE,
    mathjax = TRUE,
    seed = seed,
    path = file.path(path, "reference"),
    depth = 1L
  )
  build_articles(pkg, path = file.path(path, "articles"), depth = 1L)
  # build_news(pkg)

  if (preview) {
    preview_site(path)
  }
  invisible(TRUE)
}

preview_site <- function(path) {
  preview_path <- file.path(tempdir(), "staticdocs-preview")
  if (file.exists(preview_path)) {
    unlink(preview_path, recursive = TRUE)
  }
  mkdir(preview_path, quiet = TRUE)
  file.copy(path, preview_path, recursive = TRUE)

  # Open in browser/viewer
  preview_url <- file.path(preview_path, path, "index.html")
  if (rstudioapi::isAvailable()) {
    rstudioapi::viewer(preview_url)
  } else {
    utils::browseURL(preview_site)
  }
}

build_site_rstudio <- function() {
  devtools::document()
  build_site(preview = TRUE)
}

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
