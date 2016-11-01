as_html <- function(x, ...) {
  UseMethod("as_html")
}

# Various types of text ------------------------------------------------------

flatten_text <- function(x, ...) {
  x %>%
    purrr::map_chr(as_html, ...) %>%
    paste(collapse = "")
}

#' @export
as_html.Rd <- function(x, ...) flatten_text(x, ...)

# All components inside a text string should be collapsed into a single string
# Also need to do html escaping here and in as_html.RCODE
#' @export
as_html.TEXT <-  function(x, ...) flatten_text(x, ...)
#' @export
as_html.RCODE <- function(x, ...) flatten_text(x, ...)
#' @export
as_html.LIST <-  function(x, ...) flatten_text(x, ...)
#' @export
as_html.VERB <-  function(x, ...) flatten_text(x, ...)
#' @export
as_html.COMMENT <- function(x, ...) {
  paste0("<!-- ", flatten_text(x), " -->")
}

# USERMACRO appears first, followed by the rendered macro
#' @export
as_html.USERMACRO <-  function(x, ...) ""

# If it's a character vector, we've got to the leaves of the tree
#' @export
as_html.character <- function(x, ..., escape = TRUE) {
  # src_highlight (used by usage & examples) also does escaping
  # so we need some way to turn it off when needed.
  if (escape) {
    escape_html(x)
  } else {
    x
  }
}

#' @export
as_html.tag_subsection <- function(x, ...) {
  paste0(
    "<h3>", flatten_text(x[[1]]), "</h3>\n",
    flatten_text(x[[2]])
  )
}

# Equations ------------------------------------------------------------------

#' @export
as_html.tag_eqn <- function(x, ..., mathjax = TRUE) {
  stopifnot(length(x) <= 2)
  if (isTRUE(mathjax)){
    latex_rep <- x[[1]]
    paste0("\\(", flatten_text(latex_rep, ...), "\\)")
  }else{
    ascii_rep <- x[[length(x)]]
    paste0("<code class = 'eq'>", flatten_text(ascii_rep, ...), "</code>")
  }
}

#' @export
as_html.tag_deqn <- function(x, ..., mathjax = TRUE) {
  stopifnot(length(x) <= 2)
  if (isTRUE(mathjax)) {
    latex_rep <- x[[1]]
    paste0("$$", flatten_text(latex_rep, ...), "$$")
  }else{
    ascii_rep <- x[[length(x)]]
    paste0("<pre class = 'eq'>", flatten_text(ascii_rep, ...), "</pre>")
  }
}

# Links ----------------------------------------------------------------------
#' @export
as_html.tag_url <- function(x, ...) {
  stopifnot(length(x) == 1)
  paste0("<a href = '", flatten_text(x[[1]]), "'>", flatten_text(x[[1]]), "</a>")
}
#' @export
as_html.tag_href <- function(x, ...) {
  stopifnot(length(x) == 2)
  paste0(
    "<a href = '", flatten_text(x[[2]]), "'>",
    flatten_text(x[[1]]),
    "</a>"
  )
}
#' @export
as_html.tag_email <- function(x, ...) {
  stopifnot(length(x) %in% c(1L, 2L))
  paste0("<a href='mailto:", x[[1]], "'>", x[[length(x)]], "</a>")
}

# If single, need to look up alias to find file name and package
#' @export
as_html.tag_link <- function(x, ..., index = NULL, current = NULL) {
  stopifnot(length(x) == 1)
  opt <- attr(x, "Rd_option")

  in_braces <- flatten_text(x[[1]])

  if (is.null(opt)) {
    # \link{topic}
    link_local(in_braces, in_braces, index = index, current = current)
  } else if (substr(opt, 1, 1) == "=") {
    # \link[=dest]{name}
    link_local(in_braces, substr(opt, 2, nchar(opt)), index = index, current = current)
  } else {
    match <- regexec('([^:]+):(.*)', opt)
    parts <- regmatches(opt, match)[[1]]

    if (length(parts) == 0) {
      # \link[pkg]{foo}
      link_remote(in_braces, in_braces, package = opt)
    } else {
      # \link[pkg:bar]{foo}
      link_remote(in_braces, parts[3], package = parts[2])
    }
  }
}

