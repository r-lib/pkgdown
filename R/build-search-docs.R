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

  template <- find_template(
    "config",
    "docsearch",
    ext = ".json",
    bs_version = pkg$bs_version
  )

  json <- render_template(template, data)

  json_path <- path(pkg$dst_path, "docsearch.json")

  write_if_different(pkg, json, json_path, check = FALSE)
}

build_sitemap <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  url <- paste0(pkg$meta$url, "/")
  if (is.null(url)) {
    return()
  }

  if (pkg$development$in_dev && pkg$bs_version > 3) {
    url <- paste0(url, meta_development(pkg$meta, pkg$version)$destination, "/")
  }

  urls <- paste0(
    url,
    fs::path_rel(
      fs::dir_ls(pkg$dst_path, glob = "*.html", recurse = TRUE),
      pkg$dst_path
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

build_search <- function(pkg = ".",
                         override = list()) {
  pkg <- as_pkgdown(pkg)
  rule("Building search index")

  paths <- fs::path_rel(
      fs::dir_ls(pkg$dst_path, glob = "*.html", recurse = TRUE),
      pkg$dst_path
  )
  paths <- paths[paths != "404.html"]

  index <- lapply(paths, file_search_index, pkg = pkg)
  index <- purrr::compact(index)
  jsonlite::write_json(
    index,
    file.path(pkg$dst_path, "search.json"),
    auto_unbox = TRUE
  )
  file.edit( file.path(pkg$dst_path, "search.json"))
}

file_search_index <- function(path, pkg) {
  # later add more sectioning
  node <- xml2::read_html(file.path(pkg$dst_path, path)) %>%
    xml2::xml_find_all(".//div[contains(@class, 'contents')]")
  xml2::xml_remove(xml2::xml_find_first(node, ".//img[contains(@class, 'pkg-logo')]"))
  bs4_index_data(node, path, path)
}
# from https://github.com/rstudio/bookdown/blob/abd461593033294d82427139040a0a03cfa0390a/R/bs4_book.R#L518
# index -------------------------------------------------------------------

bs4_index_data <- function(node, chapter, path) {
  contents <- xml2::xml_find_all(node,
    ".//*[contains(@class, 'section')]"
  )
  if (length(contents) == 0) {
    return()
  }

  all <- function(...) paste0(".//", c(...), collapse = "|")
  text_path <- all("p", "li", "caption", "figcaption", "dt", "dd")
  code_path <- all("pre")

  code <- xml2::xml_find_all(contents, code_path)
  text <- xml2::xml_find_all(contents, text_path)

  list(
    path = path,
    id = xml2::xml_attr(node, "id"),
    chapter = chapter,
    heading = xml_text1(xml2::xml_find_first(node, ".//h1")),
    text = strip_stop_words(xml_text1(text)),
    code = xml_text1(code)
  )
}

xml_text1 <- function(x) {
  paste0(xml2::xml_text(x), collapse = "")
}

strip_stop_words <- function(x) {
  # paste(tidytext::get_stopwords()$word, collapse = "|")
  pattern <- "\\b(i|me|my|myself|we|our|ours|ourselves|you|your|yours|yourself|yourselves|he|him|his|himself|she|her|hers|herself|it|its|itself|they|them|their|theirs|themselves|what|which|who|whom|this|that|these|those|am|is|are|was|were|be|been|being|have|has|had|having|do|does|did|doing|would|should|could|ought|i'm|you're|he's|she's|it's|we're|they're|i've|you've|we've|they've|i'd|you'd|he'd|she'd|we'd|they'd|i'll|you'll|he'll|she'll|we'll|they'll|isn't|aren't|wasn't|weren't|hasn't|haven't|hadn't|doesn't|don't|didn't|won't|wouldn't|shan't|shouldn't|can't|cannot|couldn't|mustn't|let's|that's|who's|what's|here's|there's|when's|where's|why's|how's|a|an|the|and|but|if|or|because|as|until|while|of|at|by|for|with|about|against|between|into|through|during|before|after|above|below|to|from|up|down|in|out|on|off|over|under|again|further|then|once|here|there|when|where|why|how|all|any|both|each|few|more|most|other|some|such|no|nor|not|only|own|same|so|than|too|very|will)\\b ?"
  gsub(pattern, "", x, ignore.case = TRUE)
}
