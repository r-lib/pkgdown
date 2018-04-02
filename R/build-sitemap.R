build_sitemap <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  url <- pkg$meta$url
  if (is.null(url)) {
    return()
  }

  urls <- paste0(url, "/",
    c(
      path("reference", unique(pkg$topics$file_out)),
      path(pkg$vignettes$file_out)
    )
  )

  write_if_different(pkg, urls, "sitemap.txt", check = FALSE)
  invisible()
}
