markdown_text <- function(pkg, text, ...) {
  if (identical(text, NA_character_) || is.null(text)) {
    return(NULL)
  }

  md_path <- withr::local_tempfile()
  write_lines(text, md_path)
  markdown_path_html(pkg, md_path, ...)
}

markdown_text_inline <- function(pkg,
                                 text,
                                 error_path,
                                 error_call = caller_env()) {
  html <- markdown_text(pkg, text)
  if (is.null(html)) {
    return()
  }

  children <- xml2::xml_children(xml2::xml_find_first(html, ".//body"))
  if (length(children) > 1) {
    msg <- "{.field {error_path}} must be inline markdown."
    config_abort(pkg, msg, call = error_call)
  }

  paste0(xml2::xml_contents(children), collapse = "")
}

markdown_text_block <- function(pkg, text, ...) {
  html <- markdown_text(pkg, text, ...)
  if (is.null(html)) {
    return()
  }

  children <- xml2::xml_children(xml2::xml_find_first(html, ".//body"))
  paste0(as.character(children, options = character()), collapse = "")
}

markdown_body <- function(pkg, path, strip_header = FALSE) {
  xml <- markdown_path_html(pkg, path, strip_header = strip_header)

  if (is.null(xml)) {
    return(NULL)
  }

  # Extract body of html - as.character renders as xml which adds
  # significant whitespace in tags like pre
  transformed_path <- withr::local_tempfile()
  body <- xml2::xml_find_first(xml, ".//body")
  xml2::write_html(body, transformed_path, format = FALSE)

  lines <- read_lines(transformed_path)
  lines <- sub("<body>", "", lines, fixed = TRUE)
  lines <- sub("</body>", "", lines, fixed = TRUE)

  structure(
    paste(lines, collapse = "\n"),
    title = attr(xml, "title")
  )
}

markdown_path_html <- function(pkg, path, strip_header = FALSE) {
  html_path <- withr::local_tempfile()
  convert_markdown_to_html(pkg, path, html_path)
  xml <- read_html_keep_ansi(html_path)
  if (!inherits(xml, "xml_node")) {
    return(NULL)
  }

  # Capture heading, and optionally remove
  h1 <- xml2::xml_find_first(xml, ".//h1")
  title <- xml2::xml_text(h1)
  if (strip_header) {
    xml2::xml_remove(h1)
  }

  structure(xml, title = title)
}

markdown_to_html <- function(pkg, text, dedent = 4, bs_version = 3) {
  if (dedent) {
    text <- dedent(text, dedent)
  }

  md_path <- withr::local_tempfile()
  html_path <- withr::local_tempfile()

  write_lines(text, md_path)
  convert_markdown_to_html(pkg, md_path, html_path)

  html <- xml2::read_html(html_path, encoding = "UTF-8")
  tweak_page(html, "markdown", list(bs_version = bs_version))
  html
}

dedent <- function(x, n = 4) {
  gsub(paste0("($|\n)", strrep(" ", n)), "\\1", x, perl = TRUE)
}

convert_markdown_to_html <- function(pkg, in_path, out_path, ...) {
  if (rmarkdown::pandoc_available("2.0")) {
    from <- "markdown+gfm_auto_identifiers-citations+emoji+autolink_bare_uris"
  } else if (rmarkdown::pandoc_available("1.12.3")) {
    from <- "markdown_github-hard_line_breaks+tex_math_dollars+tex_math_single_backslash+header_attributes"
  } else {
    if (is_testing()) {
      testthat::skip("Pandoc not available")
    } else {
      cli::cli_abort("Pandoc not available")
    }
  }

  rmarkdown::pandoc_convert(
    input = in_path,
    output = out_path,
    from = from,
    to = "html",
    options = purrr::compact(c(
      if (!rmarkdown::pandoc_available("2.0")) "--smart",
      if (rmarkdown::pandoc_available("2.0")) c("-t", "html4"),
      "--indented-code-classes=R",
      "--section-divs",
      "--wrap=none",
      paste0("--", config_math_rendering(pkg)),
      ...
    ))
  )

  invisible()
}

config_math_rendering <- function(pkg, call = caller_env()) {
  if (is.null(pkg)) {
    # Special case for tweak_highlight_other() where it's too annoying to
    # pass down the package, and it doesn't matter much anyway.
    return("mathml")
  }

  math <- config_pluck_string(
    pkg,
    "template.math-rendering",
    default = "mathml",
    call = call
  )
  allowed <- c("mathml", "mathjax", "katex")

  if (!math %in% allowed) {
    msg <- "{.field template.math-rendering} must be one of {allowed}, not {math}."
    config_abort(pkg, msg, call = call)
  }

  math
}
