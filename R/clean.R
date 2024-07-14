#' Clean site
#'
#' Delete all files in `docs/` (except for `CNAME`).
#'
#' @param quiet If `TRUE`, suppresses a message.
#' @inheritParams build_site
#' @rdname clean
#' @export
clean_site <- function(pkg = ".", quiet = FALSE) {

  pkg <- as_pkgdown(pkg)

  if (!quiet) {
    cli::cli_inform("Cleaning {.pkg {pkg$package}} pkgdown docs from {.path {pkg$dst_path}}")
  }

  if (!dir_exists(pkg$dst_path)) return(invisible())

  top_level <- dest_files(pkg)
  if (length(top_level) > 0) {
    check_dest_is_pkgdown(pkg)
  }

  is_dir <- is_dir(top_level)
  dir_delete(top_level[is_dir])
  file_delete(top_level[!is_dir])

  invisible(TRUE)
}

#' Clean cache
#'
#' Delete all files in the pkgdown cache directory.
#'
#' @rdname clean
#' @export
clean_cache <- function(pkg = ".", quiet = FALSE) {

  pkg <- as_pkgdown(pkg)
  cache_path <- tools::R_user_dir("pkgdown", "cache")

  if (dir_exists(cache_path)) {
    if (!quiet) {
      cli::cli_inform(
        "Cleaning {.pkg {pkg$package}} cache files from {.path {cache_path}}"
      )
    }

    dir_delete(cache_path)
  }

  invisible(TRUE)
}

check_dest_is_pkgdown <- function(pkg) {
  if (file_exists(path(pkg$dst_path, "pkgdown.yml"))) {
    return()
  }

  cli::cli_abort(c(
    "{.file {pkg$dst_path}} is non-empty and not built by pkgdown",
    "!" = "Make sure it contains no important information \\
            and use {.run pkgdown::clean_site()} to delete its contents."
    )
  )
}

dest_files <- function(pkg) {
  if (!dir_exists(pkg$dst_path)) {
    character()
  } else {
    top_level <- dir_ls(pkg$dst_path)
    top_level[!path_file(top_level) %in% c("CNAME", "dev")]
  }
}
