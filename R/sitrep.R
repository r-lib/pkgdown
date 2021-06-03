#' Report package pkgdown situation
#'
#' @description
#'
#' `pkgdown_sitrep()` reports
#'
#' * If there is an `url` field in the pkgdown configuration;
#'
#' * If that pkgdown website URL is stored in the DESCRIPTION file.
#'
#' @inheritParams as_pkgdown
#'
#' @export
#'
pkgdown_sitrep <- function(pkg = ".") {
  pkg_dir <- pkg
  pkg <- as_pkgdown(pkg_dir)
  if (is.null(pkg$meta[["url"]])) {
    cat(sprintf("* %s not configured.", pkgdown_field(pkg, "url")))
  } else {
    urls <- desc::desc(pkg_dir)$get_urls()
    urls <- sub("/$", "", urls)
    if (!pkg$meta[["url"]] %in% urls) {
      cat("* URL missing from the DESCRIPTION URL field.")
    } else {
      cat("All good :-)")
    }
  }

  invisible()
}
