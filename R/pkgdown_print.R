#' Print object in pkgdown output
#'
#' This lets package authors control how objects are printed just for
#' pkgdown examples. The default is to call [print()] apart from htmlwidgets
#' where the object is returned as is (with sizes tweaked).
#'
#' @param x Object to display
#' @param visible Whether it is visible or not
#' @return Either a character vector representing printed output (which
#'   will be escaped for HTML as necessary) or literal HTML produced
#'   by the htmltools or htmlwidgets packages.
#' @keywords internal
#' @export
pkgdown_print <- function(x, visible = TRUE) {
  UseMethod("pkgdown_print")
}

#' @export
pkgdown_print.default <- function(x, visible = TRUE) {
  if (!visible) {
    return(invisible())
  }

  # inlined from htmltools::is.browsable()
  if (isTRUE(attr(x, "browsable_html", exact = TRUE))) {
    x
  } else {
    print(x)
  }
}

#' @export
pkgdown_print.htmlwidget <- function(x, visible = TRUE) {
  if (!visible) {
    return(invisible())
  }

  settings <- fig_settings()
  x$width <- x$width %||% (settings$fig.width * settings$dpi)
  x$height <- x$height %||% (settings$fig.height * settings$dpi)
  x
}
