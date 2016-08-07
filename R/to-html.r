#' Convert an rdoc to a list of html components.
#'
#' All span-level tags are converted to html, and higher level blocks are
#' returned as components of the list.
#'
#' @return A list, suitable for rendering with
#'   \code{\link[whisker]{whisker.render}}
#' @param x rd object to convert to html
#' @param ... other arguments passed onto to methods
#' @export
to_html <- function(x, ...) {
  UseMethod("to_html")
}

# Parse a complete Rd file
#' @export
to_html.Rd_doc <- function(x, ...) {
  tags <- vapply(x, tag, FUN.VALUE = character(1))
  get_tags <- function(tag) x[tags == tag]
  get_tag <- function(tag) {
    if (tag %in% tags) {
      x[[which(tags == tag)]]
    }
  }

  # Remove line breaks between sections
  line_breaks <- tags == "TEXT"
  x <- x[!line_breaks]
  tags <- tags[!line_breaks]

  out <- list()

  # Capture name, title and aliasess
  out$name <- to_html(get_tag("name"), ...)
  out$title <- to_html(get_tag("title"), ...)
  out$aliases <- vapply(get_tags("alias"), to_html, character(1), ...)
  out$keywords <- vapply(get_tags("keyword"), to_html, character(1), ...)

  out$usage <- to_html(get_tag("usage"), ...)
  out$arguments <- to_html(get_tag("arguments"), ...)
  if (length(out$arguments)) {
    out$has_args <- TRUE # Work around mustache deficiency
  }
  out$author <- to_html(get_tag("author"), ...)

  out$seealso <- to_html(get_tag("seealso"), ...)
  out$examples <- to_html(get_tag("examples"), ...)

  # Everything else stays in original order, and becomes a list of sections.
  sections <- x[!(tags %in% c("name", "title", "alias", "keyword",
    "usage", "author", "seealso", "arguments", "examples"))]
  out$sections <- compact(to_html(sections, topic = out$name, ...))

  out
}

# A list of elements should stay as a list
#' @export
to_html.list <- function(x, ...) {
  lapply(x, to_html, ...)
}

# Elements that don't return anything ----------------------------------------

#' @export
to_html.NULL <- function(x, ...) character(0)
#' @export
to_html.COMMENT <- function(x, ...) character(0)
#' @export
to_html.dontshow <- function(x, ...) character(0)
#' @export
to_html.testonly <- function(x, ...) character(0)
#' @export
to_html.concept <- function(x, ...) character(0)

# Various types of text ------------------------------------------------------

# All components inside a text string should be collapsed into a single string
# Also need to do html escaping here and in to_html.RCODE
#' @export
to_html.TEXT <- function(x, ...) {
  str_c(unlist(to_html.list(x, ...)), collapse = "")
}
#' @export
to_html.RCODE <- to_html.TEXT
#' @export
to_html.LIST <- to_html.TEXT
#' @export
to_html.VERB <- to_html.TEXT

# If it's a character vector, we've got to the leaves of the tree
#' @export
to_html.character <- function(x, ...) x

#' @export
to_html.name <- function(x, ...) to_html(x[[1]], ...)
#' @export
to_html.title <- function(x, ...) to_html.TEXT(x, ...)
#' @export
to_html.usage <- function(x, pkg, ...) {
  text <- paste(to_html.TEXT(x, ...), collapse = "\n")

  text <- str_trim(text)

  # It's nice not to wrap in the middle of a simple "arg = default"
  text <- str_replace_all(text, " = ", "&nbsp;=&nbsp;")
  # Wrap each individual function in its own div, so that text-indent
  # CSS rules can be used effectively
  text <- str_replace_all(text, "\n\n", "</div>\n<div>")
  text <- paste0("<div>", text, "</div>")
  # Collapse all hardcoded hanging indents
  text <- str_replace_all(text, "\n +", " ")

  src_highlight(text, pkg$rd_index)
}
#' @export
to_html.alias <- function(x, ...) unlist(to_html.list(x, ...))
#' @export
to_html.keyword <- function(x, ...) unlist(to_html.list(x, ...))
#' @export
to_html.seealso <- function(x, ...) to_html.TEXT(x, ...)
#' @export
to_html.author <- function(x, ...) to_html.TEXT(x, ...)


