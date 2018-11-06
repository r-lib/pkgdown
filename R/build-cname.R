
build_cname <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  url <- pkg$meta$url

  if (!is.null(url)) {

    cname <- cname_url(url)

    if (is.null(cname)) {
      return()
    }

    cname_path <- path(pkg$dst_path, "CNAME")

    write_if_different(pkg, cname, cname_path, check = FALSE)
  }

  invisible()
}

cname_url <- function(url) {

  # CNAME files don't have protocols
  cname <- sub("^https?://", "", url)
  # or trailing slashes
  cname <- sub("/$", "", cname)

  # Check whether the cleaned URL has a path.
  # e.g., check.com is OK; check.com/path is not.
  if (length(strsplit(cname, "/")[[1]]) > 1) {
    return(NULL)
  }

  cname
}
