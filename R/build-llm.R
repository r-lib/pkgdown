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

  # fix code
  convert_code_chunks(main_html)

  # fix badges
  convert_lifecycle_badges(main_html)

  # drop internal anchors
  xml2::xml_remove(xml2::xml_find_all(main_html, ".//a[@class='anchor']"))

  # replace all links with absolute link to .md
  create_absolute_links(main_html, pkg)

  pandoc::pandoc_convert(
    text = main_html,
    from = "html",
    to = "gfm+definition_lists-raw_html",
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
    a_internal <- a[
      !startsWith(xml2::xml_attr(a, "href"), "https") &
        !startsWith(xml2::xml_attr(a, "href"), "#")
    ]

    href_absolute <- xml2::url_absolute(xml2::xml_attr(a_internal, "href"), url)
    href_absolute <- sub("html$", "md", href_absolute)
    xml2::xml_attr(a_internal, "href") <- href_absolute
  }

  xml2::xml_attr(a, "class") <- NULL
}

convert_popovers_to_footnotes <- function(main_html) {
  popover_refs <- xml2::xml_find_all(
    main_html,
    ".//a[@class='footnote-ref']"
  )
  if (length(popover_refs) == 0) {
    return()
  }

  # Create footnotes section
  footnotes_section <- xml2::xml_find_first(
    main_html,
    ".//section[@class='footnotes']"
  )
  if (length(footnotes_section) == 0) {
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

  purrr::iwalk(popover_refs, function(ref, i) {
    text_content <- xml2::xml_attr(ref, "data-bs-content")
    fn_id <- paste0("fn", i)
    fnref_id <- paste0("fnref", i)
    xml2::xml_attrs(ref) <- list(
      href = paste0("#", fn_id),
      id = fnref_id,
      role = "doc-noteref",
      class = "footnote-ref"
    )

    fn_li <- xml2::xml_add_child(footnotes_ol, "li", id = fn_id)
    parsed_content <- xml2::read_html(text_content) |>
      xml2::xml_find_first(".//body") |>
      xml2::xml_children()
    purrr::walk(parsed_content, \(x) xml2::xml_add_child(fn_li, x))
  })
}

convert_lifecycle_badges <- function(html) {
  badges <- xml2::xml_find_all(html, ".//a[contains(@href, 'lifecycle.r')]")

  if (length(badges) == 0) {
    return(invisible())
  }

  purrr::walk(badges, \(x) {
    stage <- sub(
      "https://lifecycle.r-lib.org/articles/stages.html#",
      "",
      xml2::xml_attr(x, "href")
    )
    xml2::xml_replace(
      x,
      "strong",
      stage
    )
  })
}

convert_code_chunks <- function(html) {
  code <- xml2::xml_find_all(html, ".//pre[contains(@class, 'sourceCode')]")

  purrr::walk(
    code,
    \(x) {
      lang <- trimws(sub(
        "sourceCode",
        "",
        sub("downlit", "", xml2::xml_attr(x, "class"))
      ))
      xml2::xml_attr(x, "class") <- lang
    }
  )
}
