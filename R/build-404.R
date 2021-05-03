build_404 <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  # if this file exists, it will be handled by build_home_md()
  page_md <- path(pkg$src_path, ".github", "404.md")

  if (!file_exists(page_md)) {
    render_page(
      pkg, "title-body",
      data = list(
        pagetitle = "Page not found (404)",
        body = c("Content not found. Please use links in the navbar.")
      ),
      path = "404.html"
    )
    update_html(path_abs("404.html", start = pkg$dst_path), tweak_404, pkg = pkg)
  }

  invisible()
}
