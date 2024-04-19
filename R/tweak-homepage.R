tweak_homepage_html <- function(html,
                                strip_header = FALSE,
                                sidebar = TRUE,
                                show_badges = TRUE,
                                bs_version = 3,
                                logo = NULL) {

  html <- tweak_sidebar_html(html, sidebar = sidebar, show_badges = show_badges)

  # Always remove dummy page header
  header <- xml2::xml_find_all(html, ".//div[contains(@class, 'page-header')]")
  if (length(header) > 0)
    xml2::xml_remove(header, free = TRUE)

  header <- xml2::xml_find_first(html, ".//h1")
  if (strip_header) {
    page_header <- xml2::xml_remove(header, free = TRUE)
  } else {
    page_header <- xml2::xml_add_parent(header, "div", class = "page-header")
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

    # Add back to header
    xml2::xml_add_sibling(page_header, "img",
      src = logo,
      class = "logo",
      alt = "",
      .where = "before"
    )
  }

  invisible()
}

tweak_sidebar_html <- function(html, sidebar = TRUE, show_badges = TRUE) {
  if (!sidebar) {
    return(html)
  }

  # this extracts *and removes* badges from HTML
  badges <- badges_extract(html)

  dev_status_html <- html %>% xml2::xml_find_first(".//div[@class='dev-status']")
  if (inherits(dev_status_html, "xml_missing")) {
    return(html)
  }
  if (!show_badges || length(badges) == 0) {
    xml2::xml_remove(dev_status_html)
  } else {
    list <- sidebar_section(tr_("Dev status"), badges)
    list_html <- list %>% xml2::read_html(encoding = "UTF-8") %>% xml2::xml_find_first(".//div")
    xml2::xml_replace(dev_status_html, list_html)
  }

  html
}

# Mutates `html`, removing the badge container
badges_extract <- function(html) {
  # First try specially named element;
  x <- xml2::xml_find_first(html, "//div[@id='badges']")
  strict <- FALSE

  # then try usethis-readme-like more complex structure;
  if (length(x) == 0) {
    # Find start comment, then all elements after
    # which are followed by the end comment.
    x <- xml2::xml_find_all(html, "
      //comment()[contains(., 'badges: start')][1]
      /following-sibling::*[following-sibling::comment()[contains(., 'badges: end')]]
    ")

  }

  # then try usethis-readme-like paragraph;
  # where the badges: end comment is inside the paragraph after badges: start
  if (length(x) == 0) {
    x <- xml2::xml_find_all(html, ".//*/comment()[contains(., 'badges: start')]/following-sibling::p[1]")
  }

  # finally try first paragraph
  if (length(x) == 0) {
    # BS5 (main) and BS3 (div)
    x <- xml2::xml_find_first(html, "//main/p|//div[@class='contents col-md-9']/p")
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
  html <- xml2::read_html(x, encoding = "UTF-8")
  badges_extract(html)
}
