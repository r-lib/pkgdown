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

  data <- list(
    "index_name" = pkg$package,
    "start_urls" = pkg$meta$url,
    "stop_urls" = stop_urls,
    "sitemap_urls" = paste0(pkg$meta$url, "sitemap.txt"),
    "selectors" = list(
      "lvl0" = ".contents h1",
      "lvl1" = ".contents h2",
      "lvl2" = ".contents h3, .contents th, .contents dt",
      "lvl3" = ".contents h4",
      "lvl4" = ".contents h5",
      "text" = ".contents p, .contents li, .usage, .template-article .contents .pre"
    ),
    "selectors_exclude" = ".dont-index"
  )

  json_path <- path(pkg$dst_path, "docsearch.json")
  cat_line("Writing ", dst_path(json_path))

  jsonlite::write_json(
    data,
    json_path,
    pretty = TRUE,
    auto_unbox = TRUE
  )
}
