as_data <- function(x, ...) {
  UseMethod("as_data")
}

as_data.NULL <- function(x, ...) {
  NULL
}

# as_data.list <- function(x, ...) {
#   lapply(x, as_data, ...)
# }

# Usage -------------------------------------------------------------------

as_data.tag_usage <- function(x, pkg, ...) {
  text <- paste(flatten_text(x, ..., escape = FALSE), collapse = "\n")
  text <- str_trim(text)

  html <- src_highlight(text, pkg$topics)

  if (!identical(text, html)) {
    # It's nice not to wrap in the middle of a simple "arg = default"
    html <- str_replace_all(
      html,
      ' <span class="argument">=</span> ',
      '&nbsp;<span class="argument">=</span>&nbsp;'
    )
    html
  } else {
    html <- str_replace_all(text, " = ", "&nbsp;=&nbsp;")
    # Wrap each individual function in its own div, so that text-indent
    # CSS rules can be used effectively
    html <- str_replace_all(html, "\n\n", "</div>\n<div>")
    html <- paste0("<div>", html, "</div>")
    # Collapse all hardcoded hanging indents
    html <- str_replace_all(html, "\n +", " ")

    html
  }
}

# Arguments ------------------------------------------------------------------

as_data.tag_arguments <- function(x, ...) {
  x %>%
    purrr::keep(inherits, "tag_item") %>%
    purrr::map(as_data, ...)
}

as_data.tag_item <- function(x, ...) {
  # If no subelements, then is an item from a itemise or enumerate, and
  # is dealt with those methods
  if (length(x) == 0) return()

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

as_data.tag_details <- function(x, ...) {
  parse_section(x, "Details", ...)
}
as_data.tag_description <- function(x, ...) {
  parse_section(x, "Description", ...)
}
as_data.tag_references <- function(x, ...) {
  parse_section(x, "References", ...)
}
as_data.tag_source <- function(x, ...) {
  parse_section(x, "Source", ...)
}
as_data.tag_format <- function(x, ...) {
  parse_section(x, "Format", ...)
}
as_data.tag_note <- function(x, ...) {
  parse_section(x, "Note", ...)
}
as_data.tag_seealso <- function(x, ...) {
  parse_section(x, "See also", ...)
}
as_data.tag_section <- function(x, ...) {
  parse_section(x[[2]], as_html(x[[1]], ...), ...)
}
as_data.tag_value <- function(x, ...) {
  # \value is implicitly a \describe environment
  class(x) <- c("tag_describe", class(x))
  parse_section(x, "Value", ...)
}

# Examples ------------------------------------------------------------------

as_data.tag_examples <- function(x, pkg, path, ...,
                             examples = TRUE,
                             run_dont_run = FALSE,
                             topic = "unknown",
                             env = new.env(parent = globalenv())) {
  # First element of examples tag is always empty
  text <- flatten_text(x[-1], ...,
    run_dont_run = run_dont_run,
    escape = FALSE
  )

  if (examples) {
    src_highlight(text, pkg$topics)
  } else {
    old <- setwd(path %||% tempdir())
    on.exit(setwd(old), add = TRUE)
    on.exit(grDevices::graphics.off(), add = TRUE)

    expr <- evaluate::evaluate(text, env, new_device = TRUE)
    replay_html(expr, pkg = pkg, name = str_c(topic, "-"))
  }
}

as_data.tag_dontrun <- function(x, ..., run_dont_run = FALSE) {
  if (run_dont_run) {
    return(flatten_text(x))
  }

  if (length(x) == 1) {
    str_c("## Not run: " , flatten_text(x))
  } else {
    # Internal TEXT nodes contain leading and trailing \n
    text <- str_replace_all(flatten_text(x, ...), "(^\n)|(\n$)", "")
    str_c(
      "## Not run: ------------------------------------\n# " ,
      str_replace_all(text, "\n", "\n# "), "\n",
      "## ---------------------------------------------"
    )
  }
}
