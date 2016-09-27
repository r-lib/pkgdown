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
as_html.tag_eqn <- function(x, pkg, ...) {
  stopifnot(length(x) <= 2)
  if (isTRUE(pkg$mathjax)){
    latex_rep <- x[[1]]
    str_c("$", flatten_text(latex_rep, ...), "$")
  }else{
    ascii_rep <- x[[length(x)]]
    str_c("<code class = 'eq'>", flatten_text(ascii_rep, ...), "</code>")
  }
}

#' @export
as_html.tag_deqn <- function(x, pkg, ...) {
  stopifnot(length(x) <= 2)
  if (isTRUE(pkg$mathjax)) {
    latex_rep <- x[[1]]
    str_c("$$", flatten_text(latex_rep, ...), "$$")
  }else{
    ascii_rep <- x[[length(x)]]
    str_c("<pre class = 'eq'>", flatten_text(ascii_rep, ...), "</pre>")
  }
}

# Links ----------------------------------------------------------------------
#' @export
as_html.tag_url <- function(x, ...) {
  stopifnot(length(x) == 1)
  str_c("<a href = '", flatten_text(x[[1]]), "'>", flatten_text(x[[1]]), "</a>")
}
#' @export
as_html.tag_href <- function(x, ...) {
  stopifnot(length(x) == 2)
  str_c("<a href = '", flatten_text(x[[1]]), "'>", flatten_text(x[[2]]),
    "</a>")
}
#' @export
as_html.tag_email <- function(x, ...) {
  stopifnot(length(x) %in% c(1L, 2L))
  str_c("<a href='mailto:", x[[1]], "'>", x[[length(x)]], "</a>")
}


# If single, need to look up alias to find file name and package
#' @export
as_html.tag_link <- function(x, pkg, ...) {
  stopifnot(length(x) == 1)

  opt <- attr(x, "Rd_option")

  if (is.null(opt)) {
    topic <- flatten_text(x[[1]])
    label <- topic
    t_package <- NULL
  } else if (str_sub(opt, 1, 1) == "=") {
    topic <- str_sub(opt, 2, -1)
    label <- flatten_text(x[[1]])
    t_package <- NULL
  } else {
    topic <- flatten_text(x[[1]])
    label <- topic
    parts <- str_match(opt, '([^:]+):(.*)')[1,]
    if (is.na(parts[1])) {
      t_package <- opt
    } else {
      topic <- parts[3]
      t_package <- parts[2]
    }
  }

  # Special case: need to remove the package qualification if help is explicitly
  # requested from the package for which documentation is rendered (#115).
  # Otherwise find_topic() -> rd_path() will open the development version of the
  # help page, because the package is loaded with devtools::load_all().
  if (!is.null(t_package) && t_package == pkg$package) {
    t_package <- NULL
  }

  find_topic_and_make_link(topic, label, t_package, pkg)
}

# Might need to look up alias to find file name and package
#' @export
as_html.tag_linkS4class <- function(x, pkg, ...) {
  stopifnot(length(x) == 1)

  topic <- flatten_text(x[[1]])
  label <- topic
  t_package <- NULL

  topic <- paste0(topic, "-class")

  find_topic_and_make_link(topic, label, t_package, pkg)
}

find_topic_and_make_link <- function(topic, label, t_package, pkg) {
  loc <- find_topic(topic, t_package, pkg$topics)
  if (is.null(loc)) {
    message("Can't find help topic ", topic)
    return(topic)
  }

  make_link(loc, label, pkg)
}

find_topic <- function(alias, package = NULL, index) {
  # Current package, so look in index first
  if (is.null(package)) {
    match <- Position(function(x) any(x == alias), index$alias)
    if (!is.na(match)) {
      return(list(package = NULL, file = index$file_out[match]))
    }
  }

  path <- rd_path(alias, package)
  if (is.null(path)) return(NULL)

  pieces <- strsplit(path, .Platform$file.sep)[[1]]
  n <- length(pieces)

  list(package = pieces[n - 2], topic = pieces[n])
}

