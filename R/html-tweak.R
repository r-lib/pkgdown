# Tag level tweaks --------------------------------------------------------

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

tweak_all_links <- function(html, pkg = pkg) {
  links <- xml2::xml_find_all(html, ".//a")
  if (length(links) == 0)
    return()

  hrefs <- xml2::xml_attr(links, "href")
  # Users might have added absolute URLs to e.g. the Code of Conduct
  if (is.null(pkg$meta$url)) {
    needs_tweak <- grepl("https?\\:\\/\\/", hrefs)
  } else {
    url <- pkg$meta$url
    needs_tweak <- grepl("https?\\:\\/\\/", hrefs) & !grepl(url, hrefs)
  }
  tweak_class_prepend(links[needs_tweak], "external-link")

  invisible()
}


tweak_navbar_links <- function(html, pkg = pkg) {

  url <- paste0(pkg$meta$url, "/")

  html <- xml2::read_html(html)

  links <- xml2::xml_find_all(html, ".//a")
  hrefs <- xml2::xml_attr(links, "href")

  needs_tweak <- !grepl("https?\\:\\/\\/", hrefs)

  if (any(needs_tweak)) {
    xml2::xml_attr(links[needs_tweak], "href") <- paste0(
      url,
      xml2::xml_attr(links[needs_tweak], "href")
    )
  }

  return(as.character(xml2::xml_find_first(html, ".//body")))
}

tweak_tables <- function(html) {
  # Ensure all tables have class="table"
  table <- xml2::xml_find_all(html, ".//table")
  tweak_class_prepend(table, "table")

  invisible()
}

tweak_class_prepend <- function(x, class) {
  if (length(x) == 0) {
    return(invisible())
  }

  cur <- xml2::xml_attr(x, "class")
  xml2::xml_attr(x, "class") <- ifelse(is.na(cur), class, paste(class, cur))
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
    as.character(xml2::xml_children(x))
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

# File level tweaks --------------------------------------------

tweak_rmarkdown_html <- function(html, input_path, pkg = pkg) {
  # Automatically link function mentions
  downlit::downlit_html_node(html)
  tweak_anchors(html, only_contents = FALSE)
  tweak_md_links(html)
  tweak_all_links(html, pkg = pkg)
  if (pkg$bs_version > 3) tweak_footnotes(html)

  # Tweak classes of navbar
  toc <- xml2::xml_find_all(html, ".//div[@id='tocnav']//ul")
  xml2::xml_attr(toc, "class") <- "nav nav-pills nav-stacked"

  # Mame sure all images use relative paths
  img <- xml2::xml_find_all(html, "//img")
  src <- xml2::xml_attr(img, "src")
  abs_src <- is_absolute_path(src)
  if (any(abs_src)) {
    purrr::walk2(
      img[abs_src],
      path_rel(src[abs_src], input_path),
      xml2::xml_set_attr,
      attr = "src"
    )
  }

  tweak_tables(html)

  invisible()
}

tweak_homepage_html <- function(html,
  strip_header = FALSE,
  sidebar = TRUE,
  bs_version = 3,
  logo = NULL) {

  html <- tweak_sidebar_html(html, sidebar = sidebar)

  # Always remove dummy page header
  header <- xml2::xml_find_all(html, ".//div[contains(@class, 'page-header')]")
  if (length(header) > 0)
    xml2::xml_remove(header, free = TRUE)

  header <- xml2::xml_find_first(html, ".//h1")
  if (strip_header) {
    xml2::xml_remove(header, free = TRUE)
  } else {
    page_header_text <- class_page_header(bs_version = bs_version, header = header)
    page_header <- xml2::read_html(page_header_text) %>% xml2::xml_find_first("//div")
    xml2::xml_replace(header, page_header)
  }


  # logo
  if (!is.null(logo) && bs_version > 3) {
    # Remove logo if added to h1
    xml2::xml_remove(
      xml2::xml_find_first(
        html,
        ".//h1/img[contains(@src, 'logo')]"
      )
    )

    # Add logo
    xml2::xml_find_first(html,".//div[contains(@class,'contents')]") %>%
      xml2::xml_child() %>%
      xml2::xml_add_sibling(
        "img", src = "package-logo.png",
        id = "logo-homepage", alt = "", width = "120",
        .where = "before"
      )
  }

  # Fix relative image links
  imgs <- xml2::xml_find_all(html, ".//img")
  urls <- xml2::xml_attr(imgs, "src")
  new_urls <- gsub("^vignettes/", "articles/", urls)
  new_urls <- gsub("^man/figures/", "reference/figures/", new_urls)
  purrr::map2(imgs, new_urls, ~ (xml2::xml_attr(.x, "src") <- .y))

  tweak_tables(html)

  invisible()
}

class_page_header <- function(bs_version, header) {
  if (bs_version == 3) {
    paste0("<div class='page-header'>", header, "</div>")
  } else {
    paste0("<div class='pb-2 mt-4 mb-2 border-bottom'>", header, "</div>")
  }
}

tweak_sidebar_html <- function(html, sidebar) {
  if (!sidebar) {
    return(html)
  }

  dev_status_html <- html %>% xml2::xml_find_first(".//div[@class='dev-status']")
  if (!inherits(dev_status_html, "xml_node")) {
    return(html)
  }

  badges <- badges_extract(html)
  if (length(badges) == 0) {
    xml2::xml_remove(dev_status_html)
    return(html)
  }

  list <- sidebar_section("Dev status", badges)
  list_html <- list %>% xml2::read_html() %>% xml2::xml_find_first(".//div")
  xml2::xml_replace(dev_status_html, list_html)
  html
}

# Mutates `html`, removing the badge container
badges_extract <- function(html) {
  # First try specially named element;
  x <- xml2::xml_find_first(html, "//div[@id='badges']")
  strict <- FALSE

  # then try usethis-readme-like paragraph;
  if (length(x) == 0) {
    # Find start comment, then all elements after
    # which are followed by the end comment.
    x <- xml2::xml_find_all(html, "
      //comment()[contains(., 'badges: start')][1]
      /following-sibling::*[following-sibling::comment()[contains(., 'badges: end')]]
    ")
  }

  # finally try first paragraph
  if (length(x) == 0) {
    x <- xml2::xml_find_first(html, "//p")
    strict <- TRUE
  }

  # No paragraph
  if (length(x) == 0) {
    return(character())
  }

  # If we guessed the element,
  # we only proceed if there is no text
  if (strict && any(xml2::xml_text(x, trim = TRUE) != "")) {
    return(character())
  }

  # Proceed if we find image-containing links
  badges <- xml2::xml_find_all(x, ".//a[img]")
  if (length(badges) == 0) {
    return(character())
  }

  xml2::xml_remove(x)

  as.character(badges)
}

badges_extract_text <- function(x) {
  xml <- xml2::read_html(x)
  badges_extract(xml)
}
# Update file on disk -----------------------------------------------------

update_html <- function(path, tweak, ...) {
  html <- xml2::read_html(path, encoding = "UTF-8")
  tweak(html, ...)

  xml2::write_html(html, path, format = FALSE)
  path
}
