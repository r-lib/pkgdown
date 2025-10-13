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

  # fix footnotes
  convert_popovers_to_footnotes(main_html)

  # drop internal anchors
  xml2::xml_remove(xml2::xml_find_all(main_html, ".//a[@class='anchor']"))

  # replace all links with absolute link to .md
  create_absolute_links(main_html, pkg)

  lua_filter <- system.file("pandoc", "badge.lua", package = "pkgdown")
  pandoc::pandoc_convert(
    text = main_html,
    from = "html",
    to = "markdown_strict+definition_lists+footnotes+backtick_code_blocks",
    args = c(sprintf("--lua-filter=%s", lua_filter)),
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

convert_popovers_to_footnotes <- function(main_html) {
  # Find all popover footnote references
  popover_refs <- xml2::xml_find_all(
    main_html,
    ".//a[@class='footnote-ref'][@data-bs-content]"
  )

  if (length(popover_refs) == 0) {
    return(main_html)
  }

  # Create footnotes section if it doesn't exist
  footnotes_section <- xml2::xml_find_first(
    main_html,
    ".//section[@class='footnotes']"
  )
  if (length(footnotes_section) == 0) {
    # Add footnotes section at the end of main
    footnotes_section <- xml2::xml_add_child(
      main_html,
      "section",
      id = "footnotes",
      class = "footnotes footnotes-end-of-document",
      role = "doc-endnotes"
    )
    xml2::xml_add_child(footnotes_section, "hr")
    footnotes_ol <- xml2::xml_add_child(footnotes_section, "ol")
  } else {
    footnotes_ol <- xml2::xml_find_first(footnotes_section, ".//ol")
  }

  # Process each popover reference using purrr
  purrr::iwalk(popover_refs, function(ref, i) {
    # Extract footnote content from data-bs-content
    content <- xml2::xml_attr(ref, "data-bs-content")

    # Decode HTML entities in the content
    content <- xml2::xml_text(xml2::read_html(paste0(
      "<div>",
      content,
      "</div>"
    )))

    # Create footnote ID
    fn_id <- paste0("fn", i)
    fnref_id <- paste0("fnref", i)

    # Update the reference link
    xml2::xml_attr(ref, "href") <- paste0("#", fn_id)
    xml2::xml_attr(ref, "class") <- "footnote-ref"
    xml2::xml_attr(ref, "id") <- fnref_id
    xml2::xml_attr(ref, "role") <- "doc-noteref"
    xml2::xml_set_attr(ref, "tabindex", NULL)
    xml2::xml_set_attr(ref, "data-bs-toggle", NULL)
    xml2::xml_set_attr(ref, "data-bs-content", NULL)

    # Create footnote list item
    fn_li <- xml2::xml_add_child(footnotes_ol, "li", id = fn_id)
    fn_p <- xml2::xml_add_child(fn_li, "p")
    xml2::xml_text(fn_p) <- content

    # Add back reference
    back_ref <- xml2::xml_add_child(
      fn_p,
      "a",
      "↩︎",
      href = paste0("#", fnref_id),
      class = "footnote-back",
      role = "doc-backlink"
    )
  })

  return(main_html)
}
