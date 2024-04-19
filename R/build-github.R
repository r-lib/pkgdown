#' Build site for GitHub pages
#'
#' @description
#' Designed to be run as part of automated workflows for deploying
#' to GitHub pages. It cleans out the old site, builds the site into `dest_dir`
#' adds a `.nojekyll` file to suppress rendering by Jekyll, and adds a `CNAME`
#' file if needed.
#'
#' It is designed to be run in CI, so by default it:
#'
#' * Cleans out the old site.
#' * Does not install the package.
#' * Runs [build_site()] in process.
#'
#' @inheritParams build_site
#' @inheritParams deploy_to_branch
#' @param dest_dir Directory to build site in.
#' @export
build_site_github_pages <- function(pkg = ".",
                                    ...,
                                    dest_dir = "docs",
                                    clean = TRUE,
                                    install = FALSE,
                                    new_process = FALSE) {
 pkg <- as_pkgdown(pkg, override = list(destination = dest_dir))

  if (clean) {
    cli::cli_rule("Cleaning files from old site")
    clean_site(pkg)
  }

  build_site(pkg, preview = FALSE, install = install, new_process = new_process, ...)
  build_github_pages(pkg)

  invisible()
}

build_github_pages <- function(pkg = ".") {
  cli::cli_rule("Extra files for GitHub pages")
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
