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
  parse_section(x, tr_("Details"), ...)
}
#' @export
as_data.tag_description <- function(x, ...) {
  parse_section(x, tr_("Description"), ...)
}
#' @export
as_data.tag_references <- function(x, ...) {
  parse_section(x, tr_("References"), ...)
}
#' @export
as_data.tag_source <- function(x, ...) {
  parse_section(x, tr_("Source"), ...)
}
#' @export
as_data.tag_format <- function(x, ...) {
  parse_section(x, tr_("Format"), ...)
}
#' @export
as_data.tag_note <- function(x, ...) {
  parse_section(x, tr_("Note"), ...)
}
#' @export
as_data.tag_author <- function(x, ...) {
  parse_section(x, tr_("Author"), ...)
}
#' @export
as_data.tag_seealso <- function(x, ...) {
  section <- parse_section(x, tr_("See also"), ...)
  section$contents <- dont_index(section$contents)
  section
}
#' @export
as_data.tag_section <- function(x, ...) {
  parse_section(x[[2]], as_html(x[[1]], ...), ...)
}

# \arguments{} & \details{} -----------------------------------------------
# Both are like the contents of \description{} but can contain arbitrary
# text outside of \item{}

#' @export
as_data.tag_arguments <- function(x, ...) {
  list(
    title = tr_("Arguments"),
    contents = describe_contents(x, ...)
  )
}

#' @export
as_data.tag_value <- function(x, ...) {
  list(
    title = tr_("Value"),
    contents = describe_contents(x, ...)
  )
}

describe_contents <- function(x, ...) {
  # Drop pure whitespace nodes between items
  is_ws <- purrr::map_lgl(x, is_whitespace)
  x <- x[!is_ws]

  # Group continguous \items{} into a <dl>
  is_item <- purrr::map_lgl(x, inherits, "tag_item")
  changed <- is_item[-1] != is_item[-length(is_item)]
  group <- cumsum(c(TRUE, changed))

  parse_piece <- function(x) {
    if (inherits(x[[1]], "tag_item")) {
      paste0("<dl>\n", parse_descriptions(x, ...), "</dl>")
    } else {
      flatten_para(x, ...)
    }
  }
  pieces <- split(x, group)
  out <- purrr::map(pieces, parse_piece)

  paste(unlist(out), collapse = "\n")
}

is_whitespace <- function(x) {
  inherits(x, "TEXT") && all(grepl("^\\s*$", x))
}


# For testing
value2html <- function(x) {
  rd <- rd_text(paste0("\\value{", x, "}"), fragment = FALSE)[[1]]
  html <- as_data(rd)$contents
  str_trim(strsplit(str_trim(html), "\n")[[1]])
}
