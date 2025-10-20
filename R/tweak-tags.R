tweak_anchors <- function(html) {
  headings <- xml2::xml_find_all(html, ".//h1|.//h2|.//h3|.//h4|.//h5|.//h6")
  # Find all headings that are contained in a div with an id and
  # have class 'section'

  is_ok <- xml2::xml_find_lgl(
    headings,
    "boolean(
      (parent::div[contains(@class, 'section') and @id]) or
      (parent::section[@id])
    )"
  )
  headings <- headings[is_ok]
  if (length(headings) == 0) {
    return(invisible())
  }

  id <- xml2::xml_find_chr(
    headings,
    "string(parent::div/@id|parent::section/@id)"
  )

  # Update ids: dot in the anchor breaks scrollspy and rd translation
  # doesn't have enough information to generate unique ids
  new_id <- make.unique(gsub(".", "-", id, fixed = TRUE), "-")

  # Move ids to headings so that the js TOC doesn't add create new ids
  divs <- xml2::xml_parent(headings)
  xml2::xml_attr(divs, "id") <- NULL
  xml2::xml_attr(headings, "id") <- new_id

  # Insert anchors
  anchor <- anchor_html(new_id)
  for (i in seq_along(headings)) {
    heading <- headings[[i]]
    if (length(xml2::xml_contents(heading)) == 0) {
      # skip empty headings
      next
    }
    # Insert anchor in first element of header
    xml2::xml_add_child(heading, xml2::read_xml(anchor[[i]]))
  }
  invisible()
}

anchor_html <- function(id) {
  paste0("<a class='anchor' aria-label='anchor' href='#", id, "'></a>")
}

tweak_link_md <- function(html) {
  links <- xml2::xml_find_all(html, ".//a")
  if (length(links) == 0) {
    return()
  }

  hrefs <- xml2::xml_attr(links, "href")

  urls <- xml2::url_parse(hrefs)
  needs_tweak <- urls$scheme == "" & grepl("\\.md$", urls$path)

  fix_links <- function(x) {
    x <- gsub("\\.md\\b", ".html", x)
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

tweak_link_external <- function(html, pkg = list()) {
  links <- xml2::xml_find_all(html, ".//a")
  if (length(links) == 0) {
    return()
  }

  links <- links[!has_class(links, "external-link")]

  hrefs <- xml2::xml_attr(links, "href")
  links <- links[!is_internal_link(hrefs, pkg = pkg)]

  # Users might have added absolute URLs to e.g. the Code of Conduct
  tweak_class_prepend(links, "external-link")

  invisible()
}

# Fix relative image links
tweak_img_src <- function(html) {
  fix_path <- function(x) {
    x <- gsub("(^|/)vignettes/", "\\1articles/", x, perl = TRUE)
    x <- gsub("(^|/)man/figures/", "\\1reference/figures/", x, perl = TRUE)
    x
  }

  imgs <- xml2::xml_find_all(html, ".//img[not(starts-with(@src, 'http'))]")
  urls <- fix_path(xml2::xml_attr(imgs, "src"))
  purrr::map2(imgs, urls, ~ xml2::xml_set_attr(.x, "src", .y))

  imgs <- xml2::xml_find_all(
    html,
    ".//source[not(starts-with(@srcset, 'http'))]"
  )
  urls <- fix_path(xml2::xml_attr(imgs, "srcset"))
  purrr::map2(imgs, urls, ~ xml2::xml_set_attr(.x, "srcset", .y))

  invisible()
}

tweak_link_absolute <- function(html, pkg = list()) {
  # If there's no URL links can't be made absolute
  if (is.null(pkg$meta$url)) {
    return()
  }

  url <- paste0(pkg$meta$url, "/")

  # <a> + <link> use href
  href <- xml2::xml_find_all(html, ".//a | .//link")
  xml2::xml_attr(href, "href") <- xml2::url_absolute(
    xml2::xml_attr(href, "href"),
    url
  )

  # <img> + <script> uses src
  src <- xml2::xml_find_all(html, ".//script | .//img")
  xml2::xml_attr(src, "src") <- xml2::url_absolute(
    xml2::xml_attr(src, "src"),
    url
  )

  invisible()
}

tweak_link_R6 <- function(html, cur_package) {
  r6_span <- xml2::xml_find_all(html, ".//span[@class=\"pkg-link\"]")
  if (length(r6_span) == 0) {
    return()
  }

  pkg <- xml2::xml_attr(r6_span, "data-pkg")
  topic <- xml2::xml_attr(r6_span, "data-topic")
  id <- xml2::xml_attr(r6_span, "data-id")

  url <- paste0(topic, ".html")
  external <- pkg != cur_package
  if (any(external)) {
    url[external] <- purrr::map2_chr(
      topic[external],
      pkg[external],
      downlit::href_topic
    )
  }
  url <- paste0(url, ifelse(is.na(id), "", "#method-"), id)

  r6_a <- xml2::xml_find_first(r6_span, "./a")
  xml2::xml_attr(r6_a, "href") <- url

  invisible()
}

# Fix seealso links
tweak_link_seealso <- function(html) {
  seealso_links <- xml2::xml_find_all(html, "//code[a and text() = '()']")

  # add () inside link
  seealso_text <- xml2::xml_children(seealso_links)
  xml2::xml_text(seealso_text) <- paste0(xml2::xml_text(seealso_text), "()")

  # remove () outside the link
  text_nodes <- xml2::xml_find_all(seealso_links, "./text()[. = '()']")
  xml2::xml_remove(text_nodes)

  invisible()
}

tweak_tables <- function(html) {
  # Ensure all tables have class="table" apart from arguments
  table <- xml2::xml_find_all(html, ".//table")
  table <- table[!has_class(table, "ref-arguments")]

  tweak_class_prepend(table, "table")

  invisible()
}

# from https://github.com/rstudio/bookdown/blob/ed31991df3bb826b453f9f50fb43c66508822a2d/R/bs4_book.R#L307
tweak_footnotes <- function(html) {
  container <- xml2::xml_find_all(
    html,
    ".//div[contains(@class, 'footnotes')]|.//section[contains(@class, 'footnotes')]"
  )
  if (length(container) != 1) {
    return()
  }
  # Find id and contents
  footnotes <- xml2::xml_find_all(container, ".//li")
  id <- xml2::xml_attr(footnotes, "id")
  xml2::xml_remove(xml2::xml_find_all(footnotes, "//a[@class='footnote-back']"))
  contents <- vapply(footnotes, FUN.VALUE = character(1), function(x) {
    paste(
      as.character(xml2::xml_children(x), options = character()),
      collapse = "\n"
    )
  })
  # Add popover attributes to links
  for (i in seq_along(id)) {
    links <- xml2::xml_find_all(html, paste0(".//a[@href='#", id[[i]], "']"))
    xml2::xml_attr(links, "href") <- NULL
    xml2::xml_attr(links, "id") <- NULL
    xml2::xml_attr(links, "tabindex") <- "0"
    xml2::xml_attr(links, "data-bs-toggle") <- "popover"
    xml2::xml_attr(links, "data-bs-content") <- contents[[i]]
  }
  # Delete container
  xml2::xml_remove(container)
}

tweak_strip <- function(html, in_dev = FALSE) {
  to_remove <- if (in_dev) "pkgdown-release" else "pkgdown-devel"
  xpath <- paste0(
    ".//*[contains(@class, '",
    to_remove,
    "')]|",
    ".//*[contains(@class, 'pkgdown-hide')]"
  )
  nodes <- xml2::xml_find_all(html, xpath)
  xml2::xml_remove(nodes)
}
