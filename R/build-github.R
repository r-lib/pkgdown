build_github_pages <- function(pkg = ".") {
  rule("Extra files for GitHub pages")
  pkg <- as_pkgdown(pkg)

  # Add .nojekyll since site is static HTML
  write_if_different(pkg, "", ".nojekyll", check = FALSE)

  # Add CNAME if url present
  cname <- cname_url(pkg$meta$url)
  if (is.null(cname)) {
    return(invisible())
  }

  write_if_different(pkg, cname, "CNAME", check = FALSE)
  invisible()
}

cname_url <- function(url) {
  if (is.null(url))
    return(NULL)

  pieces <- xml2::url_parse(url)
  if (!pieces$path %in% c("", "/"))
    return(NULL)

  pieces$server
}
