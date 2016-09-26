#' Build home page
#'
#' First looks for \code{README.md}, then \code{index.md}. If neither is
#' found, falls back to the description field in \code{DESCRIPTION}.
#'
#' @param path Output path
#' @export
build_home <- function(pkg = ".", path = NULL) {
  rule("Building home")

  data <- spec_index(pkg)
  render_page(pkg, "home", data, out_path(path, "index.html"))
}

spec_index <- function(pkg = ".") {
  pkg <- as_staticdocs(pkg)
  path <- find_index(pkg)

  out <- list()
  if (is.null(path)) {
    out$index <- pkg$description
  } else {
    out$index <- markdown(path = path)
  }

  out$package <- pkg

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
