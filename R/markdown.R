markdown <- function(path = NULL, ..., strip_header = FALSE, pkg) {
  tmp <- tempfile(fileext = ".html")
  on.exit(unlink(tmp), add = TRUE)

  if (rmarkdown::pandoc_available("2.0")) {
    from <- "markdown+gfm_auto_identifiers-citations+emoji+autolink_bare_uris"
  } else if (rmarkdown::pandoc_available("1.12.3")) {
    from <- "markdown_github-hard_line_breaks+tex_math_dollars+tex_math_single_backslash+header_attributes"
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
  tweak_all_links(xml, pkg = pkg)
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

markdown_text <- function(text, pkg = pkg, ...) {
  if (identical(text, NA_character_) || is.null(text)) {
    return(NULL)
  }

  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)

  write_lines(text, path = tmp)
  markdown(tmp, ..., pkg = pkg)
}


markdown_text_children <- function(text, pkg, ...) {

  html <- markdown_text(text, pkg = pkg, ...)
  html %>%
    xml2::read_html() %>%
    xml2::xml_child() %>% # body
    xml2::xml_children()

}

markdown_inline <- function(text, pkg, where, ...) {

  if (is.null(text)) {
    return(NULL)
  }

  children <- markdown_text_children(text, pkg = pkg, ...)

  if (length(children) > 1) {
    abort(
      sprintf(
        "Can't use a block element here, need an inline element: \n %s \n%s",
        what = pkgdown_field(pkg = pkg, where),
        text
      )
    )
  }

  paste0(xml2::xml_contents(children), collapse="")

}

markdown_block <- function(text, pkg, ...) {

  if (is.null(text)) {
    return(NULL)
  }

  children <- markdown_text_children(text, pkg = pkg, ...)
  output <- paste0(as.character(children, options = character()), collapse="")
  gsub("\\\n", "", output)
}