#' @export
as_html.tag_linkS4class <- function(x, ..., index = NULL, current = NULL) {
  stopifnot(length(x) == 1)

  in_braces <- flatten_text(x[[1]])
  link_local(in_braces, paste0(in_braces, "-class"), index = index, current = current)
}

# Miscellaneous --------------------------------------------------------------

#' @export
as_html.tag_method <- function(x, ...) method_usage(x, "S3")
#' @export
as_html.tag_S3method <- function(x, ...) method_usage(x, "S3")
#' @export
as_html.tag_S4method <- function(x, ...) method_usage(x, "S4")

method_usage <- function(x, type) {
  fun <- as_html(x[[1]])
  class <- as_html(x[[2]])

  paste0(
    "# ", type, " method for ", class, "\n",
    fun
  )
}

# Conditionals and Sexprs ----------------------------------------------------

#' @export
as_html.tag_Sexpr <- function(x, ...) {
  # Currently assume output is always Rd
  options <- attr(x, "Rd_option")

  code <- flatten_text(x, escape = FALSE)
  # Not sure if this is the correct environment
  expr <- eval(parse(text = code)[[1]], new.env(parent = globalenv()))

  rd <- rd_text(as.character(expr))
  as_html(rd, ...)
}

#' @export
as_html.tag_if <- function(x, ...) {
  if (x[[1]] == "html") {
    as_html(x[[2]])
  } else {
    ""
  }
}

#' @export
as_html.tag_ifelse <- function(x, ...) {
  if (x[[1]] == "html") as_html(x[[2]]) else as_html(x[[3]])
}

# Tables ---------------------------------------------------------------------

#' @export
as_html.tag_tabular <- function(x, ...) {
  align_abbr <- strsplit(as_html(x[[1]], ...), "")[[1]][-1]
  align_abbr <- align_abbr[!(align_abbr %in% c("|", ""))]
  align <- unname(c("r" = "right", "l" = "left", "c" = "center")[align_abbr])

  contents <- x[[2]]
  row_sep <- purrr::map_lgl(contents, inherits, "tag_cr")
  col_sep <- purrr::map_lgl(contents, inherits, "tag_tab")

  last <- rev(which(row_sep))[1] - 1L
  contents <- contents[seq_len(last)]
  cell_grp <- cumsum(col_sep | row_sep)[seq_len(last)]
  cells <- split(contents, cell_grp)

  cell_contents <- vapply(cells, flatten_text, ...,
    FUN.VALUE = character(1), USE.NAMES = FALSE)
  cell_contents <- paste0("<td>", cell_contents, "</td>\n")
  cell_contents <- matrix(cell_contents, ncol = length(align), byrow = TRUE)

  rows <- apply(cell_contents, 1, paste0, collapse = "")

  paste0("<table>", paste0("<tr>", rows, "</tr>", collapse = ""), "</table>")
}



# List -----------------------------------------------------------------------

#' @export
as_html.tag_itemize <- function(x, ...) {
  paste0("<ul>\n", parse_items(x[-1], ...), "</ul>\n")
}
#' @export
as_html.tag_enumerate <- function(x, ...) {
  paste0("<ol>\n", parse_items(x[-1], ...), "</ol>\n")
}
#' @export
as_html.tag_describe <- function(x, ...) {
  paste0("<dl class='dl-horizontal'>\n", parse_descriptions(x[-1], ...), "</dl>\n")
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

  # remove empty first group, if present
  rd <- rd[group != 0]
  group <- group[group != 0]

  parse_item <- function(x) {
    paste0("<li>", flatten_text(x, ...), "</li>\n")
  }

  rd %>%
    split(group) %>%
    purrr::map_chr(parse_item) %>%
    paste(collapse = "")
}

