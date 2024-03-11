#' Open site in browser
#'
#' @inheritParams build_article
#' @param path Path relative to destination
#' @export
preview_site <- function(pkg = ".", path = ".", preview = NA) {
  pkg <- as_pkgdown(pkg)

  if (is.na(preview)) {
    preview <- interactive() && !is_testing()
  }

  if (preview) {
    cli::cli_alert_info("Previewing site")
    utils::browseURL(path(pkg$dst_path, path, "index.html"))
  }

  invisible()
}

#' Preview a local pkgdown page in the browser
#'
#' Only works when rendering the working directory, as this is the most
#' common interactive workflow.
#'
#' @export
#' @keywords internal
preview_page <- function(path, pkg = ".") {
  pkg <- as_pkgdown(".")
  utils::browseURL(path_abs(path(pkg$dst_path, path)))
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}
