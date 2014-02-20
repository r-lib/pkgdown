#' Render complete page.
#'
#' @param package Path to package to document.
#' @param name Name of the template (e.g. index, demo, topic)
#' @param data Data for the template
#' @param path Location to create file. If \code{""} (the default),
#'   prints to standard out.
#' @export
render_page <- function(package, name, data, path = "") {
  # render template components
  pieces <- c("head", "navbar", "header", "content", "footer")
  components <- lapply(pieces, render_template, package = package, name, data)
  names(components) <- pieces

  # render complete layout
  out <- render_template(package, "layout", name, components)
  cat(out, file = path)
}

#' @importFrom whisker whisker.render
render_template <- function(package, type, name, data) {
  template <- readLines(find_template(package, type, name))
  if (length(template) == 0 || (length(template) == 1 && str_trim(template) == ""))
    return("")

  whisker.render(template, data)
}

# Find template by looking first in package/staticdocs then in
# staticdocs/templates, trying first for a type-name.html otherwise
# defaulting to type.html
find_template <- function(package, type, name) {
  paths <- c(
    pkg_sd_path(package),
    file.path(inst_path(), "templates")
  )

  if (!is.null(package$templates_path))
    paths <- c(package$templates_path, paths)

  names <- c(
    str_c(type, "-", name, ".html"),
    str_c(type, ".html")
  )

  locations <- as.vector(t(outer(paths, names, FUN = "file.path")))
  Find(file.exists, locations, nomatch =
    stop("Can't find template for ", type, "-", name, ".", call. = FALSE))
}


file.path.ci <- function(...) {
  default <- file.path(...)
  if (file.exists(default)) return(default)

  dir <- dirname(default)
  if (!file.exists(dir)) return(default)

  pattern <- glob2rx(basename(default)) # Not perfect, but safer than raw name
  matches <- list.files(dir, pattern, ignore.case = TRUE,
    full.names = TRUE, include.dirs = TRUE, all.files = TRUE)
  if (length(matches) == 0) return(default)

  matches[[1]]
}