# Sections get a element called text and an element called content, which
# contains a list of paragraphs.
#' @export
to_html.details <- function(x, ...) parse_section(x, "Details", ...)
#' @export
to_html.description <- function(x, ...) parse_section(x, "Description", ...)
#' @export
to_html.value <- function(x, ...) {
  # Note that \value is implicitly a \describe environment
  class(x) <- c("describe", class(x))

  text <- to_html(x, ...)
  paras <- str_trim(str_split(text, "\\n\\s*\\n")[[1]])

  list(title = "Value", contents = paras)
}
#' @export
to_html.references <- function(x, ...) parse_section(x, "References", ...)
#' @export
to_html.source <- function(x, ...) parse_section(x, "Source", ...)
#' @export
to_html.format <- function(x, ...) parse_section(x, "Format", ...)
#' @export
to_html.note <- function(x, ...) parse_section(x, "Note", ...)
#' @export
to_html.section <- function(x, ...) {
  parse_section(x[[2]], to_html(x[[1]], ...), ...)
}

parse_section <- function(x, title, ...) {
  text <- to_html.TEXT(x, ...)
  paras <- str_trim(str_split(text, "\\n\\s*\\n")[[1]])

  list(title = title, contents = paras)
}

# Examples ------------------------------------------------------------------

#' @importFrom evaluate evaluate
#' @export
to_html.examples <- function(x, pkg, topic = "unknown", env = new.env(parent = globalenv()), ...) {
  if (!pkg$examples) return()

  # First element of examples tag is always empty
  text <- to_html.TEXT(x[-1], ...)
  expr <- evaluate(text, env, new_device = TRUE)

  replay_html(expr, pkg = pkg, name = str_c(topic, "-"))
}

# Arguments ------------------------------------------------------------------

#' @export
to_html.arguments <- function(x, ...) {
  items <- Filter(function(x) tag(x) == "item", x)
  to_html(items, ...)
}

#' @export
to_html.item <- function(x, ...) {
  # If no subelements, then is an item from a itemise or enumerate, and
  # is dealt with those methods
  if (length(x) == 0) return()

  list(name = to_html(x[[1]], ...), description = to_html.TEXT(x[[2]], ...))
}

# Equations ------------------------------------------------------------------

#' @export
to_html.eqn <- function(x, pkg, ...) {
  stopifnot(length(x) <= 2)
  ascii_rep <- x[[length(x)]]
  if (pkg$mathjax){
    str_c("$", to_html.TEXT(ascii_rep, ...), "$")
  }else{
    str_c("<code class = 'eq'>", to_html.TEXT(ascii_rep, ...), "</code>")
  }
}

#' @export
to_html.deqn <- function(x, pkg, ...) {
  stopifnot(length(x) <= 2)
  if (pkg$mathjax){
    str_c("$$", to_html.TEXT(x[[length(x)-1]], ...), "$$")
  }else{
    str_c("<pre class = 'eq'>", to_html.TEXT(x[[length(x)]], ...), "</pre>")
  }
}

# Links ----------------------------------------------------------------------
#' @export
to_html.url <- function(x, ...) {
  stopifnot(length(x) == 1)
  str_c("<a href = '", to_html.TEXT(x[[1]]), "'>", to_html.TEXT(x[[1]]), "</a>")
}
#' @export
to_html.href <- function(x, ...) {
  stopifnot(length(x) == 2)
  str_c("<a href = '", to_html.TEXT(x[[1]]), "'>", to_html.TEXT(x[[2]]),
    "</a>")
}
#' @export
to_html.email <- function(x, ...) {
  stopifnot(length(x) %in% c(1L, 2L))
  str_c("<a href='mailto:", x[[1]], "'>", x[[length(x)]], "</a>")
}


