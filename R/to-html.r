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
#' @S3method to_html Rd_doc
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
#' @S3method to_html list
to_html.list <- function(x, ...) {
  lapply(x, to_html, ...)
}

# Elements that don't return anything ----------------------------------------

#' @S3method to_html NULL
to_html.NULL <- function(x, ...) character(0)
#' @S3method to_html COMMENT
to_html.COMMENT <- function(x, ...) character(0)
#' @S3method to_html dontshow
to_html.dontshow <- function(x, ...) character(0)
#' @S3method to_html testonly
to_html.testonly <- function(x, ...) character(0)
#' @S3method to_html concept
to_html.concept <- function(x, ...) character(0)

# Various types of text ------------------------------------------------------

# All components inside a text string should be collapsed into a single string
# Also need to do html escaping here and in to_html.RCODE
#' @S3method to_html TEXT
to_html.TEXT <- function(x, ...) {
  str_c(unlist(to_html.list(x, ...)), collapse = "")
}
#' @S3method to_html RCODE
to_html.RCODE <- to_html.TEXT
#' @S3method to_html LIST
to_html.LIST <- to_html.TEXT
#' @S3method to_html VERB
to_html.VERB <- to_html.TEXT

# If it's a character vector, we've got to the leaves of the tree
#' @S3method to_html character
to_html.character <- function(x, ...) x

#' @S3method to_html name
to_html.name <- function(x, ...) to_html(x[[1]], ...)
#' @S3method to_html title
to_html.title <- function(x, ...) to_html.TEXT(x, ...)
#' @S3method to_html usage
to_html.usage <- function(x, package, ...) {
  text <- to_html.TEXT(x, ...)
  
  # Parse and deparse to convert (e.g.) +(a, b) to a + b
  expr <- as.list(parse(text = text))
  text <- lapply(expr, function(x) {
    lines <- deparse(x, width = 80)
    lines[-1] <- str_c("  ", lines[-1])
    str_c(lines, collapse = "\n")
  })
  
  # Collapse, fix indenting and highlight
  usage <- str_c(unlist(text), collapse = "\n\n")
  usage <- str_replace(usage, "      ", "  ")
  src_highlight(usage, package$rd_index)
}
#' @S3method to_html alias
to_html.alias <- function(x, ...) unlist(to_html.list(x, ...))
#' @S3method to_html keyword
to_html.keyword <- function(x, ...) unlist(to_html.list(x, ...))
#' @S3method to_html seealso
to_html.seealso <- function(x, ...) to_html.TEXT(x, ...)
#' @S3method to_html author
to_html.author <- function(x, ...) to_html.TEXT(x, ...)


# Sections get a element called text and an element called content, which
# contains a list of paragraphs.
#' @S3method to_html details
to_html.details <- function(x, ...) parse_section(x, "Details", ...)
#' @S3method to_html description
to_html.description <- function(x, ...) parse_section(x, "Description", ...)
#' @S3method to_html value
to_html.value <- function(x, ...) parse_section(x, "Value", ...)
#' @S3method to_html references
to_html.references <- function(x, ...) parse_section(x, "References", ...)
#' @S3method to_html format
to_html.format <- function(x, ...) parse_section(x, "Format", ...)
#' @S3method to_html note
to_html.note <- function(x, ...) parse_section(x, "Note", ...)
#' @S3method to_html section
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
#' @S3method to_html examples
to_html.examples <- function(x, package, topic = "unknown", env = new.env(parent = globalenv()), ...) {
  if (!package$examples) return()

  # First element of examples tag is always empty
  text <- to_html.TEXT(x[-1], ...)
  expr <- evaluate(text, env)
  
  replay_html(expr, package = package, name = str_c(topic, "-"))
}

# Arguments ------------------------------------------------------------------

#' @S3method to_html arguments
to_html.arguments <- function(x, ...) {
  items <- Filter(function(x) tag(x) == "item", x)  
  to_html(items, ...)
}

#' @S3method to_html item
to_html.item <- function(x, ...) {
  # If no subelements, then is an item from a itemise or enumerate, and 
  # is dealt with those methods
  if (length(x) == 0) return()
  
  list(name = to_html(x[[1]], ...), description = to_html.TEXT(x[[2]], ...))
}

# Equations ------------------------------------------------------------------

#' @S3method to_html eqn
to_html.eqn <- function(x, ...) {
  stopifnot(length(x) <= 2)
  ascii_rep <- x[[length(x)]]
  
  str_c("<code class = 'eq'>", to_html.TEXT(ascii_rep, ...), "</code>")
}

