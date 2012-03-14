to_html <- function(x, ...) {
  UseMethod("to_html", x)
}

# A list of elements should stay as a list
to_html.list <- function(x, ...) {
  lapply(rd, to_html)
}

# Elements that don't return anything ----------------------------------------

to_html.NULL <- function(x, ...) ""
to_html.COMMENT <- function(x, ...) ""
to_html.dontshow <- function(x, ...) ""
to_html.testonly <- function(x, ...) ""

# Various types of text ------------------------------------------------------

# All components inside a text string should be collapsed into a single string
to_html.TEXT <- function(x, ...) {
  str_c(unlist(to_html.list(x)), collapse = "")
}

# If it's a character vector, we've got to the leaves of the tree
to_html.character <- function(x, ...) x

# Sections get a element called text and an element called content, which
# contains a list of paragraphs.
to_html.details <- function(x, ...) parse_section(x, "Details")
to_html.description <- function(x, ...) parse_section(x, "Description")
to_html.value <- function(x, ...) parse_section(x, "Value")
to_html.author <- function(x, ...) parse_section(x, "Authors")
to_html.seealso <- function(x, ...) parse_section(x, "Seealso")
to_html.section <- function(x, ...) parse_section(x[[1]], x[[2]])

parse_section <- function(x, title) {
  text <- to_html.list(x)
  paras <- str_trim(str_split(text, "\\n\\n")[[1]])
  
  list(title = title, contents = paras)
}

# Equations ------------------------------------------------------------------

to_html.eqn <- function(x, ...) {
  stopifnot(length(x) <= 2)
  ascii_rep <- x[[length(x)]]
  
  str_c("<code class = 'eq'>", to_html.list(ascii_rep), "</code>")
}

to_html.deqn <- function(x, ...) {
  stopifnot(length(x) <= 2)
  ascii_rep <- x[[length(x)]]
  
  str_c("<pre class = 'eq'>", to_html.list(ascii_rep), "</code>")
}

# Links ----------------------------------------------------------------------
to_html.url <- function(x, ...) {
  stopifnot(length(x) == 1)
  str_c("<a href = '", x[[1]], "'>", x[[1]], "</a>")
}
to_html.href <- function(x, ...) {
  stopifnot(length(x) == 2)
  str_c("<a href = '", x[[1]], "'>", x[[2]], "</a>")
}
to_html.email <- function(x, ...) {
  stopifnot(length(x) == 2)
  str_c("<a href='mailto:", x[[1]], "'>", x[[2]], "</a>")
}

to_html.link <- function(x, ...) {
  stopifnot(length(x) == 1)

  opt <- attr(x, "Rd_option")
  if (is.null(opt)) {
    str_c("<a href='", x[[1]], ">", x[[1]], "</a>")
  } else if (str_sub(opt, 1, 1) == "=") {
    topic <- str_sub(opt, 2, -1)
    
    str_c("<a href='", topic, ">", x[[1]], "</a>")
  } else {
    str_c("<a href='http://www.inside-r.org/r-doc/", opt, "/", x[[1]], ">", 
      x[[1]], "</a>")
  }

}

# Miscellaneous --------------------------------------------------------------

# First element of enc is the encoded version (second is the ascii version)
to_html.enc <- function(x, ...) {
  x[[1]]
}

to_html.dontrun <- function(x, ...) {
  str_c(
    "## <strong>Not run</strong>:", 
    str_replace_all(to_html.list(rd), "\n", "\n#"), 
    "## <strong>End(Not run)</strong>"
  )
}

to_html.special <- function(x, ...) {
  txt <- to_html.TEXT(x)
  # replace '<' and '>' with html markings avoid browser misinterpretation
  txt <- str_replace_all(txt, "<", "&#60;")
  txt <- str_replace_all(txt, ">", "&#62;")
  txt <- str_replace_all(txt, "\\\\dots", "...")

  stupid <- unlist(str_match_all(txt, "\\\\[a-zA-Z]*"))
  for (i in seq_len(length(stupid))) {
    message("Uknown tag (", stupid[i], ") found in 'special' tag")
  }
  
  str_c("<em>", txt, "</em>")
}

to_html.method <- function(x, ...) {
  rd[[2]]
}
to_html.S3method <- to_html.method
to_html.S4method <- to_html.method

# Conditionals and Sexprs ----------------------------------------------------

to_html.Sexpr <- function(x, ...) {
  expr <- eval(parse(text = x[[1]]), globalenv())

  con <- textConnection(expr)
  on.exit(close(con))
  rd <- parse_Rd(con, fragment = TRUE)
  
  to_html(rd)
}

to_html.if <- function(x, ...) {
  if (rd[[1]] != "html") return()
  rd[[2]]
}

to_html.ifelse <- function(x, ...) {
  if (rd[[1]] == "html") rd[[2]] else rd[[3]]
}

# Tables ---------------------------------------------------------------------

to_html.tabular <- function(tabular) {
  #' make all alignements into left, right or center
  alignments <- unlist(str_split(tabular[[1]][[1]], ""))
  alignments <- alignments[nchar(alignments) > 0]
  #' remove line markings
  alignments <- alignments[alignments != "|"]
  alignments <- c("r" = "right", "l" = "left", "c" = "center")[alignments]
  
  rows <- tabular[[2]]
  column <- 1
  output <- character(length(rows))
  
  # Go through each item and reconstruct it if it is not a tab or carriage return
  # (Really need strategy that works like list: break into rows and then
  # columns)
  for (i in seq_along(rows)) {
    row_tag <- tag(rows[[i]])

    if (row_tag == "\\tab") {
      column <- column + 1
      output[i] <- str_c("</td><td align='", alignments[column], "'>")
    } else if (row_tag == "\\cr") {
      output[i] <- str_c("</td></tr><tr><td align='", alignments[1], "'>")
      column <- 1
    } else {
      output[i] <- to_html(rows[[i]])
    }
  }
  
  output[1] <- str_c("<table><tr><td align='", alignments[1], "'>", output[1])
  output[length(rows)] <- str_c(output[length(rows)], "</td></tr></table>")

  str_c(output, collapse = "")
}

# List -----------------------------------------------------------------------

to_html.itemize <- function(x, ...) {
  str_c("<ul>\n", parse_items(x[[1]]), "</ul>\n")
}
to_html.enumerate <- function(x, ...) {
  str_c("<ol>\n", parse_items(x[[1]]), "</ol>\n")
}

parse_items <- function(rd) {
  separator <- vapply(rd, function(x) tag(x) == "item", 
    FUN.VALUE = logical(1))
  
  group <- cumsum(separator)

  items <- split(rd, group)
  li <- lapply(items, function(x) str_c("<li>", to_html.TEXT(x), "</li>\n"))
  
  str_c(li, collapse = "")
}

# Simple tags that need minimal processing -----------------------------------

to_html.Rd <- function(x, ...) {
  tag <- tag(x)
  
  if (tag %in% names(simple_tags)) {
    # If we can process tag with just prefix & suffix, do so
    html <- simple_tags[[tag]]
    str_c(html[1], to_html.TEXT(x), html[2])
  } else {
    # Otherwise we don't know about this tag
    message("Unknown tag: ", tag)
    str_c(to_html.TEXT(x), collapse = "")
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
  "verb" =         c("<code>", "</code>"),

  "RCODE" =        c("", ""),
  "VERB" =         c("", ""),
  "LIST" =         c("<ul>", "</ul>")
)
