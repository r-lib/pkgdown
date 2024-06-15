as_data <- function(x, ...) {
  UseMethod("as_data")
}

#' @export
as_data.NULL <- function(x, ...) {
  NULL
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
    contents = describe_contents(x, ..., id_prefix = "arg-")
  )
}

#' @export
as_data.tag_value <- function(x, ...) {
  list(
    title = tr_("Value"),
    contents = describe_contents(x, ...)
  )
}

describe_contents <- function(x, ..., id_prefix = NULL) {
  if (length(x) == 0) {
    return("")
  }

  # Group contiguous \items{}/whitespace into a <dl>; everything else
  # is handled as is
  block_id <- integer(length(x))
  block_id[[1]] <- 1
  cur_block_is_dl <- inherits(x[[1]], "tag_item")

  for (i in seq2(2, length(x))) {
    is_item <- inherits(x[[i]], "tag_item")
    if (cur_block_is_dl) {
      same_type <- is_item || is_whitespace(x[[i]])
    } else {
      same_type <- !is_item
    }

    if (same_type) {
      block_id[[i]] <- block_id[[i - 1]]
    } else {
      block_id[[i]] <- block_id[[i - 1]] + 1
      cur_block_is_dl <- !cur_block_is_dl
    }
  }

  parse_block <- function(x) {
    is_dl <- any(purrr::map_lgl(x, inherits, "tag_item"))
    if (is_dl) {
      paste0(
        "<dl>\n",
        parse_descriptions(x, ..., id_prefix = id_prefix),
        "</dl>"
      )
    } else {
      flatten_para(x, ...)
    }
  }
  blocks <- split(x, block_id)
  out <- purrr::map(blocks, parse_block)

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