parse_descriptions <- function(rd, ...) {
  is_item <- purrr::map_lgl(rd, inherits, "tag_item")

  parse_item <- function(x) {
    if (inherits(x, "tag_item")) {
      paste0(
        "<dt>", flatten_text(x[[1]], ...), "</dt>",
        "<dd>", flatten_text(x[-1], ...), "</dd>"
      )
    } else {
      flatten_text(x, ...)
    }
  }

  rd %>%
    purrr::map_chr(parse_item) %>%
    paste(collapse = "")
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
as_html.tag_emph <-         tag_wrapper("<em>", "</em>")
#' @export
as_html.tag_strong <-       tag_wrapper("<strong>", "</strong>")
#' @export
as_html.tag_bold <-         tag_wrapper("<b>", "</b>")

#' @export
as_html.tag_dQuote <-       tag_wrapper("&#8220;", "&#8221;")
#' @export
as_html.tag_sQuote <-       tag_wrapper("&#8216;", "&#8217;")

#' @export
as_html.tag_code <-         tag_wrapper("<code>", "</code>")
#' @export
as_html.tag_kbd <-          tag_wrapper("<kbd>", "</kbd>")
#' @export
as_html.tag_samp <-         tag_wrapper('<samp>',"</samp>")
#' @export
as_html.tag_verb <-         tag_wrapper("<code>", "</code>")
#' @export
as_html.tag_pkg <-          tag_wrapper('<span class="pkg">',"</span>")
#' @export
as_html.tag_file <-         tag_wrapper('<code class="file">', '</code>')

#' @export
as_html.tag_var <-          tag_wrapper("<var>", "</var>")
#' @export
as_html.tag_env <-          tag_wrapper('<code class="env">', '</code>')
#' @export
as_html.tag_option <-       tag_wrapper('<span class="option">',"</span>")
#' @export
as_html.tag_command <-      tag_wrapper("<code class='command'>", "</code>")

#' @export
as_html.tag_preformatted <- tag_wrapper('<pre>','</pre>')

#' @export
as_html.tag_dfn <-          tag_wrapper("<dfn>", "</dfn>")
#' @export
as_html.tag_cite <-         tag_wrapper("<cite>", "</cite>")
#' @export
as_html.tag_acroynm <-      tag_wrapper('<acronym>','</acronym>')

# Insertions --------------------------------------------------------------

tag_insert <- function(value) {
  function(x, ...) {
    value
  }
}

#' @export
as_html.tag_R <-        tag_insert('<span style="R">R</span>')
#' @export
as_html.tag_dots <-     tag_insert("&#8230;")
#' @export
as_html.tag_ldots <-    tag_insert("&#8230;")

#' @export
as_html.tag_cr <-       tag_insert("<br >")

# First element of enc is the encoded version (second is the ascii version)
#' @export
as_html.tag_enc <- function(x, ...) {
  as_html(x[[1]], ...)
}


# Elements that don't return anything ----------------------------------------

#' @export
as_html.NULL <-         function(x, ...) ""
#' @export
as_html.tag_dontshow <- function(x, ...) ""
#' @export
as_html.tag_testonly <- function(x, ...) ""
#' @export
as_html.tag_concept <-  function(x, ...) ""
#' @export
as_html.tag_out <-      function(x, ...) ""
#' @export
as_html.tag_tab <-      function(x, ...) ""
#' @export
as_html.tag_cr <-       function(x, ...) ""
#' @export
as_html.tag_newcommand <- function(x, ...) ""
#' @export
as_html.tag_renewcommand <- function(x, ...) ""

#' @export
as_html.tag <- function(x, ...) {
  if (identical(class(x), "tag")) {
    flatten_text(x, ...)
  } else {
    message("Unknown tag: ", paste(class(x), collapse = "/"))
    ""
  }
}
