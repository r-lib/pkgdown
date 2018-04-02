#' @importFrom jsonlite write_json
build_docsearch_json <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  data <- list(
    "index_name" = pkg$package,
    "start_urls" = pkg$meta$url,
    "sitemap_urls" = paste0(pkg$meta$url, "/", "sitemap.txt"),
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
  cat_line("Writing ", dst_path(path_rel(json_path, pkg$dst_path)))

  jsonlite::write_json(
    data,
    json_path,
    pretty = TRUE,
    auto_unbox = TRUE
  )
}

build_sitemap <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  url <- pkg$meta$url
  if (is.null(url)) {
    return()
  }

  urls <- paste0(url, "/",
    c(
      path("reference", unique(pkg$topics$file_out)),
      path(pkg$vignettes$file_out)
    )
  )

  write_if_different(pkg, urls, "sitemap.txt", check = FALSE)
  invisible()
}
