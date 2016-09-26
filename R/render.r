#' Render complete page.
#'
#' @param package Path to package to document.
#' @param name Name of the template (e.g. index, demo, topic)
#' @param data Data for the template. Package metadata is always automatically
#'   added to this list under key \code{package}.
#' @param path Location to create file. If \code{""} (the default),
#'   prints to standard out.
#' @export
render_page <- function(package, name, data, path = "") {
  package <- as_staticdocs(package)

  # render template components
  pieces <- c("head", "navbar", "header", "content", "footer")
  components <- lapply(pieces, render_template, package = package, name, data)
  names(components) <- pieces

  # render complete layout
  out <- render_template(package, "layout", name, components)
  message("Writing '", path, "'")

  cat(out, file = path)
}

#' @importFrom whisker whisker.render
render_template <- function(package, type, name, data) {
  data$package <- package$package

  template <- readLines(find_template(package, type, name))
  if (length(template) == 0 || (length(template) == 1 && str_trim(template) == ""))
    return("")

  whisker.render(template, data)
}

# Find template by looking first in package/staticdocs then in
# staticdocs/templates, trying first for a type-name.html otherwise
# defaulting to type.html
find_template <- function(package, type, name) {
  package <- as_staticdocs(package)

  paths <- c(
    package$options$templates_path,
    pkg_sd_path(package),
    file.path(inst_path(), "templates")
  )

  names <- c(
    str_c(type, "-", name, ".html"),
    str_c(type, ".html")
  )

  locations <- as.vector(t(outer(paths, names, FUN = "file.path")))
  Find(file.exists, locations, nomatch =
    stop("Can't find template for ", type, "-", name, ".", call. = FALSE))
}


