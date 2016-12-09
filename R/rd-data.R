as_data <- function(x, ...) {
  UseMethod("as_data")
}

#' @export
as_data.NULL <- function(x, ...) {
  NULL
}

# Usage -------------------------------------------------------------------

#' @export
as_data.tag_usage <- function(x, ..., index = NULL, current = NULL) {
  text <- paste(flatten_text(x, ..., escape = FALSE), collapse = "\n")
  text <- trimws(text)

  syntax_highlight(text, index = index, current = current)
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
    description = flatten_text(x[[2]], ...)
  )
}

# Sections ----------------------------------------------------------------

parse_section <- function(x, title, ...) {
  text <- flatten_text(x, ...)
  paras <- split_at_linebreaks(text)

  list(
    title = title,
    contents = paras
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
as_data.tag_seealso <- function(x, ...) {
  parse_section(x, "See also", ...)
}
#' @export
as_data.tag_section <- function(x, ...) {
  parse_section(x[[2]], as_html(x[[1]], ...), ...)
}
#' @export
as_data.tag_value <- function(x, ...) {
  # \value is implicitly a \describe environment
  class(x) <- c("tag_describe", class(x))
  parse_section(x, "Value", ...)
}

# Examples ------------------------------------------------------------------

#' @export
as_data.tag_examples <- function(x, path, ...,
                             index = NULL,
                             current = NULL,
                             examples = TRUE,
                             run_dont_run = FALSE,
                             topic = "unknown",
                             env = new.env(parent = globalenv())) {
  # First element of examples tag is always empty
  text <- flatten_text(x[-1], ...,
    run_dont_run = run_dont_run,
    escape = FALSE
  )

  if (!examples) {
    syntax_highlight(text, index = index, current = current)
  } else {
    old_dir <- setwd(path %||% tempdir())
    on.exit(setwd(old_dir), add = TRUE)

    old_opt <- options(width = 80)
    on.exit(options(old_opt), add = TRUE)

    expr <- evaluate::evaluate(text, env, new_device = TRUE)
    replay_html(
      expr,
      name = paste0(topic, "-"),
      index = index,
      current = current
    )
  }
}

#' @export
as_html.tag_dontrun <- function(x, ..., run_dont_run = FALSE) {
  if (run_dont_run) {
    flatten_text(drop_leading_newline(x), escape = FALSE)
  } else if (length(x) == 1) {
    paste0("## Not run: " , flatten_text(x))
  } else {
    # Internal TEXT nodes contain leading and trailing \n
    text <- gsub("(^\n)|(\n$)", "", flatten_text(x, ...))
    paste0(
      "## Not run: ------------------------------------\n",
      "# " , gsub("\n", "\n# ", text), "\n",
      "## ---------------------------------------------"
    )
  }
}

#' @export
as_html.tag_donttest <- function(x, ...) {
  flatten_text(drop_leading_newline(x), escape = FALSE)
}

# This helps with \donrun{} and \donttest{} which usually start with a
# newline. However, It doesn't fully resolve the problem because there's
# typically also a new line before and after (outside) the tag
drop_leading_newline <- function(x) {
  if (length(x) == 0)
    return()

  first <- x[[1]]
  if (!inherits(first, "RCODE"))
    return(x)

  first <- as.character(first)
  if (!identical(first, "\n"))
    return(x)

  x[-1]
}
