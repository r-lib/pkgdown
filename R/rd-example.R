rd2ex <- function(x, ...) {
  x <- rd_text(paste0("\\examples{", x, "}"), fragment = FALSE)[[1]]
  x <- process_conditional_examples(x)
  x <- flatten_ex(x, ...)

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

  x <- process_conditional_examples(x)
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

process_conditional_examples <- function(rd) {
  if (is.list(rd)) {
    which_exif <- which(purrr::map_lgl(rd, function(x) {
      "tag_dontshow" %in% class(x) &&
        is.character(x[[1]]) &&
        grepl("# examplesIf$", x[[1]])
    }))
    if (length(which_exif) == 0) return(rd)
    if (length(which_exif) %% 2 != 0) stop("@examplesIf error, not closed?")
    remove <- integer()
    modes <- c("begin", "end")
    for (idx in which_exif) {
      if (rd[[idx]] != "}) # examplesIf") {
        # Start of @examplesIf
        if (modes[1] == "end") stop("@examplesIf error, not closed?")
        cond_expr <- parse(text = paste0(rd[[idx]], "\n})"))[[1]][[2]]
        cond <- eval(cond_expr)
        if (isTRUE(cond)) {
          remove <- c(remove, idx, idx + 1L)
        } else {
          is_false <- deparse(cond_expr) == "FALSE"
          if (!is_false) {
            new_cond <- paste0("if (FALSE) { # ", deparse(cond_expr))
            warning(
              "@examplesIf condition `",
              deparse(cond_expr),
              "` is FALSE"
            )
          } else {
            new_cond <- "if (FALSE) {"
          }
          rd[[idx]] <- structure(list(new_cond), class = c("RCODE", "tag"))
        }
      } else {
        # End of @examplesIf
        if (modes[1] == "begin") stop("@examplesIf error, closed twice?")
        if (isTRUE(cond)) {
          remove <- c(remove, idx, idx + 1L)
        } else {
          rd[[idx]] <- structure(list("}"), class = c("RCODE", "tag"))
        }
      }
      modes <- rev(modes)
    }
    if (length(remove)) rd <- rd[-remove]
    rd

  } else {
    rd
  }
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
as_example.COMMENT <- function(x, run_dont_run = FALSE) {
  if (grepl("^%[^ ]*%", x)) {
    warning(
      "In the examples,  ", unclass(x), "\n",
      "is an Rd comment: did you mean  ", gsub("%", "\\\\%", x), " ?",
      call. = FALSE
    )
  }
  ""
}
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
