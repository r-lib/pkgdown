
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
  xml <- xml2::read_html(x, encoding = "UTF-8")
  badges_extract(xml)
}
