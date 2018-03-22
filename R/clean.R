#' Clean site
#'
#' Deletes all files in `doc/` (except for `CNAME`)
#'
#' @inheritParams build_site
#' @export
clean_site <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  top_level <- dir_ls(pkg$dst_path)
  top_level <- top_level[!path_file(top_level) %in% c("CNAME", "dev")]

  is_dir <- is_dir(top_level)
  dir_delete(top_level[is_dir])
  file_delete(top_level[!is_dir])

  invisible(TRUE)
}
