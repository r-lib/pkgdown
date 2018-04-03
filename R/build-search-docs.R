#' @import jsonlite
build_docsearch_json <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  data <- list(
    "index_name" = pkg$package,
    "start_urls" = pkg$meta$url,
    "stop_urls" = paste0(pkg$meta$url, "/", "index.html"),
    "sitemap_urls" = paste0(pkg$meta$url, "/", "sitemap.xml"),
    "selectors" = list(
      "lvl0" = jsonlite::unbox(".contents h1"),
      "lvl1" = jsonlite::unbox(".contents .name"),
      "lvl2" = jsonlite::unbox(".contents h2"),
      "lvl3" = jsonlite::unbox(".contents h3, .contents th, .contents dt"),
      "lvl4" = jsonlite::unbox(".contents h4"),
      "text" = jsonlite::unbox(
        ".contents p, .contents li, .usage, .template-article .contents .pre"
        )
    ),
    "selectors_exclude" = ".dont-index"
  )

  json_path <- path(pkg$dst_path, "docsearch.json")
  cat_line("Writing ", dst_path(path_rel(json_path, pkg$dst_path)))

  jsonlite::write_json(
    data,
    json_path,
    pretty = TRUE
  )
}

build_sitemap <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  url <- pkg$meta$url
  if (is.null(url)) {
    return()
  }

  urls <- paste0(
    url, "/",
    c(
      path("reference", unique(pkg$topics$file_out)),
      path(pkg$vignettes$file_out)
    )
  )

  doc <- xml2::read_xml(
    paste0("<urlset xmlns = 'http://www.sitemaps.org/schemas/sitemap/0.9'></urlset>")
  )

  url_nodes <- purrr::map(urls, url_node)
  for (url in url_nodes) {
    xml2::xml_add_child(doc, url)
  }

  xml_path <- path(pkg$dst_path, "sitemap.xml")
  cat_line("Writing ", dst_path(path_rel(xml_path, pkg$dst_path)))

  xml2::write_xml(doc, file = xml_path)

  invisible()
}

url_node <- function(url) {
  xml2::read_xml(
    paste0("<url><loc>", url, "</loc></url>")
  )
}
