#' Clean site
#'
#' Deletes all files in `doc/` (except for `CNAME`)
#'
#' @inheritParams build_site
#' @export
clean_site <- function(pkg = ".", path = "docs") {
  pkg <- as_pkgdown(pkg)
  path <- rel_path(path, pkg$path)

  top_level <- dir(path, full.names = TRUE)
  top_level <- top_level[basename(top_level) != "CNAME"]

  unlink(top_level, recursive = TRUE)

  invisible(TRUE)
}
