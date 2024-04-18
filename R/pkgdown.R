#' @importFrom magrittr %>%
#' @importFrom utils installed.packages
#' @import rlang
#' @import fs
#' @keywords internal
"_PACKAGE"

release_bullets <- function() {
  c(
    "Check that [test/widget.html](https://pkgdown.r-lib.org/dev/articles/) responds to mouse clicks on 5/10/50"
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

local_pkgdown_template_pkg <- function(path = NULL, meta = NULL, env = parent.frame()) {
  if (is.null(path)) {
    path <- withr::local_tempdir(.local_envir = env)
    desc <- desc::desc("!new")
    desc$set("Package", "templatepackage")
    desc$set("Title", "A test template package")
    desc$write(file = file.path(path, "DESCRIPTION"))
  }

  if (!is.null(meta)) {
    path_pkgdown_yml <- fs::path(path, "inst", "pkgdown", "_pkgdown.yml")
    fs::dir_create(fs::path_dir(path_pkgdown_yml))
    yaml::write_yaml(meta, path_pkgdown_yml)
  }

  rlang::check_installed("pkgload")
  pkgload::load_all(path)
  withr::defer(pkgload::unload("templatepackage"), envir = env)

  path
}

