#' Generate YAML templates
#'
#' Use these function to generate the default YAML that pkgdown uses for
#' the different parts of `_pkgdown.yml`. This are useful starting
#' points if you want to customise your site.
#'
#' @param path Path to package root
#' @rdname templates
#' @examples
#' \dontrun{
#' pkgdown::template_navbar()
#' }
#'
#' @export
template_navbar <- function(path = ".") {
  pkg <- as_pkgdown(path)

  print_yaml(list(
    navbar = list(
      structure = navbar_structure(),
      components = navbar_components(pkg)
    )
  ))
}

#' @rdname templates
#' @examples
#' \dontrun{
#' pkgdown::template_reference()
#' }
#'
#' @export
template_reference <- function(path = ".") {
  print_yaml(list(reference = default_reference_index(path)))
}

#' @rdname templates
#' @examples
#' \dontrun{
#' pkgdown::template_articles()
#' }
#'
#' @export
template_articles <- function(path = ".") {
  print_yaml(list(articles = default_articles_index(path)))
}
