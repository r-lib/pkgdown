as_html <- function(x, ...) {
  UseMethod("as_html")
}

# Various types of text ------------------------------------------------------

flatten_para <- function(x, ...) {
  if (length(x) == 0) {
    return(character())
  }

  # Look for "\n" TEXT blocks after a TEXT block, and not at end of file
  is_nl <- purrr::map_lgl(x, is_newline, trim = TRUE)
  is_text <- purrr::map_lgl(x, inherits, "TEXT")
  is_text_prev <- c(FALSE, is_text[-length(x)])
  has_next <- c(rep(TRUE, length(x) - 1), FALSE)
  is_para_break <- is_nl & is_text_prev & has_next

  # Or tags that are converted to HTML blocks
  block_tags <- c(
    "tag_preformatted",
    "tag_itemize",
    "tag_enumerate",
    "tag_tabular",
    "tag_describe",
    "tag_subsection"
  )
  is_block <- purrr::map_lgl(x, inherits, block_tags)

  # Break before and after each status change
  before_break <- is_para_break | is_block
  after_break <- c(FALSE, before_break[-length(x)])
  groups <- cumsum(before_break | after_break)

  unwrap_purrr_error(html <- purrr::map(x, as_html, ...))
  # split at line breaks for everything except blocks
  empty <- purrr::map_lgl(x, purrr::is_empty)
  needs_split <- !is_block & !empty
  html[needs_split] <- purrr::map(html[needs_split], split_at_linebreaks)

  blocks <- purrr::map_chr(split(html, groups), function(x) {
    paste(unlist(x), collapse = "")
  })

  # There are three types of blocks:
  # 1. Combined text and inline tags
  # 2. Paragraph breaks (text containing only "\n")
  # 3. Block-level tags
  #
  # Need to wrap 1 in <p>
  needs_p <- purrr::map_lgl(split(!(is_nl | is_block), groups), any)
  blocks[needs_p] <- paste0("<p>", str_trim(blocks[needs_p]), "</p>")

  paste0(blocks, collapse = "")
}

split_at_linebreaks <- function(text) {
  if (length(text) == 0) {
    character()
  } else {
    strsplit(text, "\\n\\s*\\n")[[1]]
  }
}

flatten_text <- function(x, ...) {
  if (length(x) == 0) {
    return("")
  }

  unwrap_purrr_error(html <- purrr::map_chr(x, as_html, ...))
  paste(html, collapse = "")
}

#' @export
as_html.Rd <- function(x, ...) flatten_text(x, ...)

#' @export
as_html.LIST <- flatten_text

# Leaves  -----------------------------------------------------------------

#' @export
as_html.character <- function(x, ..., escape = TRUE) {
  # src_highlight (used by usage, examples, and out) also does escaping
  # so we need some way to turn it off when needed.
  if (escape) {
    escape_html(x)
  } else {
    as.character(x)
  }
}
#' @export
as_html.TEXT <- function(x, ..., escape = TRUE) {
  # tools:::htmlify
  x <- gsub("---", "\u2014", x)
  x <- gsub("--", "\u2013", x)
  x <- gsub("``", "\u201c", x)
  x <- gsub("''", "\u201d", x)

  x <- as_html.character(x, ..., escape = escape)
  x
}
#' @export
as_html.RCODE <- as_html.character
#' @export
as_html.VERB <- as_html.character
#' @export
as_html.COMMENT <- function(x, ...) {
  paste0("<!-- ", flatten_text(x), " -->")
}
# USERMACRO appears first, followed by the rendered macro
#' @export
as_html.USERMACRO <- function(x, ...) ""

#' @export
as_html.tag_subsection <- function(x, ..., subsection_level = 3L) {
  h <- paste0("h", subsection_level)

  title <- flatten_text(x[[1]], ...)
  id <- make_slug(title)
  text <- flatten_para(x[[2]], ..., subsection_level = subsection_level + 1L)

  # fmt: skip
  paste0(
    "<div class='section' id='", id, "'>\n",
    "<", h, ">", title, "</", h, ">\n",
    text, "\n",
    "</div>"
  )
}

# Equations ------------------------------------------------------------------

#' @export
as_html.tag_eqn <- function(x, ...) {
  latex_rep <- x[[1]]
  paste0("\\(", flatten_text(latex_rep, ...), "\\)")
}

#' @export
as_html.tag_deqn <- function(x, ...) {
  latex_rep <- x[[1]]
  paste0("$$", flatten_text(latex_rep, ...), "$$")
}

