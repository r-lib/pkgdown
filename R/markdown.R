markdown <- function(path = NULL, ..., strip_header = FALSE) {
  tmp <- tempfile(fileext = ".html")
  on.exit(file_delete(tmp), add = TRUE)

  if (rmarkdown::pandoc_available("2.0")) {
    from <- "markdown_github-hard_line_breaks+smart+auto_identifiers+tex_math_dollars+tex_math_single_backslash+markdown_in_html_blocks"
  } else if (rmarkdown::pandoc_available("1.12.3")) {
    from <- "markdown_github-hard_line_breaks+tex_math_dollars+tex_math_single_backslash"
  } else {
    stop("Pandoc not available", call. = FALSE)
  }

  rmarkdown::pandoc_convert(
    input = path,
    output = tmp,
    from = from,
    to = "html",
    options = purrr::compact(c(
      if (!rmarkdown::pandoc_available("2.0")) "--smart",
      if (rmarkdown::pandoc_available("2.0")) c("-t", "html4"),
      "--indented-code-classes=R",
      "--section-divs",
      ...
    ))
  )

  xml <- xml2::read_html(tmp, encoding = "UTF-8")

  if (!inherits(xml, "xml_node")) {
    return("")
  }

  # Capture heading, and optional remove
  h1 <- xml2::xml_find_first(xml, ".//h1")
  title <- xml2::xml_text(h1)
  if (strip_header) {
    xml2::xml_remove(h1)
  }

  downlit::downlit_html_node(xml)
  tweak_md_links(xml)
  tweak_anchors(xml, only_contents = FALSE)

  # Extract body of html - as.character renders as xml which adds
  # significant whitespace in tags like pre
  xml %>%
    xml2::xml_find_first(".//body") %>%
    xml2::write_html(tmp, format = FALSE)

  lines <- read_lines(tmp)
  lines <- sub("<body>", "", lines, fixed = TRUE)
  lines <- sub("</body>", "", lines, fixed = TRUE)

  structure(
    paste(lines, collapse = "\n"),
    title = title
  )
}

markdown_text <- function(text, ...) {
  if (identical(text, NA_character_) || is.null(text)) {
    return(NULL)
  }


  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)

  write_lines(text, path = tmp)
  markdown(tmp, ...)
}
