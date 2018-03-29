#' Build documents for search infrastructure
#'
#' These documents are built under `docs` as part of the Docsearch
#' infrastructure:
#'
#' - `docsearch.json`
#'
#' @export
build_search_docs <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  rule("Building search docs")

  build_docsearch_json(pkg)
}

#' Build Docsearch JSON
#'
#' Create a Docsearch search configuration in JSON format and save it as
#' `docsearch.json` to be used as a suggested starting point when setting up a
#' Docsearch crawler.
#'
#' @importFrom jsonlite write_json
build_docsearch_json <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  stop_urls <- c(
    "/index.html",
    "/reference/index.html",
    "/news/",
    "LICENSE.html$"
  )

  data <- list(
    "index_name" = pkg$package,
    "start_urls" = pkg$meta$url,
    "stop_urls" = stop_urls,
    "selectors" = list(
      "lvl0" = ".ds-lvl0",
      "lvl1" = ".ds-lvl1",
      "lvl2" = ".ds-lvl2",
      "text" = ".ds-text"
    ),
    # exclude see-also because these are exit links on the target page
    "selectors_exclude" = ".no-ds"
  )

  json_path <- path("docsearch.json")
  cat_line("Writing ", dst_path(path_rel(json_path, pkg$dst_path)))

  jsonlite::write_json(
    data,
    json_path,
    pretty = TRUE,
    auto_unbox = TRUE
  )
}
