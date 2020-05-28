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
