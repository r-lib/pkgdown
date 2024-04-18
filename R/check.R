#' Check `_pkgdown.yml`
#'
#' @description
#' Check that your `_pkgdown.yml` is valid without building the whole
#' site. Currently this:
#'
#' * Checks the reference and article indexes to ensure that pkgdown can
#'   read them, and that every documentation topic and vignette/article is 
#'   included in the index.
#'
#' * Validates any opengraph metadata that you might have supplied
#'
#' @export
#' @inheritParams as_pkgdown
check_pkgdown <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  data_open_graph(pkg)
  data_articles_index(pkg)
  data_reference_index(pkg)

  cli::cli_inform(c(
    "v" = "No problems found in {pkgdown_config_href({pkg$src_path})}"
  ))
}
