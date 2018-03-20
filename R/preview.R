#' Open site in browser
#'
#' @inheritParams build_article
#' @param path Path relative to destination
#' @export
preview_site <- function(pkg = ".", path = ".", preview = NA) {
  pkg <- as_pkgdown(pkg)

  if (is.na(preview)) {
    preview <- interactive()
  }

  if (preview) {
    rule("Previewing site")
    utils::browseURL(path(pkg$dst_path, path, "index.html"))
  }

  invisible()
}