#' @S3method to_html deqn
to_html.deqn <- function(x, ...) {
  stopifnot(length(x) <= 2)
  ascii_rep <- x[[length(x)]]
  
  str_c("<pre class = 'eq'>", to_html.TEXT(ascii_rep, ...), "</code>")
}

# Links ----------------------------------------------------------------------
#' @S3method to_html url
to_html.url <- function(x, ...) {
  stopifnot(length(x) == 1)
  str_c("<a href = '", x[[1]], "'>", x[[1]], "</a>")
}
#' @S3method to_html href
to_html.href <- function(x, ...) {
  stopifnot(length(x) == 2)
  str_c("<a href = '", to_html.TEXT(x[[1]]), "'>", to_html.TEXT(x[[2]]),
    "</a>")
}
#' @S3method to_html email
to_html.email <- function(x, ...) {
  stopifnot(length(x) %in% c(1L, 2L))
  str_c("<a href='mailto:", x[[1]], "'>", x[[length(x)]], "</a>")
}


# If single, need to look up alias to find file name and package
#' @S3method to_html link
to_html.link <- function(x, package, ...) {
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
    t_package <- opt
  }
  
  loc <- find_topic(topic, t_package, package$rd_index)
  if (is.null(loc)) {
    message("Can't find help topic ", topic)
    return(topic)
  }  

  make_link(loc, label, package)
}
  
make_link <- function(loc, label, package = NULL) {
  if (is.null(loc$package)) {
    str_c("<a href='", loc$file, "'>", label, "</a>")
  } else {
    str_c("<a href='http://www.inside-r.org/r-doc/", loc$package, "/", 
      loc$topic, "'>", label, "</a>")
  }
}

# Miscellaneous --------------------------------------------------------------

# First element of enc is the encoded version (second is the ascii version)
#' @S3method to_html enc
to_html.enc <- function(x, ...) {
  to_html(x[[1]], ...)
}

#' @S3method to_html dontrun
to_html.dontrun <- function(x, ...) {
  if (length(x) == 1) {
    str_c("## <strong>Not run</strong>: " , to_html.TEXT(x))    
  } else {
    str_c(
      "## <strong>Not run</strong>: " , 
      str_replace_all(to_html.TEXT(x, ...), "\n", "\n# "), 
      "## <strong>End(Not run)</strong>"
    )    
  }
}

#' @S3method to_html special
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

#' @S3method to_html method
to_html.method <- function(x, ...) {
  str_c('"', to_html(x[[1]], ...), '"')
}
#' @S3method to_html S3method
to_html.S3method <- to_html.method
#' @S3method to_html S4method
to_html.S4method <- to_html.method

#' @S3method to_html docType
to_html.docType <- function(...) NULL


# Conditionals and Sexprs ----------------------------------------------------

#' @S3method to_html Sexpr
#' @importFrom tools parse_Rd
to_html.Sexpr <- function(x, env, ...) {
  expr <- eval(parse(text = x[[1]]), env)

  con <- textConnection(expr)
  on.exit(close(con))
  rd <- parse_Rd(con, fragment = TRUE)
  
  to_html(rd, ...)
}

#' @S3method to_html if
to_html.if <- function(x, ...) {
  if (x[[1]] != "html") return()
  x[[2]]
}

#' @S3method to_html ifelse
to_html.ifelse <- function(x, ...) {
  if (x[[1]] == "html") x[[2]] else x[[3]]
}

# Tables ---------------------------------------------------------------------

#' @S3method to_html tabular
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

#' @S3method to_html tab
to_html.tab <- function(x, ...) character(0)
#' @S3method to_html cr
to_html.cr <- function(x, ...) character(0)


# List -----------------------------------------------------------------------

#' @S3method to_html itemize
to_html.itemize <- function(x, ...) {
  str_c("<ul>\n", parse_items(x[-1], ...), "</ul>\n")
}
#' @S3method to_html enumerate
to_html.enumerate <- function(x, ...) {
  str_c("<ol>\n", parse_items(x[-1], ...), "</ol>\n")
}

parse_items <- function(rd, ...) {
  separator <- vapply(rd, function(x) tag(x) == "item", 
    FUN.VALUE = logical(1))
  
  group <- cumsum(separator)

  items <- split(rd, group)
  li <- vapply(items, function(x) {
    str_c("<li>", to_html.TEXT(x, ...), "</li>\n")
  }, FUN.VALUE = character(1))
  
  str_c(li, collapse = "")
}

# Simple tags that need minimal processing -----------------------------------

#' @S3method to_html Rd
to_html.Rd <- function(x, ...) {
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
  "describe" =     c("<span class='describe'>", "</span>"),
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
