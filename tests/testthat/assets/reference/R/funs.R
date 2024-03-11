#' A
#' @export
#' @keywords foo
a <- function() {}

#' B
#' @export
#' @concept graphics
b <- function() {}

#' C
#' @export
c <- function() {}

#' D
#' @usage
#' \special{?topic}
#' @export
`?` <- function() {}

#' E
#' @name e
NULL

#' F
#' @keywords internal
#' @examples
#' testpackage:::f()
f <- function() {runif(5L)}
