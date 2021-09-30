#' Build site for GitHub pages
#'
#' Designed to be run as part of automated workflows for deploying
#' to GitHub pages. It cleans out the old site, builds the site into `dest_dir`
#' (assuming the package has already been installed), adds a `.nojekyll`
#' file to suppress rendering by Jekyll, and adds a `CNAME` file if needed.
#'
#' @inheritParams deploy_to_branch
#' @param dest_dir Directory to build site in.
#' @export
build_site_github_pages <- function(pkg = ".", ..., dest_dir = "docs", clean = TRUE) {
 pkg <- as_pkgdown(pkg, override = list(destination = dest_dir))

  if (clean) {
    rule("Cleaning files from old site", line = 1)
    clean_site(pkg)
  }

  build_site(pkg, preview = FALSE, install = FALSE, new_process = FALSE, ...)
  build_github_pages(pkg)

  invisible()
}

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