# Links ----------------------------------------------------------------------
#' @export
as_html.tag_url <- function(x, ...) {
  if (length(x) != 1) {
    if (length(x) == 0) {
      msg <- "Check for empty \\url{{}} tags."
    } else {
      msg <- "This may be caused by a \\url tag that spans a line break."
    }
    stop_bad_tag("url", msg)
  }

  text <- flatten_text(x[[1]])
  a(text, href = text)
}
#' @export
as_html.tag_href <- function(x, ...) {
  a(flatten_text(x[[2]]), href = flatten_text(x[[1]]))
}
#' @export
as_html.tag_email <- function(x, ...) {
  if (length(x) != 1) {
    stop_bad_tag("email", "empty {}")
  }
  paste0("<a href='mailto:", x[[1]], "'>", x[[1]], "</a>")
}

# If single, need to look up alias to find file name and package
#' @export
as_html.tag_link <- function(x, ...) {
  opt <- attr(x, "Rd_option")

  in_braces <- flatten_text(x)

  if (is.null(opt)) {
    # \link{topic}
    href <- downlit::href_topic(in_braces)
  } else if (substr(opt, 1, 1) == "=") {
    # \link[=dest]{name}
    href <- downlit::href_topic(substr(opt, 2, nchar(opt)))
  } else {
    match <- regexec('^([^:]+)(?:|:(.*))$', opt)
    parts <- regmatches(opt, match)[[1]][-1]

    if (parts[[2]] == "") {
      # \link[pkg]{foo}
      href <- downlit::href_topic(in_braces, opt)
    } else {
      # \link[pkg:bar]{foo}
      href <- downlit::href_topic(parts[[2]], parts[[1]])
    }
  }

  a(in_braces, href = href)
}

#' @export
as_html.tag_linkS4class <- function(x, ...) {
  if (length(x) != 1) {
    stop_bad_tag("linkS4class")
  }

  text <- flatten_text(x[[1]])
  href <- downlit::href_topic(paste0(text, "-class"))
  a(text, href = href)
}

# Conditionals and Sexprs ----------------------------------------------------

#' @export
as_html.tag_Sexpr <- function(x, ...) {
  code <- flatten_text(x, escape = FALSE)
  options <- parse_opts(attr(x, "Rd_option"))

  # Needs to be package root
  old_wd <- setwd(context_get("src_path"))
  on.exit(setwd(old_wd), add = TRUE)

  # Environment shared across a file
  env <- context_get("sexpr_env")

  results <- options$results %||% "rd"
  if (results == "verbatim") {
    outlines <- utils::capture.output({
      out <- withVisible(eval(parse(text = code), env))
      res <- out$value
      if (out$visible) print(res)
    })
    paste0(
      "<pre>\n",
      paste0(escape_html(outlines), collapse = "\n"),
      "\n</pre>\n"
    )
  } else {
    res <- eval(parse(text = code), env)
    switch(
      results,
      text = as.character(res),
      rd = flatten_text(rd_text(as.character(res))),
      hide = "",
      cli::cli_abort(
        "unknown \\Sexpr option: results={results}",
        call = NULL
      )
    )
  }
}

#' @export
as_html.tag_if <- function(x, ...) {
  if (x[[1]] == "html") {
    as_html(x[[2]], ...)
  } else {
    ""
  }
}

#' @export
as_html.tag_ifelse <- function(x, ...) {
  if (x[[1]] == "html") as_html(x[[2]], ...) else as_html(x[[3]], ...)
}

# Used inside a \usage{} Rd tag to prevent the code from being treated as
# regular R syntax, either because it is not valid R, or because its usage
# intentionally deviates from regular R usage. An example of the former is the
# command line documentation, e.g. `R CMD SHLIB`
# (https://github.com/wch/r-source/blob/trunk/src/library/utils/man/SHLIB.Rd):
#
#    \special{R CMD SHLIB [options] [-o dllname] files}
#
# An example of the latter is the documentation shortcut `?`
# (https://github.com/wch/r-source/blob/trunk/src/library/utils/man/Question.Rd):
#
#    \special{?topic}
#
#' @export
as_html.tag_special <- function(x, ...) {
  flatten_text(x, ...)
}

#' @export
`as_html.#ifdef` <- function(x, ...) {
  os <- trimws(flatten_text(x[[1]]))
  if (os == "unix") {
    flatten_text(x[[2]])
  } else {
    ""
  }
}

#' @export
`as_html.#ifndef` <- function(x, ...) {
  os <- trimws(flatten_text(x[[1]]))
  if (os == "windows") {
    flatten_text(x[[2]])
  } else {
    ""
  }
}

# Tables ---------------------------------------------------------------------

