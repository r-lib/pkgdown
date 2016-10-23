#' Build pkgdown website
#'
#' \code{build_site()} is a convenient wrapper around four functions:
#' \itemize{
#'   \item \code{\link{build_articles}()}
#'   \item \code{\link{build_home}()}
#'   \item \code{\link{build_reference}()}
#'   \item \code{\link{build_news}()}
#' }
#' See the documentation for the each function to learn how to control
#' that aspect of the site.
#'
#' @section YAML config:
#'
#' There are four top-level YAML settings that affect the entire site:
#'
#' \describe{
#'  \item{title}{Site title, used in page title and default navbar.}
#'  \item{assets_path}{Path to directory of additional assets to be
#'    copied into root directory of site. Use this when you want complete
#'    control over the visual design of the site. Recommended for advanced
#'    users only.}
#'  \item{template_path}{Path to directory of templates. Override the
#'    default (the templates built-in to pkgdown) to completely
#'    control the display of your site. Recommended for advanced users
#'    only.}
#'  \item{template}{Additional metadata to be passed on to the template.
#'    The default template supports
#'    \itemize{
#'      \item \code{bootswatch} to customise the
#'        overall theme with a bootswatch theme. You can see a complete list
#'        and preview how they look at
#'        \url{https://gallery.shinyapps.io/117-shinythemes/}.
#'      \item \code{ganalytics} to enable
#'        \href{Google Analytics}{https://www.google.com/analytics/} by
#'        providing your
#'        \href{tracking id}{https://support.google.com/analytics/answer/1032385}
#'        (e.g. \code{"UA-000000-01"}).
#'    }}
#' }
#'
#' You can also control the \code{navbar}. It uses the same syntax as
#' \href{RMarkdown}{http://rmarkdown.rstudio.com/rmarkdown_websites.html#site_navigation}.
#' The following YAML snippet illustrates some of the most important features.
#'
#' \preformatted{
#' navbar:
#'   type: inverse
#'   left:
#'     - text: "Home"
#'       href: index.html
#'     - text: "Reference"
#'       href: reference/index.html
#'     - text: "Articles"
#'       menu:
#'         - text: "Heading 1"
#'         - text: "Article A"
#'           href: articles/page_a.html
#'         - text: "Article B"
#'           href: articles/page_b.html
#'         - text: "---------"
#'         - text: "Heading 2"
#'         - text: "Article C"
#'           href: articles/page_c.html
#'         - text: "Article D"
#'           href: articles/page_d.html
#'   right:
#'     - icon: fa-github fa-lg
#'       href: https://example.com
#' }
#'
#'
#' Use \code{type} to choose between "default" and "inverse" themes.
#'
#' You position elements by placing under either \code{left} or \code{right}.
#' Components can contain sub-\code{menu}s with headings (indicated by missing
#' \code{href}) and separators. Currently pkgdown only supports fontawesome
#' icons. You can see a full list of options at
#' \url{http://fontawesome.io/icons/}.
#'
#' @inheritParams build_articles
#' @inheritParams build_reference
#' @param path Location in which to save website, relative to package
#'   path.
#' @param preview If \code{TRUE}, will preview freshly generated site
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

  pkg <- as_pkgdown(pkg)
  # Use path relative to pkg
  if (pkg$path != ".") {
    path <- file.path(pkg$path, path)
  }

  init_site(path, pkg$meta$assets_path)

  build_logo(pkg, path = path)
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
  build_news(pkg, path = file.path(path, "news"), depth = 1L)

  if (preview) {
    preview_site(path)
  }
  invisible(TRUE)
}

preview_site <- function(path) {
  utils::browseURL(file.path(path, "index.html"))
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
