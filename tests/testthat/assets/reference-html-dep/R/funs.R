#' Example with HTML dependency
#'
#' @examples
#' a()
#' @export
a <- function() {
  x <- htmltools::tagList(
    htmltools::p("hello"),
    rmarkdown::html_dependency_jquery(),
    rmarkdown::html_dependency_bootstrap("flatly")
  )
  htmltools::browsable(x)
}
