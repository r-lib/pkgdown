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
    rule("Previewing site")
    utils::browseURL(path(pkg$dst_path, path, "index.html"))
  }

  invisible()
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}
