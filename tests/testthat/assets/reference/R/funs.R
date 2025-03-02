#' A
#' @export
#' @keywords foo
#' @param a a letter
#' @param b a a number
#' @param c a logical
a <- function(a, b, c) {
}

#' B
#' @export
#' @concept graphics
b <- function() {
}

#' C
#' @export
c <- function() {
}

#' D
#' @usage
#' \special{?topic}
#' @export
`?` <- function() {
}

#' E
#' @name e
NULL

#' F
#' @keywords internal
#' @examples
#' testpackage:::f()
f <- function() {
  runif(5L)
}


#' g <-> h
#' @keywords internal
g <- function() 1
