#' Clean site
#'
#' Deletes all files in `doc/` (except for `CNAME`)
#'
#' @inheritParams build_site
#' @export
clean_site <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  top_level <- fs::dir_ls(pkg$dst_path)
  top_level <- top_level[basename(top_level) != "CNAME"]

  is_dir <- fs::is_dir(top_level)
  fs::dir_delete(top_level[is_dir])
  fs::file_delete(top_level[!is_dir])

  invisible(TRUE)
}
