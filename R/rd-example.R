rd2ex <- function(x, ...) {
  x <- rd_text(paste0("\\examples{", x, "}"), fragment = FALSE)
  x <- flatten_ex(x[[1]], ...)

  if (grepl("\n", x)) {
    strsplit(x, "\n")[[1]]
  } else {
    x
  }
}

run_examples <- function(x,
                         topic = "unknown",
                         env = globalenv(),
                         run_examples = TRUE,
                         run_dont_run = FALSE
                         ) {

  if (!inherits(x, "tag")) {
    x <- rd_text(x)
  }

  # Trim newline that usually occurs after \examples{
  if (is_newline(x[[1]], trim = TRUE)) {
    x <- x[-1]
  }

  code <- flatten_ex(x, run_dont_run = run_dont_run)

  if (!can_parse(code)) {
    warning("Failed to parse example for topic '", topic, "'", call. = FALSE)
    return("")
  }

  if (run_examples) {
    highlight_examples(code, topic, env = env)
  } else {
    highlight_text(code)
  }
}

highlight_examples <- function(x, topic, env = globalenv()) {
  withr::local_options(list(
    crayon.enabled = getOption("crayon.enabled", crayon::has_color()),
    crayon.colors = getOption("crayon.colors", crayon::num_colors())
  ))

  expr <- evaluate::evaluate(x, child_env(env), new_device = TRUE)
  replay_html(expr, topic = topic, obj_id = unique_id())
}

# as_example --------------------------------------------------------------

as_example <- function(x, run_dont_run = FALSE) {
  UseMethod("as_example")
}

#' @export
as_example.RCODE <- function(x, run_dont_run = FALSE) as.character(x)
#' @export
as_example.VERB <- as_example.RCODE
#' @export
as_example.TEXT <- as_example.RCODE

#' @export
as_example.tag_dontrun <- function(x, run_dont_run = FALSE) {
  if (run_dont_run) {
    block_tag_to_comment("\\dontrun", x, run_dont_run = run_dont_run)
  } else {
    ex <- flatten_ex(x, run_dont_run = run_dont_run)
    if (is_newline(x[[1]], trim = TRUE)) {
      paste0("if (FALSE) {", ex, "}")
    } else {
      paste0("if (FALSE) ", ex, "")
    }
  }
}

#' @export
as_example.tag_donttest <- function(x, run_dont_run = FALSE) {
  block_tag_to_comment("\\donttest", x, run_dont_run = run_dont_run)
}
#' @export
as_example.tag_dontshow <- function(x, run_dont_run = FALSE) {
  block_tag_to_comment("\\dontshow", x, run_dont_run = run_dont_run)
}
#' @export
as_example.tag_testonly <- function(x, run_dont_run = FALSE) {
  block_tag_to_comment("\\testonly", x, run_dont_run = run_dont_run)
}

block_tag_to_comment <- function(tag, x, run_dont_run = FALSE) {
  if (is_newline(x[[1]], trim = TRUE)) {
    paste0("# ", tag, "{", flatten_ex(x, run_dont_run = run_dont_run), "# }")
  } else {
    flatten_ex(x, run_dont_run = run_dont_run)
  }
}

#' @export
as_example.tag <- function(x, run_dont_run = FALSE) {
  warning("Unknown tag: ", paste(class(x), collapse = "/"), call. = FALSE)
  ""
}

#' @export
as_example.tag_dots <- function(x, run_dont_run = FALSE) {
  "..."
}
#' @export
as_example.tag_ldots <- as_example.tag_dots

#' @export
as_example.tag_if <- function(x, run_dont_run = FALSE) {
  if (x[[1]] == "html") {
    flatten_ex(x[[2]], run_dont_run = run_dont_run)
  } else {
    ""
  }
}
#' @export
as_example.tag_ifelse <- function(x, run_dont_run = FALSE) {
  if (x[[1]] == "html") {
    flatten_ex(x[[2]], run_dont_run = run_dont_run)
  } else {
    flatten_ex(x[[3]], run_dont_run = run_dont_run)
  }
}
#' @export
as_example.tag_out <- function(x, run_dont_run = FALSE) {
  flatten_ex(x, run_dont_run = run_dont_run)
}

# Helpers -----------------------------------------------------------------

flatten_ex <- function(x, run_dont_run = FALSE) {
  out <- purrr::map_chr(x, as_example, run_dont_run = run_dont_run)
  paste(out, collapse = "")
}

can_parse <- function(x) {
  tryCatch({
    parse(text = x)
    TRUE
  }, error = function(e) FALSE)
}

unique_id <- function() {
  i <- 0

  function() {
    i <<- i + 1
    i
  }
}
