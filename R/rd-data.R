as_data <- function(x, ...) {
  UseMethod("as_data")
}

#' @export
as_data.NULL <- function(x, ...) {
  NULL
}

# Usage -------------------------------------------------------------------

#' @export
as_data.tag_usage <- function(x, ...) {
  text <- paste(flatten_text(x, ..., escape = FALSE), collapse = "\n")
  text <- str_trim(text)

  highlight_text(text)
}

# Arguments ------------------------------------------------------------------

#' @export
as_data.tag_arguments <- function(x, ...) {
  x %>%
    purrr::keep(inherits, "tag_item") %>%
    purrr::map(as_data, ...)
}

#' @export
as_data.tag_item <- function(x, ...) {

  list(
    name = as_html(x[[1]], ...),
    description = flatten_para(x[[2]], ...)
  )
}

# Sections ----------------------------------------------------------------

parse_section <- function(x, title, ...) {
  text <- flatten_para(x, ...)
  html <- xml2::read_html(text)
  r_blocks <- xml2::xml_find_all(html, "//div[contains(@class, 'sourceCode r')]/pre/code")
  # now add blocks with no language information
  nolang_r_blocks <- xml2::xml_find_all(
    xml2::xml_find_all(html, "//pre/code/parent::*[not(ancestor::div)]"), # not in a div
    "code"
  )

  highlight_r_block <- function(block) {
    out <- downlit::highlight(
      xml2::xml_text(block),
      classes = downlit::classes_pandoc()
    )
    if (!is.na(out)) {
      xml2::xml_text(block) <- out
    }
  }

  purrr::walk(r_blocks, highlight_r_block)
  purrr::walk(nolang_r_blocks, highlight_r_block)

  non_r_blocks <- xml2::xml_find_all(
    html,
    "//div[contains(@class, 'sourceCode') and not(contains(@class, 'sourceCode r'))]"
  )

  highlight_other_block <- function(block) {
    lang <- sub("sourceCode ", "", xml2::xml_attr(block, "class"))
    code <- xml2::xml_text(xml2::xml_find_first(block, "pre/code"))
    highlighted <- markdown_text(
      paste(c(sprintf("```%s", lang), code, "```"), collapse = "\n"),
      pkg = NULL
    )
    code_node <- xml2::xml_find_first(block, "pre/code")
    xml2::xml_text(code_node) <- paste(
      as.character(
        xml2::xml_contents(
          xml2::xml_find_first(
            xml2::read_html(highlighted),
            "//div/pre/code"
          )
        )
      ),
      collapse = ""
    )
  }

  purrr::walk(non_r_blocks, highlight_other_block)

  text <- xml2::xml_find_first(html, "body") %>%
    xml2::xml_contents() %>%
    as.character() %>%
    paste(collapse = "") %>%
    unescape_html() # highlighted was escaped

  list(
    title = title,
    contents = text
  )
}

#' @export
as_data.tag_details <- function(x, ...) {
  parse_section(x, "Details", ...)
}
#' @export
as_data.tag_description <- function(x, ...) {
  parse_section(x, "Description", ...)
}
#' @export
as_data.tag_references <- function(x, ...) {
  parse_section(x, "References", ...)
}
#' @export
as_data.tag_source <- function(x, ...) {
  parse_section(x, "Source", ...)
}
#' @export
as_data.tag_format <- function(x, ...) {
  parse_section(x, "Format", ...)
}
#' @export
as_data.tag_note <- function(x, ...) {
  parse_section(x, "Note", ...)
}
#' @export
as_data.tag_author <- function(x, ...) {
  parse_section(x, "Author", ...)
}
#' @export
as_data.tag_seealso <- function(x, ...) {
  section <- parse_section(x, "See also", ...)
  section$contents <- dont_index(section$contents)
  section
}
#' @export
as_data.tag_section <- function(x, ...) {
  parse_section(x[[2]], as_html(x[[1]], ...), ...)
}
#' @export
as_data.tag_value <- function(x, ...) {
  # \value is implicitly a \describe environment, with
  # optional text block before first \item

  idx <- Position(function(x) inherits(x, "tag_item"), x, nomatch = 0)
  if (idx == 0) {
    text <- x
    values <- list()
  } else if (idx == 1) {
    text <- list()
    values <- x
  } else {
    text <- x[seq_len(idx - 1)]
    values <- x[-seq_len(idx - 1)]
  }

  text <- flatten_para(text, ...)
  values <- parse_descriptions(values)

  list(
    title = "Value",
    contents = paste(c(text, values), collapse = "\n")
  )
}
