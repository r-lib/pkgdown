#' Clean site
#'
#' Delete all files in `docs/` (except for `CNAME`).
#'
#' @param quiet If `TRUE`, suppresses a message.
#' @inheritParams build_site
#' @export
clean_site <- function(pkg = ".", quiet = FALSE) {

  pkg <- as_pkgdown(pkg)

  if (!quiet) {
    cli::cli_inform("Cleaning {.pkg {pkg$package}} pkgdown docs from {.path {pkg$dst_path}}")
  }

  if (!dir_exists(pkg$dst_path)) return(invisible())

  top_level <- dir_ls(pkg$dst_path)
  top_level <- top_level[!path_file(top_level) %in% c("CNAME", "dev")]

  is_dir <- is_dir(top_level)
  dir_delete(top_level[is_dir])
  file_delete(top_level[!is_dir])

  invisible(TRUE)
}
