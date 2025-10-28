#' Build docs for LLMs
#'
#' @description
#' `build_llm_docs()` creates an `LLMs.txt` at the root of your site
#' that contains the contents of your `README.md`, your reference index,
#' and your articles index. It also creates a `.md` file for every existing
#' `.html` file in your site. Together, this gives an LLM an overview of your
#' package and the ability to find out more by following links.
#'
#' If you don't want these files generated for your site, you can opt-out by
#' adding the following to your `pkgdown.yml`:
#'
#' ```yaml
#' llm-docs: false
#' ```
#'
#' @family site components
#' @inheritParams build_site
#' @export
build_llm_docs <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  if (isFALSE(pkg$meta$`llm-docs`)) {
    return(invisible())
  }

  cli::cli_rule("Building docs for llms")

  paths <- get_site_paths(pkg)
  purrr::walk(paths, \(path) {
    src_path <- path(pkg[["dst_path"]], path)
    dst_path <- path_ext_set(src_path, "md")
    convert_md(src_path, dst_path, full_url(pkg, path))
  })

  index <- c(
    read_lines(path(pkg$dst_path, "index.md")),
    "",
    read_file_if_exists(path(pkg$dst_path, "reference", "index.md")),
    "",
    read_file_if_exists(path(pkg$dst_path, "articles", "index.md"))
  )
  write_lines(index, path(pkg$dst_path, "llms.txt"))

  invisible()
}

full_url <- function(pkg, path) {
  if (is.null(pkg$meta$url)) {
    return()
  }

  url <- paste0(pkg$meta$url, "/")
  if (pkg$development$in_dev) {
    url <- paste0(url, pkg$prefix)
  }

  xml2::url_absolute(paste0(path_dir(path), "/"), url)
}

convert_md <- function(src_path, dst_path, url = NULL) {
  html <- xml2::read_html(src_path)
  main_html <- xml2::xml_find_first(html, ".//main")
  if (length(main_html) == 0) {
    return()
  }

  simplify_page_header(main_html)
  simplify_anchors(main_html)
  simplify_code(main_html)
  simplify_popovers_to_footnotes(main_html)
  simplify_lifecycle_badges(main_html)
  simplify_dls(main_html)
  create_absolute_links(main_html, url)

  path <- file_temp()
  xml2::write_html(main_html, path, format = FALSE)
  on.exit(file_delete(path), add = TRUE)

  rmarkdown::pandoc_convert(
    input = path,
    output = dst_path,
    from = "html",
    to = "gfm+definition_lists-raw_html",
  )
}

# Helpers ---------------------------------------------------------------------

# simplify page header (which includes logo + source link)
simplify_page_header <- function(html) {
  title <- xml2::xml_find_first(html, ".//h1")
  # website for a package without README/index.md
  if (length(title) > 0) {
    xml2::xml_remove(xml2::xml_find_first(html, ".//div[@class='page-header']"))
    xml2::xml_add_child(html, title, .where = 0)
  }
  invisible()
}

# drop internal anchors
simplify_anchors <- function(html) {
  xml2::xml_remove(xml2::xml_find_all(html, ".//a[@class='anchor']"))
  invisible()
}

# strip extraneoous classes
simplify_code <- function(html) {
  extract_lang <- function(class) {
    trimws(gsub("sourceCode|downlit", "", class))
  }
  code <- xml2::xml_find_all(html, ".//pre[contains(@class, 'sourceCode')]")

  purrr::walk(code, \(x) {
    xml2::xml_attr(x, "class") <- extract_lang(xml2::xml_attr(x, "class"))
  })
  invisible()
}

simplify_popovers_to_footnotes <- function(main_html) {
  popover_refs <- xml2::xml_find_all(main_html, ".//a[@class='footnote-ref']")
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

simplify_lifecycle_badges <- function(html) {
  # on reference index
  badges <- xml2::xml_find_all(html, "//span[contains(@class, 'lifecycle')]")
  xml2::xml_replace(badges, "strong", paste0("[", xml2::xml_text(badges), "]"))

  # on individual pages
  badges <- xml2::xml_find_all(
    html,
    "//a[.//img[starts-with(@src, 'figures/lifecycle-')]]"
  )
  imgs <- xml2::xml_find_first(badges, ".//img")
  xml2::xml_replace(badges, "strong", tolower(xml2::xml_attr(imgs, "alt")))

  invisible()
}

create_absolute_links <- function(main_html, url = NULL) {
  a <- xml2::xml_find_all(main_html, ".//a")
  xml2::xml_attr(a, "class") <- NULL

  href <- xml2::xml_attr(a, "href")
  is_internal <- !is.na(href) &
    !startsWith(href, "https") &
    !startsWith(href, "#")
  if (!is.null(url)) {
    href[is_internal] <- xml2::url_absolute(href[is_internal], url)
  }
  href[is_internal] <- sub("html$", "md", href[is_internal])

  xml2::xml_attr(a[is_internal], "href") <- href[is_internal]

  invisible()
}

read_file_if_exists <- function(path) {
  if (file_exists(path)) {
    read_lines(path)
  }
}
