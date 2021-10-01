tweak_anchors <- function(html, only_contents = TRUE) {
  if (only_contents) {
    sections <- xml2::xml_find_all(html, ".//div[@class='contents']//div[@id]")
  } else {
    sections <- xml2::xml_find_all(html, "//div[@id]")
  }

  if (length(sections) == 0)
    return()

  # Update anchors: dot in the anchor breaks scrollspy
  anchor <- sections %>%
    xml2::xml_attr("id") %>%
    gsub(".", "-", ., fixed = TRUE)
  purrr::walk2(sections, anchor, ~ (xml2::xml_attr(.x, "id") <- .y))

  # Update href of toc anchors , use "-" instead "."
  toc_nav <- xml2::xml_find_all(html, ".//div[@id='tocnav']//a")
  hrefs <- toc_nav %>%
    xml2::xml_attr("href") %>%
    gsub(".", "-", ., fixed = TRUE)
  purrr::walk2(toc_nav, hrefs, ~ (xml2::xml_attr(.x, "href") <- .y))

  headings <- xml2::xml_find_first(sections, ".//h1|h2|h3|h4|h5")
  has_heading <- !is.na(xml2::xml_name(headings))

  for (i in seq_along(headings)[has_heading]) {
    # Insert anchor in first element of header
    heading <- headings[[i]]
    if (length(xml2::xml_contents(heading)) == 0) {
      # skip empty headings
      next
    }

    xml2::xml_attr(heading, "class") <- "hasAnchor"
    xml2::xml_add_sibling(
      xml2::xml_contents(heading)[[1]],
      "a", href = paste0("#", anchor[[i]]),
      class = "anchor",
      `aria-hidden` = "true",
      .where = "before"
    )
  }
  invisible()
}

tweak_md_links <- function(html) {
  links <- xml2::xml_find_all(html, ".//a")
  if (length(links) == 0)
    return()

  hrefs <- xml2::xml_attr(links, "href")
  needs_tweak <- grepl("\\.md$", hrefs) & xml2::url_parse(hrefs)$scheme == ""

  fix_links <- function(x) {
    x <- gsub("\\.md$", ".html", x)
    x <- gsub("\\.github/", "", x)
    x
  }

  if (any(needs_tweak)) {
    purrr::walk2(
      links[needs_tweak],
      fix_links(hrefs[needs_tweak]),
      xml2::xml_set_attr,
      attr = "href"
    )
  }

  invisible()
}

tweak_all_links <- function(html, pkg = list()) {
  links <- xml2::xml_find_all(html, ".//a")
  if (length(links) == 0)
    return()

  hrefs <- xml2::xml_attr(links, "href")
  # Users might have added absolute URLs to e.g. the Code of Conduct
  tweak_class_prepend(links[!is_internal_link(hrefs, pkg = pkg)], "external-link")

  invisible()
}

tweak_404 <- function(html, pkg = pkg) {

  # If there's no URL links can't be made absolute
  if (is.null(pkg$meta$url)) {
    return()
  }

  url <- paste0(pkg$meta$url, "/")

  # Links
  links <- xml2::xml_find_all(html, ".//a | .//link")
  rel_links <- links[!grepl("https?\\://", xml2::xml_attr(links, "href"))]
  if (length(rel_links) > 0) {
    new_urls <- paste0(url, xml2::xml_attr(rel_links, "href"))
    xml2::xml_attr(rel_links, "href") <- new_urls
  }

  # Scripts
  scripts <- xml2::xml_find_all(html, ".//script")
  scripts <- scripts[!is.na(xml2::xml_attr(scripts, "src"))]
  rel_scripts <- scripts[!grepl("https?\\://", xml2::xml_attr(scripts, "src"))]
  if (length(rel_scripts) > 0) {
    new_srcs <- paste0(url, xml2::xml_attr(rel_scripts, "src"))
    xml2::xml_attr(rel_scripts, "src") <- new_srcs
  }

  # Logo
  logo <- xml2::xml_find_first(html, ".//img[@class='pkg-logo']")
  if (inherits(logo, "xml_node")) {
    xml2::xml_attr(logo, "src") <- paste0(url, logo_path(pkg, depth = 0))
  }

  TRUE
}

tweak_tables <- function(html) {
  # Ensure all tables have class="table"
  table <- xml2::xml_find_all(html, ".//table")
  tweak_class_prepend(table, "table")

  invisible()
}

# from https://github.com/rstudio/bookdown/blob/ed31991df3bb826b453f9f50fb43c66508822a2d/R/bs4_book.R#L307
tweak_footnotes <- function(html) {
  container <- xml2::xml_find_all(html, ".//div[@class='footnotes']")
  if (length(container) != 1) {
    return()
  }
  # Find id and contents
  footnotes <- xml2::xml_find_all(container, ".//li")
  id <- xml2::xml_attr(footnotes, "id")
  xml2::xml_remove(xml2::xml_find_all(footnotes, "//a[@class='footnote-back']"))
  contents <- vapply(footnotes, FUN.VALUE = character(1), function(x) {
    as.character(xml2::xml_children(x), options = character())
  })
  # Add popover attributes to links
  for (i in seq_along(id)) {
    links <- xml2::xml_find_all(html, paste0(".//a[@href='#", id[[i]], "']"))
    xml2::xml_attr(links, "href") <- NULL
    xml2::xml_attr(links, "id") <- NULL
    xml2::xml_attr(links, "tabindex") <- "0"
    xml2::xml_attr(links, "data-toggle") <- "popover"
    xml2::xml_attr(links, "data-content") <- contents[[i]]
  }
  # Delete container
  xml2::xml_remove(container)
}