#' @export
as_html.tag_tabular <- function(x, ...) {
  align_abbr <- strsplit(as_html(x[[1]], ...), "")[[1]]
  align_abbr <- align_abbr[!(align_abbr %in% c("|", ""))]
  align <- unname(c("r" = "right", "l" = "left", "c" = "center")[align_abbr])

  contents <- x[[2]]
  class <- purrr::map_chr(contents, ~ class(.x)[[1]])
  cell_contents <- purrr::map_chr(contents, flatten_text, ...)

  row_sep <- class == "tag_cr"
  contents[row_sep] <- list("")
  col_sep <- class == "tag_tab"
  sep <- col_sep | row_sep

  # Identify groups in reverse order (preserve empty cells)
  # Negative maintains correct ordering once reversed
  cell_grp <- rev(cumsum(-rev(sep)))
  cells <- unname(split(contents, cell_grp))
  # Remove trailing content (that does not match the dimensions of the table)
  cells <- cells[seq_len(length(cells) - length(cells) %% length(align))]
  cell_contents <- purrr::map_chr(cells, flatten_text, ...)
  cell_contents <- paste0("<td>", str_trim(cell_contents), "</td>")
  cell_contents <- matrix(cell_contents, ncol = length(align), byrow = TRUE)

  rows <- apply(cell_contents, 1, paste0, collapse = "")

  paste0(
    "<table class='table'>\n",
    paste0("<tr>", rows, "</tr>\n", collapse = ""),
    "</table>\n"
  )
}


# Figures -----------------------------------------------------------------

#' @export
as_html.tag_figure <- function(x, ...) {
  n <- length(x)
  path <- as.character(x[[1]])

  if (n == 1) {
    paste0("<img src='figures/", path, "' alt='' />")
  } else if (n == 2) {
    opt <- paste(trimws(as.character(x[[2]])), collapse = " ")
    if (substr(opt, 1, 9) == "options: ") {
      extra <- substr(opt, 9, nchar(opt))
      paste0("<img src='figures/", path, "'", extra, " />")
    } else {
      paste0("<img src='figures/", path, "' alt='", opt, "' />")
    }
  }
}

# List -----------------------------------------------------------------------

#' @export
as_html.tag_itemize <- function(x, ...) {
  paste0("<ul>\n", parse_items(x[-1], ...), "</ul>")
}
#' @export
as_html.tag_enumerate <- function(x, ...) {
  paste0("<ol>\n", parse_items(x[-1], ...), "</ol>")
}
#' @export
as_html.tag_describe <- function(x, ...) {
  paste0("<dl>\n", parse_descriptions(x[-1], ...), "\n</dl>")
}

# Effectively does nothing: only used by parse_items() to split up
# sequence of tags.
#' @export
as_html.tag_item <- function(x, ...) {
  ""
}

parse_items <- function(rd, ...) {
  separator <- purrr::map_lgl(rd, inherits, "tag_item")
  group <- cumsum(separator)

  # Drop anything before first tag_item
  if (!all(group == 0) && any(group == 0)) {
    rd <- rd[group != 0]
    group <- group[group != 0]
  }

  parse_item <- function(x) {
    x <- trim_ws_nodes(x)
    paste0("<li>", flatten_para(x, ...), "</li>\n")
  }

  paste(purrr::map_chr(split(rd, group), parse_item), collapse = "")
}

parse_descriptions <- function(rd, ..., id_prefix = NULL) {
  if (length(rd) == 0) {
    return(character())
  }

  parse_item <- function(x) {
    if (inherits(x, "tag_item")) {
      term <- flatten_text(x[[1]], ...)
      def <- flatten_para(x[[2]], ...)

      if (!is.null(id_prefix)) {
        id <- paste0(id_prefix, make_slug(term))
        id_attr <- paste0(" id='", id, "'")
        anchor <- anchor_html(id)
      } else {
        id_attr <- ""
        anchor <- ""
      }
      paste0(
        "<dt",
        id_attr,
        ">",
        term,
        anchor,
        "</dt>\n",
        "<dd>",
        def,
        "</dd>\n"
      )
    } else {
      flatten_text(x, ...)
    }
  }

  paste(purrr::map_chr(rd, parse_item), collapse = "")
}

# Marking text ------------------------------------------------------------
# https://cran.rstudio.com/doc/manuals/r-devel/R-exts.html#Marking-text

tag_wrapper <- function(prefix, suffix = NULL) {
  function(x, ...) {
    html <- flatten_text(x, ...)
    paste0(prefix, html, suffix)
  }
}

#' @export
as_html.tag_emph <- tag_wrapper("<em>", "</em>")
#' @export
as_html.tag_strong <- tag_wrapper("<strong>", "</strong>")
#' @export
as_html.tag_bold <- tag_wrapper("<b>", "</b>")

#' @export
as_html.tag_dQuote <- tag_wrapper("&#8220;", "&#8221;")
#' @export
as_html.tag_sQuote <- tag_wrapper("&#8216;", "&#8217;")

