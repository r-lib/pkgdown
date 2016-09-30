#' Build home page
#'
#' First looks for \code{README.md}, then \code{index.md}. If neither is
#' found, falls back to the description field in \code{DESCRIPTION}.
#'
#' @section YAML config:
#' There are currently no options to control the appearance of the
#' homepage.
#'
#' @inheritParams build_articles
#' @export
build_home <- function(pkg = ".", path = NULL) {
  rule("Building home")

  data <- data_index(pkg)
  render_page(pkg, "home", data, out_path(path, "index.html"))
}

data_index <- function(pkg = ".") {
  pkg <- as_staticdocs(pkg)
  path <- find_index(pkg)

  out <- list()
  if (is.null(path)) {
    out$index <- pkg$description
  } else {
    out$index <- markdown(path = path, depth = 0L, index = pkg$topics)
  }

  out$pagetitle <- "Home"

  out
}

find_index <- function(pkg = ".") {
  pkg <- as_staticdocs(pkg)

  path <- file.path(pkg$path, "README.md")
  if (file.exists(path)) {
    return(path)
  }

  path <- file.path(pkg$path, "index.md")
  if (file.exists(path)) {
    return(path)
  }

  NULL
}
