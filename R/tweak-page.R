# File level tweaks --------------------------------------------

tweak_rmarkdown_html <- function(html, input_path, pkg = pkg) {
  # Automatically link function mentions
  downlit::downlit_html_node(html)
  tweak_anchors(html, only_contents = FALSE)
  tweak_link_md(html)
  tweak_link_external(html, pkg = pkg)

  if (pkg$bs_version > 3) {
    tweak_footnotes(html)
    tweak_tabsets(html)
  }

  # Tweak classes of navbar
  toc <- xml2::xml_find_all(html, ".//div[@id='tocnav']//ul")
  xml2::xml_attr(toc, "class") <- "nav nav-pills nav-stacked"

  # Make sure all images use relative paths
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
    page_header <- xml2::read_html(page_header_text, encoding = "UTF-8") %>% xml2::xml_find_first("//div")
    xml2::xml_replace(header, page_header)
  }

  if (!is.null(logo) && bs_version > 3) {
    # Remove logo if added to h1
    # Bare image
    xml2::xml_remove(xml2::xml_find_all(html, ".//h1/img[contains(@src, 'logo')]"))

    # Image in link
    xml2::xml_remove(
      xml2::xml_parent(
        xml2::xml_find_all(html, ".//h1/a/img[contains(@src, 'logo')]")
      )
    )

    # Add logo
    xml2::xml_find_first(html,".//div[contains(@class,'contents')]") %>%
      xml2::xml_child() %>%
      xml2::xml_add_sibling("img",
        src = logo,
        class = "pkg-logo",
        alt = "",
        width = "120",
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


# Update file on disk -----------------------------------------------------

update_html <- function(path, tweak, ...) {

  raw <- read_file(path)
  # Following the xml 1.0 spec, libxml2 drops low-bit ASCII characters
  # so we convert to \u2029, relying on downlit to convert back in
  # token_escape().
  raw <- gsub("\033", "\u2029", raw, fixed = TRUE)
  html <- xml2::read_html(raw, encoding = "UTF-8")
  tweak(html, ...)

  xml2::write_html(html, path, format = FALSE)
  path
}
