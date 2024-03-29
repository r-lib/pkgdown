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
  pkg <- as_pkgdown(pkg)
  warns <- c()

  if (is.null(pkg$meta[["url"]])) {
    msg_fld <- pkgdown_field(pkg, "url", cfg = TRUE, fmt = TRUE)
    warns <- c(warns, x = paste0(msg_fld, "is misconfigured. See {.vignette pkgdown::metatdata}."))
  }

  desc_urls <- pkg$desc$get_urls()
  desc_urls <- sub("/$", "", desc_urls)
  if (length(desc_urls) == 0 || !pkg$meta[["url"]] %in% desc_urls) {
    warns <- c(warns, x = "{.file DESCRIPTION} {.field URL} is empty.")
  }

  if (length(warns) == 0) {
    cli::cli_alert_success("pkgdown situation report: {.emph {cli::col_green('all clear')}}")
    cli::cli_inform("{.emph Double-check the following URLs:}")
    cli::cli_inform("{.file {pkgdown_config_relpath(pkg)}} contains URL {.url {pkg$meta['url']}}")
    cli::cli_inform("{.file DESCRIPTION} contains URL{?s} {.url {desc_urls}}")
  } else {
    cli::cli_warn(c(
      "pkgdown situation report: {.emph {cli::col_red('configuration error')}}",
      warns
    ))
  }

  invisible()
}
