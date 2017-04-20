
build_citation <- function(pkg = ".", path = "docs", depth = 0L) {
  pkg <- as_pkgdown(pkg)

  data <- list(
    pagetitle = "Citation",
    citation = format(pkg$citation, style = "html")
  )

  render_page(pkg, "citation", data, file.path(path, "citation.html"), depth = depth)
}


