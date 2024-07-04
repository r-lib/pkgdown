build_docsearch_json <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  index_name <- config_pluck_string(pkg, "template.params.docsearch.index_name")
  if (is.null(index_name)) {
    return()
  }

  data <- list(
    index = index_name,
    package = pkg$package,
    url = config_pluck_string(pkg, "url")
  )

  template <- find_template("config", "docsearch", ext = ".json", pkg = pkg)

  json <- render_template(template, data)

  json_path <- path(pkg$dst_path, "docsearch.json")

  write_if_different(pkg, json, json_path, check = FALSE)
}

build_sitemap <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  url <- paste0(config_pluck_string(pkg, "url"), "/")
  if (is.null(url)) {
    return()
  }

  cli::cli_rule("Building sitemap")
  if (pkg$development$in_dev && pkg$bs_version > 3) {
    url <- paste0(url, pkg$prefix)
  }

  urls <- paste0(url, get_site_paths(pkg))
  doc <- paste0(
    "<urlset xmlns = 'http://www.sitemaps.org/schemas/sitemap/0.9'>\n",
    paste0("<url><loc>", escape_html(urls), "</loc></url>\n", collapse = ""),
    "</urlset>\n"
  )

  write_if_different(pkg, doc, "sitemap.xml", check = FALSE)
  invisible()
}

#' Build search index
#' 
#' @description
#' Generate a JSON search index from the built site. This is used by 
#' [fuse.js](https://www.fusejs.io/) to provide a javascript powered search for
#' BS5 powered pkgdown sites.
#'
#' NB: `build_search()` is called automatically by [build_site()]; you don't 
#' need call it yourself. This page documents how it works and its customisation
#' options.
#'
#' # YAML config
#' You can exclude some paths from the search index using `search.exclude`.
#' Below we exclude the changelog from the search index:
#'
#' ```yaml
#' search:
#'   exclude: ['news/index.html']
#' ```
#' # Debugging and local testing
#'
#' Locally (as opposed to on GitHub Pages or Netlify for instance),
#' search won't work if you simply use pkgdown preview of the static files.
#' You can use `servr::httw("docs")` instead.
#'
#' If search is not working, run `pkgdown::pkgdown_sitrep()` to eliminate
#' common issues such as the absence of URL in the pkgdown configuration file
#' of your package.
#'
#' @inheritParams build_articles
#' @export
#'
build_search <- function(pkg = ".",
                         override = list()) {
  pkg <- section_init(pkg, override = override)
  cli::cli_rule("Building search index")

  search_index <- build_search_index(pkg)
  jsonlite::write_json(
    search_index,
    path(pkg$dst_path, "search.json"),
    auto_unbox = TRUE
  )
}

build_search_index <- function(pkg) {
  paths <- get_site_paths(pkg)
  paths <- paths[!paths %in% c("404.html", "articles/index.html", "reference/index.html")]

  # user-defined exclusions
  paths <- paths[!paths %in% config_pluck_character(pkg, "search.exclude")]

  if ("news/index.html" %in% paths) {
    index <- lapply(paths[paths != "news/index.html"], file_search_index, pkg = pkg)
    index <- unlist(index, recursive = FALSE)
    index <- c(index, news_search_index("news/index.html", pkg = pkg))
  } else {
    index <- lapply(paths, file_search_index, pkg = pkg)
    index <- unlist(index, recursive = FALSE)
  }

  # Make URLs absolute if possible
  url <- config_pluck_string(pkg, "url", default = "")
  fix_path <- function(x) {
    x$path <- sprintf("%s%s", url, x$path)
    x
  }
  purrr::map(index, fix_path)
}

news_search_index <- function(path, pkg) {
  html <- xml2::read_html(path(pkg$dst_path, path), encoding = "UTF-8")

  # Get contents minus logo
  node <- xml2::xml_find_all(html, ".//main")
  xml2::xml_remove(xml2::xml_find_first(node, ".//img[contains(@class, 'pkg-logo')]"))
  sections <- xml2::xml_find_all(node, ".//*[contains(@class, 'section')]")

  purrr::pmap(
    list(
      sections,
      purrr::map_chr(sections, get_headings, depth = 4),
      title = purrr::map_chr(sections, get_version)
    ),
    bs4_index_data,
    dir = "Changelog",
    path = paste0("/", pkg$prefix, path)
  )
}

file_search_index <- function(path, pkg) {
  html <- xml2::read_html(path(pkg$dst_path, path), encoding = "UTF-8")
  # Get page title
  title_element <- xml2::xml_find_first(html, ".//meta[@property='og:title']")
  title <- xml2::xml_attr(title_element, "content")

  # Get contents minus logo
  node <- xml2::xml_find_all(html, ".//main")
  xml2::xml_remove(xml2::xml_find_first(node, ".//img[contains(@class, 'pkg-logo')]"))
  sections <- xml2::xml_find_all(node, ".//div[contains(@class, 'section')]|.//section")

  purrr::pmap(
    list(
      sections,
      purrr::map_chr(sections, get_headings, depth = 3),
      title = title
    ),
    bs4_index_data,
    dir = get_dir(path),
    path = paste0("/", pkg$prefix, path)
  )

}
# Directory parts (where in the site)
get_dir <- function(path) {
  dir <- path_dir(path)
  if (dir == ".") {
    return("")
  }
  paste(capitalise(unlist(path_split(dir))), collapse = " > ")
}
# Headings (where in the page)
get_headings <- function(section, depth) {
  level <- get_section_level(section)
  if (level < depth) {
    return("")
  }

  headings <- purrr::map_chr(seq(depth - 1, level - 1), get_h, section = section)
  paste0(headings[headings != ""], collapse = " > ")
}
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
get_version <- function(section) {
  parents <- xml2::xml_parents(section)
  parents <- parents[!is.na(xml2::xml_attr(parents, "class"))]
  h_section <- parents[grepl("section level2", xml2::xml_attr(parents, "class"))]
  if (length(h_section) == 0) {
    h <- xml2::xml_contents(section)[is_heading(xml2::xml_contents(section))]
  } else {
    h <- xml2::xml_contents(h_section)[is_heading(xml2::xml_contents(h_section))]
  }

  sub("^\\n", "", xml_text1(h))
}
# edited from https://github.com/rstudio/bookdown/blob/abd461593033294d82427139040a0a03cfa0390a/R/bs4_book.R#L518
# index -------------------------------------------------------------------

