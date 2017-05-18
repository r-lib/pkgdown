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
    description = flatten_para(x[[2]], ...)
  )
}

# Sections ----------------------------------------------------------------

parse_section <- function(x, title, ...) {
  text <- flatten_para(x, ...)
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

  text <- if (length(text) > 0) flatten_para(text, ...) else NULL
  values <- if (length(values) > 0) parse_descriptions(values) else NULL

  list(
    title = "Value",
    contents = paste(c(text, values), collapse = "\n")
  )
}

# Examples ------------------------------------------------------------------

#' @export
as_data.tag_examples <- function(x, path, ...,
                             index = NULL,
                             current = NULL,
                             examples = TRUE,
                             run_dont_run = FALSE,
                             topic = "unknown",
                             env = globalenv()) {
  # First element of examples tag is always empty
  text <- flatten_text(x[-1], ...,
    run_dont_run = run_dont_run,
    examples = examples,
    escape = FALSE
  )

  if (!examples) {
    syntax_highlight(text, index = index, current = current)
  } else {
    old_dir <- setwd(path %||% tempdir())
    on.exit(setwd(old_dir), add = TRUE)

    old_opt <- options(width = 80)
    on.exit(options(old_opt), add = TRUE)

    code_env <- new.env(parent = env)
    code_env$not_run <- function(...) invisible()

    expr <- evaluate::evaluate(text, code_env, new_device = TRUE)

    replay_html(
      expr,
      name_prefix = paste0(topic, "-"),
      index = index,
      current = current
    )
  }
}

#' @export
as_html.tag_dontrun <- function(x, ..., examples = TRUE, run_dont_run = FALSE) {
  if (!examples || run_dont_run) {
    flatten_text(drop_leading_newline(x), escape = FALSE)
  } else if (length(x) == 1) {
    paste0("## Not run: " , flatten_text(x))
  } else {
    # Internal TEXT nodes contain leading and trailing \n
    text <- gsub("(^\n)|(\n$)", "", flatten_text(x, ...))
    paste0(
      "not_run({\n" ,
      "  ", gsub("\n", "\n  ", text),
      "\n})"
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

  if (is_newline(x[[1]])) {
    x[-1]
  } else {
    x
  }
}

is_newline <- function(x) {
  inherits(x, "TEXT") && identical(x[[1]], "\n")
}
