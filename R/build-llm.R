build_llm_docs <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  cli::cli_rule("Building llm documentation")
  if (pkg$development$in_dev && pkg$bs_version > 3) {
    url <- paste0(url, pkg$prefix)
  }

  paths <- get_site_paths(pkg)
  purrr::walk(paths, build_md, pkg = pkg)

  index <- c(
    read_file_if_exists(path(pkg$dst_path, "index.html.md")),
    read_file_if_exists(path(pkg$dst_path, "reference", "index.html.md")),
    read_file_if_exists(path(pkg$dst_path, "articles", "index.html.md"))
  )
  writeLines(index, path(pkg$dst_path, "llms.txt"))

  invisible()
}

read_file_if_exists <- function(path) {
  if (file_exists(path)) {
    read_lines(path)
  }
}

build_md <- function(path, pkg) {
  rlang::check_installed("pandoc")
  path <- path(pkg[["dst_path"]], path)

  main_html <- xml2::read_html(path) |>
    xml2::xml_find_first(".//main")

  if (length(main_html) == 0) {
    return()
  }

  # uninformative image (logo) + source link
  title <- xml2::xml_find_first(main_html, ".//h1")
  xml2::xml_remove(
    xml2::xml_find_first(main_html, ".//div[@class='page-header']")
  )
  xml2::xml_add_child(main_html, title, .where = 0)

  # clean links
  xml2::xml_remove(xml2::xml_find_all(main_html, ".//a[@class='anchor']"))

  internal_links <- xml2::xml_find_all(
    main_html,
    ".//a[not(@class='external-link')]"
  )

  purrr::walk(
    internal_links,
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
