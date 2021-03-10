#' Print object in pkgdown output
#'
#' @param x Object to display
#' @param visible Whether it is visible or not
#'
#' @return character vector showing the value of x
#' @export
pkgdown_print <- function(x, visible) {
  UseMethod("pkgdown_print")
}

#' @export
pkgdown_print.default <- function(x, visible) {
  # methods is only suggested, but you won't have S4 objects
  # without it
  if (visible)
    if (isS4(x)) methods::show(x) else print(x)
}
