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
  # \value is a mixture of \items (which should be put inside of \describe)
  # and other blocks

  is_item <- purrr::map_lgl(x, inherits, "tag_item")
  changed <- is_item[-1] != is_item[-length(is_item)]
  group <- cumsum(c(TRUE, changed))

  parse_piece <- function(x) {
    if (inherits(x[[1]], "tag_item")) {
      paste0("<dl>\n", parse_descriptions(x, ...), "\n</dl>")
    } else {
      flatten_para(x, ...)
    }
  }
  pieces <- split(x, group)
  out <- purrr::map(pieces, parse_piece)
  list(
    title = "Value",
    contents = paste(unlist(out), collapse = "\n")
  )
}

value2html <- function(x) {
  rd <- rd_text(paste0("\\value{", x, "}"), fragment = FALSE)[[1]]
  html <- as_data(rd)$contents
  str_trim(strsplit(str_trim(html), "\n")[[1]])
}
