#' Print object in pkgdown output
#'
#' @param x Object to display
#'
#' @return character vector showing the value of x
#' @export
pkgdown_print <- function(x) {
  UseMethod("pkgdown_print")
}

#' @export
pkgdown_print.default <- function(x) {
  if (isS4(x)) methods::show(x) else print(x)
}
