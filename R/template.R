#' Generate YAML templates
#'
#' Use these function to generate the default YAML the staticdocs uses for
#' the different parts of \code{_staticdocs.yml}. This are useful starting
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
template_references <- function(path = ".") {
  print_yaml(list(references = default_reference_index(path)))
}
