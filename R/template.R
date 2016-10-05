#' Generate YAML templates
#'
#' Use these function to generate the default YAML that pkgdown uses for
#' the different parts of \code{_pkgdown.yml}. This are useful starting
#' points if you want to customise your site.
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
