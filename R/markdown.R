markdown <- function(path = NULL, ...) {
  tmp <- tempfile(fileext = ".html")
  on.exit(file_delete(tmp), add = TRUE)

  if (rmarkdown::pandoc_available("2.0")) {
    from <- "markdown_github-hard_line_breaks+smart"
  } else {
    from <- "markdown_github-hard_line_breaks"
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
  tweak_code(xml)
  tweak_anchors(xml, only_contents = FALSE)

  # Extract body of html - as.character renders as xml which adds
  # significant whitespace in tags like pre
  xml %>%
    xml2::xml_find_first(".//body") %>%
    xml2::write_html(tmp, format = FALSE)

  lines <- readLines(tmp, warn = FALSE)
  lines <- sub("<body>", "", lines, fixed = TRUE)
  lines <- sub("</body>", "", lines, fixed = TRUE)
  paste(lines, collapse = "\n")
}

markdown_text <- function(text, ...) {
  if (is.null(text))
    return(text)

  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)

  write_utf8(text, path = tmp, sep = "\n")
  markdown(tmp, ...)
}
