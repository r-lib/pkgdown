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
  text <- trimws(text)

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
                                 examples = TRUE,
                                 run_dont_run = FALSE,
                                 topic = "unknown",
                                 env = globalenv()) {

  # Divide top-level RCODE into contiguous chunks
  is_rcode <- purrr::map_lgl(x, inherits, "RCODE")
  is_tag <- !is_rcode
  is_after_tag <- c(TRUE, is_tag[-length(is_tag)])

  is_break <- is_tag | is_after_tag
  group <- cumsum(is_break)

  # Drop nl's immediately following a tag
  is_nl <- purrr::map_lgl(x, is_newline, trim = TRUE)
  remove <- is_nl & is_after_tag
  x <- x[!remove]
  group <- group[!remove]

  # Extract code and combine into chunks
  chunks <- unname(split(x, group))
  code <- purrr::map(chunks, flatten_text, escape = FALSE)
  type <- purrr::map_chr(chunks, ~ class(.[[1]])[[1]])

  # Run or format each chunk
  if (!examples) {
    run <- rep(FALSE, length(code))
  } else {
    if (run_dont_run) {
      run <- type %in% c("RCODE", "tag_dontshow", "tag_donttest", "tag_dontrun")
    } else {
      run <- type %in% c("RCODE", "tag_dontshow", "tag_donttest")
    }
  }

  show <- !(type %in% c("tag_dontshow", "tag_testonly"))

  id_generator <- UniqueId$new()

  html <- purrr::pmap_chr(
    list(code = code, run = run, show = show),
    format_example_chunk,
    env = child_env(env),
    path = path,
    topic = topic,
    obj_id = id_generator$id
  )
  paste(html, collapse = "")
}

format_example_chunk <- function(code, run, show, path,
                                 topic = "unknown",
                                 obj_id,
                                 env = global_env()) {

  if (!run) {
    code <- gsub("^\n|^", "# NOT RUN {\n", code)
    code <- gsub("\n$|$", "\n# }\n", code)

    return(highlight_text(code))
  }

  old_dir <- setwd(path)
  on.exit(setwd(old_dir), add = TRUE)

  old_opt <- options(width = 80)
  on.exit(options(old_opt), add = TRUE)

  expr <- evaluate::evaluate(code, env, new_device = TRUE)

  if (show) {
    replay_html(expr, topic = topic, obj_id = obj_id)
  } else {
    ""
  }
}

#' @export
as_html.tag_dontrun <- function(x, ...) {
  flatten_text(drop_leading_newline(x), escape = FALSE)
}

#' @export
as_html.tag_donttest <- function(x, ...) {
  flatten_text(drop_leading_newline(x), escape = FALSE)
}

#' @export
as_html.tag_dontshow <- function(x, ...) {
  flatten_text(drop_leading_newline(x), escape = FALSE)
}

#' @export
as_html.tag_testonly <- function(x, ...) {
  flatten_text(drop_leading_newline(x), escape = FALSE)
}


# This helps with \donrun{} and \donttest{} which usually start with a
# newline.
drop_leading_newline <- function(x) {
  if (length(x) == 0)
    return()

  if (is_newline(x[[1]], trim = TRUE)) {
    x[-1]
  } else {
    x
  }
}

is_newline <- function(x, trim = FALSE) {
  if (!inherits(x, "TEXT") && !inherits(x, "RCODE") && !inherits(x, "VERB"))
    return(FALSE)

  text <- x[[1]]
  if (trim) {
    text <- gsub("^[ \t]+|[ \t]+$", "", text)
  }
  identical(text, "\n")
}

UniqueId <- R6Class("UniqueId", public = list(
  env = new_environment(),

  id = function(name) {
    if (!env_has(self$env, name)) {
      id <- 1
    } else {
      id <- env_get(self$env, name) + 1
    }

    env_bind(self$env, !!name := id)
    id
  }
))
