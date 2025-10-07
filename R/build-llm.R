build_llm_docs <- function(pkg = ".") {
  rlang::check_installed("pandoc")
  pkg <- as_pkgdown(pkg)

  cli::cli_rule("Building llm documentation")
  paths <- get_site_paths(pkg)
  purrr::walk(paths, convert_md, pkg = pkg)

  index <- c(
    read_file_if_exists(path(pkg$dst_path, "index.html.md")),
    read_file_if_exists(path(pkg$dst_path, "reference", "index.html.md")),
    read_file_if_exists(path(pkg$dst_path, "articles", "index.html.md"))
  )
  writeLines(index, path(pkg$dst_path, "llms.txt"))

  invisible()
}

convert_md <- function(path, pkg) {
  path <- path(pkg[["dst_path"]], path)

  html <- xml2::read_html(path)
  main_html <- xml2::xml_find_first(html, ".//main")
  if (length(main_html) == 0) {
    return()
  }

  # simplify page header (which includes logo + source link)
  title <- xml2::xml_find_first(main_html, ".//h1")
  xml2::xml_remove(
    xml2::xml_find_first(main_html, ".//div[@class='page-header']")
  )
  xml2::xml_add_child(main_html, title, .where = 0)

  # drop anchors
  xml2::xml_remove(xml2::xml_find_all(main_html, ".//a[@class='anchor']"))

  # replace all internal links with absolute link to .md
  internal <- xml2::xml_find_all(main_html, ".//a[not(@class='external-link')]")
  purrr::walk(
    internal,
    add_website_url,
    pkg = pkg,
    root = fs::path_rel(fs::path_dir(path), start = pkg$dst_path)
  )
  xml2::xml_set_attr(
    xml2::xml_find_all(main_html, ".//a[@class='external-link']"),
    attr = "class",
    value = NULL
  )

  pandoc::pandoc_convert(
    text = main_html,
    from = "html",
    to = "markdown_strict+definition_lists+footnotes+backtick_code_blocks",
    output = sprintf("%s.md", path)
  )
}

# Helpers ---------------------------------------------------------------------

add_website_url <- function(node, pkg, root) {
  url <- sprintf("%s/", config_pluck_string(pkg, "url"))
  if (pkg$development$in_dev && pkg$bs_version > 3) {
    url <- paste0(url, pkg$prefix)
  }

  if (root != ".") {
    url <- sprintf("%s%s/", url, root)
  }

  xml2::xml_set_attr(
    node,
    attr = "href",
    value = sprintf("%s%s.md", url, xml2::xml_attr(node, "href"))
  )
}


read_file_if_exists <- function(path) {
  if (file_exists(path)) {
    read_lines(path)
  }
}
