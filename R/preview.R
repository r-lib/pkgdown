#' Open site in browser
#'
#' `preview_site()` opens your pkgdown site in your browser. pkgdown has been
#' carefully designed to work even when served from the file system like
#' this; the only part that doesn't work is search. You can use `servr::httw("docs/")`
#'  to create a server to make search work locally.
#'
#' @inheritParams build_article
#' @param path Path relative to destination
#' @export
preview_site <- function(pkg = ".", path = ".", preview = TRUE) {
  path <- local_path(pkg, path)

  check_bool(preview, allow_na = TRUE)
  if (is.na(preview)) {
    preview <- interactive() && !is_testing()
  }

  if (preview) {
    cli::cli_inform(c(i = "Previewing site"))
    utils::browseURL(path)
  }

  invisible()
}

local_path <- function(pkg, path, call = caller_env()) {
  pkg <- as_pkgdown(pkg)
  check_string(path, call = call)

  abs_path <- path_abs(path, pkg$dst_path)
  if (!file_exists(abs_path)) {
    cli::cli_abort("Can't find file {.path {path}}.", call = call)
  }

  if (is_dir(abs_path)) {
    abs_path <- path(abs_path, "index.html")
  }
  abs_path
}

#' Preview a local pkgdown page in the browser
#'
#' @description
#' `r lifecycle::badge("deprecated")` Use [preview_site()] instead.
#'
#' @export
#' @keywords internal
preview_page <- function(path, pkg = ".") {
  lifecycle::deprecate_warn("2.1.0", "preview_page()", "preview_site()")
  preview_site(pkg, path, preview = TRUE)
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}
