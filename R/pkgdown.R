#' Determine if code is executed by pkgdown
#'
#' This is occasionally useful when you need different behaviour by
#' pkgdown and regular documentation.
#'
#' @export
#' @examples
#' in_pkgdown()
in_pkgdown <- function() {
  identical(Sys.getenv("IN_PKGDOWN"), "true")
}

#' @rdname in_pkgdown
#' @param pkg Package name (a string)
#' @export
#' @examples
#' in_pkgdown_pkg("pkgdown")
in_pkgdown_pkg <- function(pkg) {
  identical(Sys.getenv("IN_PKGDOWN_PKG"), pkg)
}

local_envvar_pkgdown <- function(pkg, scope = parent.frame()) {
  withr::local_envvar(
    IN_PKGDOWN = "true",
    IN_PKGDOWN_PKG = pkg$package,
    LANGUAGE = pkg$lang,
    .local_envir = scope
  )
}
