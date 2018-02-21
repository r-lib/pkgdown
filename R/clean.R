#' Clean site
#'
#' Deletes all files in `doc/` (except for `CNAME`)
#'
#' @inheritParams build_site
#' @export
clean_site <- function(pkg = ".", path = "docs") {
  pkg <- as_pkgdown(pkg)
  path <- rel_path(path, pkg$path)

  top_level <- fs::dir_ls(path)
  top_level <- top_level[basename(top_level) != "CNAME"]

  fs::dir_delete(top_level[fs::is_dir(top_level)])
  fs::file_delete(top_level[!fs::is_dir(top_level)])

  invisible(TRUE)
}
