as_html <- function(x, ...) {
  UseMethod("as_html")
}

# Various types of text ------------------------------------------------------

flatten_para <- function(x, ...) {
  # Look for "\n" TEXT blocks within sequence of TEXT blocks
  is_nl <- purrr::map_lgl(x, is_newline)
  is_text <- purrr::map_lgl(x, inherits, "TEXT")
  is_text_prev <- c(FALSE, is_text[-length(x)])
  is_text_next <- c(is_text[-1], FALSE)
  is_para_break <- is_nl & is_text_prev & is_text_next

  # Or tags that are converted to HTML blocks
  block_tags <- c(
    "tag_preformatted", "tag_itemize", "tag_enumerate", "tag_tabular",
    "tag_describe", "tag_subsection"
  )
  is_block <- purrr::map_lgl(x, inherits, block_tags)

  # Break before and after each status change
  before_break <- is_para_break | is_block
  after_break <- c(FALSE, before_break[-length(x)])
  groups <- cumsum(before_break | after_break)

  blocks <- x %>%
    purrr::map_chr(as_html, ...) %>%
    split(groups) %>%
    purrr::map_chr(paste, collapse = "")

  # There are three types of blocks:
  # 1. Combined text and inline tags
  # 2. Paragraph breaks (text containing only "\n")
  # 3. Block-level tags
  #
  # Need to wrap 1 in <p>
  needs_p <- (!(is_nl | is_block)) %>%
    split(groups) %>%
    purrr::map_lgl(any)

  blocks[needs_p] <- paste0("<p>", trimws(blocks[needs_p]), "</p>")

  paste0(blocks, collapse = "")
}


flatten_text <- function(x, ...) {
  if (length(x) == 0) return("")

  x %>%
    purrr::map_chr(as_html, ...) %>%
    paste(collapse = "")
}

#' @export
as_html.Rd <- function(x, ...) flatten_text(x, ...)

#' @export
as_html.LIST <-  flatten_text

# Leaves  -----------------------------------------------------------------

#' @export
as_html.character <- function(x, ..., escape = TRUE) {
  # src_highlight (used by usage & examples) also does escaping
  # so we need some way to turn it off when needed.
  if (escape) {
    escape_html(x)
  } else {
    as.character(x)
  }
}
#' @export
as_html.TEXT <-  as_html.character
#' @export
as_html.RCODE <- as_html.character
#' @export
as_html.VERB <-  as_html.character
#' @export
as_html.COMMENT <- function(x, ...) {
  paste0("<!-- ", flatten_text(x), " -->")
}
# USERMACRO appears first, followed by the rendered macro
#' @export
as_html.USERMACRO <-  function(x, ...) ""

#' @export
as_html.tag_subsection <- function(x, ...) {
  paste0(
    "<h3>", flatten_text(x[[1]], ...), "</h3>\n",
    flatten_text(x[[2]], ...)
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
    "<a href = '", flatten_text(x[[1]]), "'>",
    flatten_text(x[[2]]),
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
  opt <- attr(x, "Rd_option")

  in_braces <- flatten_text(x)

  if (is.null(opt)) {
    # \link{topic}
    link_local(in_braces, in_braces, index = index, current = current)
  } else if (substr(opt, 1, 1) == "=") {
    # \link[=dest]{name}
    link_local(in_braces, substr(opt, 2, nchar(opt)), index = index, current = current)
  } else {
    match <- regexec('^([^:]+)(?:|:(.*))$', opt)
    parts <- regmatches(opt, match)[[1]][-1]

    pkg_name <- attr(current, "pkg_name")
    stopifnot(!is.null(pkg_name))

    if (parts[[1]] == pkg_name) {
      # \link[my_pkg]{foo}
      link_local(in_braces, in_braces, index = index, current = current)
    } else if (parts[[2]] == "") {
      # \link[pkg]{foo}
      link_remote(in_braces, in_braces, package = opt)
    } else {
      # \link[pkg:bar]{foo}
      link_remote(in_braces, parts[[2]], package = parts[[1]])
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
  if (x[[1]] == "html") as_html(x[[2]], ...) else as_html(x[[3]], ...)
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


# Figures -----------------------------------------------------------------

#' @export
as_html.tag_figure <- function(x, ...) {
  n <- length(x)
  path <- as.character(x[[1]])

  if (n == 1) {
    paste0("<img src='figures/", path, "' alt='' />")
  } else if (n == 2) {
    opt <- as.character(x[[2]])
    if (substr(opt, 1, 9) == "options: ") {
      extra <- substr(opt, 9, nchar(opt))
      paste0("<img src='figures/", path, "'",  extra, " />")
    } else {
      paste0("<img src='figures/", path, "' alt='", opt, "' />")
    }
  } else {
    stop("Invalid \\figure{} markup", call. = FALSE)
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
  paste0("<dl class='dl-horizontal'>\n", parse_descriptions(x[-1], ...), "</dl>")
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
        "<dd>", flatten_para(x[-1], ...), "</dd>"
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
as_html.tag_code <-         function(x, ..., depth = 1L) {
  html <- flatten_text(x, ...)

  expr <- tryCatch(
    parse(text = html)[[1]],
    error = function(e) NULL
  )

  if (is_call_vignette(expr)) {
    html <- link_vignette(expr, html, depth = depth)
  }

  paste0("<code>", html, "</code>")
}
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

# Whitespace helper -------------------------------------------------------

trim_ws_nodes <- function(x, side = c("both", "left", "right")) {
  is_ws <- purrr::map_lgl(x, ~ inherits(., "TEXT") && grepl("^\\s*$", .[[1]]))

  if (!any(is_ws))
    return(x)
  if (all(is_ws))
    return(x[0])

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

