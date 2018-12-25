build_404 <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  page_md <- path(pkg$src_path, "404.md")

  if (file_exists(page_md)) {
    render_md(pkg, page_md)
  } else {
    cat_line("Creating default 404 page")

    render_page(
      pkg, "title-body",
      data = list(
        pagetitle = "Page not found (404)",
        body = c("Content not found. Please use links in the navbar.")
      ),
      path = "404.html"
    )

    invisible()
  }
}
