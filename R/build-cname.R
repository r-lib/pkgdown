build_cname <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  cname <- cname_url(pkg$meta$url)
  if (is.null(cname)) {
    return(invisible())
  }

  cname_path <- path(pkg$dst_path, "CNAME")
  write_if_different(pkg, cname, cname_path, check = FALSE)
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
