build_llm_docs <- function(pkg = ".") {
  rlang::check_installed("pandoc")
  pkg <- as_pkgdown(pkg)

  cli::cli_rule("Building docs for llms")
  paths <- get_site_paths(pkg)

  purrr::walk(paths, convert_md, pkg = pkg)

  index <- c(
    read_lines(path(pkg$dst_path, "index.md")),
    read_file_if_exists(path(pkg$dst_path, "reference", "index.md")),
    read_file_if_exists(path(pkg$dst_path, "articles", "index.md"))
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
  # website for a package without README/index.md
  if (length(title) > 0) {
    xml2::xml_remove(
      xml2::xml_find_first(main_html, ".//div[@class='page-header']")
    )
    xml2::xml_add_child(main_html, title, .where = 0)
  }

  # drop internal anchors
  xml2::xml_remove(xml2::xml_find_all(main_html, ".//a[@class='anchor']"))

  # replace all links with absolute link to .md
  create_absolute_links(main_html, pkg)

  pandoc::pandoc_convert(
    text = main_html,
    from = "html",
    to = "markdown_strict+definition_lists+footnotes+backtick_code_blocks",
    output = path_ext_set(path, "md")
  )
}

# Helpers ---------------------------------------------------------------------

read_file_if_exists <- function(path) {
  if (file_exists(path)) {
    read_lines(path)
  }
}

create_absolute_links <- function(main_html, pkg) {
  a <- xml2::xml_find_all(main_html, ".//a")
  if (!is.null(pkg$meta$url)) {
    url <- paste0(pkg$meta$url, "/")
    if (pkg$development$in_dev && pkg$bs_version > 3) {
      url <- paste0(url, pkg$prefix)
    }
    a_external <- a[!grepl("external-link", xml2::xml_attr(a, "class"))]

    href_absolute <- xml2::url_absolute(xml2::xml_attr(a_external, "href"), url)
    href_absolute <- path_ext_set(href_absolute, "md")
  }
  xml2::xml_attr(a, "class") <- NULL
}
