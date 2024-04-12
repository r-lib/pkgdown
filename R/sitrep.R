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
    warns <- c(warns, x = paste0(msg_fld, " is absent. See {.vignette pkgdown::metadata}."))
  }

  desc_urls <- pkg$desc$get_urls()
  desc_urls <- sub("/$", "", desc_urls)
  if (length(desc_urls) == 0 || !pkg$meta[["url"]] %in% desc_urls) {
    warns <- c(warns, x = "{.file DESCRIPTION} {.field URL} is empty.")
  }

  if (length(warns) == 0) {
    cli::cli_inform(c(
      "v" = "pkgdown situation report: {.emph {cli::col_green('all clear')}}",
       "!" = "{.emph Double-check the following URLs:}",
       " " = "{pkgdown_config_href({pkg$src_path})} contains URL {.url {pkg$meta['url']}}",
       " " = "{.file DESCRIPTION} contains URL{?s} {.url {desc_urls}}"
    ))
  } else {
    cli::cli_warn(c(
      "pkgdown situation report: {.emph {cli::col_red('configuration error')}}",
      warns
    ))
  }

  invisible()
}