# If single, need to look up alias to find file name and package
#' @export
to_html.link <- function(x, pkg, ...) {
  stopifnot(length(x) == 1)

  opt <- attr(x, "Rd_option")

  if (is.null(opt)) {
    topic <- to_html.TEXT(x[[1]])
    label <- topic
    t_package <- NULL
  } else if (str_sub(opt, 1, 1) == "=") {
    topic <- str_sub(opt, 2, -1)
    label <- to_html.TEXT(x[[1]])
    t_package <- NULL
  } else {
    topic <- to_html.TEXT(x[[1]])
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
  # requested from the package for which documentation is rendered.
  # Otherwise find_topic() -> rd_path() will open the development version of the
  # help page, because the package is loaded with devtools::load_all().
  if (!is.null(t_package) && t_package == pkg$package) {
    t_package <- NULL
  }

  loc <- find_topic(topic, t_package, pkg$rd_index)
  if (is.null(loc)) {
    message("Can't find help topic ", topic)
    return(topic)
  }

  make_link(loc, label, pkg)
}

make_link <- function(loc, label, pkg = NULL) {
  if (is.null(loc$package)) {
    str_c("<a href='", loc$file, "'>", label, "</a>")
  } else if (loc$package %in% builtin_packages) {
    str_c("<a href='http://www.inside-r.org/r-doc/", loc$package,
          "/", loc$topic, "'>", label, "</a>")
  } else {
    str_c("<a href='http://www.inside-r.org/packages/cran/", loc$package,
      "/docs/", loc$topic, "'>", label, "</a>")
  }
}

builtin_packages <- c("base", "boot", "class", "cluster", "codetools", "compiler",
                      "datasets", "foreign", "graphics", "grDevices", "grid", "KernSmooth",
                      "lattice", "MASS", "Matrix", "methods", "mgcv", "nlme", "nnet",
                      "parallel", "rpart", "spatial", "splines", "stats", "stats4",
                      "survival", "tcltk", "tools", "utils")

# Miscellaneous --------------------------------------------------------------

# First element of enc is the encoded version (second is the ascii version)
#' @export
to_html.enc <- function(x, ...) {
  to_html(x[[1]], ...)
}

#' @export
to_html.dontrun <- function(x, ...) {
  if (length(x) == 1) {
    str_c("## Not run: " , to_html.TEXT(x))
  } else {
    str_c(
      "## Not run: " ,
      str_replace_all(to_html.TEXT(x, ...), "\n", "\n# "),
      "## End(Not run)"
    )
  }
}

#' @export
to_html.special <- function(x, ...) {
  txt <- to_html.TEXT(x, ...)
  # replace '<' and '>' with html markings avoid browser misinterpretation
  txt <- str_replace_all(txt, "<", "&#60;")
  txt <- str_replace_all(txt, ">", "&#62;")
  txt <- str_replace_all(txt, "\\\\dots", "...")

  stupid <- unlist(str_match_all(txt, "\\\\[a-zA-Z]*"))
  for (i in seq_len(length(stupid))) {
    message("Unknown tag (", stupid[i], ") found in 'special' tag")
  }

  str_c("<em>", txt, "</em>")
}

#' @export
to_html.method <- function(x, ...) {
  str_c('"', to_html(x[[1]], ...), '"')
}
#' @export
to_html.S3method <- to_html.method
#' @export
to_html.S4method <- to_html.method

#' @export
to_html.docType <- function(...) NULL


# Conditionals and Sexprs ----------------------------------------------------

#' @export
#' @importFrom tools parse_Rd
to_html.Sexpr <- function(x, env, ...) {
  code <- to_html.TEXT(x)
  expr <- eval(parse(text = code), env)

  con <- textConnection(expr)
  on.exit(close(con))

  rd <- parse_Rd(con, fragment = TRUE)
  rd <- structure(set_classes(rd), class = c("Rd_doc", "Rd"))

  to_html.TEXT(rd, ...)
}

#' @export
to_html.if <- function(x, ...) {
  if (x[[1]] != "html") return()
  x[[2]]
}

#' @export
to_html.ifelse <- function(x, ...) {
  if (x[[1]] == "html") x[[2]] else x[[3]]
}

# Tables ---------------------------------------------------------------------

#' @export
to_html.tabular <- function(x, ...) {
  align_abbr <- str_split(to_html(x[[1]], ...), "")[[1]][-1]
  align_abbr <- align_abbr[!(align_abbr %in% c("|", ""))]
  align <- unname(c("r" = "right", "l" = "left", "c" = "center")[align_abbr])

  contents <- x[[2]]
  row_sep <- vapply(contents, function(x) tag(x) == "cr",
    FUN.VALUE = logical(1))
  col_sep <- vapply(contents, function(x) tag(x) == "tab",
    FUN.VALUE = logical(1))

  last <- rev(which(row_sep))[1] - 1L
  contents <- contents[seq_len(last)]
  cell_grp <- cumsum(col_sep | row_sep)[seq_len(last)]
  cells <- split(contents, cell_grp)

  cell_contents <- vapply(cells, to_html.TEXT, ...,
    FUN.VALUE = character(1), USE.NAMES = FALSE)
  cell_contents <- str_c("<td>", cell_contents, "</td>\n")
  cell_contents <- matrix(cell_contents, ncol = length(align), byrow = TRUE)

  rows <- apply(cell_contents, 1, str_c, collapse = "")

  str_c("<table>", str_c("<tr>", rows, "</tr>", collapse = ""), "</table>")
}

#' @export
to_html.tab <- function(x, ...) character(0)
#' @export
to_html.cr <- function(x, ...) character(0)


# List -----------------------------------------------------------------------

#' @export
to_html.itemize <- function(x, ...) {
  str_c("<ul>\n", parse_items(x[-1], ...), "</ul>\n")
}
#' @export
to_html.enumerate <- function(x, ...) {
  str_c("<ol>\n", parse_items(x[-1], ...), "</ol>\n")
}
#' @export
to_html.describe <- function(x, ...) {
  str_c("<dl>\n", parse_descriptions(x[-1], ...), "</dl>\n")
}

parse_items <- function(rd, ...) {
  separator <- vapply(rd, function(x) tag(x) == "item",
    FUN.VALUE = logical(1))
  group <- cumsum(separator)

  # remove empty first group, if present
  rd <- rd[group != 0]
  group <- group[group != 0]

  items <- split(rd, group)

  li <- vapply(items, function(x) {
    str_c("<li>", to_html.TEXT(x, ...), "</li>\n")
  }, FUN.VALUE = character(1))

  str_c(li, collapse = "")
}

parse_descriptions <- function(rd, ...) {
  is_item <- vapply(rd, function(x) tag(x) == "item",
                      FUN.VALUE = logical(1))

  li <- character(length(rd))
  for (i in seq_along(rd)) {
    if (is_item[[i]])
      li[i] <- str_c("<dt>", to_html.TEXT(rd[[i]][[1]], ...), "</dt><dd>", to_html.TEXT(rd[[i]][-1], ...), "</dd>\n")
    else
      li[i] <- to_html.TEXT(rd[i], ...)
  }

  str_c(li, collapse = "")
}

# Simple tags that need minimal processing -----------------------------------

#' @export
to_html.Rd_content <- function(x, ...) {
  tag <- tag(x)

  if (is.null(tag)) {
    to_html.TEXT(x, ...)
  } else if (!is.null(tag) && tag %in% names(simple_tags)) {
    # If we can process tag with just prefix & suffix, do so
    html <- simple_tags[[tag]]
    str_c(html[1], to_html.TEXT(x, ...), html[2])
  } else {
    # Otherwise we don't know about this tag
    message("Unknown tag: ", tag)
    to_html.TEXT(x, ...)
  }
}

simple_tags <- list(
  "acronym" =      c('<acronym>','</acronym>'),
  "bold" =         c("<b>", "</b>"),
  "cite" =         c("<cite>", "</cite>"),
  "code" =         c("<code>", "</code>"),
  "command" =      c("<code>", "</code>"),
  "cr" =           c("<br >", ""),
  "dfn" =          c("<dfn>", "</dfn>"),
  "donttest" =     c("", ""),
  "dots" =         c("...", ""),
  "dquote" =       c("&#147;", "&#148;"),
  "dQuote" =       c("&#147;", "&#148;"),
  "emph" =         c("<em>", "</em>"),
  "env" =          c('<span class = "env">', '</span>'),
  "file" =         c('&#145;<span class = "file">', '</span>&#146;'),
  "item" =         c("<li>", "</li>"),
  "kbd" =          c("<kbd>", "</kbd>"),
  "ldots" =        c("...", ""),
  "option" =       c('<span class = "option">',"</span>"),
  "out" =          c("", ""),
  "pkg" =          c('<span class = "pkg">',"</span>"),
  "preformatted" = c("<pre>","</pre>"),
  "R" =            c('<span style="R">R</span>', ""),
  "samp" =         c('<span class = "samp">',"</span>"),
  "sQuote" =       c("&#145;","&#146;"),
  "strong" =       c("<strong>", "</strong>"),
  "text" =         c("<p>", "</p>"),
  "var" =          c("<var>", "</var>"),
  "verb" =         c("<code>", "</code>")
)
