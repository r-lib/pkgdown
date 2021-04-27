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
    url <- paste0(url, pkg$prefix)
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

#' Build search index
#'
#' Build a JSON file encompassing all HTML pages, for use by the search script.
#'
#' @section YAML config:
#' You can exclude some paths from the search index.
#' Below we exclude the changelog from the search index.
#'
#' ```yaml
#' search:
#'   exclude: ['news/index.html']
#' ```
#' @section Local testing:
#' Search won't work if you simply use pkgdown preview of the static files.
#' You can use `servr::httw("docs")` instead.
#'
#'
#' @inheritParams build_articles
#' @export
#'
build_search <- function(pkg = ".",
                         override = list()) {
  pkg <- section_init(pkg, depth = 1L, override = override)
  rule("Building search index")

  paths <- fs::path_rel(
    fs::dir_ls(pkg$dst_path, glob = "*.html", recurse = TRUE),
    pkg$dst_path
  )
  paths <- paths[!paths %in% c("404.html", "articles/index.html", "reference/index.html")]

  # user-defined exclusions
  paths <- paths[!paths %in% pkg$meta$search$exclude]

  index <- lapply(paths, file_search_index, pkg = pkg)
  index <- unlist(index, recursive = FALSE)
  index <- purrr::compact(index)
  jsonlite::write_json(
    index,
    file.path(pkg$dst_path, "search.json"),
    auto_unbox = TRUE
  )
}

file_search_index <- function(path, pkg) {
  html <- xml2::read_html(file.path(pkg$dst_path, path))
  # Get page title
  title <- xml2::xml_find_first(html, ".//meta[@property='og:title']") %>%
    xml2::xml_attr("content")

  # Get contents minus logo
  node <- xml2::xml_find_all(html, ".//div[contains(@class, 'contents')]")
  xml2::xml_remove(xml2::xml_find_first(node, ".//img[contains(@class, 'pkg-logo')]"))
  sections <- xml2::xml_find_all(node, ".//*[contains(@class, 'section')]")

  # Function for extracting all headers
  get_h <- function(level, section) {
    parents <- xml2::xml_parents(section)
    if (length(parents) == 0) {
      return("")
    }
    parents <- parents[!is.na(xml2::xml_attr(parents, "class"))]
    h_section <- parents[grepl(paste0("section level", level), xml2::xml_attr(parents, "class"))]
    h <- xml2::xml_contents(h_section)[is_heading(xml2::xml_contents(h_section))]
    sub("^\\n", "", xml_text1(h))
  }

  get_headings <- function(section, title, path) {
    min_level <- ifelse(grepl("news/index.html", path), 2, 3)
    if (get_section_level(section) < min_level) {
      headings <- ""
    } else {

      headings <- purrr::map_chr((min_level - 1):get_section_level(section), get_h, section = section) %>%
        purrr::discard(function(x) x == "")

      if (length(headings) > 1) headings <- paste(headings, collapse = " > ", sep = "")

    }

    dir <- fs::path_dir(path)
    if (dir == ".") {
      return(headings)
    } else {
      if (headings == "") {
        headings <- paste(unlist(fs::path_split(dir)), collapse = " > ")
      } else {
        headings <- paste(c(unlist(fs::path_split(dir)), headings), collapse = " > ")
      }

    }

    return(headings)
  }

  get_section_level <- function(section) {
    as.numeric(
      sub(
        ".*section level", "",
        xml2::xml_attr(section, "class")
      )
    )
  }

  purrr::map2(
    sections,
    purrr::map_chr(sections, get_headings, path = path),
    bs4_index_data,
    title = title,
    path = paste0("/", pkg$prefix, path)
  )

}
# edited from https://github.com/rstudio/bookdown/blob/abd461593033294d82427139040a0a03cfa0390a/R/bs4_book.R#L518
# index -------------------------------------------------------------------

bs4_index_data <- function(node, previous_headings, title, path) {
  # Make a copy of the node because we will remove contents from it for getting the data
  node_copy <- node
  # remove sections nested inside the current section to prevent duplicating content
  xml2::xml_remove(xml2::xml_find_all(node_copy, ".//*[contains(@class, 'section')]"))
  # remove dont-index sections
  xml2::xml_remove(xml2::xml_find_all(node_copy, ".//*[contains(@class, 'dont-index')]"))

  # Helpers for XPath queries
  all <- function(...) paste0(".//", c(...), collapse = "|")
  text_xpath <- all("p", "li", "caption", "figcaption", "dt", "dd", "blockquote", "div[contains(@class, 'line-block')]")
  code_xpath <- all("pre")

  # Special case for definitions (mostly encountered in Rd files)
  if (xml2::xml_name(node_copy) == "dt") {
    code <- xml2::xml_find_all(node_copy, code_xpath)
    # both argument name and definition
    text <- paste(
      xml_text1(node_copy),
      xml_text1(xml2::xml_find_first(node_copy, "following-sibling::*")),
      collapse = " "
    )
    heading <- paste(xml_text1(node_copy), "(argument)")
  } else {
    # Other cases
    code <- xml2::xml_find_all(node_copy, code_xpath)
    text <- xml_text1(xml2::xml_find_all(node_copy, text_xpath))
    children <- xml2::xml_children(node_copy)
    heading_node <- children[purrr::map_lgl(children, is_heading)][1]
    heading <- xml_text1(heading_node)

    # Add heading for Usage section of Rd
    if (grepl("ref-usage", xml2::xml_attr(node_copy, "class"))) {
      heading <- "Usage"
    }
  }

  # If no specific heading, use the title
  if (nchar(heading) == 0) {
    heading <- title
    title <- previous_headings
  } else if (previous_headings != "") {
    title <- paste(previous_headings, title, sep = " > ")
  }

  index_data <- list(
    path = path,
    id = xml2::xml_attr(node_copy, "id"),
    title = title,
    heading = heading,
    text = strip_stop_words(text),
    code = xml_text1(code)
  )

  if (index_data$text=="" && index_data$code == "") {
    return(NULL)
  }

  index_data
}

xml_text1 <- function(x) {
  paste0(xml2::xml_text(x), collapse = "")
}

strip_stop_words <- function(x) {
  # paste(tidytext::get_stopwords()$word, collapse = "|")
  pattern <- "\\b(i|me|my|myself|we|our|ours|ourselves|you|your|yours|yourself|yourselves|he|him|his|himself|she|her|hers|herself|it|its|itself|they|them|their|theirs|themselves|what|which|who|whom|this|that|these|those|am|is|are|was|were|be|been|being|have|has|had|having|do|does|did|doing|would|should|could|ought|i'm|you're|he's|she's|it's|we're|they're|i've|you've|we've|they've|i'd|you'd|he'd|she'd|we'd|they'd|i'll|you'll|he'll|she'll|we'll|they'll|isn't|aren't|wasn't|weren't|hasn't|haven't|hadn't|doesn't|don't|didn't|won't|wouldn't|shan't|shouldn't|can't|cannot|couldn't|mustn't|let's|that's|who's|what's|here's|there's|when's|where's|why's|how's|a|an|the|and|but|if|or|because|as|until|while|of|at|by|for|with|about|against|between|into|through|during|before|after|above|below|to|from|up|down|in|out|on|off|over|under|again|further|then|once|here|there|when|where|why|how|all|any|both|each|few|more|most|other|some|such|no|nor|not|only|own|same|so|than|too|very|will)\\b ?"
  gsub(pattern, "", x, ignore.case = TRUE)
}

is_heading <- function(node) {
  xml2::xml_name(node) %in% c("h1", "h2", "h3", "h4", "h5")
}
