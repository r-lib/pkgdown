#' Check `_pkgdown.yml`
#'
#' Check that your `_pkgdown.yml` is valid without building the whole
#' site.
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
