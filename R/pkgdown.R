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

local_envvar_pkgdown <- function(pkg, scope = parent.frame()) {
  withr::local_envvar(
    IN_PKGDOWN = "true",
    LANGUAGE = pkg$lang,
    .local_envir = scope
  )
}

local_pkgdown_site <- function(path = NULL, meta = NULL, env = parent.frame()) {
  if (is.null(path)) {
    path <- withr::local_tempdir(.local_envir = env)
    desc <- desc::desc("!new")
    desc$set("Package", "testpackage")
    desc$set("Title", "A test package")
    desc$write(file = file.path(path, "DESCRIPTION"))
  }

  if (is.character(meta)) {
    meta <- yaml::yaml.load(meta)
  } else if (is.null(meta)) {
    meta <- list()
  }
  pkg <- as_pkgdown(path, meta)
  pkg$dst_path <- withr::local_tempdir(.local_envir = env)

  withr::defer(unlink(pkg$dst_path, recursive = TRUE), envir = env)

  pkg
}