bs4_index_data <- function(node, previous_headings, title, dir, path) {
  # Make a copy of the node because we will remove contents from it for getting the data
  node_copy <- node
  # remove sections nested inside the current section to prevent duplicating content
  xml2::xml_remove(xml2::xml_find_all(node_copy, ".//*[contains(@class, 'section')]"))
  # remove dont-index sections
  xml2::xml_remove(xml2::xml_find_all(node_copy, ".//*[contains(@class, 'dont-index')]"))

  # Helpers for XPath queries
  # We want to find all nodes corresponding to ... but whose descendants
  # do not correspond to any ... otherwise we would treat some text/code twice,
  # e.g. the text of p nested within li.
  all <- function(...) {
    not <- sprintf("[not(%s)]", paste0(paste0("descendant::", c(...)), collapse = "|"))
    paste0(".//", c(...), not, collapse = "|")
  }
  text_xpath <- all("p", "li", "caption", "figcaption", "dt", "dd", "blockquote", "div[contains(@class, 'line-block')]")
  code_xpath <- all("pre")
  code <- xml2::xml_find_all(node_copy, code_xpath)

  # Special case for definitions (mostly encountered in Rd files)
  if (xml2::xml_name(node_copy) == "dt") {
    # both argument name and definition
    text <- paste(
      xml_text1(node_copy),
      xml_text1(xml2::xml_find_first(node_copy, "following-sibling::*")),
      collapse = " "
    )
    heading <- paste(xml_text1(node_copy), "(argument)")
  } else {
    # Other cases
    text <- xml_text1(xml2::xml_find_all(node_copy, text_xpath))
    children <- xml2::xml_children(node_copy)
    heading_node <- children[purrr::map_lgl(children, is_heading)][1]
    heading <- xml_text1(heading_node)

    # Add heading for Usage section of Rd
    if (xml2::xml_attr(node_copy, "id", default = "") == "ref-usage") {
      heading <- "Usage"
    }
  }

  # If no specific heading, use the title
  if (nchar(heading) == 0) {
    heading <- title
    previous_headings <- ""
  }

  index_data <- list(
    path = path,
    id = section_id(node_copy),
    dir = dir,
    previous_headings = previous_headings,
    what = heading,
    title = title,
    text = strip_stop_words(text),
    code = xml_text1(code)
  )

  if (index_data$text == "" && index_data$code == "") {
    return(NULL)
  }

  index_data
}

xml_text1 <- function(x) {
  trimws(
    gsub("(\r\n|\r|\n)", " ",
      paste0(trimws(xml2::xml_text(x)), collapse = " ")
    )
  )
}

strip_stop_words <- function(x) {
  # paste(tidytext::get_stopwords()$word, collapse = "|")
  pattern <- "\\b(i|me|my|myself|we|our|ours|ourselves|you|your|yours|yourself|yourselves|he|him|his|himself|she|her|hers|herself|it|its|itself|they|them|their|theirs|themselves|what|which|who|whom|this|that|these|those|am|is|are|was|were|be|been|being|have|has|had|having|do|does|did|doing|would|should|could|ought|i'm|you're|he's|she's|it's|we're|they're|i've|you've|we've|they've|i'd|you'd|he'd|she'd|we'd|they'd|i'll|you'll|he'll|she'll|we'll|they'll|isn't|aren't|wasn't|weren't|hasn't|haven't|hadn't|doesn't|don't|didn't|won't|wouldn't|shan't|shouldn't|can't|cannot|couldn't|mustn't|let's|that's|who's|what's|here's|there's|when's|where's|why's|how's|a|an|the|and|but|if|or|because|as|until|while|of|at|by|for|with|about|against|between|into|through|during|before|after|above|below|to|from|up|down|in|out|on|off|over|under|again|further|then|once|here|there|when|where|why|how|all|any|both|each|few|more|most|other|some|such|no|nor|not|only|own|same|so|than|too|very|will)\\b ?"
  gsub(pattern, "", x, ignore.case = TRUE)
}

is_heading <- function(node) {
  xml2::xml_name(node) %in% c("h1", "h2", "h3", "h4", "h5")
}

capitalise <- function(string) {
  paste0(toupper(substring(string, 1, 1)), substring(string, 2))
}

get_site_paths <- function(pkg) {
  paths <- dir_ls(pkg$dst_path, glob = "*.html", recurse = TRUE)
  paths_rel <- path_rel(paths, pkg$dst_path)

  # do not include dev package website in search index / sitemap
  paths_rel <- paths_rel[!path_has_parent(paths_rel, pkg$development$destination)]

  # do not include redirects
  redirects <- purrr::map_chr(data_redirects(pkg, has_url = TRUE), 1)
  setdiff(paths_rel, redirects)
}
