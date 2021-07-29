#' A
#' @export
a <- function() {}

#' B
#' @export
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
#' @examples
#' pkgdown_print.foo <- function(x, visible) x
#' registerS3method("pkgdown_print","foo", pkgdown_print.foo,
#'                  envir = asNamespace("pkgdown"))
#' replay_html.foo <- function(x, ...)
#' structure(
#'   "<div>test</div>\n",
#'   html = TRUE,
#'   class = base::c("html",
#'             "character"),
#'   dependencies = list(
#'     structure(
#'       list(
#'         name = "foo",
#'         version = "1.0",
#'         src = list(file = system.file("javascript", package = "testpackage")),
#'         script = "foo.js",
#'         all_files = TRUE
#'       ),
#'       class = "html_dependency"
#'     )
#'   )
#' )
#' registerS3method("replay_html", "foo", replay_html.foo,
#'   envir = asNamespace("downlit"))
#' structure("text", class = "foo")
#'
e <- function() {}