#' @export
as_html.tag_code <- function(x, ..., auto_link = TRUE) {
  text <- flatten_text(x, ...)

  if (auto_link) {
    href <- downlit::autolink_url(text)
    text <- a(text, href = href)
  }
  paste0("<code>", text, "</code>")
}

#' @export
as_html.tag_preformatted <- function(x, ...) {
  # the language is stored in a prior \if{}{\out{}} block, so we delay
  # highlighting until we have the complete html page
  pre(flatten_text(x, ...))
}

#' @export
as_html.tag_kbd <- tag_wrapper("<kbd>", "</kbd>")
#' @export
as_html.tag_samp <- tag_wrapper('<samp>', "</samp>")
#' @export
as_html.tag_verb <- tag_wrapper("<code>", "</code>")

#' @export
as_html.tag_pkg <- tag_wrapper('<span class="pkg">', "</span>")
#' @export
as_html.tag_file <- tag_wrapper('<code class="file">', '</code>')

#' @export
as_html.tag_var <- tag_wrapper("<var>", "</var>")
#' @export
as_html.tag_env <- tag_wrapper('<code class="env">', '</code>')
#' @export
as_html.tag_option <- tag_wrapper('<span class="option">', "</span>")
#' @export
as_html.tag_command <- tag_wrapper("<code class='command'>", "</code>")

#' @export
as_html.tag_dfn <- tag_wrapper("<dfn>", "</dfn>")
#' @export
as_html.tag_cite <- tag_wrapper("<cite>", "</cite>")
#' @export
as_html.tag_acronym <- tag_wrapper('<acronym>', '</acronym>')

#' @export
as_html.tag_out <- function(x, ...) flatten_text(x, ..., escape = FALSE)

# Insertions --------------------------------------------------------------

#' @export
as_html.tag_R <- function(x, ...) '<span style="R">R</span>'
#' @export
as_html.tag_dots <- function(x, ...) "..."
#' @export
as_html.tag_ldots <- function(x, ...) "..."
#' @export
as_html.tag_cr <- function(x, ...) "<br>"

# First element of enc is the encoded version (second is the ascii version)
#' @export
as_html.tag_enc <- function(x, ...) {
  if (length(x) == 2) {
    as_html(x[[1]], ...)
  } else {
    stop_bad_tag("enc")
  }
}

# Elements that don't return anything ----------------------------------------

#' @export
as_html.tag_tab <- function(x, ...) ""
#' @export
as_html.tag_newcommand <- function(x, ...) ""
#' @export
as_html.tag_renewcommand <- function(x, ...) ""

#' @export
as_html.tag <- function(x, ...) {
  if (identical(class(x), "tag")) {
    flatten_text(x, ...)
  } else {
    cli::cli_inform("Unknown tag: {.cls {class(x)}}")
    ""
  }
}

# Whitespace helper -------------------------------------------------------

trim_ws_nodes <- function(x, side = c("both", "left", "right")) {
  is_ws <- purrr::map_lgl(x, ~ inherits(., "TEXT") && grepl("^\\s*$", .[[1]]))

  if (!any(is_ws)) {
    return(x)
  }
  if (all(is_ws)) {
    return(x[0])
  }

  which_not <- which(!is_ws)

  side <- match.arg(side)
  if (side %in% c("left", "both")) {
    start <- which_not[1]
  } else {
    start <- 1
  }

  if (side %in% c("right", "both")) {
    end <- which_not[length(which_not)]
  } else {
    end <- length(x)
  }

  x[start:end]
}


# Helpers -----------------------------------------------------------------

parse_opts <- function(string) {
  if (is.null(string)) {
    return(list())
  }

  args <- list("text", "verbatim", "rd", "hide", "build", "install", "render")
  names(args) <- args
  arg_env <- child_env(baseenv(), !!!args)

  args <- strsplit(string, ",")[[1]]
  exprs <- purrr::map(args, parse_expr)

  env <- child_env(arg_env)
  purrr::walk(exprs, eval_bare, env = env)

  as.list(env)
}

stop_bad_tag <- function(tag, msg = NULL) {
  bad_tag <- paste0("\\", tag, "{}")
  msg_abort <- 'Failed to parse tag {.val {bad_tag}}.'
  cli::cli_abort(c(msg_abort, i = msg), call = NULL)
}

is_newline <- function(x, trim = FALSE) {
  if (!inherits(x, "TEXT") && !inherits(x, "RCODE") && !inherits(x, "VERB")) {
    return(FALSE)
  }

  text <- x[[1]]
  if (trim) {
    text <- gsub("^[ \t]+|[ \t]+$", "", text)
  }
  identical(text, "\n")
}
