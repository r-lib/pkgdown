# Modifies in place
autolink_html <- function(x, depth = 0L) {
  stopifnot(inherits(x, "xml_node"))

  # <code> with no children
  x %>%
    xml2::xml_find_all(".//code[count(*) = 0]") %>%
    autolink_nodeset(depth = depth)

  # <span class='kw'>
  x %>%
    xml2::xml_find_all(".//span[@class = 'kw']") %>%
    autolink_nodeset(depth = depth, bare_symbol = TRUE)

  invisible()
}
autolink_nodeset <- function(nodes, ...) {
  text <- nodes %>% xml2::xml_text()
  href <- text %>% purrr::map_chr(make_link, ...)

  has_link <- !is.na(href)

  nodes[has_link] %>%
    xml2::xml_contents() %>%
    xml2::xml_replace("a", href = href[has_link], text[has_link])

  invisible()
}
make_link <- function(string, ...) {
  expr <- tryCatch(parse(text = string)[[1]], error = function(e) NULL)
  if (is.null(expr)) {
    return(NA_character_)
  }

  href <- href_expr(expr, ...)
  if (is.null(href)) {
    return(NA_character_)
  }
  href
}

# Helper for testing
autolink_html_ <- function(x, ...) {
  x <- paste0("<html><body>", x, "</body></html>")
  xml <- xml2::read_html(x)

  autolink_html(xml, ...)

  xml %>%
    xml2::xml_find_first(".//body[1]") %>%
    xml2::xml_children() %>%
    as.character()
}
