#' Generate YAML templates
#'
#' Use these function to generate the default YAML that pkgdown uses for
#' the different parts of `_pkgdown.yml`. This are useful starting
#' points if you want to customise your site.
#'
#' The `template_*` functions print YAML to the screen, which you can copy into
#' your existing `_pkgdown.yml` file. If the file does not yet exist, you can
#' call `init_yaml()` to create it using those templates.
#'
#' @param path Path to package root
#' @export
#' @rdname templates
template_navbar <- function(path = ".") {
  print_yaml(list(navbar = default_navbar(path)))
}

#' @export
#' @rdname templates
template_reference <- function(path = ".") {
  print_yaml(list(reference = default_reference_index(path)))
}

#' @export
#' @rdname templates
template_articles <- function(path = ".") {
  print_yaml(list(articles = default_articles_index(path)))
}

#' @export
#' @rdname templates
init_yaml <- function(path = ".") {
  yml <- file.path(path, "_pkgdown.yml")
  if (file.exists(yml)) {
    stop("_pkgdown.yml already exists", call. = FALSE)
  }

  sink(yml)
  on.exit(sink())
  print(template_navbar(path))
  print(template_reference(path))
  print(template_articles(path))
}
