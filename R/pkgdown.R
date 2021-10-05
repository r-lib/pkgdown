#' @importFrom magrittr %>%
#' @importFrom utils installed.packages
#' @import rlang
#' @import fs
#' @keywords internal
"_PACKAGE"

release_bullets <- function() {
  c(
    "Check that 'test/widget.html' responds to mouse clicks"
  )
}

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

local_envvar_pkgdown <- function(scope = parent.frame()) {
  withr::local_envvar(list(IN_PKGDOWN = "true"), .local_envir = scope)
}

local_pkgdown_site <- function(path, override = list(), env = parent.frame()) {
  pkg <- as_pkgdown(path, override)

  clean_up <- function(path) {
    if (!fs::dir_exists(path)) {
      return()
    }
    fs::dir_delete(path)
  }
  if (pkg$development$in_dev) {
    withr::defer(clean_up(path_dir(pkg$dst_path)), envir = env)
  } else {
    withr::defer(clean_up(pkg$dst_path), envir = env)
  }

  pkg
}