rd_path <- function(topic, package = NULL) {
  topic <- as.name(topic)
  if (!is.null(package)) package <- as.name(package)

  help_call <- substitute(utils::help(topic, package = package, try.all.packages = TRUE),
    list(topic = topic, package = package))

  res <- eval(help_call)
  if (length(res) == 0) return(NULL)

  res[[1]]
}

make_link <- function(loc, label, pkg = NULL) {
  if (is.null(loc$package)) {
    str_c("<a href='", loc$file, "'>", label, "</a>")
  } else {
    str_c("<a href='http://www.rdocumentation.org/packages/", loc$package,
      "/topics/", loc$topic, "'>", label, "</a>")
  }
}

builtin_packages <- c("base", "boot", "class", "cluster", "codetools", "compiler",
                      "datasets", "foreign", "graphics", "grDevices", "grid", "KernSmooth",
                      "lattice", "MASS", "Matrix", "methods", "mgcv", "nlme", "nnet",
                      "parallel", "rpart", "spatial", "splines", "stats", "stats4",
                      "survival", "tcltk", "tools", "utils")

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
as_html.tag_Sexpr <- function(x, env, ...) {
  code <- flatten_text(x, escape = FALSE)
  expr <- eval(parse(text = code), env)

  con <- textConnection(expr)
  on.exit(close(con))

  rd <- tools::parse_Rd(con, fragment = TRUE)
  rd <- structure(set_classes(rd), class = c("Rd_doc", "Rd"))

  flatten_text(rd, ...)
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
  align_abbr <- str_split(as_html(x[[1]], ...), "")[[1]][-1]
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
  cell_contents <- str_c("<td>", cell_contents, "</td>\n")
  cell_contents <- matrix(cell_contents, ncol = length(align), byrow = TRUE)

  rows <- apply(cell_contents, 1, str_c, collapse = "")

  str_c("<table>", str_c("<tr>", rows, "</tr>", collapse = ""), "</table>")
}



# List -----------------------------------------------------------------------

#' @export
as_html.tag_itemize <- function(x, ...) {
  str_c("<ul>\n", parse_items(x[-1], ...), "</ul>\n")
}
#' @export
as_html.tag_enumerate <- function(x, ...) {
  str_c("<ol>\n", parse_items(x[-1], ...), "</ol>\n")
}
#' @export
as_html.tag_describe <- function(x, ...) {
  str_c("<dl>\n", parse_descriptions(x[-1], ...), "</dl>\n")
}

parse_items <- function(rd, ...) {
  separator <- purrr::map_lgl(rd, inherits, "tag_item")
  group <- cumsum(separator)

  # remove empty first group, if present
  rd <- rd[group != 0]
  group <- group[group != 0]

  items <- split(rd, group)

  li <- vapply(items, function(x) {
    str_c("<li>", flatten_text(x, ...), "</li>\n")
  }, FUN.VALUE = character(1))

  str_c(li, collapse = "")
}

parse_descriptions <- function(rd, ...) {
  is_item <- purrr::map_lgl(rd, inherits, "tag_item")

  li <- character(length(rd))
  for (i in seq_along(rd)) {
    if (is_item[[i]])
      li[i] <- str_c("<dt>", flatten_text(rd[[i]][[1]], ...), "</dt><dd>", flatten_text(rd[[i]][-1], ...), "</dd>\n")
    else
      li[i] <- flatten_text(rd[i], ...)
  }

  str_c(li, collapse = "")
}

# Marking text ------------------------------------------------------------
# https://cran.rstudio.com/doc/manuals/r-devel/R-exts.html#Marking-text

tag_wrapper <- function(prefix, suffix = NULL) {
  function(x, ...) {
    html <- as_html(x[[1]], ...)
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
as_html.tag_preformatted <- tag_wrapper("<pre>","</pre>")
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
as_html.tag_donttest <- function(x, ...) ""
#' @export
as_html.tag_tab <-      function(x, ...) ""
#' @export
as_html.tag_cr <-       function(x, ...) ""

#' @export
as_html.tag <- function(x, ...) {
  if (identical(class(x), "tag")) {
    flatten_text(x, ...)
  } else {
    message("Unknown tag: ", paste(class(x), collapse = "/"))
    ""
  }
}
