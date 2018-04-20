build_docsearch_json <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  index_name <- pkg$meta$template$params$docsearch$index_name
  if (is.null(index_name)) {
    return()
  }

  data <- list(
    index = index_name,
    package = pkg$package,
    url = pkg$meta$url
  )

  template <- find_template("config", "docsearch", ext = ".json")
  json <- render_template(template, data)

  json_path <- path(pkg$dst_path, "docsearch.json")

  write_if_different(pkg, json, json_path, check = FALSE)
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
      path("index.html"),
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
